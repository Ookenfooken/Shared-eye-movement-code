function [allepochs] = analysis_interactive()

% analysis_interactive

% This function allows one to visualize the influence of filtering
% parameters / saccade detection parameters on eye data:
% - change parameters in textbox to see the change in eye trace
% - check 'HIDE' if you don't want to see these boxes

% Designed for trial-based tracking, use '<< Trial' or
% 'Trial >>' to view other trials

% Mark events using the checkboxes on the right (Discard, Blink, Saccade),
% uncheck if you want to remove markings

% At the end of clicking, press 'Save' so that data and analysisParams will
% be saved in the data directory

% INPUT:
% NA; But user needs to select sub folder when prompted

% OUTPUT:
% NA

% UPDATE RECORD:
% 03/30/2021 (DC): update and add to share github, not working yet
% 03/30/2021 (DC): implement Engbert & Mergenthaler (2006)
% 03/29/2021 (DC): V3 working

% TO-DO:
% - remove epoch
% - fix findBlinks_local
% - Experiment.screen.dpp is missing

%% initialize
close all
global sampleRate fig  timeStart timeEnd segWidth analysisParams ...
    dataPath analysisPath currentSubject currentTrial...
    eventLog blinkLog Experiment epochs epochNum viewEpoch allepochs...
    markedEvents currentSubjectPath errorFileName...
    buttons textbox checkboxes

% default filtering parameters
analysisParams.filt.filtOrder = 2;
analysisParams.filt.filtCutoffPosition = 15;
analysisParams.filt.filtCutoffVelocity = 40; % 30
analysisParams.filt.method = 2; % 0: position & velocity filtering; 1: position filtering; 2: velocity filtering

% default saccade detection parameters
analysisParams.sac.Vthreshold = 30;
analysisParams.sac.Athreshold = 1200;
analysisParams.sac.Jthreshold = 30000;
analysisParams.sac.stimulusSpeed = 0; % updated at line~304
analysisParams.sac.numSuccesiveFrames = 5;
analysisParams.sac.method = 0; % 0: velocity-based; 1: acceleration-based; 2: jerk-based; 3: Engbert
analysisParams.sac.velSD = 6; % Engbert, check value
analysisParams.sac.minDur = 6; % Engbert, check value
analysisParams.sac.mergeInt = 1; % Engbert, check value

% default blink detection parameters
analysisParams.blink.DYThreshold = 20; % velocity threshold
analysisParams.blink.TimeWindowMS = 50; % time window to find deflection of DY in ms

% default remove saccade parameters
analysisParams.noSac.method = 'linear'; % interpolation method
analysisParams.noSac.removeMS = 16; % window to remove data in ms, Kerzel(16)
analysisParams.noSac.removeExtremeGain = [-0.2 2.2]; % remove extreme gain values and interpolate

% default epoching parameters
analysisParams.epoch.windowWidthMS = [200 400]; % range of time window to epoch in ms

% default range of data to visualize and to initialize
viewEpoch = 1; % 0: show trial data; 1: show epoched data
timeStart = 0;
segWidth = 2; % segment width in seconds
timeEnd = timeStart+segWidth;
currentTrial = 1; epochNum = currentTrial;

% select data folder and load relevant information
analysisPath = pwd;
cd ..
dataPath = fullfile(pwd,'data');
cd(analysisPath);
currentSubjectPath = selectSubject(dataPath);
cd(currentSubjectPath);
load info_Experiment % experiment info
load eventLog % event info

cd(analysisPath);
sidx = strfind(currentSubjectPath, 'data');
currentSubject = currentSubjectPath(sidx+5:end);

% prepare error file
errorFilePath = fullfile(analysisPath,'ErrorFiles');
if exist(errorFilePath, 'dir') == 0
    % Make folder if it does not exist.
    mkdir(errorFilePath);
end
errorFileName = fullfile(errorFilePath,['Sub_' currentSubject '_errorFile.mat']);
try
    load(errorFileName);
    disp('Error file loaded');
catch  %#ok<CTCH>
    errorStatus = NaN(size(eventLog, 1), 1);
    disp('No error file found. Created a new one.');
end

