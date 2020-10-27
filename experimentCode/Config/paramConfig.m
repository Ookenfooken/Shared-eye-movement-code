function [trialData] = paramConfig(const,sbj)
% =========================================================================
% paramConfig(const,sbj)
% =========================================================================
% Function created to set up all Experimental Parameters (constants and
% randomized variables). Performs permutation for all randomized variables.
% 
% -------------------------------------------------------------------------
% Input:
% const:     structure containing different constant settings
% sbj:       structure containing subject information
% -------------------------------------------------------------------------
% Output: 
% trialData: structure containing all experimental parameters for all trials.
% -------------------------------------------------------------------------
%%
% if sbj.block == 1 && ~exist([sbj.sbjFolder ,'/info.mat'],'file')
    % (1) SET UP MEASURE VARIABLES                                              % These will be filled in during experiment
    trialData.tStartTrial        = NaN(const.numTrials, 1);
    trialData.tStartTrial2       = NaN(const.numTrials, 1);
    trialData.tDisappearMeasure  = NaN(const.numTrials, 1);                     % actual measured time that the target disappeared
    trialData.tFlashMeasure      = NaN(const.numTrials, 1);  
    trialData.tFlashPosition     = NaN(const.numTrials, 2);  
    trialData.tEndTrial          = NaN(const.numTrials, 1);                     % when it is intercepted or timed out (tStartTrial - tEndTrial) is the elapsed time
    trialData.t_start_VBL        = NaN(const.numTrials, 5);
    trialData.t_move_VBL         = NaN(const.numTrials, 5);
    trialData.t_flash_VBL        = NaN(const.numTrials, 5);
    % Sync Times Setup:
    trialData.tMainSync          = zeros(const.numTrials, 1);                   % Time (GetSecs) at trial start.



    % (2) RANDOMIZED VARIABLES
    randVar.tPreFixation         = [0.3 0.7];                                   % Intial fixation time (random between 300 and 700 ms)
    randVar.tPreFixation2        = [0.3 0.4];                                   % Second fixation time (after jump; random between 200 and 300 ms)
    randVar.tFlashRandVar        = [1:3:99]';                                      % 33
    randVar.FlashDir             = [0 1 2]';                                      % 1 = downwards flash, 2 = upwards flash (?). Corresponds to setting in runSingleTrial   
    randVar.FlashXPosRandVar     = [2 2 2]';                                    % 1 = left of center, 2 center, 3 right of center. Corresponds to setting in runSingleTrial    
    randVar.PursuitDir           = [1 2 3 4]';                                      % 1 = left -> right; 2 left <- right

    % perform randomization:
    n = 0;
    for block = 1:size(const.numTrialsPerBlock, 2)
        params(n+1:n+const.numTrialsPerBlock(block)) = pick_params(randVar, const.numTrialsPerBlock(block));
        n  = length(params);
    end

    fNames = fieldnames(params);
    for j = 1:numel(fNames)
        for i = 1:length(params)
            trialData.(fNames{j})(i) = params(i).(fNames{j});
        end
    end


    % (3) CONSTANT VARIABLES                                                    % Set some constants that are used similarly in all blocks

    % Create field in trialData for translated tFlashRandVar in Frames:
    tFlash                     = [35:1:133]';                        % this in frames (*1/85 to get in secs)

    % here you can add some generell information that are the same for all
    % trials:
    for i = 1:numel(params)
        trialData.trajDuration(i)          = 2;                                 % how long trajectory lats - shown or occluded (in sec)
        trialData.trajIdx(i)               = 1;                                 % Different target trajectories (currently just one)
        trialData.waitBetweenTrials(i)     = .5;                                 % How long to wait between trials
        trialData.tFlash(i)                = tFlash(trialData.tFlashRandVar(i));% translated tFlashRandVar into tFlash in Frames
    end

%    % (4) SAVE TRIALDATA 
%     save([sbj.sbjFolder ,'/info.mat'], 'trialData');
% else
%     load([sbj.sbjFolder ,'/info.mat']);
end

