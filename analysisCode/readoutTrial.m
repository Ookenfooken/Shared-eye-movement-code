% FUNCTION to set up data structure for reading out and later saving all
% relevant experimental info, data, and parameters
% history
% 07-2012       JE created readoutTrial.m
% 05-2014       JF edited readoutTrial.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 
% input: eyeData --> structure containing filtered eye movements
%        currentSubject --> selected subject using selectSubject.m
%        parameters --> all other relevant experimental information
%        currentTrial --> current trial
% output: trial --> a structure containing all relevant information for
%                   each trial

function [trial] = readoutTrial(eyeData, currentSubject, analysisPath, parameters, currentTrial, eventLog)
% get eyeData for this trial
trial.eyeX_filt = eyeData.X_filt;
trial.eyeY_filt = eyeData.Y_filt;

trial.eyeDX_filt = eyeData.DX_filt;
trial.eyeDY_filt = eyeData.DY_filt;

trial.eyeDDX_filt = eyeData.DDX_filt;
trial.eyeDDY_filt = eyeData.DDY_filt;

trial.eyeDDDX = eyeData.DDDX;
trial.eyeDDDY = eyeData.DDDY;

% save some info for each trial and store it in trial.log
% for example stimulus speed, fixation duration and other events
trial.log.subject = currentSubject;
trial.log.trialNumber = currentTrial;
trial.log.trialType = parameters.trialType(currentTrial, 1); % 0-perceptual trial, 1-standard trial
trial.log.prob = parameters.prob(currentTrial, 1); % n%
trial.log.rdkDir = parameters.rdkDir(currentTrial, 1); % -1=left, 1=right, 0=0 coherence, no direction
trial.log.coh = parameters.coh(currentTrial, 1)*parameters.rdkDir(currentTrial, 1); % negative-left, positive-right
trial.log.choice = parameters.choice(currentTrial, 1); % 0-left, 1-right
trial.stimulus.absoluteVelocity = 10;

% frame indices of all events; after comparing eventLog with eyeData.frameIdx
trial.log.trialStart = 1; % the first frame, fixation onset, decided in readEyeData
trial.log.fixationOff = find(eyeData.frameIdx==eventLog.fixationOff(currentTrial, 1));
trial.log.targetOnset = find(eyeData.frameIdx==eventLog.rdkOn(currentTrial, 1)); % rdk onset
trial.log.trialEnd = find(eyeData.frameIdx==eventLog.rdkOff(currentTrial, 1)); % rdk offset
end