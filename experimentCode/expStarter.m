%% ----------------------------- EXP STARTER -------------------------- %%
% ----------------------------------------------------------------------
% This script starts the experiment
% ----------------------------------------------------------------------
% written by Philipp KREYENMEIER (philipp.kreyenmeier@gmail.com)
% 07 / 10 / 2020
% Project : FastEye
% Version : 1
% 
% ----------------------------------------------------------------------
% Description of Experiment
% 
% 
% 
% 
% ----------------------------------------------------------------------
% Description of Version
% 
% Oblique Tracking, with oblique saccades
% Flash always 90? to the pursuit target
% Pursuit target remains visible until it disappears.
% 
% ----------------------------------------------------------------------
% Last Changes:
% 
% 07/10/2020 (PK) - adapted for Koerner S257
% ----------------------------------------------------------------------
%% ---------------------------------------------------------------------



%% Initial Setup:
clear all; clear mex; clear functions; close all; home; sca;
pathConfig;

const.expName              = 'FastPursuit'; 								% Experiment name
const.expType              = 1;                                             % 1: interception; 2: button press; 3: saccade
const.startExp             = 1;                                             % 1 = experiment mode; 0 = debugging mode
const.checkEyeFix          = 1;                                             % 1 = checks gaze fixation (this needs to be 1 also when in dummy mode)
const.feedback             = 1;												% 1 = show task feedback (defined in runSingleTrial); 0 = off
const.makeVideo            = 0;                                             % 1 = creates a video of a single trial(set any conditions manually in expMain); 0 = off (normal experiment mode)
const.runScreenCalib       = 0;                                             % 1 = run screen calibration instead of experiment; 0 = experiment mode
const.showGaze             = 0;
% Some dsign-related things (These will be used in paramConfig):
const.numTrialsPerBlock    = [5 5 5];                                          % Each column = number of trials in block; number of columns = number of blocks
if const.makeVideo; const.numTrialsPerBlock = 1; end
const.numTrials            = sum(const.numTrialsPerBlock);                  % total number of trials


% Eyelink Setup:
eyelink.mode               = 1;                                             % 1 = use eyelink; 0 = off
eyelink.dummy              = 0;                                             % 1 = eyelink in dummy mode; 0 = eyelink dummy off
eyelink.recalib            = true;                                          % true = recalibrate between blocks (recommanded); false = no calibration between blocks
eyelink.dummyEye           = [0,0];                                         % dummy start pos
% eyelink.edfFile            = cell(const.numTrials,1); 
eyelink.edfFile            = cell(numel(const.numTrialsPerBlock),1);        % structure setup for edf files
for i = 1:numel(const.numTrialsPerBlock)
    eyelink.edfFile{i}     = sprintf('%.7d', i);
end     

%% Do some configurations (keys, screen, constants, trialData, sbj):
[sbj]                      = sbjConfig(const);
[keys] 					   = keyConfig;                                     % unify and define some keys
[screen]                   = screenConfig(const);                           % screen configurations (update if changes on setup or new setup used); opens PTB!
[const]                    = constConfig(screen, const);                    % set some constants and variables used in experiment
[trialData]                = paramConfig(const,sbj);

%% Generate Target Trajectory and Other Stimuli:
[const]                    = generateTargetTrajectory(const,screen);        % Moving target trajectory
[const]                    = generateStationaryStimuli(const,screen,...     % Stationary stimuli
                                trialData);       

                            
%% save all the constants and initial trialData struct:
%% (6.1) Save complete trialData file
Experiment.const       = const;
Experiment.eyelink     = eyelink;
Experiment.trialData   = trialData;
Experiment.sbj         = sbj;
Experiment.screen      = screen;
save([sbj.sbjFolder '/Experiment.mat'], 'Experiment');
                            
%% Run the Experiment with defined Settings:
if ~const.runScreenCalib
    expMain(const, screen, eyelink, trialData, sbj);% run experiment
    
    % run convert2ascSynch for the current subject, when done:
%     if IsWin
%         convert2ascSynch(sbj)
%     end
%% Alternatively, run Gamma Calibration procedure:
elseif const.runScreenCalib
    [screen]                = gammaCalib(screen, const, keys);              % run Screen Gamma Calibration
end
