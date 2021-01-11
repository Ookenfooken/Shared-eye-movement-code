function [] = process_findSaccades_interactive()

% integrated processEyeData and findSaccades interactive

% This function ...

% INPUT:
% NA; But user needs to make sure there is alltrial in the workspace

% OUTPUT:
% NA

% UPDATE RECORD:
% 1/6/2020 (DC): integrating

% TO-DO:


%% initialize
close all
global sampleRate analysisParams fig  ...
    alltrial currentTrial timeStart timeEnd segWidth

% default processing parameters
sampleRate = 1000;
analysisParams.sac.Vthreshold = 30;
analysisParams.sac.Athreshold = 1200;
analysisParams.sac.Jthreshold = 30000;
analysisParams.sac.stimulusSpeed = 0;
analysisParams.sac.numSuccesiveFrames = 5;
analysisParams.sac.useAcc = 0;
analysisParams.filt.filtOrder = 2;
analysisParams.filt.filtCutoffPosition = 15;
analysisParams.filt.filtCutoffVelocity = 30;
analysisParams.filt.method = 0;

% default range of data to visualize
timeStart = 0; 
segWidth = 0.5; % segment width in seconds
timeEnd = timeStart+segWidth; 
currentTrial = 1;

% load eyeData from workspace and prepare
alltrial = evalin('base', 'alltrial');

% initialize figure
fig = figure('Position', [204,90,1535,987]);
set(fig,'defaultLegendAutoUpdate','off'); 

% process and update figure
updateData;

% interactive components
% - view eyeData of other time window
buttonVertPositionStart = 50; buttPositionHeight = 30; buttonCount = 1;
buttons.saveData = uicontrol(fig,'string','Save','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback', @saveData); buttonCount = buttonCount + 1;
buttons.next = uicontrol(fig,'string','Trial >>','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;
buttons.nextSeg = uicontrol(fig,'string','Epoch >>','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;
% - the rest for scrollData
buttons.previousSeg = uicontrol(fig,'string','<< Epoch','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;
buttons.previous = uicontrol(fig,'string','<< Trial','Position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'callback',@scrollData); buttonCount = buttonCount + 1;

buttonCount = buttonCount + 1; % add empty space

% - set filtering parameters
textbox.Velocity = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtCutoffVelocity),...
    'callback',@updateVelocityCutOff); buttonCount = buttonCount + 1;
textbox.VelocityName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','filtCutoffVelocity:'); buttonCount = buttonCount + 1;
textbox.Position = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtCutoffPosition),...
    'callback',@updatePositionCutOff); buttonCount = buttonCount + 1;
textbox.PositionName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','filtCutoffPosition:'); buttonCount = buttonCount + 1;
textbox.Order = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.filt.filtOrder),...
    'callback',@updatefiltOrder); buttonCount = buttonCount + 1;
textbox.OrderName = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','filtOrder:'); buttonCount = buttonCount + 1;
textbox.Method = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
            'string',num2str(analysisParams.filt.method),...
            'callback',@updateFiltMethod); buttonCount = buttonCount + 1;

buttonCount = buttonCount + 2; % add empty space

% - set saccade detection parameters
textbox.Frames = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.numSuccesiveFrames),...
    'callback',@updateNumFrames); buttonCount = buttonCount + 1;
textbox.Frames_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','Num Frames:'); buttonCount = buttonCount + 1;
textbox.Speed = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.stimulusSpeed),...
    'callback',@updateStimSpeed); buttonCount = buttonCount + 1;
textbox.Speed_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','Stimulus Speed:'); buttonCount = buttonCount + 1;
textbox.Vthresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Vthreshold),...
    'callback',@updateVThresh); buttonCount = buttonCount + 1;
textbox.Vthresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','Velocity Threshold:'); buttonCount = buttonCount + 1;
textbox.Athresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Athreshold),...
    'callback',@updateAThresh); buttonCount = buttonCount + 1;
textbox.Athresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','Acc Thresh:'); buttonCount = buttonCount + 1;
textbox.Jthresh = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string',num2str(analysisParams.sac.Jthreshold),...
    'callback',@updateJThresh); buttonCount = buttonCount + 1;
textbox.Jthresh_Name = uicontrol(fig,'style','text','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
    'string','Jerk Thresh:'); buttonCount = buttonCount + 1;
textbox.Method2 = uicontrol(fig,'style','edit','position',[0,buttonVertPositionStart+(buttonCount-1)*(buttPositionHeight+5),100,buttPositionHeight],...
            'string',num2str(analysisParams.sac.useAcc),...
            'callback',@updateSacMethod); buttonCount = buttonCount + 1;

end

function [fig] = plotthistrial (fig, eyeData, saccades, timeStart, timeEnd)

global sampleRate

startFrame = max(1,round(timeStart*sampleRate)); endFrame = min(round(timeEnd*sampleRate),length(eyeData.X));

% do saccade check for later plots
tmpValid = [];
for tmpSac = 1:(min(length(saccades.onsets),length(saccades.offsets)))    
    if any(isnan(eyeData.X_filt(saccades.onsets(tmpSac):saccades.offsets(tmpSac)))) || ...
            any(isnan(eyeData.Y_filt(saccades.onsets(tmpSac):saccades.offsets(tmpSac))))
        continue        
    else
        tmpValid = [tmpValid tmpSac];
    end    
end

