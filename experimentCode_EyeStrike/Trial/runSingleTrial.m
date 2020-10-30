function [const, trialData, control, eyelink, trakstar, el] = runSingleTrial(const, trialData, control, eyelink, trakstar, responsePixx, el, screen)
% =========================================================================
% runSingleTrial(const, trialData, control, eyelink, trakstar, el, INTERP_TXY, screen)
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
% 11/09/2019 (PK) - cleaned up function
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings
% trialData: structure containing all trial relevant information
% control:   structure containing current trial information
% eyelink:   structure containing eyelink settings        
% trakstar:  structure containing trakstar settings
% el:        structure containing open screen information
% screen:    strucrure containing screen settings
% -------------------------------------------------------------------------
%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) INITIAL DRAWING:
%     - Check if recalibration of hardware is forced
%     - Set up the timer t (using the Eyelink timer, counting up from 0 for
%     every trial!)
%     - Draw Background & stationary things that are always visible during
%     the trial (pre-defined in generateStationaryStimuli)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if any hardware recalibration needs to be done:
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

%recalibration option for trakSTAR --> press t
if trakstar.mode && PTBcheck_key_press('t')
    control.forceRecalibTS = 1;
    return;
else
    control.forceRecalibTS = 0;
end

%% Draw Background and Occluder:
curTrial    = control.currentTrial;                                         % current trial
Screen('FillRect', el.window, screen.background);                           % Draw background


