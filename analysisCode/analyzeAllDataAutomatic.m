%% Script to analyze all collected data automatically and write trial 
% info into mat files that will be saved per subject
% this script is the autmatic equivalent to viewEyeData.m and requires 
% analyzeTrialAutomatic.mat
% if you update sampling rate, saccade threshold or similar, please
% also update in viewEyeData.m 

% history
% 2012-2016     JF created analyzeAllPlayersAllTrials.m 
% 28-09-2018    JF renamed script and commented to make the script more accecable 
%				for future VPOM students
% for questions email jolande.fooken@rwth-aachen.de 

% ask for general settings (using some standard settings)
prompt = {'Enter eye tracker sampling rate', ...
    'Enter monitor resolution x', 'Enter monitor resolution y',...
    'Enter monitor size x (cm)', 'Enter monitor size y (cm)', ...
     'Enter viewing distance (cm)'};
dlgtitle = 'Setup settings';
num_lines = 1;
definput = {'1000','1280', '1024','53', '30', '50'};
answer = inputdlg(prompt,dlgtitle,num_lines,definput);

sampleRate = str2double(answer{1});
screenSizeX = str2double(answer{2});
screenSizeY = str2double(answer{3});
screenResX = str2double(answer{4});
screenResY = str2double(answer{5});
distance = str2double(answer{6});

% other thresholds are currently inputted manually
distanceZ = 17;     %distance from finger to screen in initial position
saccadeThreshold = 50; %threshold for saccade sensitivity
microSaccadeThreshold = 6;

analysisPath = pwd;
dataPath = fullfile(pwd,'..','data\');
resultPath = fullfile(pwd,'results\');

%% create list of all subjects
folderNames = dir(dataPath);
currentSubject = {};


%% Loop over all subjects

for i = 3:length(folderNames)
    currentSubject{i-2} = folderNames(i).name;
    
    currentFolder = [dataPath currentSubject{i-2}];
    cd(currentFolder);
    
    numTrials = length(dir('*edf'));
    eyeFiles = dir('*.asc');
	% load mat file containing experimental infor
	load('parameters.mat');
    % go into analysis folder
    cd(analysisPath)
    % now we are inside the subject's folder and loop over trials
    %% analyze for each trial
    for currentTrial = 1:numTrials[results.trial] = analyzeTrialAutomatic(eyeFiles, currentTrial, currentSubject{i-2}, analysisPath, dataPath, parameters);
        analysisResults(:,currentTrial) = results;
    end
    
    cd(resultPath)
    save(currentSubject{i-2}, 'analysisResults')
    cd(analysisPath)
    
    clear analysisResults
    clear results
    clear eyeFiles
    clear ascfiles
    clear numTrials
    clear currentFolder
    clear trialList

end