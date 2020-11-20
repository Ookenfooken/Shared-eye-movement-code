function comb = genCombinations(allCons)
% Input:
% allCons should be a struct containing at least two variables, each being one
% vector
%
% Output:
% comb is a table containing all combinations of elements in all vectors in allCons
%
% for example, allCons.a = [0, 1], allCons.b = [2, 3] => comb = 
% a | b
% -----
% 0 | 2
% 1 | 2
% 0 | 3
% 1 | 3
%
% 10/13/2017, Xiuyun Wu; edited 11/16/2020
comb = table(); % initialize the final output table

% get the variable names from the struct
fNames = fieldnames(allCons);
variableTotalN = numel(fNames);
% put all arrays into an cell array
for variableN = 1:variableTotalN
    allCell{variableN} = allCons.(fNames{variableN});
    % make sure the arrays have consistent shapes
    allCell{variableN} = reshape(allCell{variableN}, [], 1);
end

% use ndgrid to get all grids
[outputCell{1:variableN}] = ndgrid(allCell{1:variableN});

% sort and reshape all arrays, to put them together into the table
for variableN = 1:variableTotalN
    comb.(fNames{variableN})(:, 1) = reshape(outputCell{variableN}, [], 1);
end

end