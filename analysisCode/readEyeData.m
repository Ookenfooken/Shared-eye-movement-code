% FUNCTION to read ein eye data and convert them into visual degrees
% requires pixels2degrees.m
% history
% 07-2012       JE created readEyeData.m
% 05-2014       JF edited readEyeData.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 
% input: ascFile --> current eye movement file
%        dataPath --> data path
%        currentSubject --> selected subject using selectSubject.m
%        analysisPath --> working directory
%        trialStart --> index from which you want to look at eye movements
% output: eyeData --> matrix containing eye data in pixels (eyeData.rawX/Y)
%                     and in visual degrees (eyeData.X/Y)

function [eyeData] = readEyeData(ascFile, dataPath, currentSubject, analysisPath, trialStartIdx, trialEndIdx)
    % get screen resolution from main work space
    screenResX = evalin('base', 'screenResX');
    screenResY = evalin('base', 'screenResY');
    % go into subject's data directory
    currentSubjectPath = fullfile(dataPath, currentSubject);
    cd(currentSubjectPath);
    % load eye movement file
%     allData = load(ascFile);
    load(ascFile)
    trialStartIdx = find(allData(:, 1)==trialStartIdx);
    trialEndIdx = find(allData(:, 1)==trialEndIdx);
    
    % replace blinks/signal loss (samples > 9000) with 0
    % convert to screen centred frame 
    % for eye data in X
    eyeDataX = allData(trialStartIdx:trialEndIdx,2);
    replace = eyeDataX > 9000;
    eyeDataX(replace) = 0;
    eyeDataTempX = eyeDataX-(screenResX/2);
    % and Y
    eyeDataY = allData(trialStartIdx:trialEndIdx,3);
    replace = eyeDataY > 9000;
    eyeDataY(replace) = 0;
    eyeDataTempY = (screenResY/2)-eyeDataY;
    % go back to main working directory
    cd(analysisPath);
    % convert from pixels to degrees
    eyeData = pixels2degrees(eyeDataTempX, eyeDataTempY);
    % write results into structure
    eyeData.X = eyeData.degX;
    eyeData.Y = eyeData.degY;
    
    eyeData.rawX = eyeDataX;
    eyeData.rawY = eyeDataY;
    
    eyeData.frameIdx = allData(trialStartIdx:trialEndIdx,1);
end

