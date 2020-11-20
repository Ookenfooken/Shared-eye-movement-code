function [trialCondition, trialData] = paramConfig(const,sbj)
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
% trialCondition: structure containing all experimental parameters for all trials.
%   should be used as a look-up table during the experiment and not be
%   changed; each row is one trial
% trialData: the actual trials presented in the experiment, being changed
%   and edited after each trial; would be different from trialCondition if
%   we repeat some trials at the end of a block (for example, too slow trials for a "fast" instruction block)
% -------------------------------------------------------------------------
%%
if sbj.block == 1 && sbj.trial==1 % ~exist([sbj.sbjFolder ,'/trialData.mat'],'file')
    rng('shuffle') % just do it once per experiment, make sure that differet people will have different randomization
    
    trialCondition = table;
    % (1) SET UP MEASURE VARIABLES                                              % These will be filled in during the experiment
% now just write into trialData directly during the experiment
%     trialCondition.tMainSync          = zeros(const.numTrials, 1);                   % Time (GetSecs) at trial start, also fixation on.
%     trialCondition.tRDKon        = NaN(const.numTrials, 1);
%     trialCondition.tRDKoff  = NaN(const.numTrials, 1);                     % actual measured time that the target appeared/disappeared
%     trialCondition.tResponse          = NaN(const.numTrials, 1);               % also the end of the trial
%     %     trialData.t_start_VBL        = NaN(const.numTrials, 5);
%     %     trialData.t_rdkOn_VBL         = NaN(const.numTrials, 5);
%     %     trialData.t_rdkOff_VBL        = NaN(const.numTrials, 5);
%     %     trialData.t_response_VBL        = NaN(const.numTrials, 5);
%     trialCondition.choice          = NaN(const.numTrials, 1); % -1=up, 1=down
    % Sync Times Setup:
    
            
    % (2) RANDOMIZED VARIABLES
    % randVar.continuous: pick from the given range uniformly for each trial; 
    %   such as fixation duration
    % randVar.trial: condition in each trial, discrete numbers
    % randVar.block: blocked condition, randomize the order of all blocks, discrete
    %   numbers
    % randVar.blockPartial: blocked condition, not completely randomized,
    %   but present blocks with the same conditions together; only randomize
    %   the order of all combination of conditions
    % If both blockPartial and block exist, "block" should be randomized
    % within "blockPartial"; all blockPartial will have the same "block"
    % conditions in total
    randVar.continuous.fixationDuration = [0.5 0.8]; % Intial fixation time (random between 300 and 700 ms)
    randVar.trial.dotDirSD = const.rdk.dotDirSD;
    randVar.trial.dotDirMean = [const.rdk.dotDirMean -const.rdk.dotDirMean]; % upwards is minus, and downwards is plus
    
    if const.startExp~=-1 % make accurate blocks first, and then fast, just so that it's easier to learn
        randVar.blockPartial.instruction = [0 1]; % 0-fast, 1-accurate;
        randVar.blockPartial.eyeCondition = [0 1]; % 0-fixation, 1-pursuit        
        % if simply want to randomly interleave all blocks,
        % comment the above lines under "if" and uncomment below
        % % ============================================================
        % randVar.block.instruction = [0 1]; % 0-fast, 1-accurate; 
        % randVar.block.eyeCondition = [0 1]; % 0-fixation, 1-pursuit
        % % ============================================================
    end

    % perform randomization:
    trialCondition = [trialCondition pick_paramsAll(randVar, const.numTrialsPerBlock)];
    
    % (3) CONSTANT VARIABLES                                                    % Set some constants that are used similarly in all blocks
    if const.startExp==-1 % simply define the condition for the practice blocks
        % first one accurate pursuit block, then one accurate fixation block, then one fast pursuit block
        accurateTrialN = sum(const.numTrialsPerBlock(1:2));
        trialCondition.instruction(1:accurateTrialN, 1) = 1; % accurate first
        trialCondition.instruction(accurateTrialN+1:end, 1) = 0;
        trialCondition.eyeCondition(:, 1) = 1; 
        trialCondition.eyeCondition(const.numTrialsPerBlock(1)+1:accurateTrialN, 1) = 0;
    end
    
    % (4) SAVE TRIALDATA
    save([sbj.sbjFolder ,'/trialCondition.mat'], 'trialCondition');
    trialData = table; % simply initialize trialData for later use
else
    load([sbj.sbjFolder ,'/trialCondition.mat']);
    load([sbj.sbjFolder ,'/trialData.mat']) % trialData will be generated and saved once the experiment started; load this as well if starting from the middle of an experiment
end

