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
% 09/25/2020    XW modified the function; read in blocked edf, and eventually output trial asc. xiuyunwu5@gmail.com

% DC check github by uploading
% DC check github again 3:50pm

close all;
clear all;

%% STEP 1
% Define different folder and data structure
startFolder = [pwd '\'];  % Eyelink's edf2asc executable has to be in this folder
cd ..
dataPath = fullfile(pwd,'data\'); % assuming that the data folder is in the start folder
folderNames = dir(dataPath); % this will be a list of all folders in the data folder, e.g. a list of all subjects
currentSubject = {};
trialPerBlock = 4;
nHeader = 10; % this number depends on data collection; lines to skip when reading out messages

%% STEP 2
% % select folder by hand
% cd(startFolder)
% currentFolder = selectSubject(dataPath);
% cd(currentFolder);

% or Loop over all subjects and convert
for i = 3:length(folderNames) % we are starting at 3 because matlab always has 2 empty entries for the dir command
    % define current subject/folder
    currentSubject{i-2} = folderNames(i).name;
    currentFolder = [dataPath currentSubject{i-2}];
    disp(['processing subject ' currentSubject{i-2}]);
    cd(currentFolder);
    % Step 2.1
    % this step converts edf to asc containing all information
    [res, stat] = system([startFolder 'edf2asc -y ' currentFolder '\*.edf']);
    % create a list of all converted files
    ascFiles = dir([currentFolder '\*.asc']);    
    trialPosition = struct;
    
    % STEP 2.2
    % loop over all asc files for 1 subject/data folder
    for blockN = 1:length(ascFiles)
        ascfile = ascFiles(blockN).name;
        path = fullfile(currentFolder, ascfile);
        fid = fopen(path);
        % skip the header and then search for messages
        textscan(fid, '%*[^\n]', nHeader);
        entries = textscan(fid, '%s %s %s %s %s %s %s %*[^\n]');
        for lineN = 1:size(entries{1}, 1)
            if strcmp(entries{1}{lineN}, 'MSG')
                if strcmp(entries{3}{lineN}, 'TRIALID')
                    trialN = str2num(entries{4}{lineN})+(blockN-1)*trialPerBlock;
                    frameCount = 1;
                elseif strcmp(entries{3}{lineN}, 'GAZE_COORDS') % check the original codes on the pc... but, well...
                    targetLog.screenX(trialN, 1) = str2num(entries{6}{lineN})+1;
                    targetLog.screenY(trialN, 1) = str2num(entries{7}{lineN})+1;
                elseif strcmp(entries{3}{lineN}, '!MODE') && strcmp(entries{4}{lineN}, 'RECORD')
                    targetLog.recordingStart(trialN, 1) = str2num(entries{2}{lineN});
                elseif strcmp(entries{3}{lineN}, '!V') && strcmp(entries{4}{lineN}, 'TARGET_POS')
                    targetLog.time(trialN, frameCount) = str2num(entries{2}{lineN});
                    targetLog.posX(trialN, frameCount) = str2num(entries{6}{lineN}(2:end-1));
                    targetLog.posY(trialN, frameCount) = str2num(entries{7}{lineN}(1:end-1));
                    frameCount = frameCount+1;
                elseif strcmp(entries{5}{lineN}, 'freq_x') % check the original codes on the pc... but, well...
                    targetLog.freqX(trialN, 1) = str2num(entries{6}{lineN});
                elseif strcmp(entries{5}{lineN}, 'freq_y') % check the original codes on the pc... but, well...
                    targetLog.freqY(trialN, 1) = str2num(entries{6}{lineN});
                end
            elseif strcmp(entries{1}{lineN}, 'END') % check the original codes on the pc... but, well...
                targetLog.recordingOff(trialN, 1) = str2num(entries{2}{lineN})-1;
            end
        end
        fclose(fid);
    end
    save('targetLog.mat', 'targetLog')
    %     STEP 2.3
    %     convert data into samples only and replace missing values with 9999
    [res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' currentFolder '\*.edf']);
    
    %% STEP 3
    % split the asc files into each trial... otherwise too slow to
    % load when clicking through
    % actually just save .mat files, makes it easier...
    for blockN = 1:length(ascFiles)
        rawAsc = load(ascFiles(blockN, 1).name);
        for trialN = 1:trialPerBlock
            currentTrial = trialN+(blockN-1)*trialPerBlock;
            startI = find(rawAsc(:, 1)==targetLog.recordingStart(currentTrial, 1));
            endI = find(rawAsc(:, 1)==(targetLog.recordingOff(currentTrial, 1))); 
            allData = rawAsc(startI:endI, :);
            save([currentSubject{i-2}, 't', num2str(currentTrial, '%02d'), '.mat'], 'allData')
            %         currentTrial = currentTrial+1;
        end
    end
end
