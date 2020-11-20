function randomCons = pick_paramsAll(conditions, blockTrialAll)
%% general permutation function
% Input:
% conditions: a struct containing all conditions that should be randomized;
% --conditions.continuous: pick from the given range uniformly for each trial;
%   such as fixation duration
% --conditions.trial: condition in each trial, pick from the given discrete numbers
% --conditions.block: blocked condition, randomize the order, pick form the
%   given discrete numbers
% --conditions.blockPartial: blocked condition, not completely randomized,
%   but present blocks with the same conditions together; only randomize
%   the order of all combination of conditions
% blockTrialAll: const.numTrialsPerBlock; a vector containing number of
%   trials per block; each element is the trial number for one block.
% 
% Output:
% randomCons: an n x m table; each row is one trial, each column is one
%   condition, all trials for the whole experiment
%
% Here we assume that the number of trials in each block is the same; and
% the trial conditions within each block are the same. There may still be
% blocked conditions, but all conditions.trial will be the same within each
% block. If both blockPartial and block exist, "block" should be randomized
% within "blockPartial"; all blockPartial will have the same "block"
% conditions in total.
% created by Xiuyun Wu, 24/02/2020; edited 11/16/2020

trialPerBlock = blockTrialAll(1);
blockTotalN = length(blockTrialAll);
fNames = fieldnames(conditions);

% initialize 
randomCons = table;
% counters in conditions
randomCons.trialConditionIdx(:, 1) = [1:trialPerBlock*blockTotalN]';
for blockN = 1:blockTotalN
    startI = sum(blockTrialAll(1:blockN-1))+1;
    endI = sum(blockTrialAll(1:blockN));
    randomCons.blockN(startI:endI, 1) = blockN;
end
% initialize different condition groups
randomConsBlockPartial = table;
blockPartialConsTotalN = 0; % total number of block partial conditions
randomConsBlock = table;
randomConsTrial = table;

% first randomize blockPartial conditions
if ~isempty(find(strcmp(fNames, 'blockPartial')))
    % generate the combination of all blockPartial conditions
    blockPartialCons = genCombinations(conditions.blockPartial);
    
    % randomize the order
    blockPartialCons = blockPartialCons(randperm(size(blockPartialCons, 1)), :);
    blockPartialConsTotalN = size(blockPartialCons, 1);
    
    % calculate trial number within each chunk of the block partial conditions   
    if mod(blockTotalN, blockPartialConsTotalN)~=0
        error('Number of block partial conditions does not match total block numbers!');
    end
    repNumber = blockTotalN/blockPartialConsTotalN*trialPerBlock;
    
    % assign the conditions to each trial
    for conN = 1:blockPartialConsTotalN
        randomConsBlockPartial = [randomConsBlockPartial; repmat(blockPartialCons(conN, :), repNumber, 1)];
    end
end

% then randomize blocked conditions
if ~isempty(find(strcmp(fNames, 'block')))
    % generate the combination of all blockPartial conditions
    blockCons = genCombinations(conditions.block);
    
    % depends on whether there are block partial conditions, assign them
    if blockPartialConsTotalN>0
        % calculate number of repetition needed within each block partial
        % condition
        % after repmat there should be one row for each block in the specific block partial condition 
        if mod(blockTotalN/blockPartialConsTotalN, size(blockCons, 1))~=0
            error('Number of block conditions does not match block partial numbers!');
        end
        repNumber = blockTotalN/blockPartialConsTotalN/size(blockCons, 1);
        
        for ii = 1:blockPartialConsTotalN
            blockConsTemp = repmat(blockCons, repNumber, 1); % each row is the condition for one block in the specific block partial condition
            blockConsTemp = blockConsTemp(randperm(size(blockConsTemp, 1)), :); % randomize the order
            % assign to each trial in each block
            for conN = 1:size(blockConsTemp, 1)
                randomConsBlock = [randomConsBlock; repmat(blockConsTemp(conN, :), trialPerBlock, 1)];
            end
        end
    else
        % calculate number of repetition needed for the block conditions;
        % after repmat there should be one row for each block
        if mod(blockTotalN, size(blockCons, 1))~=0
            error('Number of block conditions does not match total block numbers!');
        end
        repNumber = blockTotalN/size(blockCons, 1);
        blockCons = repmat(blockCons, repNumber, 1); % each row is the condition for one block
        blockCons = blockCons(randperm(size(blockCons, 1)), :); % randomize the order
        
        % assign the conditions to each trial in each block
        for conN = 1:size(blockCons, 1)
            randomConsBlock = [randomConsBlock; repmat(blockCons(conN, :), trialPerBlock, 1)];
        end
    end
end

% lastly, randomize trials in each block
if ~isempty(find(strcmp(fNames, 'trial'))) % randomize trials within each block
    % generate the combination of all trial conditions
    trialCons = genCombinations(conditions.trial);
    
    % calculate number of repetition needed within each block
    % after repmat there should be one row for each trial in one block
    if mod(trialPerBlock, size(trialCons, 1))~=0
        error('Number of trial conditions does not match trial numbers!');
    end
    repNumber = trialPerBlock/size(trialCons, 1);
    
    for ii = 1:blockTotalN % assign trial conditions for each block
        trialConsTemp = repmat(trialCons, repNumber, 1); % each row is the condition for one block in the specific block partial condition
        trialConsTemp = trialConsTemp(randperm(size(trialConsTemp, 1)), :); % randomize the order
        randomConsTrial = [randomConsTrial; trialConsTemp];
    end
end
% for continuous randomized variables, just randomize for each trial
if ~isempty(find(strcmp(fNames, 'continuous'))) 
    fNamesContinuous = fieldnames(conditions.continuous);
    for ii = 1:numel(fNamesContinuous)
        minValue = conditions.continuous.(fNamesContinuous{ii})(1);
        maxValue = conditions.continuous.(fNamesContinuous{ii})(2);
        randomConsTrial.(fNamesContinuous{ii})(:, 1) = ...
            minValue + rand(sum(blockTrialAll), 1)*(maxValue-minValue);
    end
end

randomCons = [randomCons randomConsBlockPartial randomConsBlock randomConsTrial];