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

function [trial] = readoutTrial(eyeData, currentSubject, analysisPath, Experiment, currentTrial, eventLog)
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
trial.log.rdkDirMean = -Experiment.trialData.dotDirMean(currentTrial, 1); % positive is up, negative is down
trial.log.rdkDirVar = Experiment.trialData.choice(currentTrial, 1); % variance
trial.log.choice = -Experiment.trialData.choice(currentTrial, 1); % -1 = down, 1 = up
trial.stimulus.absoluteVelocity = Experiment.const.rdk.speed;

% frame indices of all events; after comparing eventLog with eyeData.frameIdx
trial.log.trialStart = 1; % the first frame, fixation onset, decided in readEyeData
trial.log.targetOnset = find(eyeData.frameIdx==eventLog.rdkOn(currentTrial, 1)); % rdk onset
trial.log.targetOffset = find(eyeData.frameIdx==eventLog.rdkOff(currentTrial, 1)); % rdk offset
trial.log.trialEnd = find(eyeData.frameIdx==eventLog.respond(currentTrial, 1)); % response given
end