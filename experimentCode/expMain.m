function expMain(const, screen, eyelink, trialData, sbj)
% =========================================================================
% expMain(const, screen, eyelink, trialData, sbj)
% =========================================================================
% Function created to run the framework of experiment:
% 1. Initialize Experiment/ Show Experiment Instructions
% 2. Setup & Calibrate DPI; Enter Block Loop:
% 3. Single Trial Setup
% 4. Run Single Trials (Enter Trial-While-loop, main flip)
% 5. Finish Trial (close files)
% 6. Close Experiment
% + DPI - a global structure initiated during dpi_init; contains analog
%   input data collection
% 
% Last Changes:
% 04/11/2019 (PK) - cleaned up function
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings
% screen:    strucrure containing screen settings
% dpi_set:   structure containing DPI settings
% photo:     structure containting photodiode settings
% trialData: structure containing all trial relevant information
% sbj:       structure containing subject information
% -------------------------------------------------------------------------
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) INITIALIZE EXPERIMENT: 
%     1) initialize experiment, 2) show experiment instruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% (1.1) Initialize Psychtoolbox; create el-structure, if Eyelink not used
% if const.startExp; ListenChar(2); end          %HideCursor;                  % Disable key output to Matlab window and hide cursor:


%% (1.2) Initialize and Calibrate Eyelink
if eyelink.mode
    [el]                     = eyelink_init(screen, const, eyelink);       
end


