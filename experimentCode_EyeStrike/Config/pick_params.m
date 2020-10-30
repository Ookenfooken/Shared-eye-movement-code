function ret = pick_params(param, N)
%% general permutation function

% create N copy of parameters that are ramdomly chosen according to the following rule:
%   -parameters are generally defined as [n x 2] matrix
%   -this is n ramdom variables of which the min-max range is defined as corresponding row vector
%   -for entire N copy, n random variable shows up with a same frequency
%   -the actual value is randomly picked from the correponding min-max range
%   -if it is a single column, it means the variables are deterministic

    ret = [];
    fNames = fieldnames(param);

    rowPick = zeros(N, numel(fNames)); % this specifies for each trial and for each parameter what row (i.e. which random varilable) will be used
    
    for i = 1:numel(fNames)
   
        p = param.(fNames{i});

        nRows = size(p,1); % number of random varilables specificed in the parameter
        nTimes = floor(N / nRows); % each random variable will be used for this times
        
        for j = 1:nRows
            if j ~= nRows
                range = ((j-1) * nTimes + 1) : (j * nTimes);
            else
                range = ((j-1) * nTimes + 1) : N;
            end
            
            rowPick(range,i) = j;
        end
    end

    % permute!
    for i = 1:size(rowPick,2)
        rowPick(:,i) = rowPick(randperm(size(rowPick,1)),i);
    end
    
    % build parameter vectors 
    for trial = 1:N
        for j = 1:numel(fNames)
            rowIndex = rowPick(trial, j);
            
            p = param.(fNames{j});
            pRange = p(rowIndex,:);
            
            if length(pRange) == 1
                ret(trial).(fNames{j}) = pRange;
            else
                ret(trial).(fNames{j}) = pRange(1) + (pRange(2) - pRange(1)) * rand();
            end
        end
    end
end