function [const, trialData, control, eyelink] = runSingleTrial(const, trialData, control, eyelink, screen)
% =========================================================================
% runSingleTrial(const, trialData, control, screen, photo)
% =========================================================================
% Single Trial Routine to draw all stimuli on the screen, go through 
% different phases of the trial. Note, this function is called in the
% while-loop (i.e it's being run every refresh rate cycle!) - anything
% computationally expensive should be programmed outside the while loop!
% 1. Initial Drawings (BG, Stationary stim)
% 3. Different Phases of Experiment
% 3.1. Ready - check initial fixation 
% 3.2. Set - check peripheral fixation 
% 3.3. Intercept - target motion etc 
% 3.4. finish - feedback etc.
% 
% Last Changes:
% 23/10/2019 (PK) - cleaned up function
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings
% trialData: structure containing all trial relevant information
% control:   structure containing current trial information
% screen:    strucrure containing screen settings
% photo:     structure containting photodiode settings
% -------------------------------------------------------------------------
%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) INITIAL DRAWING:
%     - Set up the trial timer t (counting up from 0 for every trial!)
%     - Draw Background & stationary things that are always visible during
%     the trial (pre-defined in generateStationaryStimuli)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if eyelink.mode
    % timer, if Eyetracker is used: 
    t = eyelink.Data.time;                                                  % switched from trakstar.Data.time to eyelink.Data.time (PK, 05/2019)
    
    % recalibration option for eyetracker --> press e
    if PTBcheck_key_press('e')
        control.forceRecalibEL = 1;
        return;
    else
        control.forceRecalibEL = 0;
    end
else
    % timer, if Eyetracker is NOT used:
    t = eyelink.Data.time;                                                  % in expMain this is defined as GetSecs-tMainSync (i.e. equivalent to when eyelink is used!)
    if const.makeVideo == 1; t = control.frameCounter*screen.refreshRate; end
end

curTrial    = control.currentTrial;                                         % current trial
Screen('FillRect', screen.window, screen.background);                            % Draw background


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (2) ENTER DIFFERENT STAGES OF THE TRIAL
%     (1) Ready: 
%     (2) Set:
%     (3) Intercept:
%     (4) Finish:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch control.mode
    
    %% (2.1) --------------------------------------------------------------
    case 1                                                                  % PHASE 1: READY
        control.eyeTarget           = control.eyeReady;
        control.tPreFixation        = trialData.tPreFixation(curTrial);     % read out Fixation time in the current trial 

        % Check whether Eye and Finger are fixating at their Start Position
        if eyelink.mode == 1
           [b_fix_first, control]         = check_eye_fixated_to(const, eyelink, screen, control.eyeReady, control.tPreFixation, control);
        elseif  eyelink.mode == 0
            tElapse                 = t; % - trialData.tMainSync(curTrial);
            if tElapse > control.tPreFixation
                b_fix_first                   = 1;
            else
                b_fix_first                   = 0;
            end
        end
        

        % draw target       
%         PTBdraw_target(screen, control.eyeTarget, screen.targetColor, const);
        PTBdraw_target_gaussian(screen, control.eyeTarget, const);
     
        % if Fixation time passed, move to next phase
        if b_fix_first
            control.mode   = 2;                                             % leave ready-phase = fixation was successful, move on to next phase
            control.tStart = t;
            trialData.tStartTrial(curTrial) = t;
        end

        
    %% (2.2) --------------------------------------------------------------    
    case 2                                                                  % PHASE 2: SET
        control.eyeTarget           = control.eyeReady2;
        control.tPreFixation2       = trialData.tPreFixation2(curTrial);    % read out Fixation time in the current trial 

        
                % Check whether Eye and Finger are fixating at their Start Position
        if eyelink.mode == 1
           [b_fix_second, control]         = check_eye_fixated_to(const, eyelink, screen, control.eyeReady2, control.tPreFixation2, control);
        elseif  eyelink.mode == 0
            tElapse                 = t - trialData.tStartTrial(curTrial);
            if tElapse > control.tPreFixation2
                b_fix_second                   = 1;
            else
                b_fix_second                   = 0;
            end
        end

        
        % draw target:
%         PTBdraw_target(screen, control.eyeTarget, screen.targetColor, const);
        PTBdraw_target_gaussian(screen, control.eyeTarget, const);
        
        % if Second Fixation passen, move to next phase
        if  b_fix_second
            control.mode    = 3;                                            % leave set-phase = fixation was successful, move on to next phase
            control.tStart2 = t;
            trialData.tStartTrial2(curTrial) = t;
        end  
        
    %% (2.3)---------------------------------------------------------------    
    case 3                                                                  % PHASE 3: GO
        tElapse             = t - control.tStart2;
        control.tElapse     = tElapse;
        control.frameElapse = control.frameElapse + 1;                                % from now on, we will start counting frames. This is used for the flash presentation with respect to the pursuit target onset!
%         control.eyeTarget   = const.INTERP_TXY{control.PursuitDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse,+3),2:3); % Now the target moves, thus we update the current stim position according to its trajectory...
        control.eyeTarget   = const.INTERP_TXY{control.PursuitDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse*1000)/1000,2:3); % Now the target moves, thus we update the current stim position according to its trajectory...
        
        if tElapse < trialData.trajDuration(curTrial)                                 % check if target was supposed to already disappear

            % (1) draw target:
%             PTBdraw_target(screen, control.eyeTarget, screen.targetColor, const);     % draw target at updated position (i.e. it's now moving)
            PTBdraw_target_gaussian(screen, control.eyeTarget, const);
            trialData.tDisappearMeasure(curTrial) = tElapse;                          % this will be updated until time is up (last collected time = end of target traj) 

        
            % (2) draw flash (- only at the right time!):
            if control.frameElapse == control.tFlash                        % when frame at which flash is supposed to be shown is reached, draw the Flash
                if control.FlashDir ~= 0
                   PTBdraw_target(screen, const.allFlash{control.PursuitDir,control.FlashDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse*1000)/1000,:), const.flashColor, const);
%                     Screen('FillRect',  screen.window, const.flashColor, const.allFlash{control.PursuitDir,control.FlashDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse*1000)/1000,:));
%                   Screen('FillRect',  screen.window, const.flashColor, const.allFlash{control.PursuitDir,control.FlashDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse,+3),:));
    %               Screen('FillRect',  el.window, const.flashColor, trialData.AntiFlash);
                    trialData.tFlashPosition(curTrial,:) = const.allFlash{control.PursuitDir,control.FlashDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse*1000)/1000,:);
                end
                trialData.tFlashMeasure(curTrial) = tElapse;
%                 trialData.tFlashPosition(curTrial) = const.allFlash{control.PursuitDir,control.FlashDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse*1000)/1000,:);
            end
            
        elseif tElapse >= trialData.trajDuration(curTrial)                            % check if the trajectory mayalready be over = TIME OUT
            control.mode                  = 4;
            trialData.tEndTrial(curTrial) = t;
        end    
            
            
            
    %% (2.4)---------------------------------------------------------------       
    case 4                                                                  % PHASE 4: FINISH - WAIT BETWEEN TRIALS

        tElapse = t - trialData.tEndTrial(curTrial);
        
        if tElapse > trialData.waitBetweenTrials(curTrial)                           % wait and break
            control.break = 1;    
        end

                
end

