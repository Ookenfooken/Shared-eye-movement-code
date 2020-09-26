% FUNCTION to plot eye data in GUI created by viewEyeData.m
% Note that this function probably needs lots of changing depending on what
% you want to look at in your analysis e.g. there is a different version
% for EyeStrike/Eyecatch
% history
% 07-2012       JE created updatePlots.m
% 2012-2018     JF added stuff to and edited updatePlots.m
% 16-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%                  (remember by now we have stored saccade information in 
%                   trial as well)
% output: this will plot in the open figure

function [] = updatePlots(trial)
% define window for which you want to plot your data
startFrame = max(1, trial.log.targetOnset-ms2frames(400));
endFrame = trial.log.trialEnd+ms2frames(600); %length(trial.eyeX_filt); % this is all recorded eye movement data
% if the interval looking at micro-saccades differs define it here
% msStart = trial.log.microSaccade.onset; 
% msEnd = trial.log.microSaccade.offset;
stimOnset = trial.log.trialStart; % this may have to be changed depending on terminology
stimOffset = trial.log.trialEnd;
% range in degrees you want to plot eye position and velocity
minPosAbs = -10;
maxPosAbs = 10;
minPosX = -25;
maxPosX = 25;
minPosY = -25;
maxPosY = 25;
minVel = -30;
maxVel = 30;
minAcc = -400;
maxAcc = 400;
minJerk = -100000;
maxJerk = 100000;
% in subplot we divide the screen into potential plotting windows; i.e.
% subplot(2,2) means that the figure is divided into a grid of 2x2 and we
% are plotting in the first position; 'replace' allows us to refresh the
% plot every time we "click through"

% eye position plot over time
subplot(2,2,1,'replace');
% define some plot parameters
axis([startFrame endFrame minPosAbs maxPosAbs]);
hold on;
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Position (degree)', 'fontsize', 12);
% plot x- and y- eye position over time
plot(startFrame:endFrame,trial.eyeX_filt(startFrame:endFrame),'k');
plot(startFrame:endFrame,trial.eyeY_filt(startFrame:endFrame),'b');
plot(trial.saccades.X_left.onsets,trial.eyeX_filt(trial.saccades.X_left.onsets),'go');
plot(trial.saccades.X_left.offsets,trial.eyeX_filt(trial.saccades.X_left.offsets),'mo');
plot(trial.saccades.X_right.onsets,trial.eyeX_filt(trial.saccades.X_right.onsets),'g*');
plot(trial.saccades.X_right.offsets,trial.eyeX_filt(trial.saccades.X_right.offsets),'m*');
plot(trial.saccades.Y.onsets,trial.eyeY_filt(trial.saccades.Y.onsets),'y*');
plot(trial.saccades.Y.offsets,trial.eyeY_filt(trial.saccades.Y.offsets),'c*');
% legend({'x pos','y pos', 'sacLeftOn', 'sacLeftOff', 'sacRightOn', 'sacRightOff', ...
%     'sacOn', 'sacOff'},'Location','NorthWest');%, 'AutoUpdate','off');
% vertical lines indicate events/target onsets
line([trial.log.fixationOff trial.log.fixationOff], [minPosAbs maxPosAbs],'Color','b','LineStyle','--');
line([trial.log.targetOnset trial.log.targetOnset], [minPosAbs maxPosAbs],'Color','k','LineStyle','--');
line([trial.stim_offset trial.stim_offset], [minPosAbs maxPosAbs],'Color','k','LineStyle','--');
if ~isempty(trial.pursuit.onset)
    line([trial.pursuit.onset trial.pursuit.onset], [minPosAbs maxPosAbs],'Color','r','LineStyle','--');
    line([trial.pursuit.onsetTrue trial.pursuit.onsetTrue], [minPosAbs maxPosAbs],'Color','r','LineStyle','-.');
end
% if ~isempty(trial.pursuit.onsetSteadyState)
%     line([trial.pursuit.onsetSteadyState trial.pursuit.onsetSteadyState], [minVel maxVel],'Color','r','LineStyle','--');
% end

