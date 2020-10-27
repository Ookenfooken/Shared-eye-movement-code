%% ------------------- READ ME EXP_CODE_TEMPLATE ------------------------%%
%  
%  The code structure is based on EyeCatch (JF & ShY)
%  Requires Psychtoolbox and Eyelink Toolbox functions.
%  
%  written by: Philipp KREYENMEIER (philipp.kreyenmeier@gmail.com)
%  last updated: 
%  29/07/2019 (PK) - wrote ReadMe
%  ------------------------------------------------------------------------
%  
%  Structure:
%
%  1) expStarter                                    | starts Experiment; set main experiment configurations
%  1.1) pathConfig  								| add all relevant paths
%  1.2) keyConfig                           		| define keys
%  1.3) screenConfig								| do all the Screen settings
%       1.3.1) loadGRAYLinCalib OR loadRGBLinCalib  | depending on whether GREY or RGB linearisation picked, load in lineratisation table
%       1.3.2) loadgammaCalib                   	| load the linearisation and use for Screen
%  1.4) constConfig									| setup all constants used in experiment
%  1.5) paramConfig                                 | setup all trial parameters (constant and variable) 
%       1.5.1) pick_params                          | randomize all variable parameters
%  1.6) sbjConfig                                   | enter all relevant subject information to workspace
%  1.7) generateTargetTrajectory                	| if selected, generate the main moving stimulus trajectory
%  1.8) generateStationaryStimuli                	| if selected, generate the main moving stimulus trajectory
%
% ___ 2) expMain                                    | run experiment - expMain is the experiment framework
%|    2.1) trakstar_init                            | initialize Trakstar (if used) 
%|    2.2) psych_init                               | initialize PTB (Open 'Screen')
%|    2.3) eyelink_init                             | initialize and calibrate Eyelink
%|    2.4) trakstar_calibration                     | calibrate Trakstar
%|    2.5) PTBinstruction_page                      | show Experiment instruction (shown only once at beginning)
%|    --------------------------------------------- | Enter Single Trial Setup
%|    2.6) 
%|    2.7) eyelink_recalibration                    | check if recalibration is necessary (between blocks, if set) and calibrate Eyelink
%|    2.8) trakstar_recalibration                   | check if recalibration is necessary (between blocks, if set)
%|         2.7.1) trakstar_calibration              | calibrate trakstar
%|    2.9) PTBinstruction_page                      | show Block-instruction (shown before each block)
%|    2.10) eyelink_dataAcquisition                 | get current Eyelink Data (time, x and y position)
%|    2.11) trakstar_dataAcquisition                | get current Trakstar Data (time, x and y position)
%|    
%|    2.12) runSingleTrial                          | Draw all stimuli and check for any interactions
%|    --------------------------------------------- | Finish and save all the recordings
%|    2.13) cleanup                                 | close Eyelink, Trakstar and PTB Screen
%|    
%|   
%|  OR:
%|___ 3) gammaCalib                                 | runs screen calibration procedure (which one - GREY or RGB - is selected in screenConfig)
%     3.1) instructionConfig                        | set up the instructions shown for screen calibration 
%     A - Gray:
%     3.2a) grayLinCalib                            | perform initial measurements for gray calibration
%         3.2a.1) instructions                      | show instructions
%         3.2a.2) waitValues                        | wait for entry of measured value
%     3.3a) grayCheckCalib                          | perform validation measurements for gray calibration
%         3.3a.1) loadgammaCalib                    | load initial measurements from 3.2a
%         3.3a.2) instructions
%         3.3a.3) waitValues
%     3.4a) getRGBcalibVal                          | measure RGB vlaues
%         3.4a.1) loadgammaCalib
%         3.4a.2) instructions
%         3.4a.3) waitValues
%    
%    B - RGB:
%     3.2b) rgbLinCalib                             | perform initial measurements for RGB calibration
%         3.2b.1) instructions
%         3.2b.2) waitValues
%     3.3b) rgbCheckCalib                           | perform validation measurements for RGB calibration
%         3.3b.1) loadgammaCalib                    | load initial measurements from 3.2b
%         3.3b.2) instructions
%         3.3b.3) waitValues
%     3.4b) getGRAYcalibVal                         | measure GRAY vlaues
%         3.4b.1) loadgammaCalib 
%         3.4b.2) instructions
%         3.4b.3) waitValues
% 
% 
% 
% 
%  Quick Guide:
% 
%  1) General Experiment Settings: change in expStarter
%  2) Stimulus changes: change in constConfig (target appearance) + generateTarget (for changes of main target motion)
%  3) Change Design (randomized Variables and general Experiment): change in paramConfig + runSingleTrial
%  4) Run Experiment on a new setup: change in screenConfig
%  
%  ---------------------------------------------------------------------------------