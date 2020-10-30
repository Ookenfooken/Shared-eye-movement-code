function [el, const] = eyelink_init(screen, const, eyelink)
% Initialize Eyetracker and gaze recording
%   PK 21/03/2019
disp('Eyelink initiation setting: set <el> variable');

%% Set EyeLink Defaults: 
el                     = EyelinkInitDefaults(screen.window);
el.backgroundcolour    = screen.background;
el.backgroundcolour2   =  screen.background2;
el.foregroundcolour    = WhiteIndex(el.window);
el.msgfontcolour       = BlackIndex(el.window);
el.msgfontcolour2      = BlackIndex(el.window);
el.msgfontcolour3      = BlackIndex(el.window);
el.imgtitlefontcolour  = WhiteIndex(el.window);
el.imgtitlecolour      = BlackIndex(el.window);


el.wRect               = screen.wRect;
EyelinkUpdateDefaults(el);
% a fix suggested by SR Research (2013-1-10)
if IsWin % check if you're on windows
    el.calibrationtargetsize    = 1.6;  % size of calibration target as percentage of screen
    el.calibrationtargetwidth   = 0.5; % width of calibration target's border as percentage of screen 
    if ~isempty(el.callback)
        PsychEyelinkDispatchCallback(el);
    end
end

%% Initialize connection to Eyelink Eyetracker:
disp('Initialization of the connection with the Eyelink');

if ~eyelink.dummy
    dummymode = 0; 
else
    dummymode = 1;
end

if  ~EyelinkInit(dummymode) % if eyelink.dummy is 0, real initiailization will be attempted, if it is set to 1, it will initialize dummy mode!
    fprintf('Eyelink Initilaization failed. Exiting.\n');
    cleanup;  % cleanup function
    return;
end


%% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && ~dummymode
    fprintf('Eyelink not connected. Existing.\n');
    cleanup;
    return;
end


%% Calibrate/validate Eyelink
disp('Calibrate / Validate the eye tracker');
EyelinkDoTrackerSetup(el);


end