% load blink events from edf files
% - eyelink API should be installed
% - edfmex (https://github.com/HukLab/edfmex)
% - ideally use convert2ascSynch to export blink events?
blinkLog = table(); blinkcounter = 0;
%{
for thisblock = 1:10
    clear e
    edfFile = ['\' num2str(thisblock, '%07d') '.edf']; disp(edfFile);
    e=edfmex([dataPath currentSubject edfFile],0,0,0,1,1);
    for eventNum = 1:length(e.FEVENT)
        if strcmp(convertCharsToStrings(e.FEVENT(eventNum).codestring),'ENDBLINK') == 1
            % or e.FEVENT(eventNum).type == 4
            blinkLog.onsets(blinkcounter+1) = double(e.FEVENT(eventNum).sttime);
            blinkLog.offsets(blinkcounter+1) = double(e.FEVENT(eventNum).entime);
            %blinkLog.durations(blinkcounter+1) = double(e.FEVENT(eventNum).read);
            blinkLog.blocknum(blinkcounter+1) = thisblock;
            blinkLog.eventnum(blinkcounter+1) = eventNum;
            blinkcounter = blinkcounter+1;
        end
    end
end
%}

% initialize figure
fig = figure('Position', [204,10,1535,987]);
set(fig,'defaultLegendAutoUpdate','off');

% process eye data & draw eye data
updateData;

% interactive components
% Note: putting buttons that are more often used together close to each
% other to improve clicking efficiency and reduce errors
% - view eyeData of other time window
buttonVertPositionStart = 50; buttPositionHeight = 30; buttonCount = 1;
buttons.saveData = uicontrol(fig,'string','Save','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback', @saveData); buttonCount = buttonCount + 1;
buttonCount = buttonCount + 1; % skip buttons.nextSeg
buttons.next = uicontrol(fig,'string','Trial >>','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;
% - set boxes for visual inspection
checkboxes.sacUnde = uicontrol(fig,'Style','checkbox','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight], ...
    'String','Undetected Sac','Value',markedEvents.sacUnde(currentTrial),'Callback',@markEvents); buttonCount = buttonCount + 1;
checkboxes.sac = uicontrol(fig,'Style','checkbox','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight], ...
    'String','Saccade','Value',markedEvents.sac(currentTrial),'Callback',@markEvents); buttonCount = buttonCount + 1;
checkboxes.blink = uicontrol(fig,'Style','checkbox','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight], ...
    'String','Blink','Value',markedEvents.blink(currentTrial),'Callback',@markEvents); buttonCount = buttonCount + 1;
checkboxes.discardTrial = uicontrol(fig,'Style','checkbox','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight], ...
    'String','Discard','Value',markedEvents.discardTrial(currentTrial),'Callback',@markEvents); buttonCount = buttonCount + 1;
% - the rest for scrollData
buttons.previous = uicontrol(fig,'string','<< Trial','Position',[1400,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;

buttonCount = 1; % reset
% - set filtering parameters
textbox.Velocity = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtCutoffVelocity),...
    'callback',@updateVelocityCutOff); buttonCount = buttonCount + 1;
textbox.VelocityName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','filtCutoffVelocity:'); buttonCount = buttonCount + 1;
textbox.Position = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtCutoffPosition),...
    'callback',@updatePositionCutOff); buttonCount = buttonCount + 1;
textbox.PositionName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','filtCutoffPosition:'); buttonCount = buttonCount + 1;
textbox.Order = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtOrder),...
    'callback',@updatefiltOrder); buttonCount = buttonCount + 1;
textbox.OrderName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','filtOrder:'); buttonCount = buttonCount + 1;
textbox.Method = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.method),...
    'callback',@updateFiltMethod); buttonCount = buttonCount + 1;
textbox.methodName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Filt Method:');

buttonCount = buttonCount + 2; % add empty space
% - set saccade detection parameters
textbox.Frames = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.numSuccesiveFrames),...
    'callback',@updateNumFrames); buttonCount = buttonCount + 1;
textbox.Frames_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Num Frames:'); buttonCount = buttonCount + 1;
textbox.Speed = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.stimulusSpeed),...
    'callback',@updateStimSpeed); buttonCount = buttonCount + 1;
textbox.Speed_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Stimulus Speed:'); buttonCount = buttonCount + 1;
textbox.Vthresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Vthreshold),...
    'callback',@updateVThresh); buttonCount = buttonCount + 1;
textbox.Vthresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Velocity Threshold:'); buttonCount = buttonCount + 1;
textbox.Athresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Athreshold),...
    'callback',@updateAThresh); buttonCount = buttonCount + 1;
textbox.Athresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Acc Thresh:'); buttonCount = buttonCount + 1;
textbox.Jthresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Jthreshold),...
    'callback',@updateJThresh); buttonCount = buttonCount + 1;
textbox.Jthresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Jerk Thresh:'); buttonCount = buttonCount + 1;
textbox.Method2 = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.method),...
    'callback',@updateSacMethod); buttonCount = buttonCount + 1;
textbox.methodName2 = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight-10],...
    'string','Sac Method:'); buttonCount = buttonCount + 1;

% - add toggle for appearance
checkboxes.rb3 = uicontrol(fig,'Style','checkbox','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight], ...
    'String','HIDE','Value',0,'Callback',@updateAppearance); buttonCount = buttonCount + 1;



end


%% These are functions related to the specific data
% - updateData - for processing and analysis eyeData
% - plotEyeData - allows one to visualize the processed eyeData
% - plotEpoch - allows one to visualize the processed epochs

function updateData(pushbutton, eventdata)

% updateData

% This function allows one to analyze each trial, extract epochs and plot
% similar to analyzeTrial

% INPUT:
% - eyeData, analysisParams, eventLog, Experiment (see list of global
% variables at the top)

% OUTPUT:
% - epochs, allepochs (see list of global variables at the top)
% Note: Whatever new fields created that you want to be included during
% epoching, you need to define those new fields in epochData_local

% UPDATE RECORD:
% 02/02/2021 (DC): loaded sampleRate from data
% 01/13/2021 (DC): Addded description, renamed subfunctions after
% separation

% TO-DO:
% -

%%
global eyeData fig timeStart timeEnd sampleRate analysisParams...
    currentSubject currentTrial dataPath analysisPath eventLog...
    blinkLog Experiment saccades epochs epochNum viewEpoch allepochs