thisSac = find(saccades.onsets(tmpValid) > startFrame & saccades.onsets(tmpValid) <= endFrame); % mark saccade
tmpxdiff = eyeData.X_filt(saccades.offsets(tmpValid)) - eyeData.X_filt(saccades.onsets(tmpValid));
tmpydiff = eyeData.Y_filt(saccades.offsets(tmpValid)) - eyeData.Y_filt(saccades.onsets(tmpValid));
[tmptheta, tmprho] = cart2pol (tmpxdiff,tmpydiff);
directions = rad2deg(tmptheta);
amplitudes = tmprho;
durations = round((saccades.offsets(tmpValid) - saccades.onsets(tmpValid))/sampleRate*1000)';
saccadesXXvelocity = NaN(length(tmpValid),1);
saccadesXYvelocity = NaN(length(tmpValid),1);
for i = 1:length(tmpValid)
    saccadesXXvelocity(i) = max(abs(eyeData.DX_filt(saccades.onsets(tmpValid(i)):saccades.offsets(tmpValid(i)))));
    saccadesXYvelocity(i) = max(abs(eyeData.DY_filt(saccades.onsets(tmpValid(i)):saccades.offsets(tmpValid(i)))));
end
velocities = transpose(sqrt(saccadesXXvelocity.^2 + saccadesXYvelocity.^2));

% absolute position plot -
subplot(3,4,[1,2,5,6],'replace') %subplot(3,3,[1,4])
axis([-15 15 -15 15]); hold on
xlabel('x-position (deg)', 'fontsize', 12);
ylabel('y-position (deg)', 'fontsize', 12);
plot(eyeData.X_filt(startFrame:endFrame), eyeData.Y_filt(startFrame:endFrame), 'k');
%plot(trial.X.target_resampled(startFrame:endFrame), trial.Y.target_resampled(startFrame:endFrame), 'or', 'MarkerSize',1)
if strcmp(version('-release'),'2020b') == 1 legend({'eye data'},'Location','northeast','NumColumns',2,'fontsize', 12); end % works for later versions of Matlab

% absolute position plot
subplot(3,4,[3,4],'replace') %subplot(3,3,2)
axis([timeStart timeEnd -15 15]); hold on;
xlabel('Time(s)', 'fontsize', 12);
ylabel('Position (deg)', 'fontsize', 12);
% draw x/y trajectories
plot((startFrame:endFrame)./sampleRate,eyeData.X(startFrame:endFrame),'k:'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.X_filt(startFrame:endFrame),'k-'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.Y(startFrame:endFrame),'b:'); hold on
plot((startFrame:endFrame)./sampleRate,eyeData.Y_filt(startFrame:endFrame),'b-'); hold on
if strcmp(version('-release'),'2020b') == 1 legend({'horizontal','vertical'},'Location','northwest','NumColumns',2,'fontsize', 12); end % works for later versions of Matlab
% draw saccades
plot(saccades.X.onsets./sampleRate,eyeData.X_filt(saccades.X.onsets),'g*');
plot(saccades.X.offsets./sampleRate,eyeData.X_filt(saccades.X.offsets),'m*');
plot(saccades.Y.onsets./sampleRate,eyeData.Y_filt(saccades.Y.onsets),'y*');
plot(saccades.Y.offsets./sampleRate,eyeData.Y_filt(saccades.Y.offsets),'c*');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.X_filt(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.X_filt(saccades.offsets(tmpValid)),'ko');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.Y_filt(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.Y_filt(saccades.offsets(tmpValid)),'ko');
% draw reference lines
%line([trial.log.targetOnset trial.log.targetOnset], [-25 25],'Color','k','LineStyle',':');

