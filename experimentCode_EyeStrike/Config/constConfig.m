function [const] = constConfig(screen, const)
% Set a whole bunch of constants:
%   PK 01/04/2019



%% Fixation:
const.fixationRadiusEyeVA    = 2.5;                                         % This is radius threshold for eye fixation (in pix?)
const.fixationRadiusEyePX    = round(va2pix(screen, const.fixationRadiusEyeVA));
%const.fixationRadiusFingerVA = 4;                                          % This is radius threshold for finger fixation (in pix?)
const.fixationRadiusFingerPX = 50;                                          % approx. 1.5 cm round(va2pix(screen, const.fixationRadiusFingerVA));

%% STIMULI:
% Moving Stim (will be used in generateTargetTrajectory.m):
const.StimRadVA            = 0.35;                                          % radius of the target in va.
const.StimRadPX            = round(va2pix(screen, const.StimRadVA));
const.StimVelocity         = 20;                                            % in degrees va/s
const.targetTrajOffset     = 249 + 10; %[100 399]; %+10 for stimulus radius                                    % in pix. Every target should start from the left side of the screen, 462 pixels to the left = target movement at 0 deg/s2 exactly 800ms; for other trajectory, an additional offset is considered in generateTargetTrajectory.m

% different moving stimulus parameters (these are called to generate
% trajectory and in paramConfig). Reason: Trajectory parameters depend on
% presTime etc.
const.presTime             = [500];
const.accelerations        = [0, -8, 8];

% Occluder:
const.OccluderSizeX(1)     = 334;                                           % Default: this in pixel (13.4?) and corresponds to a 600ms occlusion for the fastest target (8deg/s2)
const.OccluderSizeX(2)     = 309;                                           % Test 1: 1? smaller (width = 12.4?)
const.OccluderSizeX(3)     = 359;                                           % Test 2: 1? wider (width = 14.4?) 
const.OccluderSizeX(4)     = 284;                                           % Test 3: 2? smaller (width = 11.4?)
const.OccluderSizeX(5)     = 384;                                           % Test 4: 2? wider (width = 15.4?) 

const.OccluderSizeY(1)     = screen.heightPX;
const.OccluderSizeY(2)     = screen.heightPX;
const.OccluderSizeY(3)     = screen.heightPX;
const.OccluderSizeY(4)     = screen.heightPX;
const.OccluderSizeY(5)     = screen.heightPX;

const.OccluderOffset(1)    = const.OccluderSizeX(1)/2;                      % the rectangle coordinate used by PTB is the center of the rectangle. Everything will be screen-centered, so any offset needs to be added here (e.g. we want the beginning of the occluder to be at screen center, hence the offset is X/2).
const.OccluderOffset(2)    = const.OccluderSizeX(2)/2; 
const.OccluderOffset(3)    = const.OccluderSizeX(3)/2; 
const.OccluderOffset(4)    = const.OccluderSizeX(4)/2; 
const.OccluderOffset(5)    = const.OccluderSizeX(5)/2; 

end

