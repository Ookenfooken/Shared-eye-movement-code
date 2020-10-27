function [const] = constConfig(screen, const)
% =========================================================================
% constConfig(screen, const)
% =========================================================================
% 
% 
% -------------------------------------------------------------------------
% Input:
% screen:    strucrure containing screen settings
% const:     structure containing different constant settings
% -------------------------------------------------------------------------
% Output: 
% const:     structure containing different constant settings
% -------------------------------------------------------------------------
%%
%% Fixation:
const.fixationRadiusEyeVA    = 2.5;                                         % This is radius threshold for eye fixation (in pix?)
const.fixationRadiusEyePX    = round(screen.ppd*const.fixationRadiusEyeVA);
%const.fixationRadiusFingerVA = 4;                                          % This is radius threshold for finger fixation (in pix?)
const.fixationRadiusFingerPX = 50;                                          % approx. 1.5 cm round(va2pix(screen, const.fixationRadiusFingerVA));

%% STIMULI:
% Moving Stim (will be used in generateTargetTrajectory.m):
const.StimRadVA            = 0.25;                                          % radius of the target in va.
const.StimRadPX            = round(screen.ppd*const.StimRadVA);
const.StimVelocity         = 10;                                            % in degrees va/s
const.startOffsetX         = 10;                                            % in degrees va (this is how far to the left or right the target should start from)
const.startOffsetY         = 0; 
const.stepRamp             = const.StimVelocity*0.1;                       % Step size in va of the step-ramp trajectory should be the distance traveled after 100 ms

% Flash:
const.flashSizeVA          = 0.625; %1.25;                                  % in va
const.flashSizePX          = round(screen.ppd*const.flashSizeVA);
const.flashOffsetHorizVA   = 5;                                             % in va
const.flashOffsetHorizPX   = round(screen.ppd*const.flashOffsetHorizVA);
const.flashOffsetVA        = 5;                                             % in va
const.flashOffsetPX        = round(screen.ppd*const.flashOffsetVA);

const.flashFrameVA         = .05;                                           % Frame width of the Flash-Frame in VA
const.flashFramePX         = round(screen.ppd*const.flashFrameVA);
const.flashFrameColor      = [20 20 20];
const.flashColor           = [255 255 255]; 

% Saccade Rect:
const.saccSizeVA           = 5;
const.saccSizePX           = round(screen.ppd*const.saccSizeVA);
const.saccFBcol            = [0 255 0];

% Photodiode
const.photoStimSizePX      = 50;                                            % in PX, might have to be adjusted (should not be visible for subjects)

%% DPI Setup Stimulus
const.calibtationOutRadius     = 0.225;                                     % this is in Degree VA
const.calibtationInRadius      = 0.075;                                     % this is in Degree VA


%% DPI Calibration Stimuli:
const.calibrationHorFarVA      = 8;
const.calibrationHorFarPX      = round(screen.x_ppd*const.calibrationHorFarVA);
const.calibrationHorNearVA     = 4;
const.calibrationHorNearPX     = round(screen.x_ppd*const.calibrationHorNearVA);
const.calibrationVertFarVA     = 8;
const.calibrationVertFarPX     = round(screen.y_ppd*const.calibrationVertFarVA);
const.calibrationVertNearVA    = 4;
const.calibrationVertNearPX    = round(screen.y_ppd*const.calibrationVertNearVA);

const.calibPositionsLeft       = [screen.x_mid-const.calibrationHorFarPX   screen.y_mid];
const.calibPositionsHalfLeft   = [screen.x_mid-const.calibrationHorNearPX  screen.y_mid];
const.calibPositionsCenter     = [screen.x_mid                             screen.y_mid];
const.calibPositionsHalfRight  = [screen.x_mid+const.calibrationHorNearPX  screen.y_mid];
const.calibPositionsRight      = [screen.x_mid+const.calibrationHorFarPX   screen.y_mid];

const.calibPositionsTop        = [screen.x_mid  screen.y_mid-const.calibrationVertFarPX];
const.calibPositionsHalfTop    = [screen.x_mid  screen.y_mid-const.calibrationVertNearPX];
const.calibPositionsHalfBottom = [screen.x_mid  screen.y_mid+const.calibrationVertNearPX];
const.calibPositionsBottom     = [screen.x_mid  screen.y_mid+const.calibrationVertFarPX];

const.calibPositions           = {const.calibPositionsCenter, ...
    const.calibPositionsLeft,       const.calibPositionsHalfLeft,  const.calibPositionsCenter, ...
    const.calibPositionsHalfRight,  const.calibPositionsRight,     const.calibPositionsCenter, ...
    const.calibPositionsTop,        const.calibPositionsHalfTop,   const.calibPositionsCenter, ...
    const.calibPositionsHalfBottom, const.calibPositionsBottom,    const.calibPositionsCenter};

end

