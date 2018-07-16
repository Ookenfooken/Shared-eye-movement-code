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

function [trial] = readoutTrial(eyeData, currentSubject, parameters, currentTrial)
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
trial.log.parameters = parameters; % this is just a dummy
trial.log.trialStart = parameters.trialStart;
trial.log.trialEnd = parameters.trialEnd;
trial.log.targetOnset = parameters.targetOnset;
end