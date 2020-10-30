function expMain(const, screen, eyelink, trakstar, responsePixx, trialData, sbj)
% =========================================================================
% expMain(const, screen, eyelink, trakstar, trialData, sbj)
% =========================================================================
% Function created to run the framework of experiment:
% 1. Initialize Experiment
% 3. Show Instructions
% 4. Single Trial Setup
% 5. Run Single Trials (While-loop, main flip)
% 6. Finish Trial (close files)
% 7. Close Experiment
% 
% Last Changes:
% 07/08/2019 (PK) - cleaned up function
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings
% screen:    strucrure containing screen settings
% eyelink:   structure containing eyelink settings
% trakstar:  structure containing trakstar settings
% trialData: structure containing all trial relevant information
% sbj:       structure containing subject information
% -------------------------------------------------------------------------
%%
ListenChar(1);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) INITIALIZE EXPERIMENT: 
%     load Target Trajectory, initialize Trakstar, Eyelink, and PTB Screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% (1.1) Initialize Psychtoolbox; create el-structure, if Eyelink not used
[screen, el]                 = psych_init(screen, eyelink);
% if const.startExp; ListenChar(2); HideCursor; end                           % Disable key output to Matlab window:

%% (1.2) Initialize ResponsePixx
if responsePixx.mode
    % Open Datapixx, and stop any schedules which might already be running
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
    
    % RESPONSEPixx has 5 illuminated buttons.
    % We drive those button lights by turning around 5 DIN bits to outputs.
    % Test paradigms could illuminate only the buttons which are valid in context.
    % (eg: 1 button when waiting for subject to initiate a trial,
    % 2 other buttons when waiting for 2-alternative forced-choice response).
    % comment JF: this description is from VPixx. Currently we haven't
    % figured out how to use single buttons...
    Datapixx('SetDinDataDirection', hex2dec('1F0000'));
    Datapixx('SetDinDataOut', hex2dec('1F0000'));
    Datapixx('SetDinDataOutStrength', 1);   % Set brightness of buttons
end

%% (1.3) Initialize Trakstar
if trakstar.mode
    [trakstar]               = trakstar_init(trakstar);
end

%% (1.4) Initialize and Calibrate Eyelink
if eyelink.mode
    [el]                     = eyelink_init(screen, const, eyelink);       
end

