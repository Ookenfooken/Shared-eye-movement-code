%% This function is the magic script that analyzes all your eye data
% it is basically the equivalent to analyzeTrial.m; just a function so that
% we can run it automatically. same requirements as analyzeTrial.m

% history
% 07-2012       JE created analyzeTrialautomatic.m
% 2012-2018     JF added stuff to and edited analyzeTrialAutomatic.m
% 28-09-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

function [trial, pursuit] = analyzeTrialAutomatic(eyeFiles, currentTrial, currentSubject, analysisPath, dataPath, parameters)
    %% Eye Data
    %  eye data have been converted in readEDF
    %  first step: read in converted eye data
    ascFile = eyeFiles(currentTrial,1).name;
    eyeData = readEyeData(ascFile, dataPath, currentSubject, analysisPath);
    eyeData = processEyeData(eyeData); % equivalent to socscalexy

	% set up trial structure
	trial = readoutTrial(eyeData, currentTrial, currentSubject); 
    %% find saccades
	threshold = evalin('base', 'saccadeThreshold');
	[saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.eyeDX_filt, trial.eyeDDX_filt, threshold, stimulusVelocityX);
	[saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.eyeDY_filt, trial.eyeDDY_filt, threshold, stimulusVelocityY);

    %% analyze saccades
	[trial] = analyzeSaccades(trial, saccades);
	clear saccades;
    
	%% OPTIONAL: find and analyze pursuit
	% pursuit = findPursuit(trial); 
	% % remove saccades
	% trial = removeSaccades(trial);
	% % analyze pursuit
	% pursuit = analyzePursuit(trial, pursuit);

	%% OPTIONAL: find micro saccades
	% % remove saccades
	% trial = removeSaccades(trial);
	% m_threshold = evalin('base', 'microSaccadeThreshold');
	% [saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.DX_noSac, trial.DDX_noSac, m_threshold, 0);
	% [saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.DY_noSac, trial.DDY_noSac, m_threshold, 0);
	% % analyze micro-saccades
	% [trial] = analyzeMicroSaccades(trial, saccades);
end