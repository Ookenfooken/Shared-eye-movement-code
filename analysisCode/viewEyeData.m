%% Script to manually look at each trial of all subjects
% this script requires selectSubject.m, analyzeTrial.m, plotResults.m
% always update experimental conficurations such as sampling rate distance
% to screen etc.
% you can optionally add a function to manually adjust saccades

% history
% 07-2012       JE created viewTrialByTrial.m
% 2012-2016     JF made edits
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 09/25/2020    XW edited buttons and how error file is generated, based on Janick Edinger's torsion analysis code. xiuyunwu5@gmail.com

clear all; %clc
%% open a new figure
% (size depends on your current screen size)
name = 'click through eye movement data';
screenSize = get(groot,'ScreenSize');
close all;
fig = figure('Position', [25 50 screenSize(3)-100, screenSize(4)-150],'Name',name);

%% Define some experimental parameters
currentTrial = 1;
% chose trial you want to look at here; default = 1;
c = 1; % counter
% monitor and setup specific parameters
sampleRate = 1000;
screenSizeX = 39.7;
screenSizeY = 29.5;
screenResX = 1600;
screenResY = 1200;
distance = 55;
% saccade algorithm threshold --> depends on your stimulus speed and
% expected saccade size
% note that this threshold is hard-coded! If you want to test different
% values this will not update while clicking through and you will have to
% declare the variable eagain in the command window
saccadeThreshold = 400; % acceleration

%% Subject selection
analysisPath = pwd;
% enter your data path here
cd ..
dataPath = fullfile(pwd,'data\');
cd(analysisPath);
currentSubjectPath = selectSubject(dataPath);

cd(currentSubjectPath);
load info_Experiment% load mat file containing experimental info
load eventLog % variable matrix has all the event message frame indice
% for later use in locating eye data frames
cd(analysisPath);

numTrials = length(eventLog.trialEnd);

sidx = strfind(currentSubjectPath, 'data\');
% "data\" should be the folder directly contain the sub data folder
currentSubject = currentSubjectPath(sidx+5:end);
% sidx + n, n depends on how many characters are in the string that you were finding

errorFilePath = fullfile(analysisPath,'\ErrorFiles\');
if exist(errorFilePath, 'dir') == 0
    % Make folder if it does not exist.
    mkdir(errorFilePath);
end
errorFileName = [errorFilePath 'Sub_' currentSubject '_errorFile.mat'];
try
    load(errorFileName);
    disp('Error file loaded');
catch  %#ok<CTCH>
    errorStatus = NaN(size(eventLog, 1), 1);
    disp('No error file found. Created a new one.');
end

%% run analysis for each trial and plot
analyzeTrial;
plotResults;
% finishButton.m and markError.m currently not in use
buttons.discardTrial = uicontrol(fig,'string','!Discard trial!(1) >>','Position',[0,300,100,30],...
    'callback', 'errorStatus(currentTrial, 1)=1;currentTrial = currentTrial+1;analyzeTrial;plotResults;');

buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,130,100,30],...
    'callback','errorStatus(currentTrial, 1)=0;currentTrial = currentTrial+1;analyzeTrial;plotResults;');
buttons.previous = uicontrol(fig,'string','<< Previous','Position',[0,100,100,30],...
    'callback','currentTrial = max(currentTrial-1,1);analyzeTrial;plotResults');
buttons.jumpToTrialn = uicontrol(fig,'string','Jump to trial..','Position',[0,70,100,30],...
    'callback','inputTrial = inputdlg(''Go to trial:'');currentTrial = str2num(inputTrial{:});analyzeTrial;plotResults;');

buttons.exitAndSave = uicontrol(fig,'string','Exit & Save','Position',[0,35,100,30],...
    'callback', 'close(fig);save(errorFileName,''errorStatus'');');
buttons.exit = uicontrol(fig,'string','Exit','Position',[0,5,100,30],...
    'callback','close(fig);');

assignin('base', 'buttons', buttons);
while 1
    w = waitforbuttonpress;
    if w %Key press
        figure(fig)  %focus on figure
        key = get(gcf,'CurrentKey');
        if strcmp(key,'numpad0') || strcmp(key,'0')
            errorStatus(currentTrial)=0;
            currentTrial = min(currentTrial+1,size(eventLog, 1));
            analyzeTrial;
            plotResults;
        elseif strcmp(key,'numpad1') || strcmp(key,'1')
            errorStatus(currentTrial)=1;
            currentTrial = min(currentTrial+1,size(eventLog, 1));
            analyzeTrial;
            plotResults;
%         elseif strcmp(key,'numpad2') || strcmp(key,'2')
%             errorStatus(currentTrial)=2;
%             currentTrial = min(currentTrial+1,size(eventLog, 1));
%             analyzeTrial;
%             plotResults;
%         elseif strcmp(key,'numpad3') || strcmp(key,'3')
%             errorStatus(currentTrial)=3;
%             currentTrial = min(currentTrial+1,size(eventLog, 1));
%             analyzeTrial;
%             plotResults;
        elseif strcmp(key,'backspace')
            currentTrial = max(currentTrial-1,1);
            analyzeTrial;
            plotResults;
        elseif strcmp(key,'return')
            save(errorFileName,'errorStatus');
            close(fig);
            break;
        elseif strcmp(key,'escape')
            close(fig);
            break;
        elseif strcmp(key,'f12')
            break;
        end
    end
end

%% OPTION ADJUST SACCADES
% % we have an implementation for adjusting/manually adding saccades. for
% % many experiments this won't be necessary. If you notice many undetected
% % saccades even after lowering the saccade threshold you can think about
% % adding this part. Requires the functions adjust.m, bselection.m, and
% % changeOnset.m
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
