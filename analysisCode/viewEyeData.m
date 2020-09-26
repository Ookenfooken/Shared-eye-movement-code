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
% 09/25/2020    XW edited buttons and how error file is generated, based on Janick Edinger's torsion analysis code. xiuyunwu5@gmail.com

clear all; %clc
%% open a new figure
% (size depends on your current screen size) 
name = 'click through eye movement data';
screenSize = get(0,'ScreenSize');
close all;
fig = figure('Position', [25 50 screenSize(3)-100, screenSize(4)-150],'Name',name);

%% Define some experimental parameters
currentTrial = 368; % 1 for fhF 
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
% this is a csv files that will contain information about discarded trials
% errors = load('errors.csv'); ???

%% Subject selection
analysisPath = pwd;
% enter your data path here
cd ..
cd ..
dataPath = fullfile(pwd,'data\exp1');
cd(analysisPath);
currentSubjectPath = selectSubject(dataPath);

cd(currentSubjectPath);
numTrials = length(dir('*.asc'));
% eyeFiles = dir('*.asc');
% load mat file containing experimental info
load targetPosition
% load parametersAll
% load trialLog % variable matrix has all the event message frame indice
% for later use in locating eye data frames
cd(analysisPath);

sidx = strfind(currentSubjectPath, 'data\');
currentSubject = currentSubjectPath(sidx+10:end); % exp2 +5, exp1/3+10

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
% for trialN = startTrial:height(parameters)
%     if parameters.trialType(trialN)==0
%         currentTrial = trialN;
        analyzeTrial;
        plotResults;
        
        buttons.exitAndSave = uicontrol(fig,'string','Exit & Save','Position',[0,35,100,30],...
            'callback', 'close(fig);save(errorFileName,''errorStatus'');');
        buttons.exit = uicontrol(fig,'string','Exit','Position',[0,5,100,30],...
            'callback','close(fig);');
        
%         buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,105,100,30],...
%             'callback','currentTrial = currentTrial+1;analyzeTrial;plotResults;finishButton;');
        buttons.jumpToTrialn = uicontrol(fig,'string','Jump to trial..','Position',[0,70,100,30],...
    'callback','inputTrial = inputdlg(''Go to trial:'');currentTrial = str2num(inputTrial{:});analyzeTrial;plotResults;');
        buttons.previous = uicontrol(fig,'string','<< Previous','Position',[0,100,100,30],...
            'callback','currentTrial = max(currentTrial-1,1);analyzeTrial;plotResults');
                buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,130,100,30],...
            'callback','errorStatus(currentTrial)=0;currentTrial = currentTrial+1;analyzeTrial;plotResults;');
        buttons.discardTrial = uicontrol(fig,'string','!Blink error (1) >>','Position',[0,160,100,30],...
            'callback', 'errorStatus(currentTrial)=1;currentTrial = currentTrial+1;analyzeTrial;plotResults;');
        buttons.discardTrial = uicontrol(fig,'string','!Saccade error (2) >>','Position',[0,190,100,30],...
            'callback', 'errorStatus(currentTrial)=2;currentTrial = currentTrial+1;analyzeTrial;plotResults;');
        buttons.discardTrial = uicontrol(fig,'string','!Pursuit error (3) >>','Position',[0,220,100,30],...
            'callback', 'errorStatus(currentTrial)=3;currentTrial = currentTrial+1;analyzeTrial;plotResults;');
        
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
                elseif strcmp(key,'numpad2') || strcmp(key,'2')
                    errorStatus(currentTrial)=2;
                    currentTrial = min(currentTrial+1,size(eventLog, 1));
                    analyzeTrial;
                    plotResults;
                elseif strcmp(key,'numpad3') || strcmp(key,'3')
                    errorStatus(currentTrial)=3;
                    currentTrial = min(currentTrial+1,size(eventLog, 1));
                    analyzeTrial;
                    plotResults;
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
        
%     end
    
% end
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