%% (1.5) Calibrate Trakstar
if trakstar.mode
    [trakstar]               = trakstar_calibration(trakstar, el, screen);
    [trakstar]               = trakstar_getStartPos(trakstar);              % this sets the fixation location (used to check, whether finger fixates at start position)
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (2) SHOW INSTRUCTIONS:
%     General Experiment Instructions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('EXP: Begin experiment: show instructions');
PTBinstruction_page(1,el,screen)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (3) SINGLE TRIAL SETUP
%      Enter (FOR-loop): Trial setup (control-struct), check for recalib,
%      show block instruction, open files, begin recordings, mark synctimes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forceRecalibrationEL = 0;
forceRecalibrationTS = 0;   
trialNum = 1;
try
%% (3.1) Trial Setup:
while trialNum <= const.numTrials
    control                 = [];                                           % Setup a Trial Control Structure
    control.forceRecalibEL  = 0;
    control.forceRecalibTS  = 0;
    control.currentTrial    = trialNum;                                     % current trial
    control.trialName       = sprintf('%.7d', trialNum);                    % name of trial-edf file
    control.blockConditions = trialData.blockConditions(trialNum);          % which presTime*Acceleration Condition (blocked)
    control.occluder        = trialData.occluder(trialNum);                 % which occluder width is presened    
    control.eyeReady        = const.INTERP_TXY{control.blockConditions}...          % second fixation (this is where eye should be at time 0, from here, the target starts moving).
        (const.INTERP_TXY{control.blockConditions}(:,1)==0,2:3); 
    control.tReappear       = const.INTERP_TXY{control.blockConditions}...          % read out the time of target reappearance (this is different for each trajectory)
        (find(const.INTERP_TXY{control.blockConditions}(:,2) >= const.OccluderSizeX(control.occluder),1,'first'),1);
    control.mode            = 1;                                            % different phases of the trial (changes values in runSingleTrials)
    control.break           = 0;                                            % trial completion
    control.abort           = 0;                                            % trial abortion (ESCAPE key press)
    control.frameElapse     = 0;                                            % frame counter, updates every flip from target motion onset (i.e. when mode == 3)
    control.tsOccluded      = 0;
    control.tsReappear      = 0;
    control.tsIntercept     = 0;
    iterations              = 0;                                            % counts iterations of while-loop
 
    %% (3.2) Clear ResponsePixx
    % clear any late button presses
    % Fire up the logger
    if responsePixx.mode
        Datapixx('EnableDinDebounce');                                      % Filter out button bounce
        Datapixx('SetDinLog');                                              % Configure logging with default values
        Datapixx('StartDinLog');
        Datapixx('RegWrRd');
    end
    %% (3.3) Check Recalibration (i.e. recalibration between blocks)
    if (trialNum > 1 && eyelink.recalib == 1 && eyelink.mode == 1) || forceRecalibrationEL            
        eyelink_recalibration(control,const,el,forceRecalibrationEL);                            % Recalibrate Eyelink
    end
        
    if (trialNum > 1 && trakstar.recalib == 1 && trakstar.mode == 1) || forceRecalibrationTS   
        [trakstar] = trakstar_recalibration(control,const,trakstar,el,screen,forceRecalibrationTS);     % Recalibrate Trakstar
    end
    
 %% (3.4) Show Block Instrustion (before block starts):
    for j = 1:size(const.numTrialsPerBlock,2)
       if xor(trialNum == 1,  trialNum == 1 + sum(const.numTrialsPerBlock(1:j)))
            PTBinstruction_page(2,el,screen)
           break;
       end
     end
    
    %% (3.5) Open Eyelink, Trakstar, & Target-Files: 
    fprintf('EXP: begin trial %d\n', trialNum);
    
     % (a) open Eyelink file
      if eyelink.mode % && ~forceRecalibrationEL && ~forceRecalibrationTS
        eyelink.edfFile{trialNum} = control.trialName;
        fprintf('EXP: EDFFile: %s\n', eyelink.edfFile{trialNum});

        control.tmp = Eyelink('Openfile', eyelink.edfFile{trialNum});
        if control.tmp ~= 0                                                 % if Eyetracker can't open file, stop experiment
            fprintf('EXP: Cannot create EDF file ''%s'' ',...
                eyelink.edfFile{trialNum});
            cleanup;
            return;
        end
     end   
    
    % (b) Open Trakstar File
    if trakstar.mode == 1 && ~forceRecalibrationTS && ~forceRecalibrationEL 
        trakstar.tdfFile = [control.trialName '.tdf'];
        trakstar.tdfFID  = fopen(trakstar.tdfFile, 'w');
    end     
     
    % (c) Open Target File
    if ~forceRecalibrationTS && ~forceRecalibrationEL 
        control.targetFile   = [control.trialName '.target'];
        control.targetFID    = fopen(control.targetFile, 'w');
    else
        control.targetFile   = currentTargetFile;
        control.targetFID    = currentTargetFID;
    end
      
    %% (3.6) Begin Eyelink Recordings:
    
     if eyelink.mode == 1
        EyelinkDoDriftCorrection(el);                                       % perform drift correction
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording');
        WaitSecs(0.01);                                                     % record a few samples before we actually start displaying
     end
    
    %% (3.7) Mark Synctimes:
    % (a) Trakstar:
    if trakstar.mode == 1
        control.TS_Synctime                      = trakstar_getData(trakstar);
        trialData.tTrakstarSync(trialNum)        = control.TS_Synctime.time;% get aynctime from trakstar
    else
        trialData.trakstarSync(trialNum)         = GetSecs;                 % for dummy mode, get the current time as synctime
    end    
    
    % (b) Eyelink:
    if eyelink.mode == 1
        Eyelink('Message', 'TRIAL_START %d', control.currentTrial);         % send Eylink Message to mark start of trial
        trialData.tMainSync(trialNum)            = Eyelink('TrackerTime');  % get synctime from eyelink
        Eyelink('Message', 'SYNCTIME');                                     % mark zero-plot time in edf file
    else
        trialData.tMainSync(trialNum)            = GetSecs;                 % for dummy mode, get the current time as synctime
        if const.makeVideo == 1                                             % settings for single-trial video:
            trialData.tMainSync(trialNum)        = 0;                       % can change params to show here.
            trialData.blockConditions(trialNum)  = 3;
            control.frameCounter                 = 1;
        end
    end    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (4) RUN SINGLE TRIALS (WHILE-LOOP):
    %     intialize Eyelink recording, check recording, data acquisition,
    %     run runSingleTrials.m, main flip, save target and trakstar data, 
    %     end the trial
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    fprintf('EXP: Enter while loop \n');

    %% (4.1) Initialize Eyelink Data:    
    eyelink.Data.coord = [0, 0];                                            % initialize eyelink data (since new sample can be missing for first couple of loops)
    if eyelink.mode == 1
        eyelink.Data.time = Eyelink('TrackerTime')...                       % get time before entering while loop (this should be close to 0)
            - trialData.tMainSync(trialNum);                 
    else                                                                    % for dummy mode
        eyelink.Data.time = GetSecs - trialData.tMainSync(trialNum);
    end

    %% ========================================================================
    while  1                                                                % begin WHILE- loop (code will run through this part until break
        iterations = iterations + 1;                                        % this runs every refresh Rate cycle (should be free of heavy computations)
        %% (4.2) Check Eyelink Recording:
        if eyelink.mode == 1
            error = Eyelink('CheckRecording');
            if(error ~= 0)
                fprintf('EXP: CheckRecording error %d\n', error);
                break;
            end
        end

        %% (4.3) Data Acquisition
        % (a) Eyelink
        if eyelink.mode == 1
           [eyelink] = eyelink_dataAcquisition(el,eyelink,trialData,trialNum);
        else                                                                % for dummy mode
            eyelink.Data.time = GetSecs - trialData.tMainSync(trialNum);
        end

        % (b) Trakstar:
        if trakstar.mode == 1
           [trakstar] = trakstar_dataAcquisition(trakstar,trialData,trialNum); 
        end  
        
        %% (4.4) Run Single Trial:
        % ========================================================================================================================================
        [const, trialData, control, eyelink, trakstar, el] = runSingleTrial(const, trialData, control, eyelink, trakstar, responsePixx, el, screen);
        % ========================================================================================================================================
        
        % show gaze or finger if it is turned on                            % PK, 07/08/2019: never tried - does it work? 
        if eyelink.mode && const.showGaze            
            PTBdraw_circles(el, eyelink.Data.coord, 10, [255 255 255]);
        end
        if trakstar.mode && const.showFing
            PTBdraw_cross(el, trakstar.Data.coord(1:2), round(abs(trakstar.Data.coord(3))), [255 0 0]);
        end
        
        %% (4.5) Main Flip and Time Stemps:
        % ======================================================================================================
%          Screen('Flip', el.window,screen.refreshRate, 0, 0, 2);
         [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip', el.window);
        % ======================================================================================================

        % Send Eyelink Messages to mark important events:
%         if iterations == 1 && eyelink.mode == 1
%              Eyelink('Message', 'FIX_ON');                                  % fixation onset  
%              trialData.t_fix_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
%         elseif control.frameElapse == 1 && eyelink.mode == 1
%              Eyelink('Message', 'STIM_ON');                                 % target movement onset 
%              trialData.t_start_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
%         elseif control.tsOccluded == 1 && eyelink.mode == 1
%              Eyelink('Message', 'STIM_OCCLUDED');                           % target occluded
%              trialData.t_occluded_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
%              control.tsOccluded      = 2;
%         elseif control.tsReappear == 1 && eyelink.mode == 1
%              Eyelink('Message', 'STIM_REAPPEAR')                            % target reappeared
%              trialData.t_reappear_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
%              control.tsReappear      = 2;
%          elseif control.tsIntercept == 1 && eyelink.mode == 1
%              Eyelink('Message', 'INTERCEPT')                            % target reappeared
%              trialData.t_intercept_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
%              control.tsIntercept      = 2;
%         end

        if iterations == 1
             % fixation onset  
             trialData.t_fix_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
        elseif control.frameElapse == 1
             % target movement onset 
             trialData.t_start_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
        elseif control.tsOccluded == 1 
             % target occluded
             trialData.t_occluded_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
             control.tsOccluded      = 2;
        elseif control.tsReappear == 1 
             % target reappeared
             trialData.t_reappear_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
             control.tsReappear      = 2;
         elseif control.tsIntercept == 1
             % target reappeared
             trialData.t_intercept_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
             control.tsIntercept     = 2;
        end
        
        
        if const.makeVideo == 1                                             % if making video, here images are taken of each frame
            control.frameCounter = control.frameCounter + 1;                % update frameCounter
            imageArray(:,:,:,control.frameCounter) = Screen('GetImage',screen.window);
        end
        
        %% (4.6) Save Data:                                                 % target and trakstar data is initially saved in cell, gets later written in text files
        % (a) Save Target data:     
        targetInfo{iterations,:} = [num2str([eyelink.Data.time, control.eyeTarget]), char(10)];
              
        % (b) Save Trakstar data        
        if trakstar.mode == 1
            trakstarInfo{iterations,:} = [num2str([trakstar.Data.raw.time, trakstar.Data.raw.pos, trakstar.Data.raw.ori, trakstar.Data.coord]), char(10)];
        end 
        
        %% (4.7) End the trial (i.e. break while-loop)
        if control.break
            fprintf('EXP: Trial %d finished \n', trialNum);
            break;                                                          % BREAK the while loop, if trial was finished!
        end
        
        if PTBcheck_key_press('ESCAPE')
            fprintf('EXP: Experiment aborted by pressing esc key \n');
            control.abort = 1;
            break;                                                          % BREAK the while loop, if trial was aborted by ESC press
        end    
        
        if control.forceRecalibEL || control.forceRecalibTS
                break;
        end
    
    end                                                                     % end of WHILE-loop     
    %% ========================================================================

    
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % (5) FINISH TRIAL: 
   %     close files (in case experiment was aborted), stop recording, 
   %     create video (if chosen),
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
   %% (5.1) Close Target and trakstar files, if experiment was aborted:
    if control.abort == 1
        % (a) Target file
        fclose(control.targetFID);
        movefile(control.targetFile, ['./data/' sbj.filename]);
        fprintf('EXP: Target data is saved in .\\data\\%s\\%s\n', sbj.filename, control.targetFile);

        % (b) Trakstar file
        if trakstar.mode == 1
            fclose(trakstar.tdfFID);
            movefile(trakstar.tdfFile, ['.\data\' sbj.filename]);
            fprintf('EXP: Trakstar data is saved in .\\data\\%s\\%s\n', sbj.filename, trakstar.tdfFile);
        end
        throw(MException('EXP: MainLoop','Experiment aborted'));
    end

    
    %% (5.2) Stop Eyelink Recording and close files, if recalibration is forced (repeats trial) or trial finished properly:
    if control.forceRecalibEL                                               % check if Eyelink calibration was forced
        forceRecalibrationEL = 1;
        currentTargetFile = control.targetFile;
        currentTargetFID = control.targetFID;
        clear trakstarInfo targetInfo                                       % delete target & trakstar data collected before recalibration
        Eyelink('Message', 'FORCE_RECALIB_EL');                             % send Eyelink Message
        Eyelink('StopRecording');
        Eyelink('CloseFile');                                               % Stop Eyelink Recording and close file
        if ~exist(['.\data\' sbj.filename '\trial_recalib\'], 'dir')
            mkdir(['.\data\' sbj.filename '\trial_recalib\'])
        end
    elseif control.forceRecalibTS                                           % check if trakstar calibration was forced
        forceRecalibrationTS = 1;
        currentTargetFile = control.targetFile;
        currentTargetFID = control.targetFID;
        clear trakstarInfo targetInfo                                       % delete target & trakstar data collected before recalibration
        if eyelink.mode == 1
            Eyelink('Message', 'FORCE_RECALIB_TS');                         % send Eyelink Message
            Eyelink('StopRecording');
            Eyelink('CloseFile');                                           % Stop Eyelink Recording and close file
        end
        if ~exist(['.\data\' sbj.filename '\trial_recalib\'], 'dir')
            mkdir(['.\data\' sbj.filename '\trial_recalib\'])
        end
    else                                                                    % if trial went OK (no forced caliobration)
        trialNum  = trialNum+1;
        forceRecalibrationEL = 0;
        forceRecalibrationTS = 0;
        % (a) Stop Eyelink recording and close file                         % closing file should be per block in later versions
        if eyelink.mode == 1
            WaitSecs(0.01);                                                 % wait a while to record a few more samples
            Eyelink('Message', 'TRIAL_END %d', control.currentTrial);       % mark proper (!) end of trial
            Eyelink('StopRecording');
            Eyelink('CloseFile');
        end
        % (b) write Trakstar data into text (.tdf) file and close file:
        if trakstar.mode == 1
            for ts = 1:size(trakstarInfo,1)
                fwrite(trakstar.tdfFID, trakstarInfo{ts,:});
            end
            fclose(trakstar.tdfFID);
            movefile(trakstar.tdfFile, ['.\data\' sbj.filename]);           % move data in subject data file
            fprintf('EXP: Trakstar data is saved in .\\data\\%s\\%s\n', sbj.filename, trakstar.tdfFile);
        end
        % (c) write Target data into text (.target) file and close file:
        for target = 1:size(targetInfo,1)
            fwrite(control.targetFID, targetInfo{target,:});
        end
        fclose(control.targetFID);
        movefile(control.targetFile, ['./data/' sbj.filename]);             % move data in subject data file
        fprintf('EXP: Target data is saved in .\\data\\%s\\%s\n', sbj.filename, control.targetFile);
        % (d) save trialData (every trial):
        save(['./data/' sbj.filename '/info.mat'], 'trialData');            % save data in subject data file
    end

    %% (5.3) Create Video, if chosen:
    if const.makeVideo == 1                                                 % put the single images into a video clip:
        if ~exist('./data/video', 'dir'); mkdir('./data/video'); end 
        m = cat(4,imageArray);
        vidName = input(sprintf('\n\tVideo name:\t'),'s');
        fprintf('\n\tProcessing video - please wait...\n')
        writerObj = VideoWriter(sprintf('./data/video/%s',vidName),'MPEG-4');
        writerObj.FrameRate = 120;
        writerObj.Quality = 100;
        open(writerObj);
        writeVideo(writerObj,m);
        close(writerObj);
    end
    
    clear trakstarInfo targetInfo

    % Download eyelink files
    if eyelink.mode
        try
            fprintf('EXP: Receiving data file ''%s''\n', eyelink.edfFile{control.currentTrial});
            if control.forceRecalibTS || control.forceRecalibEL
                status=Eyelink('ReceiveFile', eyelink.edfFile{control.currentTrial}, ['.\data\' sbj.filename '\trial_recalib\'], 1);            
            else
                status=Eyelink('ReceiveFile', eyelink.edfFile{control.currentTrial}, ['.\data\' sbj.filename], 1);
            end
            if status > 0
                fprintf('EXP: ReceiveFile status %d\n', status);
            end
        catch rdf
            fprintf('EXP: Problem receiving data file ''%s''\n', eyelink.edfFile{control.currentTrial});
            rdf;
        end
     end



end                                                                         % end of all-trials WHILE-loop


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (6) CLOSE EXPERIMENT: 
%     save trialData structure, download edf-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% (6.1) Save complete trialData file
Experiment.const       = const;
Experiment.eyelink     = eyelink;
Experiment.trakstar    = trakstar;
Experiment.trialData   = trialData;
Experiment.screen      = screen;
Experiment.el          = el;
Experiment.sbj         = sbj;
save(['./data/' sbj.filename '/Experiment.mat'], 'Experiment');

%% (6.2) Download Eyelink Files:
% if eyelink.mode == 1
%     for i = 1:const.numTrials
%         try
%             fprintf('EXP: Receiving data file ''%s''\n', eyelink.edfFile{i});
%             status=Eyelink('ReceiveFile', eyelink.edfFile{i}, ['.\data\' sbj.filename], 1);
%             if status > 0
%                 fprintf('EXP: ReceiveFile status %d\n', status);
%             end
%         catch rdf
%             fprintf('EXP: Problem receiving data file ''%s''\n', eyelink.edfFile{i});
%             rdf;
%         end
%     end
% end

disp('EXP: Finish experiment');
cleanup(eyelink, trakstar, responsePixx);


%% MY ERR
catch myerr                                                                 % this "catch" section executes in case of an error in the "try" section
    fclose('all');                                                          % above.  Importantly, it closes the onscreen window if its open.
    if ~exist(['./data/' sbj.filename '/Experiment.mat'], 'file')
        Experiment.const       = const;
        Experiment.eyelink     = eyelink;
        Experiment.trakstar    = trakstar;
        Experiment.trialData   = trialData;
        Experiment.screen      = screen;
        Experiment.el          = el;
        Experiment.sbj         = sbj;
        save(['./data/' sbj.filename '/Experiment.mat'], 'Experiment');
    end
    
    
    cleanup(eyelink, trakstar, responsePixx);
    commandwindow;
    myerr;
    myerr.message
    myerr.stack.line
end                                                                         % end of try...catch
end                                                                         % end of function