%% (1.3) Show General Experiment Instructions
disp('EXP: Begin experiment: show instructions');
PTBinstruction_page(1,screen)





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (2) SETUP & CALIBRATE DPI; ENTER BLOCK LOOP:
%     1) show Calibration Instruction, 2) show DPI Setup screen, 
%     3) run calibration, 4) setup trial counter for trial-loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forceRecalibrationEL = 0;
trialNum = 1;
try

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (3) SINGLE TRIAL SETUP
%      1) enter TRIAL-WHILE-loop: trial setup (control-struct),
%      2) open target file, 3) Show blank screen, wait for participant
%      4) mark synctime for target display 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% (3.1) Trial Setup:
while trialNum <= const.numTrials                                       % START TRIAL WHILE-LOOP
    control                 = [];                                       % Setup a Trial Control Structure
    control.forceRecalibEL  = 0;
    control.currentTrial    = trialNum;                                 % current trial
    control.trialName       = sprintf('%.7d', trialNum);
    control.PursuitDir      = trialData.PursuitDir(trialNum);           % pursuit direction in this trial
    control.FlashDir        = trialData.FlashDir(trialNum);             % flash direction in this trial
    control.tFlash          = trialData.tFlash(trialNum);
    control.eyeReady        = [0 0];                                    % intial fixation (in the center)
    control.eyeReady2       = const.INTERP_TXY{control.PursuitDir}...   % second fixation (this is where eye should be at time 0, from here, the target starts moving).
        (const.INTERP_TXY{control.PursuitDir}(:,1)==0,2:3); 
    control.mode            = 1;                                        % different phases of the trial (changes values in runSingleTrials)
    control.break           = 0;                                        % trial completion
    control.abort           = 0;                                        % trial abortion (ESCAPE key press)
    control.frameElapse     = 0;                                        % frame counter, updates every flip from target motion onset (i.e. when mode == 3)
    iterations              = 1;                                        % counts iterations of while-loop

    %% (3.2) Check Recalibration (i.e. recalibration between blocks)
    if (trialNum > 1 && eyelink.recalib == 1 && eyelink.mode == 1) || forceRecalibrationEL            
        eyelink_recalibration(control,const,el,forceRecalibrationEL);                            % Recalibrate Eyelink
    end
    
     %% (3.3) Show Block Instrustion (before block starts):
    for j = 1:size(const.numTrialsPerBlock,2)
       if xor(trialNum == 1,  trialNum == 1 + sum(const.numTrialsPerBlock(1:j)))
            PTBinstruction_page(2,screen)
           break;
       end
     end
    
    %% (3.4) Open Target-File (record displayed target path): 

     % (a) open Eyelink file
     if eyelink.mode && ~forceRecalibrationEL
         
        for i = 0:numel(const.numTrialsPerBlock)-1
            if control.currentTrial == 1 || control.currentTrial == sum(const.numTrialsPerBlock(1:i)) + 1 % only open a df file 
                fprintf('EXP: Entering Block %s\n', eyelink.edfFile{i+1})
                fprintf('EXP: EDFFile: %s\n', eyelink.edfFile{i+1});

                control.tmp = Eyelink('Openfile', eyelink.edfFile{i+1});
                if control.tmp ~= 0                                         % if Eyetracker can't open file, stop experiment
                    fprintf('EXP: Cannot create EDF file ''%s'' ',...
                        eyelink.edfFile{i+1});
                    cleanup;
                    return;
                end
                break;
            end
        end
        
     else
         for i = 1:numel(const.numTrialsPerBlock)
            if control.currentTrial == 1 || control.currentTrial == sum(const.numTrialsPerBlock(1:i)) + 1 % only open a df file 
                fprintf('EXP: Entering Block %s\n', eyelink.edfFile{i})
                break;
            end
         end  
     end   
    
    % (b) Open Target File
    if ~forceRecalibrationEL 
        control.targetFile   = [control.trialName '.target'];
        control.targetFID    = fopen(control.targetFile, 'w');
    else
        control.targetFile   = currentTargetFile;
        control.targetFID    = currentTargetFID;
    end
    
    fprintf('EXP: begin trial %d\n', trialNum);
    
    
    %% (3.5) Begin Eyelink Recordings & Drift Correction:
    
     if eyelink.mode == 1
        EyelinkDoDriftCorrection(el);                                       % perform drift correction
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording');
        WaitSecs(0.01);                                                     % record a few samples before we actually start displaying
    end
 

    %% (3.6) Mark Synctime (this is importnat for moving target display):
    if eyelink.mode == 1
        Eyelink('Message', 'TRIAL_START %d', control.currentTrial);         % send Eylink Message to mark start of trial
        trialData.tMainSync(trialNum)            = Eyelink('TrackerTime');  % get synctime from eyelink
        Eyelink('Message', 'SYNCTIME');                                     % mark zero-plot time in edf file
    else
        trialData.tMainSync(trialNum)            = GetSecs;                 % for dummy mode, get the current time as synctime
        if const.makeVideo == 1                                             % settings for single-trial video:
            trialData.tMainSync(trialNum)        = 0;                       % can change params to show here.
            trialData.FlashDir(trialNum)         = 2;
            trialData.tFlash(trialNum)           = 7;
            trialData.tFlashRandVar(trialNum)    = 1;
            control.FlashDir                     = 2;
            control.tFlash                       = 7;
            control.tFlashRandVar                = 1;
            control.frameCounter                 = 1;
        end
    end    
    

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (4) RUN SINGLE TRIALS (WHILE-LOOP):
    %     1) start DPI recording (for current trial), 
    %     2) update trial timer, 3) run runSingleTrials.m,
    %     4) main flip,  5) save target data, 6) end the trial/stop DPI
    %     recording
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    fprintf('EXP: Enter while loop \n');

    %% (4.1) Initialize Eyelink Data:    
    eyelink.Data.coord = [0, 0];                                            % initialize eyelink data (since new sample can be missing for first couple of loops)
    if eyelink.mode == 1
        eyelink.Data.time = Eyelink('TrackerTime')...                       % get time before entering while loop (this should be close to 0)
            - trialData.tMainSync(trialNum);                 
    end    
    
    %% ================================================================
    while  1                                                            % begin WITHIN-TRIAL-WHILE-loop (code will run through this part until break
        iterations = iterations + 1;                                    % this runs every refresh Rate cycle (should be free of heavy computations)
        
        %% (4.2) Check Eyelink Recording:
        if eyelink.mode == 1
            error = Eyelink('CheckRecording');
            if(error ~= 0)
                fprintf('EXP: CheckRecording error %d\n', error);
                break;
            end
        end

        %% (4.3) Eyelink Data Acquisition
        if eyelink.mode == 1
           [eyelink] = eyelink_dataAcquisition(el,eyelink,trialData,trialNum);
        else                                                                % for dummy mode
            eyelink.Data.time = GetSecs - trialData.tMainSync(trialNum);
        end

        %% (4.3) Run Single Trial:
        % =============================================================
        [const, trialData, control, eyelink] = runSingleTrial(const, trialData, control, eyelink, screen);
        % =============================================================
        
        % show gaze or finger if it is turned on                           
%         if eyelink.mode && const.showGaze            
%             PTBdraw_circles(screen, eyelink.Data.coord, 10, [255 255 255]);
%         end

        %% (4.4) Main Flip and Time Stemps:
        % =============================================================
        [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip', screen.window);      
        % =============================================================
        % for debugging: 
        if  ~const.startExp && control.frameElapse == trialData.tFlash(trialNum)
            control.PursuitDir
            control.FlashDir
            trialData.tFlashPosition(trialNum,:)
            control.eyeTarget
        end
        
        
        if iterations == 2
            trialData.t_start_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
        end 
        % Send Eyelink Messages to mark important events:
        if control.frameElapse == 1 && eyelink.mode == 1
            trialData.t_move_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
            Eyelink('Message', 'STIM_ON');                                 % target movement onset 
        elseif control.frameElapse == trialData.tFlash(trialNum) && eyelink.mode == 1
            trialData.t_flash_VBL(trialNum,:) = [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos]; 
            Eyelink('Message', 'FLASH_ON');                                % flash onset
        elseif control.frameElapse == trialData.tFlash(trialNum) + 1 && eyelink.mode == 1
             Eyelink('Message', 'FLASH_OFF')                                % flash offset
        end
        
        % Trial Video:
        if const.makeVideo == 1                                         % if making video, here images are taken of each frame
            imageArray(:,:,:,control.frameCounter) = Screen('GetImage',screen.window);
            control.frameCounter = control.frameCounter + 1;            % update frameCounter
        end

        %% (4.5) Data                                             
        % (a) Save Target data:                                         % target and trakstar data is initially saved in cell, gets later written in text files
%         targetInfo{iterations,:} = [num2str([eyelink.Data.time, control.eyeTarget]), char(10)];
        eyeTarget            = control.eyeTarget;
        if eyelink.mode == 1
            str = [num2str([Eyelink('TrackerTime') - trialData.tMainSync(trialNum), eyeTarget]), char(10)];
        else
            str = [num2str([GetSecs - trialData.tMainSync(trialNum), eyeTarget]), char(10)];
        end
        fwrite(control.targetFID, str);

        %% (4.6) End the trial (i.e. break while-loop; stop DPI recording)
        if control.break
            fprintf('EXP: Trial %d finished \n', trialNum);
            break;                                                      % BREAK the while loop, if trial was finished!
        end

        if PTBcheck_key_press('ESCAPE')
            fprintf('EXP: Experiment aborted by pressing esc key \n');
            control.abort = 1;
            break;                                                      % BREAK the while loop, if trial was aborted by ESC press
        end 
        
        % check forced Recalibration:
        if control.forceRecalibEL
            break;
        end

    end                                                                 % end of WITHIN-TRIAL-WHILE-loop     
   %% =================================================================

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % (5) FINISH TRIAL: 
   %     1) Save and move target file/ save trialData
   %     2) Trial Abort, 3) create video, 4) update trial counter,
   %     5) run post calibration
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
   
   %% (5.1) Stop Eyelink Recording and close files, if recalibration is forced (repeats trial) or trial finished properly:
    if control.forceRecalibEL                                               % check if Eyelink calibration was forced
        forceRecalibrationEL = 1;
        currentTargetFile    = control.targetFile;
        currentTargetFID     = control.targetFID;
        clear targetInfo                                                    % delete target & trakstar data collected before recalibration
        Eyelink('Message', 'FORCE_RECALIB_EL');                             % send Eyelink Message
    else                                                                    % if trial went OK (no forced caliobration)
        forceRecalibrationEL = 0;
        % (a) Stop Eyelink recording and close file                         % closing file should be per block in later versions
        if eyelink.mode == 1
            WaitSecs(0.01);                                                 % wait a while to record a few more samples
            Eyelink('Message', 'TRIAL_END %d', control.currentTrial);       % mark proper (!) end of trial
            Eyelink('StopRecording');

            for i = 1:numel(const.numTrialsPerBlock)
                if control.currentTrial == sum(const.numTrialsPerBlock(1:i)) % close edf file when reached the end of block
                    Eyelink('CloseFile');
                    try
                        fprintf('EXP: Receiving data file ''%s''\n', eyelink.edfFile{i});
                        status=Eyelink('ReceiveFile', eyelink.edfFile{i}, [sbj.sbjFolder], 1);
                        if status > 0
                            fprintf('EXP: ReceiveFile status %d\n', status);
                        end
                    catch rdf
                        fprintf('EXP: Problem receiving data file ''%s''\n', eyelink.edfFile{i});
                        rdf;
                    end
                    break;
                end
            end
            
        else
            for i = 1:numel(const.numTrialsPerBlock)
                if control.currentTrial == 1 || control.currentTrial == sum(const.numTrialsPerBlock(1:i)) + 1 % only open a df file 
                    fprintf('EXP: Entering Block %s\n', eyelink.edfFile{i})
                    break;
                end
            end  
        end
        
    
        %% (5.2) Save and move target file/ save trialData
        % close TARGET file and save/move file