% Occluder
Screen('FillRect',  el.window, screen.occluderColor, const.Occluder(control.occluder,:)); % Default Occluder trials 1-8 in each block
locOccluderWidth = const.OccluderSizeX(control.occluder);

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
        % check eye fixation
        if eyelink.mode == 1
           [b_eye, control]         = check_eye_fixated_to(const, eyelink, el, control.eyeReady, control.tPreFixation, control);                       
        elseif  eyelink.mode == 0
            tElapse                 = t;
            if tElapse > control.tPreFixation
                b_eye               = 1;
            else
                b_eye               = 0;
            end
        end
        % check finger fixation
        if trakstar.mode == 1
            [b_fin, control] = check_finger_fixated_to(const, trakstar, control, trakstar.startPos, control.tPreFixation);            
        else
            b_fin = 1;
        end
        % draw target       
        PTBdraw_target(el, control.eyeTarget, [0 0 0], const);
        
        % if target is stuck show which system (eye or finger) need recalibration
        if PTBcheck_key_press('r')
            if ~b_eye && ~b_fin
                PTBwrite_msg(el,'calibrate both', -100, 200)
                Screen('Flip', el.window,screen.refreshRate, 0, 0, 2);
                WaitSecs(1)
            elseif ~b_eye
                PTBwrite_msg(el,'calibrate eye tracker', -100, 200)
                Screen('Flip', el.window,screen.refreshRate, 0, 0, 2);
                WaitSecs(1)
            elseif ~b_fin
                PTBwrite_msg(el,'calibrate trakSTAR', -100, 200)
                Screen('Flip', el.window,screen.refreshRate, 0, 0, 2);
                WaitSecs(1)
            else
                PTBwrite_msg(el,'why are you pressing r?', -100, 200)
                Screen('Flip', el.window,screen.refreshRate, 0, 0, 2);
                WaitSecs(1)
            end
        end
        
        % if Fixation OK, move to next phase
        if  ~xor(const.checkEyeFix, b_eye)&& ~xor(const.checkFingFix, b_fin)
            control.mode   = 2;                                             % leave ready-phase = fixation was successful, move on to next phase
            control.tStart = t;
            trialData.tStartTrial(curTrial) = t;
        end
     
        
    %% (2.2)---------------------------------------------------------------    
    case 2                                                                  % PHASE 2: MOVEMENT
        tElapse             = t - control.tStart;
        control.tElapse     = tElapse;
        control.frameElapse = control.frameElapse + 1;                      % this is a frame counter. It counts
        control.eyeTarget   = const.INTERP_TXY{control.blockConditions}(const.INTERP_TXY{control.blockConditions}(:,1)==round(tElapse,+3),2:3); % Now the target moves, thus we update the current stim position according to its trajectory...
        
        % TARGET:
        if ~check_disappear(control, trialData) || check_reappear(control, trialData)  % check if target was supposed to already disappear
            PTBdraw_target(el, control.eyeTarget, [0 0 0], const);          % draw target at updated position (i.e. it's now moving)
%             trialData.tDisappearMeasure(curTrial) = tElapse;
        end    
        % for Eyelink timeStamps:
        if check_disappear(control, trialData) && control.tsOccluded ~= 2
            control.tsOccluded = 1;
        elseif check_reappear(control, trialData) && control.tsReappear ~= 2
            control.tsReappear = 1;    
        end
        
        
        % CHECK TIMEOUT
        if control.tElapse > control.tReappear  + 0.600 % trialData.trajDuration(curTrial)            % check if the trajectory mayalready be over = TIME OUT
            control.mode                  = 3;
            trialData.tEndTrial(curTrial) = t;
            trialData.bTimeOut(curTrial)  = 1;
            trialData.bTooEarly(curTrial) = 0;
            
            
        % CHECK INTERCEPTION - using EITHER Trakstar, ResponseBox, OR Dummy
        % (1) Trakstar:
        elseif trakstar.mode == 1 && abs(trakstar.Data.coord(3)) < 5
            control.finPosFinish               = PTBscreen_to_center(trakstar.Data.coord, el);
            control.targetPosFinish            = control.eyeTarget;
            
            if eyelink.mode == 1                                            % if Eyetracker used
                control.eyePosFinish           = [eyelink.Data.coord(1) eyelink.Data.coord(2)];
                trialData.eyePosFinish(curTrial,:) = control.eyePosFinish;
            end
            
            % if intercepted, check if too early:
            if control.tElapse < control.tReappear - 0.500
                trialData.bTooEarly(curTrial) = 1;
            else 
                trialData.bTooEarly(curTrial) = 0;
            end
            
            control.mode                       = 3;
            trialData.tEndTrial(curTrial)      = t;
            trialData.bTimeOut(curTrial)       = 0;
            trialData.finPosFinish(curTrial,:) = control.finPosFinish;
            trialData.targetPosFinish(curTrial,:) = control.targetPosFinish;
            control.tsIntercept                = 1;
            
            
        % (2) Response Box:
        elseif responsePixx.mode && VPixx_check_response_press() 
            control.targetPosFinish            = control.eyeTarget;
            
            if eyelink.mode == 1                                            % if Eyetracker used
                control.eyePosFinish           = [eyelink.Data.coord(1) eyelink.Data.coord(2)];
                trialData.eyePosFinish(curTrial,:) = control.eyePosFinish;
            end
            
            control.mode                       = 3;
            trialData.tEndTrial(curTrial)      = t;
            trialData.bTimeOut(curTrial)       = 0;
            trialData.bTooEarly(curTrial)      = 0;
            trialData.targetPosFinish(curTrial,:) = control.targetPosFinish;
%             trialData.finPosFinish(curTrial,:) = control.targetPosFinish;
            control.tsIntercept                = 1;
            
            
        % (3) Dummy (Computer mouse)    
        elseif const.listenToMouse %&& ~const.startExp
            [~,~,buttonPress] = GetMouse(el.window);
            control.finPosFinish(1:2)              = [locOccluderWidth, 0];
            if buttonPress(1)
                control.targetPosFinish            = control.eyeTarget;
                
                if eyelink.mode == 1                                            % if Eyetracker used
                    control.eyePosFinish           = [eyelink.Data.coord(1) eyelink.Data.coord(2)];
                    trialData.eyePosFinish(curTrial,:) = control.eyePosFinish;
                end

                control.mode                          = 3;
                trialData.tEndTrial(curTrial)         = t;
                trialData.bTimeOut(curTrial)          = 0;
                trialData.bTooEarly(curTrial)         = 0;
                trialData.finPosFinish(curTrial,1:2)  = control.finPosFinish;
                trialData.targetPosFinish(curTrial,:) = control.targetPosFinish;
                control.tsIntercept                   = 1;
            end
        end
                

    %% (2.3)---------------------------------------------------------------       
    case 3                                                                  % PHASE 4: FINISH

        tElapse = t - trialData.tEndTrial(curTrial);
        if tElapse > trialData.waitBetweenTrials(curTrial)                  % wait and break
            control.break = 1;    
        end

        if ~trialData.bTimeOut(curTrial) && ~trialData.bTooEarly(curTrial) && (trialData.finPosFinish(curTrial,1) >= locOccluderWidth)
             if const.feedback == 1                                         % If feedback is set to 1, show feedback
                 PTBdraw_target(el, control.targetPosFinish(1:2), [0 0 0], const);
                 PTBdraw_target(el, trialData.finPosFinish(curTrial,:), [255 0 0], const);
                 trialData.bOutOfBound(curTrial) = 0;
             end
        elseif trialData.bTimeOut(curTrial)     
             % write Time out message:
            PTBwrite_msg(el,'TOO LATE!', 'center', 150);
            trialData.bOutOfBound(curTrial) = 0;
        elseif trakstar.mode && trialData.finPosFinish(curTrial,1) < locOccluderWidth
             % write out of bound message:
            PTBwrite_msg(el,'HIT IN OCCLUDER', 'center', 150);
            trialData.bOutOfBound(curTrial) = 1;
        elseif trialData.bTooEarly(curTrial)    
             % write too early message:
            PTBwrite_msg(el,'TOO EARLY!', 'center', 150);
            trialData.bOutOfBound(curTrial) = 0;
        end 

                
end