% velocity plot over time
subplot(2,2,2,'replace');
axis([startFrame endFrame minVel maxVel]);
hold on;
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Speed (degree/second)', 'fontsize', 12);
% plot x- and y- eye velocity over time
plot(startFrame:endFrame,trial.eyeDX_filt(startFrame:endFrame),'k');
plot(startFrame:endFrame,trial.eyeDY_filt(startFrame:endFrame),'b');
% plot saccade onsets in x- and y with different colors
plot(trial.saccades.X_left.onsets,trial.eyeDX_filt(trial.saccades.X_left.onsets),'go');
plot(trial.saccades.X_left.offsets,trial.eyeDX_filt(trial.saccades.X_left.offsets),'mo');
plot(trial.saccades.X_right.onsets,trial.eyeDX_filt(trial.saccades.X_right.onsets),'g*');
plot(trial.saccades.X_right.offsets,trial.eyeDX_filt(trial.saccades.X_right.offsets),'m*');
plot(trial.saccades.Y.onsets,trial.eyeDY_filt(trial.saccades.Y.onsets),'y*');
plot(trial.saccades.Y.offsets,trial.eyeDY_filt(trial.saccades.Y.offsets),'c*');
% vertical lines indicate events/target onsets
line([trial.log.fixationOff trial.log.fixationOff], [minVel maxVel],'Color','k','LineStyle','--');
line([trial.log.targetOnset trial.log.targetOnset], [minVel maxVel],'Color','k','LineStyle','--');
line([trial.stim_offset-ms2frames(100) trial.stim_offset-ms2frames(100)], [minVel maxVel],'Color','b','LineStyle','--');
line([trial.stim_offset trial.stim_offset], [minVel maxVel],'Color','k','LineStyle','--');
if ~isempty(trial.pursuit.onset)
    line([trial.pursuit.onset trial.pursuit.onset], [minVel maxVel],'Color','r','LineStyle','--');
    line([trial.pursuit.onsetTrue trial.pursuit.onsetTrue], [minVel maxVel],'Color','r','LineStyle','-.');
    line([trial.pursuit.openLoopEndFrame trial.pursuit.openLoopEndFrame], [minVel maxVel],'Color','m','LineStyle','--');
end
% if ~isempty(trial.pursuit.onsetSteadyState)
%     line([trial.pursuit.onsetSteadyState trial.pursuit.onsetSteadyState], [minVel maxVel],'Color','r','LineStyle','--');
% end

% acceleration plot over time
subplot(2,2,3,'replace');
axis([startFrame endFrame minAcc maxAcc]);
hold on;
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Abs Acceleration', 'fontsize', 12);
% plot x- and y- eye acceleration over time
plot(startFrame:endFrame,trial.eyeDDX_filt(startFrame:endFrame),'k');
% plot(startFrame:endFrame,trial.eyeDDY_filt(startFrame:endFrame),'b');
% plot saccade onsets in x- and y with different colors
plot(trial.saccades.X_left.onsets,trial.eyeDDX_filt(trial.saccades.X_left.onsets),'go');
plot(trial.saccades.X_left.offsets,trial.eyeDDX_filt(trial.saccades.X_left.offsets),'mo');
plot(trial.saccades.X_right.onsets,trial.eyeDDX_filt(trial.saccades.X_right.onsets),'g*');
plot(trial.saccades.X_right.offsets,trial.eyeDDX_filt(trial.saccades.X_right.offsets),'m*');

% % absolute values
% plot(startFrame:endFrame,abs(trial.eyeDDX_filt(startFrame:endFrame)),'k');
% plot(trial.saccades.X_left.onsets,abs(trial.eyeDDX_filt(trial.saccades.X_left.onsets)),'go');
% plot(trial.saccades.X_left.offsets,abs(trial.eyeDDX_filt(trial.saccades.X_left.offsets)),'mo');
% plot(trial.saccades.X_right.onsets,abs(trial.eyeDDX_filt(trial.saccades.X_right.onsets)),'g*');
% plot(trial.saccades.X_right.offsets,abs(trial.eyeDDX_filt(trial.saccades.X_right.offsets)),'m*');

% plot(trial.saccades.Y.onsets,trial.eyeDDY_filt(trial.saccades.Y.onsets),'y*');
% plot(trial.saccades.Y.offsets,trial.eyeDDY_filt(trial.saccades.Y.offsets),'c*');
% vertical lines indicate events/target onsets
line([trial.log.fixationOff trial.log.fixationOff], [minAcc maxAcc],'Color','b','LineStyle','--');
line([trial.log.targetOnset trial.log.targetOnset], [minAcc maxAcc],'Color','k','LineStyle','--');
line([trial.stim_offset trial.stim_offset], [minAcc maxAcc],'Color','k','LineStyle','--');
if ~isempty(trial.pursuit.onset)
    line([trial.pursuit.onset trial.pursuit.onset], [minAcc maxAcc],'Color','r','LineStyle','--');
    line([trial.pursuit.onsetTrue trial.pursuit.onsetTrue], [minAcc maxAcc],'Color','r','LineStyle','-.');
    line([trial.pursuit.openLoopEndFrame trial.pursuit.openLoopEndFrame], [minAcc maxAcc],'Color','m','LineStyle','--');
end

subplot(2,2,4,'replace'); 
hold on;
% stft(trial.eyeDX_filt(startFrame:endFrame),1000,'Window',hamming(256,'periodic'),'OverlapLength',64);

