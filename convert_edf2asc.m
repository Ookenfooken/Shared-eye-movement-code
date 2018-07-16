%% script to convert Eyelink's edf data to matlab compatible asc files
% this script is structured in two steps
% (1) edf files are converted containing all events and massages
%     relevant experiment info is read out and stored in variables
% (2) edf files are then converted into pure samples

% history
% 01-11-2016	JF created convert2ascSynch.m
% 10-07-2018	JF edited the conversion script to a more general function
%               that can be used by future VPOM students

% for questions email jolande.fooken@rwth-aachen.de

close all;
clear all;

%% STEP 1
% Define different folder and data structure 
startFolder = [pwd '\'];  % Eyelink's edf2asc executable has to be in this folder
dataPath = fullfile(pwd,'..','data\'); %assuming that the data folder is in the start folder
folderNames = dir(dataPath); % this will be a list of all folders in the data folder, e.g. a list of all subjects
currentSubject = {};

%% STEP 2
% Loop over all subjects and convert
for i = 3:length(folderNames) % we are starting at 3 because matlab always has 2 empty entries for the dir command
    % define current subject/folder
    currentSubject{i-2} = folderNames(i).name;        
    currentFolder = [dataPath currentSubject{i-2}];
    cd(currentFolder);  
    % Step 2.1
    % this step converts edf to asc containing all information
    [res, stat] = system([startFolder 'edf2asc -y ' currentFolder '\*.edf']);
    cd(startFolder);
    % create a list of all converted files
    ascfiles = dir([currentFolder '\*.asc']);
    nHeader = 25; % this number depends on data collection; for EyeCatch/Strike it is 25
    % declare variables that you want to read out
    variable = [];
    % STEP 2.2
    % loop over all asc files for 1 subject/data folder
    for j = 1:length(ascfiles)
        ascfile = ascfiles(j).name;
        path = fullfile(currentFolder, ascfile);
        fid = fopen(path);
        % scip the header and then search for a message
        textscan(fid, '%*[^\n]', nHeader);
        entries = textscan(fid, '%s %*[^\n]');
        label = strfind(entries{:}, 'MSG');
        idx = find(not(cellfun('isempty', label)));
        variable(j,1) = idx(1);
        
        fclose(fid);
    end
    cd(currentFolder)
    save('variable', 'variable')
    cd(startFolder)
    % STEP 2.3
    % convert data into samples only and replace missing values with 9999
    [res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' currentFolder '\*.edf']);
end