%velocity plot
subplot(3,4,[7,8],'replace') %subplot(3,3,5)
axis([timeStart timeEnd -150 150]); hold on;
xlabel('Time(s)', 'fontsize', 12);
ylabel('Speed (deg/s)', 'fontsize', 12);
plot((startFrame:endFrame)./sampleRate,eyeData.DX(startFrame:endFrame),'k:'); hold on
if isfield(eyeData,'DX_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DX_filt(startFrame:endFrame),'k-'); hold on; end
plot((startFrame:endFrame)./sampleRate,eyeData.DY(startFrame:endFrame),'b:'); hold on
if isfield(eyeData,'DY_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DY_filt(startFrame:endFrame),'b-'); hold on; end
plot(saccades.X.onsets./sampleRate,eyeData.DX_filt(saccades.X.onsets),'g*');
plot(saccades.X.offsets./sampleRate,eyeData.DX_filt(saccades.X.offsets),'m*');
plot(saccades.Y.onsets./sampleRate,eyeData.DY_filt(saccades.Y.onsets),'y*');
plot(saccades.Y.offsets./sampleRate,eyeData.DY_filt(saccades.Y.offsets),'c*');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.DX_filt(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.DX_filt(saccades.offsets(tmpValid)),'ko');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.DY_filt(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.DY_filt(saccades.offsets(tmpValid)),'ko');

%acceleration plot
subplot(3,4,[11,12],'replace') %subplot(3,3,5)
axis([timeStart timeEnd -10000 10000]); hold on;
xlabel('Time(s)', 'fontsize', 12);
ylabel('Acceleration (deg/s^2)', 'fontsize', 12);
plot((startFrame:endFrame)./sampleRate,eyeData.DDX(startFrame:endFrame),'k:'); hold on
if isfield(eyeData,'DDX_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DDX_filt(startFrame:endFrame),'k-'); hold on; end
plot((startFrame:endFrame)./sampleRate,eyeData.DDY(startFrame:endFrame),'b:'); hold on
if isfield(eyeData,'DDY_filt')==1 plot((startFrame:endFrame)./sampleRate,eyeData.DDY_filt(startFrame:endFrame),'b-'); hold on; end
axis([timeStart timeEnd -1000 1000]); ylabel('Acceleration (degree/s^2)', 'fontsize', 12); xlabel('Time(s)', 'fontsize', 12);
plot(saccades.X.onsets./sampleRate,eyeData.DDX(saccades.X.onsets),'g*');
plot(saccades.X.offsets./sampleRate,eyeData.DDX(saccades.X.offsets),'m*');
plot(saccades.Y.onsets./sampleRate,eyeData.DDX(saccades.Y.onsets),'y*');
plot(saccades.Y.offsets./sampleRate,eyeData.DDY(saccades.Y.offsets),'c*');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.DDX(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.DDX(saccades.offsets(tmpValid)),'ko');
plot(saccades.onsets(tmpValid)./sampleRate,eyeData.DDY(saccades.onsets(tmpValid)),'ko');
plot(saccades.offsets(tmpValid)./sampleRate,eyeData.DDY(saccades.offsets(tmpValid)),'ko');

% quick amplitude/duration check
subplot(3,4,9,'replace')
axis([0 10 0 200]); hold on;
plot(amplitudes,durations,'ko');
if ~isempty(thisSac) plot(amplitudes(thisSac),durations(thisSac),'ro'); end
if strcmp(version('-release'),'2020b') == 1 legend({sprintf('N = %d', length(tmpValid)); sprintf('# %d ', thisSac)},'Location','northeast','NumColumns',2,'fontsize', 12); end % works for later versions of Matlab
xlabel('sac amplitude (deg)', 'fontsize', 12); ylabel ('sac duration (ms)', 'fontsize', 12);
title(sprintf('Mdn Dur = %3.f ms; Mdn Amp = %2.2f deg', nanmedian(durations), nanmedian(amplitudes)));

% quick amplitude/peak velocity check
subplot(3,4,10,'replace')
axis([0 10 0 500]); hold on;
plot(amplitudes,velocities,'ko');
if ~isempty(thisSac) plot(amplitudes(thisSac),velocities(thisSac),'ro'); end
xlabel('sac amplitude (deg)', 'fontsize', 12); ylabel ('peak velocity (deg/s)', 'fontsize', 12);
title(sprintf('Mdn Peak Vel = %3.f deg/s', nanmedian(velocities)));



end

function updateData (pushbutton, eventdata)
global fig currentTrial alltrial eyeData saccades timeStart timeEnd analysisParams sampleRate

% load the data
eyeData.X = alltrial{currentTrial}.X.eye_original';
eyeData.Y = alltrial{currentTrial}.Y.eye_original';
eyeData.X_nan = zeros(length(eyeData.X),1);
eyeData.Y_nan = zeros(length(eyeData.Y),1);

numFramesToRemove=0; %10ms; 7ms
tmpX = find(isnan(eyeData.X));
if ~isempty(tmpX)
    tmpX_diff = find(diff(tmpX) > 1);
    if isempty(tmpX_diff), tmpX_NA_ON = tmpX(1);tmpX_NA_OFF = tmpX(end); else tmpX_NA_ON = [tmpX(1) tmpX(tmpX_diff+1)']; tmpX_NA_OFF = [(tmpX(tmpX_diff))' tmpX(end)]; end
    for i=1:length(tmpX_NA_ON)
        if tmpX_NA_ON(i)-numFramesToRemove-1 < 0
            % impossible to replace data. replace with 0 for now
            eyeData.X(1:tmpX_NA_OFF(i)+numFramesToRemove) = 0;
            eyeData.X_nan(1:tmpX_NA_OFF(i)+numFramesToRemove) = 1;
        else
            tmpeye = eyeData.X(tmpX_NA_ON(i)-numFramesToRemove-1); % this is the last X position
            eyeData.X(tmpX_NA_ON(i)-numFramesToRemove:tmpX_NA_OFF(i)+numFramesToRemove) = tmpeye;
            eyeData.X_nan(tmpX_NA_ON(i)-numFramesToRemove:tmpX_NA_OFF(i)+numFramesToRemove) = 1;
        end
    end
end
tmpY = find(isnan(eyeData.Y));
if ~isempty(tmpY)
    tmpY_diff = find(diff(tmpY) > 1);
    if isempty(tmpY_diff), tmpY_NA_ON = tmpY(1);tmpY_NA_OFF = tmpY(end); else tmpY_NA_ON = [tmpY(1) tmpY(tmpY_diff+1)']; tmpY_NA_OFF = [(tmpY(tmpY_diff))' tmpY(end)]; end
    for i=1:length(tmpY_NA_ON)
        if tmpX_NA_ON(i)-numFramesToRemove-1 < 0
            % impossible to replace data. replace with 0 for now
            eyeData.Y(1:tmpY_NA_OFF(i)+numFramesToRemove) = 0;
            eyeData.X_nan(1:tmpY_NA_OFF(i)+numFramesToRemove) = 1;
        else
            tmpeye = eyeData.Y(tmpY_NA_ON(i)-numFramesToRemove-1); % this is the last X position
            eyeData.Y(tmpY_NA_ON(i)-numFramesToRemove:tmpY_NA_OFF(i)+numFramesToRemove) = tmpeye;
            eyeData.Y_nan(tmpY_NA_ON(i)-numFramesToRemove:tmpY_NA_OFF(i)+numFramesToRemove) = 1;
        end
    end
end

% process the data
eyeData = processEyeData_select(eyeData,sampleRate,analysisParams);

% replace invalid eyeData with NaN
if ~isempty(tmpX)
    for i=1:length(tmpX_NA_ON)
        thisstartFrame = max(1,tmpX_NA_ON(i)-numFramesToRemove);
        thisendFrame = min(tmpX_NA_OFF(i)+numFramesToRemove,length(eyeData.X));
        eyeData.X(thisstartFrame:thisendFrame) = NaN;
        eyeData.X_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DX(thisstartFrame:thisendFrame) = NaN;
        eyeData.DX_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDX(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDX_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDDX(thisstartFrame:thisendFrame) = NaN;
    end
end
if ~isempty(tmpY)
    for i=1:length(tmpY_NA_ON)
        thisstartFrame = max(1,tmpY_NA_ON(i)-numFramesToRemove);
        thisendFrame = min(tmpY_NA_OFF(i)+numFramesToRemove,length(eyeData.Y));
        eyeData.Y(thisstartFrame:thisendFrame) = NaN;
        eyeData.Y_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DY(thisstartFrame:thisendFrame) = NaN;
        eyeData.DY_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDY(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDY_filt(thisstartFrame:thisendFrame) = NaN;
        eyeData.DDDY(thisstartFrame:thisendFrame) = NaN;
    end
end

% detect saccades

if analysisParams.sac.useAcc == 0
    disp('using velocity');
elseif analysisParams.sac.useAcc == 1
    disp('using velocity + acceleration');
elseif analysisParams.sac.useAcc == 2 % use acceleration + jerk
    disp('using acceleration + jerk');
end
[saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades_local(1, length(eyeData.X), eyeData.DX_filt, eyeData.DDX_filt, eyeData.DDDX, analysisParams);
[saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades_local(1, length(eyeData.Y), eyeData.DY_filt, eyeData.DDY_filt, eyeData.DDDY, analysisParams);

%disp('using acceleration + jerk');
%[saccades.X.onsets, saccades.X.offsets] = findSaccadesAcc_local(1, length(eyeData.X), eyeData.DX_filt, eyeData.DDX_filt, eyeData.DDDX, analysisParams);
%[saccades.Y.onsets, saccades.Y.offsets] = findSaccadesAcc_local(1, length(eyeData.Y), eyeData.DY_filt, eyeData.DDY_filt, eyeData.DDDY, analysisParams);

% combine X and Y onsets/offsets
saccades.onsets = [saccades.X.onsets, saccades.Y.onsets];
saccades.offsets = [saccades.X.offsets, saccades.Y.offsets];
xSac = length(saccades.X.onsets);
ySac = length(saccades.Y.onsets);
if ~isempty(ySac) && ~isempty(xSac) && numel(saccades.onsets) ~= 0
    testOnsets = sort(saccades.onsets);
    testOffsets = sort(saccades.offsets);
    count1 = 1;
    tempOnset1 = [];
    tempOffset1 = [];
    count2 = 1;
    tempOnset2 = [];
    tempOffset2 = [];   
    for i = 1:length(testOnsets)-1
        if testOnsets(i+1)-testOnsets(i) < 20
            tempOnset1(count1) = testOnsets(i);
            tempOffset1(count1) = testOffsets(i);
            count1 = length(tempOnset1) +1;
        else
            tempOnset2(count2) = testOnsets(i+1);
            tempOffset2(count2) = testOffsets(i+1);
            count2 = length(tempOnset2) +1;
        end
    end
    onsets = unique([tempOnset1 tempOnset2 testOnsets(1)])';
    offsets = unique([tempOffset1 tempOffset2 testOffsets(1)])';
    saccades.onsets = onsets;
    saccades.offsets = offsets;
end

% draw eye data
[fig] = plotthistrial (fig, eyeData, saccades, timeStart, timeEnd);    

end


%% SACCADES STUFF

function [onsets, offsets, isMax] = findSaccades_local(stim_onset, stim_offset, speed, acceleration, jerk, analysisParams)

% This is work in progress - trying to combine XW's findSaccades after
% properly understanding how it works

% INPUT:
% analysisParams.sac.useAcc
% - 0: velocity (for numSuccessiveFrames); acceleration to detect
% onset/offset
% - 1: velocity and acceleration combined
% - 2: acceleration and jerk combined

% UPDATE RECORD:
% 1/5/2021 (DC): incorporate XW's findSaccades

% TO DO:
% - test on PC

%% set up
startFrame = stim_onset;
endFrame = min([stim_offset length(speed)]);

speed = speed(startFrame:endFrame);
acceleration = acceleration(startFrame:endFrame);
jerk = jerk(startFrame:endFrame);

%% speed

upperThreshold = analysisParams.sac.stimulusSpeed + analysisParams.sac.Vthreshold;
lowerThreshold = analysisParams.sac.stimulusSpeed - analysisParams.sac.Vthreshold;

%numSuccesiveFrames = 3; % can use five
middle = speed<lowerThreshold | speed>upperThreshold;
predecessor = [middle(2:end); 0]; % shift middle to one sample earlier
successor = [0; middle(1:end-1)]; % shift middle to one sample later
if analysisParams.sac.numSuccesiveFrames == 3
    relevantFrames = middle+predecessor+successor == analysisParams.sac.numSuccesiveFrames;
elseif analysisParams.sac.numSuccesiveFrames == 5
    prepredecessor = [predecessor(2:end); 0];
    sucsuccessor = [0; successor(1:end-1)];
    relevantFrames = middle+predecessor+successor+sucsuccessor+prepredecessor == analysisParams.sac.numSuccesiveFrames;
end
relevantFramesDiff = diff(relevantFrames);
relevantFramesOnsets = [relevantFramesDiff; 0]; %DC: why need the extra 0 at the end?
relevantFramesOffsets = [0; relevantFramesDiff];

speedOnsets = relevantFramesOnsets == 1;
speedOffsets = relevantFramesOffsets == -1;

speedOnsets = find(speedOnsets);
speedOffsets = find(speedOffsets);

%{
% an alternative way, needs checking
tmpValues = find(speed < lowerThreshold | speed > upperThreshold); % find speed under or above threshold
tmpIntervals = [1; find(diff(tmpValues) > 1)]; % check intervals with consecutive frames
tmpIntervals2 = [find(diff(tmpIntervals) >= analysisParams.sac.numSuccesiveFrames); length(tmpIntervals)]; % check interval length
if ~isempty(tmpIntervals2)
    speedOnsets = tmpValues(tmpIntervals(tmpIntervals2)+1);
    speedOffsets = [tmpValues(tmpIntervals(tmpIntervals2(2:end))); tmpValues(end)];
end
%}

%% acceleration
middle = acceleration/1000; %why?
predecessor = [middle(2:end); 0];
signSwitches = find((middle .* predecessor) < 0)+1;

accelerationThreshold = analysisParams.sac.Athreshold;
accelerationAbs = abs(acceleration)>accelerationThreshold;
accelerationThres = find(accelerationAbs==1); 

%% jerk
jerkThreshold = analysisParams.sac.Jthreshold;

% an alternative way, needs checking
tmpValues = find(abs(jerk)>jerkThreshold); % find jerk exceeding threshold
tmpIntervals = [1; find(diff(tmpValues) > 1)]; % check intervals with consecutive frames
tmpIntervals2 = [find(diff(tmpIntervals) >= 25); length(tmpIntervals)]; % check interval length
if ~isempty(tmpIntervals2)
    jerkOnsets = tmpValues(tmpIntervals(tmpIntervals2)+1);
end


%% find onsets and offsets
if ~isempty(signSwitches)
    
    if analysisParams.sac.useAcc == 0
        
        onsets = NaN(1,length(speedOnsets));
        offsets = NaN(1,length(speedOnsets));
        isMax = NaN(1,length(speedOnsets));
        
        for i = 1:length(speedOnsets)
            
            % saccade onset cannot happen earlier than the first acceleration sign
            % switch; saccade offset cannot happen later than the last acceleration
            % sign switch. Otherwise, skip
            if speedOnsets(i) < min(signSwitches) || speedOffsets(i) > max(signSwitches)
                continue
            end
            
            onsets(i) = max(signSwitches(signSwitches <= speedOnsets(i)));
            offsets(i) = min(signSwitches(signSwitches >= speedOffsets(i))-1); %the -1 is a subjective adjustment
            isMax(i) = speed(speedOnsets(i)) > 0;
            
        end
        
    elseif analysisParams.sac.useAcc == 1
        
        onsets = NaN(1,length(speedOnsets));
        offsets = NaN(1,length(speedOnsets));
        isMax = NaN(1,length(speedOnsets));
        
        for i = 1:length(speedOnsets)
            
            % Same as above. Additionally, check if acceleration threshold
            % is exceeded at the onset. Otherwise, skip
            
            if speedOnsets(i) < min(signSwitches) || speedOffsets(i) > max(signSwitches) || ...
                    accelerationAbs(speedOnsets(i)) == 0
                continue
            end
            
            onsets(i) = max(signSwitches(signSwitches <= speedOnsets(i)));
            offsets(i) = min(signSwitches(signSwitches >= speedOffsets(i))-1); %the -1 is a subjective adjustment
            isMax(i) = speed(speedOnsets(i)) > 0;
            
        end
        
    elseif analysisParams.sac.useAcc == 2
        
        % Use jerk to find onset
        % Following onset and prior to offset, eye acceleration was
        % required to change sign at least once
        
        % Two methods for offset according Wyatt (1998):
        % - acceleration had to fall inside the window (+/- 1200
        % deg/s2) for 12 ms samples
        % - jerk had to fall inside the window for four consecutive
        % samples
        
        % Here I use something simpler, find the acceleration
        % signSwitch closest to jerk onset + 2 (with the assumption
        % that eye acceleration had to change sign at least once)
        
        onsets = NaN(1,length(jerkOnsets));
        offsets = NaN(1,length(jerkOnsets));
        isMax = NaN(1,length(jerkOnsets));
        lastoffset = startFrame;
        
        for i = 1:length(jerkOnsets)
            
            if i > 1
                % check that this jerkOnset should be larger than last offset
                if jerkOnsets(i) < lastoffset
                    continue
                end
            end            
            
            %offsets(i) =
            %signSwitches(min(find(signSwitches>=jerkOnsets(i))) + 2); %
            %simplest method
            
            [~,closeSignSwitchLoc]=min(abs(signSwitches-jerkOnsets(i)));
            potentialoffsets = signSwitches(closeSignSwitchLoc+1):min(signSwitches(closeSignSwitchLoc+2),endFrame); % define the time window to find offset
            
            tmpA = find(diff(accelerationAbs(potentialoffsets))==1);
            tmpB = find(diff(accelerationAbs(potentialoffsets))==-1);
            
            if any((tmpB-tmpA)> 12)
                % only record onsets when offset is found
                onsets(i) = jerkOnsets(i);
                offsets(i) = potentialoffsets(tmpB((tmpB-tmpA)> 12));
                isMax(i) = speed(jerkOnsets(i)) > 0;
                lastoffset = offsets(i); % store for iteration
            end
        end        
    end    
end

%% trim to delete NaNs
onsets = onsets(~isnan(onsets))+startFrame;
offsets = offsets(~isnan(offsets))+startFrame;
isMax = isMax(~isnan(isMax));
isMax = logical(isMax);

%% make sure that saccades don't overlap. This is, find overlapping saccades and delete intermediate onset/offset
% include additional criteria for saccade, e.g., min duration; min latency
% between saccades; otherwise combine saccades
earlyOnsets = find(diff(reshape([onsets;offsets],1,[]))<0)/2+1;
previousOffsets = earlyOnsets - 1;
onsets(earlyOnsets) = [];
offsets(previousOffsets) = [];
%isMax(earlyOnsets) = [];

end

function [onsets, offsets] = findSaccadesAcc_local(stim_onset, stim_offset, speed, acceleration, jerk, analysisParams)
% FUNCTION to find saccade intervals based on acceleration criterion;
% use sign switch points in jerk to define onset and offset
% to use the function, replace findSaccades() in analyzeTrial.m
% input: stim_onset --> start of the period you want to find saccades in
%        stim_offset --> end of the period you want to find saccades in
%        speed --> eye speed
%        acceleration --> eye acceleration
%        jerk --> derivative of acceleration
%        threshold --> saccade acceleration threshold as defined in working directory
% output: onsets --> saccade onsets
%         offsets --> saccade offsetsglobal trial
% History
% 07-2020       created by Xiuyun Wu
% 10-2020       updated by XW, now using sign switch in jerk to help define
%               onsets and offsets
% for questions email xiuyunwu5@gmail.com; try plotting the acceleration
% traces to make sense of what I'm saying below...
% Note that blinks cannot be excluded using this algorithm; if you have
% blinks at the end of the trial (and you didn't exclude that trial),
% you cannot use interpol saccades as only part of the blink will be
% interpolated; need to throw the last part of the time window

% currently it might be very confusing as "peak" and "interval" may refer
% to different things under different conditions... need to organize better

% set up data
global trial
startFrame = stim_onset; % fixation onset
endFrame = stim_offset;
speed = speed(startFrame:endFrame);
acceleration = acceleration(startFrame:endFrame);
jerk = jerk(startFrame:endFrame);
% jerkThreshold = 30000; % not necessary in most cases, simply for a sanity check

% % first, separate acceleration by sign switch points (crossing zero) and get all peak
% % values (with signs to help confirm the correct pairs);
% % usually zero-crossing point would be enough:
signSwitchesAcc = find(acceleration.*[acceleration(1); acceleration(1:end-1)]<=0);
signSwitchesAcc(signSwitchesAcc==1) = [];
signSwitchesAcc(signSwitchesAcc==length(acceleration)) = [];
% indices for the time window of acceleration peak n is from binEdges(n) to binEdges(n+1)-1
binEdges = [1; signSwitchesAcc; length(acceleration)+1];

%% this part is to deal with some special conditions when defining saccade intervals based on acceleration peaks
% However, sometimes acceleration may drop to around zero but then
% increase again, not crossing zero, then two peaks could be counted as
% one; to account for this, we could find the minimum absolute
% value point within sections below a threshold (between two zero-crossing points)
% as an additional separation point of different peaks
switchPoints = abs(acceleration)<=analysisParams.sac.Athreshold; % first, find sections below a certain threshold
switchPointsDiff = diff(switchPoints);
secStart = find(switchPointsDiff==1)+1;
secEnd = find(switchPointsDiff==-1);
if ~isempty(secStart) && ~isempty(secEnd)
    % below are adjusting segment edges for special conditions (the other end of the section outside of the current window)
    if secEnd(1)<secStart(1)
        secStart = [1; secStart];
    end
    if length(secStart)>length(secEnd)
        secEnd = [secEnd; length(switchPoints)];
    end
    % then search if there are sections completely within peaks; if yes,
    % seperate that peak into two
    tempLength = length(binEdges)-1;
    for ii = 1:tempLength
        lowIdx = find(secStart>binEdges(ii) & secEnd<binEdges(ii+1)-1);
        if ~isempty(lowIdx) % the low acceleration period didn't cross zero
            minTemp(:, 1) = find(abs(acceleration(secStart(lowIdx(1)):secEnd(lowIdx(end))))==min(abs(acceleration(secStart(lowIdx(1)):secEnd(lowIdx(end))))));
            binEdges = [binEdges; secStart(lowIdx(1))+minTemp-1]; % put at the end for now
        end
    end
    binEdges = sort(binEdges); % sort into order
end
%%

% the edge of peak n is binEdge(n) to binEdge(n+1)-1
peakAccs = nan([length(binEdges)-1 1]); % value of peak accelerations, with signs
for idx = 1:length(binEdges)-1
    startI = binEdges(idx);
    endI = binEdges(idx+1)-1;
    if nanmean(acceleration(startI:endI))>0
        peakAccs(idx, 1) = max(acceleration(startI:endI));
    else
        peakAccs(idx, 1) = min(acceleration(startI:endI));
    end
    peakIdx(idx, 1) = find(abs(acceleration(startI:endI))==abs(peakAccs(idx, 1)))+startI-1;
end

largePeaks = abs(peakAccs)>analysisParams.sac.Athreshold;
successor = [0; largePeaks(1:end-1)];
relevantPeaks = (largePeaks+successor==2);

relevantPeaksDiff = diff(relevantPeaks);
onsetIntervals = find(relevantPeaksDiff==1);
offsetIntervals = find(relevantPeaksDiff==-1);
if length(offsetIntervals)<length(onsetIntervals) 
    offsetIntervals = [offsetIntervals; length(relevantPeaksDiff)]; % not ending until the end, just make the last interval the end
end
% these are index of the peak intervals, not the time frames
% if half of a saccade is at the beginning or the end, currently could
% not detect... should not be a problem, just be aware (could just make the
% findSaccade time window longer than the analysis time window)

% if two or more saccades are consecutive, count each consecutive pairs of
% acceleration peaks with opposite signs as one saccade;
% to confirm that tail peaks around saccades were not mistaken as the
% saccade's main peak, check if the peak values of the pairs are comparable
overlapIdx = find((offsetIntervals-onsetIntervals)>=3); % index of potential intervals containing multiple saccades
% if containing more than three peaks in one saccade, check if there are
% multiple saccades; one saccade should have 2 main peaks and potentially
% no more than one tail peak on each side
if ~isempty(overlapIdx)
    added = 0; % just a counter of how many new saccade intervals were added
    for ii = 1:length(overlapIdx) % loop through each intervel
        peakValues = peakAccs(onsetIntervals(overlapIdx(ii)+added):offsetIntervals(overlapIdx(ii)+added)); % within the current interval
        peakI = 1; % the counter for the ith peak we are at
        newOnsets = []; % reset for this interval
        while peakI < offsetIntervals(overlapIdx(ii)+added)-onsetIntervals(overlapIdx(ii)+added)+1 % go through each peak within the interval to find correct pairs
            % check if the current peak is a tail peak but not the main
            % peak of a saccade
            if peakValues(peakI)*peakValues(peakI+1)<0 && ...
                    max(abs([peakValues(peakI) peakValues(peakI+1)])) / min(abs([peakValues(peakI) peakValues(peakI+1)]))<2
% %                 if opposite signs and the abs values don't differ too much, likely the main peaks of a saccade
                newOnsets = [newOnsets; onsetIntervals(overlapIdx(ii)+added)+peakI-1];
                peakI=peakI+2;
            else
                peakI = peakI+1; % if likely a tail peak, just keep on
                % currently such peaks will be ignored, shouldn't matter
                % though as we will also take care of tail peaks later
            end
        end
        if isempty(newOnsets) % if still empty, likely not saccade but bad signal and weird bumps, just exclude as a whole
            newOnsets = onsetIntervals(overlapIdx(ii)+added);
            newOffsets = offsetIntervals(overlapIdx(ii)+added);
        else % add the recognized saccades, pairs of intervals
            newOffsets = newOnsets+1;
        end
        % add the new onset and offset
        onsetIntervals = [onsetIntervals(1:(overlapIdx(ii)+added-1)); newOnsets; onsetIntervals((overlapIdx(ii)+added+1):end)];
        offsetIntervals = [offsetIntervals(1:(overlapIdx(ii)+added-1)); newOffsets; offsetIntervals((overlapIdx(ii)+added+1):end)];
        added = added+length(newOnsets)-1;
    end
end


onsets = NaN(1,length(onsetIntervals)); % these are the acceleration intervals
offsets = NaN(1,length(offsetIntervals));

% then simply find sign switch points for jerk
signSwitchesJerk = find(jerk.*[jerk(1); jerk(1:end-1)]<=0);

% now loop through all marked intervals to define the saccade onset and offset
for ii = 1:length(onsets)
    % to refine the search, we start from around the peak of the acceleration values
    % but not the edge of this interval; this is mostly to avoid count in
    % the smooth part around saccades (sometimes it happens, acceleration
    % didn't change sign but only changed slope...)
%     onsetSearchPoint = binEdges(onsetIntervals(ii));
    offsetSearchPoint = binEdges(offsetIntervals(ii)+1)-1; % would not miss the last bit of a large saccade
    onsetSearchPoint = peakIdx(onsetIntervals(ii))-20; % so would not include the immediate smooth part before a saccade
%     offsetSearchPoint = peakIdx(offsetIntervals(ii))+20;

    % find the jerk swtich points around the acceleration intervals as
    % onset and offset
    onsetTmp = find(signSwitchesJerk<=onsetSearchPoint);
    if isempty(onsetTmp) % if no sigh switch point, use the bin edge of the interval
        onsets(ii) = binEdges(onsetIntervals(ii));
    else
        onsets(ii) = signSwitchesJerk(onsetTmp(end));
    end
    
    offsetTmp = find(signSwitchesJerk>=offsetSearchPoint);
    if isempty(offsetTmp)
        offsets(ii) = binEdges(offsetIntervals(ii)+1)-1;
    else
        offsets(ii) = signSwitchesJerk(offsetTmp(1));
    end
    
    % check if overlapping with the previous saccade
    if ii>1 && onsets(ii)<=offsets(ii-1)
        onsets(ii) = offsets(ii-1)+1;
    end
    % check if overlapping with the next potential saccade
    if ii<length(onsets) && offsets(ii)>=binEdges(onsetIntervals(ii+1))
        offsets(ii) = binEdges(onsetIntervals(ii+1))-1;
    end
    %     % can use jerk as a sanity check, does this interval really contain a
    %     % saccade? not necessary in most cases...
    %     if max(abs(jerk(onsets(ii):offsets(ii))))<=jerkThreshold
    %         onsets(ii) = NaN;
    %         offsets(ii) = NaN;
    %     end
end

% trim to delete NaNs
onsets = onsets(~isnan(onsets))+startFrame;
offsets = offsets(~isnan(offsets))+startFrame;

% saccades shouldn't be overlapping, but just in case
% make sure that saccades don't overlap. This is, find overlapping saccades and delete intermediate onset/offset
earlyOnsets = find(diff(reshape([onsets;offsets],1,[]))<=0)/2+1;
previousOffsets = earlyOnsets - 1;
onsets(earlyOnsets) = [];
offsets(previousOffsets) = [];
end

function updateSacMethod(src,eventdata)
global analysisParams
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
else
    analysisParams.sac.useAcc = str2num(str); % update sac detection method
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
    updateData; disp('updated Velocity threshold');     
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
    updateData; disp('updated Acceleration threshold');     
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

%% FILTERING STUFF
function [eyeData] = processEyeData_select(eyeData,sampleRate,analysisParams)

% processEyeData_select

% This function allows one to process raw position with select filtering
% parameters and method

% INPUT:
% - eyeData (.X for horizontal data; .Y for vertical data)
% - filtOrder (butterworth)
% - filtCutOffPosition (criterion for Position data filtering)
% - filtCutOffVelocity (criterion for Velocity data filtering)
% - sampleRate (data sampling rate)
% - method: 
% --- 0: butterworth filtering of position and velocity
% --- 1: butterworth filtering of position only (velocity from filtered)
% --- 2: butterworth filtering of velocity only (no position filtering)


% OUTPUT:
% - eyeData (X_filt, DX, DX_filt, DDX, DDX_filt, DDDX) - same for y

% UPDATE RECORD:
% 12/14/2020 (DC): added method 1

% TO-DO:
% - add new filtering methods + references

%%
%eyeData = rmfield(eyeData,{'X_filt','Y_filt','DX','DY','DX_filt','DY_filt','DDX','DDY','DDDX','DDDY'}); %'DDX_filt','DDY_filt',
filtFrequency = sampleRate/2;

%%
switch analysisParams.filt.method
    case 0 % in house option
        
        [a,b] = butter(analysisParams.filt.filtOrder,analysisParams.filt.filtCutoffPosition/filtFrequency);
        [c,d] = butter(analysisParams.filt.filtOrder,analysisParams.filt.filtCutoffVelocity/filtFrequency);
        
        %% position
        eyeData.X_filt = filtfilt(a,b,eyeData.X);
        eyeData.Y_filt = filtfilt(a,b,eyeData.Y);
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        DX_tmp = diff(eyeData.X_filt)*sampleRate;
        eyeData.DX_filt = filtfilt(c,d,DX_tmp);
        
        DY_tmp = diff(eyeData.Y_filt)*sampleRate;
        eyeData.DY_filt = filtfilt(c,d,DY_tmp);
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX)*sampleRate;
        eyeData.DDY = diff(eyeData.DY)*sampleRate;
        
        DDX_tmp = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDX_filt = filtfilt(c,d,DDX_tmp);
        
        DDY_tmp = diff(eyeData.DY_filt)*sampleRate;
        eyeData.DDY_filt = filtfilt(c,d,DDY_tmp);
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX_filt)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY_filt)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];
        eyeData.DDX_filt = [eyeData.DDX_filt; NaN; NaN];
        eyeData.DDY_filt = [eyeData.DDY_filt; NaN; NaN];
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
        
    case 1 % Goettker et al (2018)
        
        [a,b] = butter(analysisParams.filt.filtOrder,analysisParams.filt.filtCutoffPosition/filtFrequency);
        
        %% position
        eyeData.X_filt = filtfilt(a,b,eyeData.X);
        eyeData.Y_filt = filtfilt(a,b,eyeData.Y);
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        eyeData.DX_filt = diff(eyeData.X_filt)*sampleRate;
        eyeData.DY_filt = diff(eyeData.Y_filt)*sampleRate;
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDY = diff(eyeData.DY_filt)*sampleRate;
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];        
        eyeData.DDX_filt = [eyeData.DDX; NaN; NaN]; % save for easier use
        eyeData.DDY_filt = [eyeData.DDY; NaN; NaN]; % save for easier use
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
        
    case 2 % Kerzel et al (2010)
        
        % To identify saccades, the output of the EyeLink II eye movement
        % parser was used. The criterion used to detect saccade onset was
        % acceleration larger than 4,000°/s2 and velocity larger than 22°/s.
        % Velocity traces were filtered with a 40-Hz low-pass, zero-phase-shift
        % Butterworth filter. Saccades and four samples (16 ms) before and after
        % each saccade were removed from the velocity traces
        
        [c,d] = butter(analysisParams.filt.filtOrder,analysisParams.filt.filtCutoffVelocity/filtFrequency);
        
        %% position
        eyeData.X_filt = eyeData.X; % did not filter
        eyeData.Y_filt = eyeData.Y; % did not filter
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        DX_tmp = diff(eyeData.X_filt)*sampleRate;
        eyeData.DX_filt = filtfilt(c,d,DX_tmp);
        
        DY_tmp = diff(eyeData.Y_filt)*sampleRate;
        eyeData.DY_filt = filtfilt(c,d,DY_tmp);
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDY = diff(eyeData.DY_filt)*sampleRate;
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];
        eyeData.DDX_filt = [eyeData.DDX; NaN; NaN]; % save for easier use
        eyeData.DDY_filt = [eyeData.DDY; NaN; NaN]; % save for easier use
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
end

end

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

%%
function scrollData (pushbutton, eventdata)

global fig timeStart timeEnd segWidth...
    currentTrial alltrial eyeData saccades sampleRate

switch pushbutton.String
    
    case 'Epoch >>' %goNextSeg
        totalTime = length(alltrial{currentTrial}.X.eye_original)/sampleRate;
        timeStart = min(timeStart+segWidth, totalTime-segWidth); timeEnd = timeStart+segWidth;
        [fig] = plotthistrial (fig, eyeData, saccades, timeStart, timeEnd);
        
    case '<< Epoch' %goBeforeSeg
        timeStart = max(timeStart-segWidth, 0); timeEnd = timeStart+segWidth;
        [fig] = plotthistrial (fig, eyeData, saccades, timeStart, timeEnd);
        
    case 'Trial >>' %goNext
        currentTrial = min(currentTrial + 1, length(alltrial));
        timeStart = 0; timeEnd = timeStart+segWidth; % reset time
        updateData;
        
    case '<< Trial' %goBefore
        currentTrial = max(currentTrial - 1, 1);
        timeStart = 0; timeEnd = timeStart+segWidth; % reset time
        updateData;
end
end