% load the right trial
eyeFile = [currentSubject 't' num2str(currentTrial, '%02d') '.mat']; % mat file, eye data transformed from edf
% make sure they are included in the experiment code
eyeData = readEyeData(eyeFile, dataPath, currentSubject, currentTrial, analysisPath, eventLog, Experiment);
eyeData.eyeTime = (eyeData.timeStamp - eventLog.stimOn(currentTrial))/1000; %adjusted to stimOn in seconds

% load and incoporate sampleRate for timing-related params    
if eyeData.timeStamp(1) == eyeData.timeStamp(2) || eyeData.timeStamp(2) == eyeData.timeStamp(3)
    sampleRate = 2000;
else
    sampleRate = 1000;
end
analysisParams.sampleRate = sampleRate;
analysisParams.noSac.removeFrames = analysisParams.noSac.removeMS./1000.*sampleRate; % same as ms2frames(analysisParams.noSac.removeMS)
analysisParams.epoch.windowWidthFrames = analysisParams.epoch.windowWidthMS./1000.*sampleRate; % same as ms2frames(analysisParams.epoch.windowWidthMS)

% load timestampe of events
eyeData.events.flashcondition= eventLog.flashcondition1(currentTrial,:);
eyeData.events.soundcondition= eventLog.soundcondition1(currentTrial,:);
eyeData.events.tFlashMeasure =  Experiment.trialData.tFlashMeasure(currentTrial,:); % time (s) from stimOn
eyeData.events.targetAtFlash = Experiment.trialData.targetAtFlash(currentTrial,:,1); % x position of target at flash
eyeData.events.degtargetAtFlash = eyeData.events.targetAtFlash.*Experiment.screen.dpp;

% load target info (note that target traj is sampled at 1000Hz)
eyeData.target.stimTime = Experiment.const.INTERP_TXY{1,1}(:,1)';
eyeData.target.rawX = Experiment.const.INTERP_TXY{1,1}(:,2)';
eyeData.target.rawY = Experiment.const.INTERP_TXY{1,1}(:,3)';
eyeData.target.degX = eyeData.target.rawX.*Experiment.screen.dpp; % convert from pixels to degrees
eyeData.target.degY = eyeData.target.rawY.*Experiment.screen.dpp;
eyeData.target.DX = diff(eyeData.target.degX)*1000; % compute target velocity, note 1000
eyeData.target.DY = diff(eyeData.target.degY)*1000;
analysisParams.sac.stimulusSpeed = round(eyeData.target.DX(2)); 

% filter the data
eyeData = processEyeData_select(eyeData,analysisParams.filt.filtOrder,analysisParams.filt.filtCutoffPosition,analysisParams.filt.filtCutoffVelocity,sampleRate,analysisParams.filt.method);

% detect saccades
if analysisParams.sac.method == 0
    disp('using velocity');
elseif analysisParams.sac.method == 1
    disp('using velocity + acceleration');
elseif analysisParams.sac.method == 2 % use acceleration + jerk
    disp('using acceleration + jerk');
elseif analysisParams.sac.method == 3 % use Engbert
    disp('using Engbert & Mergenthaler (2006)');
end

