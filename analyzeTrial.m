%% THIS m-file is the magic script that analyzes all your eye data
% this script requries several functions:
% readEyeData.m, processEyeData.m, readoutTrial.m, findSaccades.m, 
% analyzeSaccades.m
% optional: findPursuit.m, analyzePursuit.m, removeSaccades.m,
% findMicroSaccades.m
% optional: we also have scripts to read and analyze target and finger data
% for the EyeCatch/EyeStrike paradigm that can be added here --> ask if you
% need more info

% history
% 07-2012       JE created analyzeTrial.m
% 2012-2018     JF added stuff to and edited analyzeTrial.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

%% Eye Data
%  eye data need to have been converted using convert_edf2asc.m
ascFile = eyeFiles(currentTrial,1).name;
trialStart = 1; %different trial start can be specified using e.g. parameters
eyeData = readEyeData(ascFile, dataPath, currentSubject, analysisPath, trialStart);
eyeData = processEyeData(eyeData); 

%% extract all relevant experimental data and store it in trial variable
trial = readoutTrial(eyeData, currentSubject, analysisPath, parameters, currentTrial); 

%% find saccades
threshold = evalin('base', 'saccadeThreshold');
[saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.eyeDX_filt, trial.eyeDDX_filt, threshold, stimulusVelocityX);
[saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.eyeDY_filt, trial.eyeDDY_filt, threshold, stimulusVelocityY);

%% analyze saccades
[trial] = analyzeSaccades(trial, saccades);
clear saccades;

 %% OPTIONAL: find and analyze pursuit
% pursuit = findPursuit(trial); 
% % remove saccades
% trial = removeSaccades(trial);
% % analyze pursuit
% pursuit = analyzePursuit(trial, pursuit);

%% OPTIONAL: find micro saccades
% % remove saccades
% trial = removeSaccades(trial);
% m_threshold = evalin('base', 'microSaccadeThreshold');
% [saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.DX_noSac, trial.DDX_noSac, m_threshold, 0);
% [saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.DY_noSac, trial.DDY_noSac, m_threshold, 0);
% % analyze micro-saccades
% [trial] = analyzeMicroSaccades(trial, saccades);


