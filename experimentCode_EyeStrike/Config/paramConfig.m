function [trialData] = paramConfig(const)
% =========================================================================
% paramConfig(const)
% =========================================================================
% Function created to set up all Experimental Parameters (constants and
% randomized variables). Performs permutation for all randomized variables.
% 
% -------------------------------------------------------------------------
% Input:
% -
% -------------------------------------------------------------------------
% Output: 
% trialData: structure containing all experimental parameters for all
% trials.
% -------------------------------------------------------------------------
%%

% (1) SET UP MEASURE VARIABLES                                              % These will be filled in during experiment
trialData.tStartTrial        = NaN(const.numTrials, 1);
trialData.tEndTrial          = NaN(const.numTrials, 1);                     % when it is intercepted or timed out (tStartTrial - tEndTrial) is the elapsed time
trialData.eyePosFinish       = NaN(const.numTrials, 2);                     % this is in screen coordinate
trialData.finPosFinish       = NaN(const.numTrials, 3);
trialData.targetPosFinish    = NaN(const.numTrials, 2);
trialData.bTimeOut           = NaN(const.numTrials, 1);
trialData.bTooEarly          = NaN(const.numTrials, 1);
trialData.bOutOfBound        = NaN(const.numTrials, 1);
trialData.t_fix_VBL          = NaN(const.numTrials, 5);
trialData.t_start_VBL        = NaN(const.numTrials, 5);
trialData.t_occluded_VBL     = NaN(const.numTrials, 5);
trialData.t_reappear_VBL     = NaN(const.numTrials, 5);
trialData.t_intercept_VBL    = NaN(const.numTrials, 5);
trialData.bOutOfBound        = zeros(const.numTrials, 1);
% Sync Times Setup:
trialData.tMainSync          = zeros(const.numTrials, 1);                   % Eyelink Sync: eyetracker time at start of trial
trialData.tTrakstarSync      = zeros(const.numTrials, 1);                   % Trakstar Sync Time: trakstar time at start of trial



% (2) RANDOMIZED VARIABLES

% 2.a perform trial randomization:
randVar.tPreFixation         = [0.8 1.0];                                   % Intial fixation time (random between 400 and 800 ms)
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

% 2.b Block Randomization:
blockRandVar.blockConditions  = [1 2 3]';                                   % Block Condition: 3 different conditions: 3 acceleration * 2 presentation times

blockParams = pick_params(blockRandVar, numel(const.numTrialsPerBlock));
m = 0;
for i = 1:length(blockParams)
    trialData.blockConditions(m+1:m+const.numTrialsPerBlock(i)) = repmat(blockParams(i).blockConditions,[1,12]);
    m  = length(trialData.blockConditions);
end

% 2.c Occluder: should be 8 trials the default occluder (1), and then 4
% random test occluders (2-narrow,3-wide) in trialData for each block: [1 1 1 1 1 1 1 1 2 3 2 3]

occluderRandVar.occluder  = [2 3 4 5]';
k = 0;
for block = 1:size(const.numTrialsPerBlock, 2)
    
    % for each block, set trials 1:8 to 1.
    trialData.occluder(k+1:k+8) = repmat(1,[1,8]);
    % now select randomly 4 trials with either 2 or 3
    tmp_params(1:4) = pick_params(occluderRandVar, 4);
    for i = 1:length(tmp_params)
        trialData.occluder(k+8+i) = tmp_params(i).occluder;
    end
    
    k  = length(trialData.occluder);
end



% (3) CONSTANT VARIABLES                                                    % Set some constants that are used similarly in all blocks

% here you can add some generell information that are the same for all
% trials:
for i = 1:numel(params)
    trialData.trajDuration(i)          = 2.5;                               % how long trajectory lats - shown or occluded (in sec)
    if trialData.blockConditions(i) == 1 || trialData.blockConditions(i) == 2 || trialData.blockConditions(i) == 3
        trialData.tDisappear(i)        = 0.5;                                 % How long trajectory is shown (in sec)
%     elseif trialData.blockConditions(i) == 4 || trialData.blockConditions(i) == 5 || trialData.blockConditions(i) == 6
%         trialData.tDisappear(i)        = 0.8;
    end
    
    if const.expType == 2; trialData.tDisappear(i) = 2.5; end
    trialData.waitBetweenTrials(i)     = 0.9;                               % How long to wait between trials
end


end

