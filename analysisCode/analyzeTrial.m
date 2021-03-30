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
eyeFile = [currentSubject 't' num2str(currentTrial, '%02d') '.mat']; % mat file, eye data transformed from edf
% make sure they are included in the experiment code
eyeData = readEyeData(eyeFile, dataPath, currentSubject, currentTrial, analysisPath, eventLog, Experiment);
eyeData = processEyeData(eyeData); 

%% extract all relevant experimental data and store it in trial variable
trial = readoutTrial(eyeData, currentSubject, analysisPath, Experiment, currentTrial, eventLog); 
trial.stim_onset = trial.log.targetOnset;
trial.stim_offset = trial.log.targetOffset;
trial.length = trial.log.trialEnd;

%% find saccades
threshold = evalin('base', 'saccadeThreshold');
onset = 1;
offset = min(trial.stim_offset, size(trial.eyeDX_filt, 1)); % to be able to detect saccades at the end of display

% use acceleration to find saccades...
[saccades.X.onsets, saccades.X.offsets] = findSaccadesAcc(onset, offset, trial.eyeDX_filt, trial.eyeDDX_filt, trial.eyeDDDX, threshold);
[saccades.Y.onsets, saccades.Y.offsets] = findSaccadesAcc(onset, offset, trial.eyeDY_filt, trial.eyeDDY_filt, trial.eyeDDDY, threshold);
% % use combination of velocity, acceleration, and jerk to find saccades
% [saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.eyeDX_filt, trial.eyeDDX_filt, trial.eyeDDDX, threshold, stimulusVelocityX);
% [saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.eyeDY_filt, trial.eyeDDY_filt, trial.eyeDDDY, threshold, stimulusVelocityY);
% remove saccades
trial = removeSaccades(trial, saccades);
clear saccades;

%% find and analyze pursuit
% pursuit = findPursuit(trial); 
% % analyze pursuit
% pursuit = analyzePursuit(trial, pursuit);
% trial.pursuit = pursuit;

%% analyze saccades
% [trial] = analyzeSaccades(trial);

%% OPTIONAL: find micro saccades
% % remove saccades
% trial = removeSaccades(trial);
% m_threshold = evalin('base', 'microSaccadeThreshold');
% [saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.DX_noSac, trial.DDX_noSac, m_threshold, 0);
% [saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.DY_noSac, trial.DDY_noSac, m_threshold, 0);
% % analyze micro-saccades
% [trial] = analyzeMicroSaccades(trial, saccades);


