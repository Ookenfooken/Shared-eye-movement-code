%% ----------------------------- EXP STARTER -------------------------- %%
% ----------------------------------------------------------------------
% This script starts the experiment
% ----------------------------------------------------------------------
% written by Philipp KREYENMEIER (philipp.kreyenmeier@gmail.com)
% 27 / 10 / 2020
% Project : PriorAcceleration
% Version : 1
% 
% ----------------------------------------------------------------------
% Description of Experiment
% 
% Follow-up of Eycceleration. Finding: People can track accelerating targets
% but can't use extracted acceleration signal to inform motion prediction
% for manual interception. Question: How do we then deal with Acceleration?
% Some studies showed that we might benefit from repeated exposure, for both
% predictive pursuit (Bennett & Barnes, 2006) and manual interception (Brenner et al., 2016) 
% 
% Aim: Test whether both predictive saccades and manual interception
% benefit from repeated exposure of the same acceleration (block-design).
% Do people really learn to predict accelerating motion or do they simply
% learn a fixed timing based on feedback from previous trials?
% 
% ---------------------------------------------------------------------
% Description of Version:
%   500 ms presentation time (200: not enough to extract acceleration on-line)
%   -8, 0, +8 ?/s2 acceleration (would reduce experiment drastically in time!)
%   BLOCKED Design: same acceleration & presentation timeover blocks of 12 trials
%   2x3 (6) experimental blocks; Each block: 8 trials with the same 344 pixel-wide occluder, 
%           followed by 4 trials each with different occluder sizes (to test whether sbj just 
%           learnt to time their reponse or whether they really learnt to extrapolate acceleration
% 
%   3*12 = 36; block repetitions: 16 = 576 trials in total
% 
% ----------------------------------------------------------------------
% Last Changes:
% 
% 27/10/2020 (PK) - programmed first version of the task.
% 28/10/2020 (PK) - tried version with only one presentation time (500ms)
% ----------------------------------------------------------------------
%% ---------------------------------------------------------------------

%% Initial Setup:
clear all; clear mex; clear functions; close all; home; sca;
const.expName              = 'PriorAcceleration'; 					    		% Experiment name
const.expType              = 1;                                             % 1: interception Experiment; 2: Familiarization with task 
const.startExp             = 1;                                             % 1 = experiment mode; 0 = debugging mode
const.listenToMouse        = 1;
const.showGaze             = 0; 										    % 1 = show online gaze position: 0 = off
const.checkEyeFix          = 1;                                             % 1 = checks gaze fixation (this needs to be 1 also when in dummy mode)
const.showFing             = 0; 											% 1 = show online finger position: 0 = off
const.checkFingFix         = 1;                                             % 1 = checks finger fixation (this needs to be 1 also when in dummy mode or trakstar not used)
const.feedback             = 1;												% 1 = show task feedback (defined in runSingleTrial); 0 = off
const.makeVideo            = 0;                                             % 1 = creates a video of a single trial(set any conditions manually in expMain); 0 = off (normal experiment mode)
const.runScreenCalib       = 0;                                             % 1 = run screen calibration instead of experiment; 0 = experiment mode

% Some dsign-related things (These will be used in paramConfig):
const.numTrialsPerBlock    = repmat(12,[1,48]);                             % 12 trials block % Each column = number of trials in block; number of columns = number of blocks
if const.makeVideo; const.numTrialsPerBlock = 12; end
if const.expType == 2; const.numTrialsPerBlock = 30; end
const.numTrials            = sum(const.numTrialsPerBlock);                  % total number of trials


% Eyelink Setup:
eyelink.mode               = 0;                                             % 1 = use eyelink; 0 = off
eyelink.dummy              = 0;                                             % 1 = eyelink in dummy mode; 0 = eyelink dummy off
eyelink.recalib            = true;                                          % true = recalibrate between blocks (recommanded); false = no calibration between blocks
eyelink.dummyEye           = [0,0];                                         % dummy start pos
eyelink.edfFile            = cell(const.numTrials,1);                       % structure setup for edf files
if const.expType == 2; eyelink.mode = 0; end

% Trakstar Setup:
trakstar.mode              = 0;                                             % 1 = use trakstar; 0 = off
trakstar.recalib           = true;                                          % true = recalibrate between blocks (recommanded); false = no calibration between blocks
trakstar.dummyFinger       = [100,0,100];                                   % dummy start pos

% ResponsePixx button box Setup:
responsePixx.mode          = 0;                                             % 1 = use responsePixx button box; 0 = off

%% Do some configurations (path, keys, screen, constants, trialData, sbj):
pathConfig;
[keys] 					   = keyConfig;                                     % unify and define some keys
[screen]                   = screenConfig(const);                           % screen configurations (update if changes on setup or new setup used)
[const]                    = constConfig(screen, const);                    % set some constants and variables used in experiment
[trialData]                = paramConfig(const);
[sbj]                      = sbjConfig(const);

%% Generate Target Trajectory and Other Stimuli:
[const]                    = generateTargetTrajectory(const,screen);        % Moving target trajectory
[const]                    = generateStationaryStimuli(const,screen);       % Stationary stimuli


%% Run the Experiment with defined Settings:
if ~const.runScreenCalib
    expMain(const, screen, eyelink, trakstar, responsePixx, trialData, sbj);% run experiment

    % run convert2ascSynch for the current sbj, when done.
    if IsWin
        convert2ascSynch(sbj)
    end
%% Alternatively, run Gamma Calibration procedure:
elseif const.runScreenCalib
    [screen]                = gammaCalib(screen, const, keys);              % run Screen Gamma Calibration
end
