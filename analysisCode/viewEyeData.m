%% Script to manually look at each trial of all subjects
% this script requires selectSubject.m, analyzeTrial.m, plotResults.m,
% finishButton.m, and markError.m
% always update experimental conficurations such as sampling rate distance 
% to screen etc.
% you can optionally add a function to manually adjust saccades

% history
% 07-2012       JE created viewTrialByTrial.m
% 2012-2016     JF made edits
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

%% open a new figure
% (size depends on your current screen size) 
name = 'click through eye movement data';
screenSize = get(0,'ScreenSize');
close all;
fig = figure('Position', [25 50 screenSize(3)-100, screenSize(4)-150],'Name',name);

%% Define some experimental parameters
currentTrial = 1; %chose trial you want to look at here; default = 1
c = 1; % counter
% monitor and setup specific parameters
sampleRate = 1000;
screenSizeX = 44.5;
screenSizeY = 36;
screenResX = 1280; 
screenResY = 1024;
distance = 46;
% saccade algorithm threshold --> depends on your stimulus speed and
% expected saccade size
% note that this threshold is hard-coded! If you want to test different
% values this will not update while clicking through and you will have to
% declare the variable eagain in the command window
saccadeThreshold = 50;
microSaccadeThreshold = 5;
% this is a csv files that will contain information about discarded trials
errors = load('errors.csv');

%% Subject selection
analysisPath = pwd;
% enter your data path here
dataPath = fullfile(pwd, '..','data');
currentSubjectPath = selectSubject(dataPath);

cd(currentSubjectPath);
numTrials = length(dir('*.asc'));
eyeFiles = dir('*.asc');
% load mat file containing experimental infor
load('parameters.mat');
cd(analysisPath);

sidx = strfind(currentSubjectPath, 'Subject');
currentSubject = currentSubjectPath(sidx:end);

%% run analysis for each trial and plot
analyzeTrial;
plotResults;

buttons.previous = uicontrol(fig,'string','<< Previous','Position',[0,70,100,30],...
    'callback','currentTrial = max(currentTrial-1,1);analyzeTrial;plotResults');

buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,105,100,30],...
    'callback','currentTrial = currentTrial+1;analyzeTrial;plotResults;finishButton;');

buttons.discardTrial = uicontrol(fig,'string','!Discard Trial!','Position',[0,220,100,30],...
    'callback', 'currentTrial = currentTrial;analyzeTrial;plotResults; markError');

%% OPTION ADJUST SACCADES
% we have an implementation for adjusting/manually adding saccades. for
% many experiments this won't be necessary. If you notice many undetected
% saccades even after lowering the saccade threshold you can think about
% adding this part. Requires the functions adjust.m, bselection.m, and
% changeOnset.m
% adjustedSacs={}; 
% adjust; 
% 
% buttons.previous = uicontrol(fig,'string','<< Previous','Position',[0,70,100,30],...
%     'callback','adjustedData=buttons.new.UserData;adjustedSacs{currentTrial}=adjustedData; currentTrial = max(currentTrial-1,1);analyzeTrial;plotResults;adjust');
% 
% buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,105,100,30],...
%     'callback','clc;adjustedData=buttons.new.UserData;adjustedSacs{currentTrial}=adjustedData;currentTrial = currentTrial+1;analyzeTrial;plotResults;finishButton;adjust');
% 
% buttons.discardTrial = uicontrol(fig,'string','!Discard Trial!','Position',[0,220,100,30],...
%     'callback', 'currentTrial = currentTrial;analyzeTrial;plotResults; markError');
