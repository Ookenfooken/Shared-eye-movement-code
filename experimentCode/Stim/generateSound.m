function [const] = generateSound(const, mysound, trialData)
% Pre-define stimuli that will be presented during the trial (auditory)
%   this should reduce work load during the main WHILE-loop.
%   Stimuli are then saved in and can be called from the const-structure.
% 
% 
% Last Changes:
% 12/01/2020 (DC): initialize, modified from generateStationaryStimuli
% 12/11/2020 (DC): add comments about how to use
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings and stimuli
% mysound:   strucrure containing sound driver settings
% -------------------------------------------------------------------------
% To do:
% - update to allow generate multiple sound files using trialData
% - soft code imported sound directory
% - give warning msg when imported Fs does not match with desired freq


%% create all possible sound required for the experiment

%const.aud.allSounds;

switch const.aud.type
    case 1 % create white noise (potential for dynamic sound)        
        y = randn(1,(const.aud.dur/1000)*mysound.desired_freq); % generate white noise
        
    case 2 % create tone (potential for dynamic sound)
        
        t=0:(1/mysound.desired_freq):(const.aud.dur/1000); % generate a vector of samples based on desired sampling rate and duration of the sound
        y=sin(2*pi*const.aud.carrierF*t); % carrier signal generated, volume controled by carrierA
        
        % dynamic sound: carrier + frequency modulating signal
        %fm=0; mi=0; % FM setting
        %y=sin(2*pi*const.aud.carrierF*t+(mi.*sin(2*pi*fm*t)));
        % dynamic sound: carrier + amplitude modulating signal
        % Vc=1; MIam = 1; % AM setting
        %yL=(Vc+MIam*sin(2*pi*fm*t)).*sin(2*pi*fc*t);
        %yR=(Vc+MIam*sin(2*pi*fm*t+pi)).*sin(2*pi*fc*t);
    
    case 3 % use make beep
        y = MakeBeep (const.aud.carrierF,const.aud.dur/1000,mysound.desired_freq);
        
    case 4 % import sound file
        [y, fileFs] = audioread('C:\Users\Display\Desktop\Multisensory-pursuit\Multisensory-pursuit\experimentCode\Stim\aud\zns999191931so1_crisps_11.wav');

end

% adjust volume based on setting
y = y.*const.aud.carrierA;

% % now ready to save y_out to const.aud.allSounds
y_out = y;
const.aud.allSounds = y_out;

%% how to use in runSingleTrial

%{

% before loading, you can alter which speaker this sound will be presented,
% e.g.,

y = const.aud.allSounds; soundLocation = 3;
switch soundLocation 
    case 0 % no sound
        y_out = [zeros(size(y,1),size(y,2)); zeros(size(y,1),size(y,2))];
        
    case 1 % load left speaker        
        y_out = [y; zeros(size(y,1),size(y,2))];
        
    case 2 % load right speaker
        y_out = [zeros(size(y,1),size(y,2)); y];
        
    case 3 % load both speakers
        y_out = [y; y];
end

% when you are ready to load (like Screen('FillRect')), use this:
PsychPortAudio('FillBuffer', mysound.pahandle, y_out);

% when you are ready to present the sound (like Screen('Flip')), use this:
PsychPortAudio('Start', mysound.pahandle, const.aud.nrepetitions, 0, waitForDeviceStart);

%}

end