%         for target = 1:size(targetInfo,1)
%            fwrite(control.targetFID, targetInfo{target,:});
%         end
        fclose(control.targetFID);
        movefile(control.targetFile, sbj.sbjFolder);
        fprintf('EXP: Target data is saved in %s/%s\n', sbj.sbjFolder, control.targetFile);

        % save updated trialData structure:
        save([sbj.sbjFolder, '/info.mat'], 'trialData');                    % save data in subjectFolder
    end

   %% (5.3) Experiment aborted
    if control.abort == 1
        Eyelink('CloseFile');
        fclose(control.targetFID);
        movefile(control.targetFile, [sbj.sbjFolder]);
%         fprintf('EXP: Target data is saved in .\\data\\%s\\%s\n', sbj.filename, control.targetFile);
        throw(MException('EXP: MainLoop','Experiment aborted'));
    end


    %% (5.4) Create Video, if chosen:
    if const.makeVideo == 1                                             % put the single images into a video clip:
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

    %% (5.5) Update trial counter
    trialNum = trialNum + 1;                                            % Update trial counter
end                                                                     % end of TRIAL-WHILE-loop


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (6) CLOSE EXPERIMENT: 
%     1) save trialData and other structures, 2) cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% (6.1) Save complete trialData file
Experiment.const       = const;
Experiment.eyelink     = eyelink;
Experiment.trialData   = trialData;
Experiment.sbj         = sbj;
Experiment.screen      = screen;
save([sbj.sbjFolder '/Experiment.mat'], 'Experiment');


%% (6.2) Download Eyelink Files:
% if eyelink.mode == 1
%     for i = 1:numel(const.numTrialsPerBlock)
%         try
%             fprintf('EXP: Receiving data file ''%s''\n', eyelink.edfFile{i});
%             status=Eyelink('ReceiveFile', eyelink.edfFile{i}, [sbj.sbjFolder], 1);
%             if status > 0
%                 fprintf('EXP: ReceiveFile status %d\n', status);
%             end
%         catch rdf
%             fprintf('EXP: Problem receiving data file ''%s''\n', eyelink.edfFile{i});
%             rdf;
%         end
%     end
% end

%% (6.3) End Experiment
disp('EXP: Finish experiment');
cleanup(eyelink);





%% MY ERR
catch myerr                                                                 % this "catch" section executes in case of an error in the "try" section
                                                                            % above.  Importantly, it closes the onscreen window if its open.
    fclose('all');                                                          % close any open files                                                              
    cleanup(eyelink);
    commandwindow;
    myerr;
    myerr.message
    myerr.stack.line
end                                                                         % end of try...catch
end                                                                         % end of function