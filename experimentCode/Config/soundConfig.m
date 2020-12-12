function [soundSetting] = soundConfig(const)
% ===============================================================
% soundConfig(const)
% ===============================================================
% written by DC, modified from screenConfig.m
% 
% Last Changes:
% 12/01/2020 (DC): initialize
% 
% ---------------------------------------------------------------
% Inputs: 
% const: structure containing different constant settings
% ---------------------------------------------------------------
% 
% Overview setups in the lab:
% KoernerS257: 
% ---------------------------------------------------------------


%% (1) Enter desired Sound Settings - this specific to each setup
soundSetting.name                = 'KoernerS257';                           % Setting

% speaker initalization
soundSetting.desired_nrchannels  = 2;                                       % desired number of channels (1 - mono; 2 - stereo)
soundSetting.desired_freq        = 44100;                                   % desired sampling rate of the sound
soundSetting.desired_volumectrl  = 0.8;                                     % switch to control volume of speakers

% speaker location
soundSetting.widthCM             = 40.6; % to be updated                    % measured distance between speaker (in cm)
soundSetting.heightCM            = 29.8; % to be updated                    % measured height of speakers from subject's eyes (in cm)
soundSetting.widthMM             = soundSetting.widthCM *10;                                           
soundSetting.heightMM            = soundSetting.heightCM *10;                                             
soundSetting.dist                = 50; % to be updated                      % measured distance (mid-point between speakers and subject) (in cm)

%% (2) Open Sound - initiating PsychPortAudio:
InitializePsychSound(1);                                                    % intialize sounddriver, set to 0 for really low latency
soundSetting.pahandle = PsychPortAudio('Open',[],1,1,... 
    soundSetting.desired_freq,soundSetting.desired_nrchannels);             % open audio port

% additional setting (not used right now):
% PsychPortAudio('Volume', soundSetting.pahandle, ... soundSetting.desired_volumectrl);

%% (3) Validate Setting
% to do

%% (4) Get Basic Sound parameters:
% to do
soundSetting.psychportaudiov = PsychPortAudio('Version');

end