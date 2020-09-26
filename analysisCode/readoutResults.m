%% Script to readout data saved by automatic pre-analysis

% history
% 2015			JF created readoutResults.m and made edits since
% 11-10-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

%% define analysis and result (data) path
analysisPath = pwd;
resultPath = fullfile(pwd, 'results'); 
allResults = dir(resultPath);
% list with flagged trials
errorList = load('errors.csv');

cd(resultPath);

%% open result fields
numResults = length(allResults)-2;
selectedResult = cell(numResults,1);
variables = [];

% this loops over all result files
for j = 3:length(allResults)
    
    selectedResult{j-2} = allResults(j).name;
    
    data = load(selectedResult{j-2} );
	% the next step is a bit redundant; if you have baseline trials you can adjust here
    block = data.analysisResults(1:end);
    numTrials = length(block);
	% define general parameters (info in file name)
    currentSubject = str2double(selectedResult{j-2}(numOn:numOff));
    subject = currentSubject*ones(numTrials,1);
	condition = str2double(selectedResult{j-2}(conOn:conOff));
    condition = condition*ones(numTrials,1);
    % initiate data driven conditions and experimental factors
    parameter1 = NaN(numTrials,1);
	% or
    parameter2 = block(1).trial.log.parameter;
    
    % now initiate eye movement variables you are interested in
    saccadeLatency = NaN(numTrials,1);
    saccadeNo = NaN(numTrials,1); % these are just dummies
    
    % flag the trials that had blinks
	% needs to be adjusted depending on your error list
    flagged = zeros(numTrials,1);
    idx = find((errorList(:,1) == currentSubject));
    flagged(errorList(idx,3)-16) = 1;
    clear idx

    for i = 1:numTrials
        % read out a few conditions e.g.
        if block(i).trial.log.parameter == 1
            parameter1(i,1) = 1;
        elseif block(i).trial.log.parameter == 2
            parameter1(i,1) = 2;
        end
        
        % eye measures
        saccadeLatency(i,1) = block(i).trial.saccades.latencies(1);
        saccadeNo(i,1) = length(block(i).trial.saccades.amplitudes);
        
    end
    
    
    currentResult = [flagged subject parameter1 parameter2 saccadeLatency saccadeNo];
    
    variables = [variables; currentResult];
    
    clear data block flagged subject parameter1 parameter2 saccadeLatency saccadeNo
end

cd(analysisPath);