% jerk plot over time
axis([startFrame endFrame minJerk maxJerk]);
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Jerk', 'fontsize', 12);
% plot x- and y- eye velocity over time
plot(startFrame:endFrame,trial.eyeDDDX(startFrame:endFrame),'k');
% plot(startFrame:endFrame,trial.eyeDDDY(startFrame:endFrame),'b');
% plot saccade onsets in x- and y with different colors
plot(trial.saccades.X_left.onsets,trial.eyeDDDX(trial.saccades.X_left.onsets),'go');
plot(trial.saccades.X_left.offsets,trial.eyeDDDX(trial.saccades.X_left.offsets),'mo');
plot(trial.saccades.X_right.onsets,trial.eyeDDDX(trial.saccades.X_right.onsets),'g*');
plot(trial.saccades.X_right.offsets,trial.eyeDDDX(trial.saccades.X_right.offsets),'m*');
% plot(trial.saccades.Y.onsets,trial.eyeDDDY(trial.saccades.Y.onsets),'y*');
% plot(trial.saccades.Y.offsets,trial.eyeDDDY(trial.saccades.Y.offsets),'c*');
% vertical lines indicate events/target onsets
line([trial.log.fixationOff trial.log.fixationOff], [minJerk maxJerk],'Color','b','LineStyle','--');
line([trial.log.targetOnset trial.log.targetOnset], [minJerk maxJerk],'Color','k','LineStyle','--');
line([trial.stim_offset trial.stim_offset], [minJerk maxJerk],'Color','k','LineStyle','--');
if ~isempty(trial.pursuit.onset)
    line([trial.pursuit.onset trial.pursuit.onset], [minJerk maxJerk],'Color','r','LineStyle','--');
    line([trial.pursuit.onsetTrue trial.pursuit.onsetTrue], [minJerk maxJerk],'Color','r','LineStyle','-.');
    line([trial.pursuit.openLoopEndFrame trial.pursuit.openLoopEndFrame], [minJerk maxJerk],'Color','m','LineStyle','--');
end

% % absolute position plot
% % we will have 3 plots in the bottom row, so we need to make a subplot with
% % 2 rows and 3 columns and plot in the 4th position
% subplot(2,2,3,'replace');
% axis([minPosX maxPosX minPosY maxPosY]);
% hold on
% xlabel('x-position (deg)', 'fontsize', 12);
% ylabel('y-position (deg)', 'fontsize', 12);
% % plot eye x- versus y-position
% plot(trial.eyeX_filt(stimOnset:stimOffset), trial.eyeY_filt(stimOnset:stimOffset) ,'k');
% % plot point of interests
% plot(ROI(:,1), ROI(:,2), 'or') % dummy

% % micro-saccade position plot
% subplot(2,3,5,'replace');
% axis([msStart msEnd -1 1]); % we don't expect micro-saccades to be much larger than 1 deg
% hold on;
% xlabel('Time(ms)', 'fontsize', 12);
% ylabel('Position (degree)', 'fontsize', 12);
% plot(msStart:msEnd,trial.X_noSac(msStart:msEnd),'k');
% plot(msStart:msEnd,trial.Y_noSac(msStart:msEnd),'b');
% legend('x position','y position');
% % plot micro saccade on and offsets same color scheme as above
% plot(trial.microSaccades.X.onsets,trial.eyeX_filt(trial.microSaccades.X.onsets),'g*');
% plot(trial.microSaccades.X.offsets,trial.eyeX_filt(trial.microSaccades.X.offsets),'m*');
% plot(trial.microSaccades.Y.onsets,trial.eyeY_filt(trial.microSaccades.Y.onsets),'y*');
% plot(trial.microSaccades.Y.offsets,trial.eyeY_filt(trial.microSaccades.Y.offsets),'c*');
% 
% % micro-saccade velocity plot
% subplot(2,3,6,'replace');
% axis([msStart msEnd -10 10]); % we don't expect micro-saccades to be much faster than 10 deg/s
% hold on;
% xlabel('Time(ms)', 'fontsize', 12);
% ylabel('Speed (degree/second)', 'fontsize', 12);
% plot(msStart:msEnd,trial.DX_noSac(msStart:msEnd),'k');
% plot(msStart:msEnd,trial.DY_noSac(msStart:msEnd),'b');
% % plot micro saccade on and offsets same color scheme as above
% plot(trial.microSaccades.X.onsets,trial.eyeDX_filt(trial.microSaccades.X.onsets),'g*');
% plot(trial.microSaccades.X.offsets,trial.eyeDX_filt(trial.microSaccades.X.offsets),'m*');
% plot(trial.microSaccades.Y.onsets,trial.eyeDY_filt(trial.microSaccades.Y.onsets),'y*');
% plot(trial.microSaccades.Y.offsets,trial.eyeDY_filt(trial.microSaccades.Y.offsets),'c*');
end