if analysisParams.sac.method < 3
    [saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades_select(1, length(eyeData.X), eyeData.DX_filt, eyeData.DDX_filt, eyeData.DDDX, analysisParams);
    [saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades_select(1, length(eyeData.Y), eyeData.DY_filt, eyeData.DDY_filt, eyeData.DDDY, analysisParams);
elseif analysisParams.sac.method == 3
    [ms] = findSaccades_Engbert(eyeData, analysisParams);
    saccades.onsets = ms(:,1)'; saccades.X.onsets = saccades.onsets; saccades.Y.onsets = saccades.onsets;
    saccades.offsets = ms(:,2)'; saccades.X.offsets = saccades.offsets; saccades.Y.offsets = saccades.offsets;
    saccades.durations = ms(:,3)';
    saccades.velocities = ms(:,4)';
    saccades.amplitudes = ms(:,7)';
    saccades.directions = ms(:,8)';
end

% detect blinks if not exported from event data
[blinks.onsets] = findBlinks_local(1, length(eyeData.DY_filt), eyeData.DY_filt, analysisParams.blink.DYThreshold, analysisParams.blink.TimeWindowMS/1000*sampleRate);
eyeData.blinks.onsets = blinks.onsets;
% load timestamps of blinks, to be improved because this is off...
%eventNum = find(blinkLog.onsets >= eventLog.trialStart(currentTrial) & blinkLog.onsets < eventLog.trialEnd(currentTrial));
%eyeData.blinks.onsets = blinkLog.onsets(eventNum)' - eventLog.trialStart(currentTrial);
%eyeData.blinks.offsets = blinkLog.offsets(eventNum)' - eventLog.trialStart(currentTrial);
%eyeData.blinks.durations = blinkLog.durations(eventNum)';

% remove saccades
[eyeData, saccades] = removeSaccades_select(eyeData, saccades, analysisParams);

% compute gain (note: downsample eyeData to 1000Hz; use DX)
if sampleRate == 1000
    eyeData.DX_filt_dnsampled = eyeData.DX_filt;
    eyeData.DX_noSac_dnsampled = eyeData.DX_noSac;
    eyeData.DX_interpolSac_dnsampled = eyeData.DX_interpolSac;
elseif sampleRate == 2000
    eyeData.DX_filt_dnsampled = downsample(eyeData.DX_filt,2);
    eyeData.DX_noSac_dnsampled = downsample(eyeData.DX_noSac,2);
    eyeData.DX_interpolSac_dnsampled = downsample(eyeData.DX_interpolSac,2);
end
eyeData.DX_gain = eyeData.DX_filt_dnsampled ./ eyeData.target.DX(1:length(eyeData.DX_filt_dnsampled))';
eyeData.DX_noSac_gain = eyeData.DX_noSac_dnsampled ./ eyeData.target.DX(1:length(eyeData.DX_noSac_dnsampled))';
eyeData.DX_interpolSac_gain = eyeData.DX_interpolSac_dnsampled ./ eyeData.target.DX(1:length(eyeData.DX_interpolSac_dnsampled))';

% remove extreme gain (eye gain outside -0.2 to 2.2, re. Kerzel)
eyeData.DX_noSac_extreme_gain = eyeData.DX_noSac_gain; % gain with saccades removed
tmpLocations = find(eyeData.DX_noSac_extreme_gain < analysisParams.noSac.removeExtremeGain(1) | eyeData.DX_noSac_extreme_gain > analysisParams.noSac.removeExtremeGain(2)); % find all gain values exceeding threshold
tmpEpisodes = [find(diff(tmpLocations)>1); length(tmpLocations)]; % this marks the end of each episode
if ~isempty(tmpLocations)
    for k = 1:length(tmpEpisodes)
        % use the same method as removeSaccade to interpolate extreme values
        if k == 1 startFrame = max(tmpLocations(1),2); else startFrame = max(tmpLocations(tmpEpisodes(k-1)+1),2); end
        endFrame = min(tmpLocations(tmpEpisodes(k)),length(eyeData.DX_noSac_extreme_gain)-1);
        t = [startFrame-1 endFrame+1];
        vyg = [eyeData.DX_noSac_extreme_gain(startFrame-1) eyeData.DX_noSac_extreme_gain(endFrame+1)];
        eyeData.DX_noSac_extreme_gain(startFrame:endFrame) = interp1(t,vyg,[startFrame:endFrame],analysisParams.noSac.method);
    end
end

eyeData.DX_interpolSac_extreme_gain = eyeData.DX_interpolSac_gain; % gain with saccades interpolated
tmpLocations = find(eyeData.DX_interpolSac_extreme_gain < analysisParams.noSac.removeExtremeGain(1) | eyeData.DX_interpolSac_extreme_gain > analysisParams.noSac.removeExtremeGain(2)); % find all gain values exceeding threshold
tmpEpisodes = [find(diff(tmpLocations)>1); length(tmpLocations)]; % this marks the end of each episode
if ~isempty(tmpLocations)
    for k = 1:length(tmpEpisodes)
        % use the same method as removeSaccade to interpolate extreme values
        if k == 1 startFrame = max(tmpLocations(1),2); else startFrame = max(tmpLocations(tmpEpisodes(k-1)+1),2); end
        endFrame = min(tmpLocations(tmpEpisodes(k)),length(eyeData.DX_interpolSac_extreme_gain)-1);
        t = [startFrame-1 endFrame+1];
        vyg = [eyeData.DX_interpolSac_extreme_gain(startFrame-1) eyeData.DX_interpolSac_extreme_gain(endFrame+1)];
        eyeData.DX_interpolSac_extreme_gain(startFrame:endFrame) = interp1(t,vyg,[startFrame:endFrame],analysisParams.noSac.method);
    end
end

% epoch data
% clear epochs
[epochs] = epochData(eyeData,saccades,eventLog,currentTrial,analysisParams);

% load epochs to allepochs (across trials)
for i=1:length(epochs)
    allepochs((currentTrial-1)*Experiment.const.totalNumOfFlashes + i) = epochs(i);
end

% ready to plot
if viewEpoch == 0
    [fig] = plotEyeData (fig, eyeData, saccades, timeStart, timeEnd);
else
    [fig] = plotEpoch (fig, allepochs, epochNum);
end

end

function [fig] = plotEyeData (fig, eyeData, saccades, timeStart, timeEnd)

global sampleRate currentTrial

set(fig,'Name', sprintf('TrialNum %d; EpochNum %d; FlashCond %d; SoundCond %d', currentTrial, 1, eyeData.events.flashcondition, eyeData.events.soundcondition));

% plotParams currently harded coded here, but should be changeable and saved
plotParams.minPos = -15; plotParams.maxPos = 15;
plotParams.minVel = -50; plotParams.maxVel = 50;
plotParams.minGain = 0; plotParams.maxGain = 3;
xlabelTitle = 'Time relative to target onset (s)';

startFrame = max(1,round(timeStart*sampleRate)); endFrame = min(round(timeEnd*sampleRate),length(eyeData.X));
stimStartFrame = find(eyeData.target.stimTime == timeStart);
stimEndFrame = find(eyeData.target.stimTime == timeEnd);

sp(1) = subplot(3,2,[1,2],'replace');
plot((startFrame:endFrame)./sampleRate,eyeData.X(startFrame:endFrame),'k:'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.X_filt(startFrame:endFrame),'k-'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.Y(startFrame:endFrame),'b:'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.Y_filt(startFrame:endFrame),'b-'); hold on
axis([timeStart timeEnd plotParams.minPos plotParams.maxPos]); ylabel('Position (deg)', 'fontsize', 12);% xlabel('Time(s)', 'fontsize', 12);
if strcmp(version('-release'),'2020b') == 1 legend({'raw x data','filtered x data','raw y data','filtered y data'},'Location','northeast','NumColumns',2,'fontsize', 12); end % works for later versions of Matlab
for i = 1:length(eyeData.events.tFlashMeasure) % to be cleaned up
    plot([eyeData.events.tFlashMeasure(i) eyeData.events.tFlashMeasure(i)], [plotParams.minPos plotParams.maxPos],'r--');
    %plot([eyeData.events.soundStamps(i) eyeData.events.soundStamps(i)]./sampleRate, [-15 15],'r--');
end
plot(saccades.X.onsets./sampleRate,eyeData.X_filt(saccades.X.onsets),'g*');
plot(saccades.X.offsets./sampleRate,eyeData.X_filt(saccades.X.offsets),'m*');
plot(saccades.Y.onsets./sampleRate,eyeData.Y_filt(saccades.Y.onsets),'y*');
plot(saccades.Y.offsets./sampleRate,eyeData.Y_filt(saccades.Y.offsets),'c*');
plot(eyeData.target.stimTime(stimStartFrame:stimEndFrame), eyeData.target.degX(stimStartFrame:stimEndFrame), 'g-');

subplot(3,2,[3,4],'replace')
%plot((startFrame:endFrame)./sampleRate,eyeData.DX(startFrame:endFrame),'k:'); hold on
if isfield(eyeData,'DX_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DX_filt(startFrame:endFrame),'k-'); hold on; end
%plot((startFrame:endFrame)./sampleRate,eyeData.DY(startFrame:endFrame),'b:'); hold on
if isfield(eyeData,'DY_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DY_filt(startFrame:endFrame),'b-'); hold on; end
axis([timeStart timeEnd plotParams.minVel plotParams.maxVel]); ylabel('Speed (deg/s)', 'fontsize', 12);% xlabel('Time(s)', 'fontsize', 12);
for i = 1:length(eyeData.events.tFlashMeasure) % to be cleaned up
    plot([eyeData.events.tFlashMeasure(i) eeyeData.events.tFlashMeasure(i)], [plotParams.minVel plotParams.maxVel],'r--');
    %plot([eyeData.events.soundStamps(i) eyeData.events.soundStamps(i)]./sampleRate, [-150 150],'r--');
end
plot(saccades.X.onsets./sampleRate,eyeData.DX_filt(saccades.X.onsets),'g*');
plot(saccades.X.offsets./sampleRate,eyeData.DX_filt(saccades.X.offsets),'m*');
plot(saccades.Y.onsets./sampleRate,eyeData.DY_filt(saccades.Y.onsets),'y*');
plot(saccades.Y.offsets./sampleRate,eyeData.DY_filt(saccades.Y.offsets),'c*');
plot(eyeData.target.stimTime(stimStartFrame:stimEndFrame), eyeData.target.DX(stimStartFrame:stimEndFrame), 'g-');

subplot(3,2,[5,6],'replace')
plot(eyeData.target.stimTime(stimStartFrame:stimEndFrame), eyeData.DX_gain(stimStartFrame:stimEndFrame),'b:'); hold on
plot(eyeData.target.stimTime(stimStartFrame:stimEndFrame), eyeData.DX_interpolSac_gain(stimStartFrame:stimEndFrame),'b-'); hold on
plot(eyeData.target.stimTime(stimStartFrame:stimEndFrame), eyeData.DX_interpolSac_extreme_gain(stimStartFrame:stimEndFrame),'b-','LineWidth',2); hold on
for i = 1:length(eyeData.events.tFlashMeasure) % to be cleaned up
    plot([eyeData.events.tFlashMeasure(i) eyeData.events.tFlashMeasure(i)], [plotParams.minGain plotParams.maxGain],'r--');
    %plot([eyeData.events.soundStamps(i) eyeData.events.soundStamps(i)]./sampleRate, [-150 150],'r--');
end
plot([timeStart timeEnd], [1 1],'k:'); %unity line
axis([timeStart timeEnd plotParams.minGain plotParams.maxGain]); ylabel('Horizontal Gain (interpolSac)', 'fontsize', 12); xlabel(xlabelTitle, 'fontsize', 12);


end

function [fig] = plotEpoch (fig, epochs, epochNum)

global  analysisParams currentTrial

thisEpoch = epochs(epochNum);
set(fig,'Name', sprintf('TrialNum %d; EpochNum %d; FlashCond %d; SoundCond %d', currentTrial, epochNum, thisEpoch.events.flashcondition, thisEpoch.events.soundcondition));

% plotParams currently harded coded here, but should be changeable and saved
plotParams.xaligned = 1;
plotParams.minPos = -15; plotParams.maxPos = 15;
plotParams.minVel = -150; plotParams.maxVel = 150;
plotParams.minGain = 0; plotParams.maxGain = 3;

if plotParams.xaligned == 1
    % in real time from flashOn
    xlabelTitle = 'Time relative to flash onset (ms)';
    timeStart = - analysisParams.epoch.windowWidthMS(1);
    timeEnd = analysisParams.epoch.windowWidthMS(2);
    tFlash = 0;
else
    % in real time from stimOn
    xlabelTitle = 'Time relative to target onset (s)';
    timeStart = thisEpoch.events.tFlashMeasure - analysisParams.epoch.windowWidthMS(1)/1000;
    timeEnd = thisEpoch.events.tFlashMeasure + analysisParams.epoch.windowWidthMS(2)/1000;
    tFlash = thisEpoch.events.tFlashMeasure;
end
timeVec_eye = linspace(timeStart,timeEnd,length(thisEpoch.eyeData.X));
timeVec_eye_dn = linspace(timeStart,timeEnd,length(thisEpoch.eyeData.DX_filt_dnsampled));
timeVec_stim = linspace(timeStart,timeEnd,length(thisEpoch.target.degX));

sp(1) = subplot(3,2,[1,2],'replace');
plot(timeVec_eye,thisEpoch.eyeData.X,'k:'); hold on
plot(timeVec_eye,thisEpoch.eyeData.X_filt,'k-'); hold on
plot(timeVec_eye,thisEpoch.eyeData.Y,'b:'); hold on
plot(timeVec_eye,thisEpoch.eyeData.Y_filt,'b-'); hold on
if strcmp(version('-release'),'2020b') == 1 legend({'raw x data','filtered x data','raw y data','filtered y data'},'Location','northeast','NumColumns',2,'fontsize', 12); end % works for later versions of Matlab
plot([tFlash tFlash], [plotParams.minPos plotParams.maxPos],'r--');
plot(timeVec_eye(thisEpoch.saccades.X.onsets),thisEpoch.eyeData.X_filt(thisEpoch.saccades.X.onsets),'g*');
plot(timeVec_eye(thisEpoch.saccades.X.offsets),thisEpoch.eyeData.X_filt(thisEpoch.saccades.X.offsets),'m*');
plot(timeVec_eye(thisEpoch.saccades.Y.onsets),thisEpoch.eyeData.Y_filt(thisEpoch.saccades.Y.onsets),'y*');
plot(timeVec_eye(thisEpoch.saccades.Y.offsets),thisEpoch.eyeData.Y_filt(thisEpoch.saccades.Y.offsets),'c*');
plot(timeVec_stim, thisEpoch.target.degX, 'g-');
axis([timeStart timeEnd plotParams.minPos plotParams.maxPos]); ylabel('Position (deg)', 'fontsize', 12);% xlabel('Time(s)', 'fontsize', 12);
%{
for i = 1:length(thisEpoch.blinks.onsets) % to be cleaned up
rectCnt = timeVec_eye(thisEpoch.blinks.onsets(i)); rectDelta = 300/1000;
rectX = rectCnt + rectDelta*[0,1]; rectY = ylim([sp(1)]);
pch1 = patch(sp(1), rectX([1,2,2,1]), rectY([1 1 2 2]), 'r', ...
    'EdgeColor', 'none', 'FaceAlpha', 0.3); % FaceAlpha controls transparency
end
%}

subplot(3,2,[3,4],'replace')
plot(timeVec_eye,thisEpoch.eyeData.DX,'k:'); hold on
if isfield(thisEpoch.eyeData,'DX_filt')==1 plot(timeVec_eye,thisEpoch.eyeData.DX_filt,'k-'); hold on; end
plot(timeVec_eye,thisEpoch.eyeData.DY,'b:'); hold on
if isfield(thisEpoch.eyeData,'DY_filt')==1 plot(timeVec_eye,thisEpoch.eyeData.DY_filt,'b-'); hold on; end
plot([tFlash tFlash], [plotParams.minVel plotParams.maxVel],'r--');
plot(timeVec_eye(thisEpoch.saccades.X.onsets),thisEpoch.eyeData.DX_filt(thisEpoch.saccades.X.onsets),'g*');
plot(timeVec_eye(thisEpoch.saccades.X.offsets),thisEpoch.eyeData.DX_filt(thisEpoch.saccades.X.offsets),'m*');
plot(timeVec_eye(thisEpoch.saccades.Y.onsets),thisEpoch.eyeData.DY_filt(thisEpoch.saccades.Y.onsets),'y*');
plot(timeVec_eye(thisEpoch.saccades.Y.offsets),thisEpoch.eyeData.DY_filt(thisEpoch.saccades.Y.offsets),'c*');
plot(timeVec_stim, thisEpoch.target.DX, 'g-');
axis([timeStart timeEnd plotParams.minVel plotParams.maxVel]); ylabel('Speed (deg/second)', 'fontsize', 12);% xlabel('Time(s)', 'fontsize', 12);

subplot(3,2,[5,6],'replace')
plot(timeVec_eye_dn, thisEpoch.eyeData.DX_gain,'b:'); hold on
plot(timeVec_eye_dn, thisEpoch.eyeData.DX_interpolSac_gain,'b-'); hold on
plot(timeVec_eye_dn, thisEpoch.eyeData.DX_interpolSac_extreme_gain,'b-','LineWidth',2); hold on
plot([tFlash tFlash], [plotParams.minGain plotParams.maxGain],'r--');
plot([timeStart timeEnd], [1 1],'k:'); %unity line
axis([timeStart timeEnd plotParams.minGain plotParams.maxGain]); ylabel('Horizontal Gain (interpolSac)', 'fontsize', 12); xlabel(xlabelTitle, 'fontsize', 12);

% for checking data
%plot(timeVec_eye,thisEpoch.eyeData.DY_filt,'b:'); hold on;
%plot(timeVec_eye,thisEpoch.eyeData.DY_noSac,'b--'); hold on;
%plot(timeVec_eye,thisEpoch.eyeData.DY_interpolSac,'b-'); hold on;
%plot(timeVec_stim,thisEpoch.eyeData.DY_interpolSac_dnsampled,'r:'); hold on;

end

%% These are functions under development

function [onsets] = findBlinks_local (stim_onset, stim_offset, speed, blinkDYthreshold, blinkTthreshold)

% findBlinks_local

% This function allows one to detect blinks (using velocity-based criterion)
% vertical velocity profile: two opposite peaks, a first negative one,
% and a second positive one both exceeding 20??/s within 50 ms
% can be optimized

% INPUT:
% - stim_onset
% - stim_offset
% - eye velocity (vertical)
% - blinkDYthreshold (criterion for Position data filtering)
% - blinkTthreshold (criterion for Velocity data filtering)

% OUTPUT:
% - onsets

% UPDATE RECORD:
% 12/29/2020 (DC): created from previous codes

% TO-DO:
% - slightly off, especially when velocity filtering is altered
% - need to improve efficiency

%%
startFrame = stim_onset;
endFrame = min([stim_offset length(speed)]);
speed = speed(startFrame:endFrame);
tmpneg = find(speed < -blinkDYthreshold);

if isempty(tmpneg)
    onsets = [];
    disp(['number of blinks detected based on velocity: ' num2str(0)]);
    
elseif ~isempty(tmpneg)
    
    for i=1:length(tmpneg)
        % for each negative velocity exceeding threshold, see if velocity exceeds positive threshold in the given time
        thisstartFrame = tmpneg(i);
        thisendFrame = min(tmpneg(i)+blinkTthreshold,length(speed));
        if sum(speed(thisstartFrame:thisendFrame)> blinkDYthreshold) >= 1
            tmpblink_vel(i) = 1;
        else
            tmpblink_vel(i) = 0;
        end
    end
    
    % find non-neighboring values
    tmplocation = tmpneg(find(tmpblink_vel==1));
    tmpboundary = find(diff(tmplocation) > 1);
    if length(tmpboundary) >= 1
        tmpblink(1) = tmplocation(1);
        for loc = 1:length(tmpboundary)
            tmpblink(loc+1) = tmplocation(tmpboundary(loc)+1);
        end
        onsets = tmpblink;
        %disp(['number of blinks detected based on velocity: ' num2str(length(tmpblink))]);
    else
        onsets = [];
        %disp(['number of blinks detected based on velocity: ' num2str(0)]);
    end
end
end


%% These are functions for interactive components of the GUI
% to be improved with more efficient coding

% Filtering stuff

function updateFiltMethod(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.filt.method = str2num(str); % update sac detection method
    updateData; disp('updated filt method');
    if analysisParams.filt.method == 0
        disp('butterworth filtering of position and velocity');
    elseif analysisParams.filt.method == 1
        disp('butterworth filtering of position only (velocity from filtered)');
    elseif analysisParams.filt.method == 2
        disp('butterworth filtering of velocity only (no position filtering)');
    end
end
end

function updatePositionCutOff(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.filt.filtCutoffPosition = str2num(str); % update filtering parameter
    updateData; disp('updated PositionCutOff');
end
end

function updateVelocityCutOff(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.filt.filtCutoffVelocity = str2num(str); % update filtering parameter
    updateData; disp('updated VelocityCutOff');
end
end

function updatefiltOrder(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.filt.filtOrder = str2num(str); % update filtering parameter
    updateData; disp('updated filtOrder');
end
end

% Saccade detection stuff

function updateSacMethod(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.method = str2num(str); % update sac detection method
    updateData; disp('updated sac method');
end
end

function updateVThresh(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.Vthreshold = str2num(str); % update filtering parameter
    updateData; disp('updated Vthreshold');
end
end

function updateAThresh(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.Athreshold = str2num(str); % update filtering parameter
    updateData; disp('updated Athreshold');
end
end

function updateJThresh(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.Jthreshold = str2num(str); % update filtering parameter
    updateData; disp('updated Jerk threshold');
end
end

function updateStimSpeed(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.stimulusSpeed = str2num(str); % update filtering parameter
    updateData; disp('updated stimulusSpeed');
end
end

function updateNumFrames(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.numSuccesiveFrames = str2num(str); % update filtering parameter
    updateData; disp('updated numSuccesiveFrames');
end
end

% Scroll data

function scrollData (pushbutton, eventdata)

global fig timeStart timeEnd segWidth...
    currentTrial eyeData Experiment saccades...
    viewEpoch epochNum epochs markedEvents checkboxes

switch pushbutton.String
    
    case 'Trial >>' %goNext
        currentTrial = min(currentTrial + 1, Experiment.const.numTrials);
        timeStart = 0; timeEnd = timeStart+segWidth; % reset time
        epochNum = currentTrial;
        updateData;
        
        % update checkboxes
        set(checkboxes.sacUnde,'Value',markedEvents.sacUnde(currentTrial));
        set(checkboxes.sac,'Value',markedEvents.sac(currentTrial));
        set(checkboxes.blink,'Value',markedEvents.blink(currentTrial));
        set(checkboxes.discardTrial,'Value',markedEvents.discardTrial(currentTrial));
        
    case '<< Trial' %goBefore
        currentTrial = max(currentTrial - 1, 1);
        timeStart = 0; timeEnd = timeStart+segWidth; % reset time
        epochNum = currentTrial;
        updateData;
        
        % update checkboxes
        set(checkboxes.sacUnde,'Value',markedEvents.sacUnde(currentTrial));
        set(checkboxes.sac,'Value',markedEvents.sac(currentTrial));
        set(checkboxes.blink,'Value',markedEvents.blink(currentTrial));
        set(checkboxes.discardTrial,'Value',markedEvents.discardTrial(currentTrial));
end
end

% Hide unwanted components

function updateAppearance (checkbox, eventdata)

global textbox

val = get(checkbox,'Value');
if val == 1 % turn off interactive
    
    % to be improved with more efficient coding
    set(textbox.Velocity,'Visible','off');
    set(textbox.VelocityName,'Visible','off');
    set(textbox.Position,'Visible','off');
    set(textbox.PositionName,'Visible','off');
    set(textbox.Order,'Visible','off');
    set(textbox.OrderName,'Visible','off');
    set(textbox.Method,'Visible','off');
    set(textbox.methodName,'Visible','off');
    set(textbox.Frames,'Visible','off');
    set(textbox.Frames_Name,'Visible','off');
    set(textbox.Speed,'Visible','off');
    set(textbox.Speed_Name,'Visible','off');
    set(textbox.Vthresh,'Visible','off');
    set(textbox.Vthresh_Name,'Visible','off');
    set(textbox.Athresh,'Visible','off');
    set(textbox.Athresh_Name,'Visible','off');
    set(textbox.Jthresh,'Visible','off');
    set(textbox.Jthresh_Name,'Visible','off');
    set(textbox.Method2,'Visible','off');
    set(textbox.methodName2,'Visible','off');
    
else
    set(textbox.Velocity,'Visible','on');
    set(textbox.VelocityName,'Visible','on');
    set(textbox.Position,'Visible','on');
    set(textbox.PositionName,'Visible','on');
    set(textbox.Order,'Visible','on');
    set(textbox.OrderName,'Visible','on');
    set(textbox.Frames,'Visible','on');
    set(textbox.Frames_Name,'Visible','on');
    set(textbox.Speed,'Visible','on');
    set(textbox.Speed_Name,'Visible','on');
    set(textbox.Method,'Visible','on');
    set(textbox.methodName,'Visible','on');
    set(textbox.Vthresh,'Visible','on');
    set(textbox.Vthresh_Name,'Visible','on');
    set(textbox.Athresh,'Visible','on');
    set(textbox.Athresh_Name,'Visible','on');
    set(textbox.Jthresh,'Visible','on');
    set(textbox.Jthresh_Name,'Visible','on');
    set(textbox.Method2,'Visible','on');
    set(textbox.methodName2,'Visible','on');
    
end
end

% Mark Events

function markEvents(checkbox, eventdata)
global currentTrial epochNum markedEvents
switch checkbox.String
    case 'Discard'
        markedEvents.discardTrial(currentTrial) = 1; % for when epoch is invalid
        disp('updated discard');
    case 'Blink'
        markedEvents.blink(currentTrial) = 1; % for when a blink occurs after flash
        disp('updated blink');
    case 'Saccade'
        markedEvents.sac(currentTrial) = 1; % for when a saccade occurs during or closely before flash
        disp('updated saccade');
    case 'Undetected Sac'
        markedEvents.sacUnde(currentTrial) = 1; % for when a saccade is undetected 
        disp('updated undetected saccade');
        
end
end

%{
% this is button version
function markEvents(pushbutton, eventdata)
global currentTrial epochNum markedEvents
switch pushbutton.String
    case 'Discard'
        markedEvents.discardTrial(currentTrial, epochNum) = 1; % for when epoch is invalid
        disp('updated discard');
    case 'Blink'
        markedEvents.blink(currentTrial, epochNum) = 1; % for when a blink occurs after flash
        disp('updated blink');
    case 'Saccade'
        markedEvents.sac(currentTrial, epochNum) = 1; % for when a saccade occurs during or closely before flash
        disp('updated blink');
        
end
end
%}

% Final Save

function saveData(pushbutton, eventdata)
global currentSubjectPath allepochs analysisParams markedEvents errorFileName
cd(currentSubjectPath)
disp('saving data ...');
save('allepochs.mat','allepochs','analysisParams');
save('markedEvents.mat','markedEvents');
save(errorFileName,'markedEvents');
disp(['saved data in ' currentSubjectPath]);
end