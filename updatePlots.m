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
startFrame = 1;
endFrame = length(trial.eyeX_filt); % this is all recorded eye movement data
% if the interval looking at micro-saccades differs define it here
msStart = trial.log.microSaccade.onset; 
msEnd = trial.log.microSaccade.offset;
stimOnset = trial.log.trialStart; % this may have to be changed depending on terminology
stimOffset = trial.log.trialEnd;
% range in degrees you want to plot eye position and velocity
minPosAbs = -10;
maxPosAbs = 10;
minPosX = -15;
maxPosX = 15;
minPosY = -15;
maxPosY = 15;
minVel = -150;
maxVel = 150;
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
legend('x position','y position');
plot(trial.saccades.X.onsets,trial.eyeX_filt(trial.saccades.X.onsets),'g*');
plot(trial.saccades.X.offsets,trial.eyeX_filt(trial.saccades.X.offsets),'m*');
plot(trial.saccades.Y.onsets,trial.eyeY_filt(trial.saccades.Y.onsets),'y*');
plot(trial.saccades.Y.offsets,trial.eyeY_filt(trial.saccades.Y.offsets),'c*');
% vertical lines indicate events/target onsets
line([trial.log.targetOnset trial.log.targetOnset], [minPosAbs maxPosAbs],'Color','k','LineStyle',':');
line([trial.length trial.length], [minPosAbs maxPosAbs],'Color','k','LineStyle',':');

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
plot(trial.saccades.X.onsets,trial.eyeDX_filt(trial.saccades.X.onsets),'g*');
plot(trial.saccades.X.offsets,trial.eyeDX_filt(trial.saccades.X.offsets),'m*');
plot(trial.saccades.Y.onsets,trial.eyeDY_filt(trial.saccades.Y.onsets),'y*');
plot(trial.saccades.Y.offsets,trial.eyeDY_filt(trial.saccades.Y.offsets),'c*');
% vertical lines indicate events/target onsets
line([trial.log.targetOnset trial.log.targetOnset], [minVel maxVel],'Color','k','LineStyle',':');
line([trial.length trial.length], [minVel maxVel],'Color','k','LineStyle',':');

% absolute position plot
% we will have 3 plots in the bottom row, so we need to make a subplot with
% 2 rows and 3 columns and plot in the 4th position
subplot(2,3,4,'replace');
axis([minPosX maxPosX minPosY maxPosY]);
hold on
xlabel('x-position (deg)', 'fontsize', 12);
ylabel('y-position (deg)', 'fontsize', 12);
plot eye x- versus y-position
plot(trial.eyeX_filt(stimOnset:stimOffset), trial.eyeY_filt(stimOnset:stimOffset) ,'k');
% plot point of interests
plot(ROI(:,1), ROI(:,2), 'or') % dummy

% micro-saccade position plot
subplot(2,3,5,'replace');
axis([msStart msEnd -1 1]); % we don't expect micro-saccades to be much larger than 1 deg
hold on;
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Position (degree)', 'fontsize', 12);
plot(msStart:msEnd,trial.X_noSac(msStart:msEnd),'k');
plot(msStart:msEnd,trial.Y_noSac(msStart:msEnd),'b');
legend('x position','y position');
% plot micro saccade on and offsets same color scheme as above
plot(trial.microSaccades.X.onsets,trial.eyeX_filt(trial.microSaccades.X.onsets),'g*');
plot(trial.microSaccades.X.offsets,trial.eyeX_filt(trial.microSaccades.X.offsets),'m*');
plot(trial.microSaccades.Y.onsets,trial.eyeY_filt(trial.microSaccades.Y.onsets),'y*');
plot(trial.microSaccades.Y.offsets,trial.eyeY_filt(trial.microSaccades.Y.offsets),'c*');

% micro-saccade velocity plot
subplot(2,3,6,'replace');
axis([msStart msEnd -10 10]); % we don't expect micro-saccades to be much faster than 10 deg/s
hold on;
xlabel('Time(ms)', 'fontsize', 12);
ylabel('Speed (degree/second)', 'fontsize', 12);
plot(msStart:msEnd,trial.DX_noSac(msStart:msEnd),'k');
plot(msStart:msEnd,trial.DY_noSac(msStart:msEnd),'b');
% plot micro saccade on and offsets same color scheme as above
plot(trial.microSaccades.X.onsets,trial.eyeDX_filt(trial.microSaccades.X.onsets),'g*');
plot(trial.microSaccades.X.offsets,trial.eyeDX_filt(trial.microSaccades.X.offsets),'m*');
plot(trial.microSaccades.Y.onsets,trial.eyeDY_filt(trial.microSaccades.Y.onsets),'y*');
plot(trial.microSaccades.Y.offsets,trial.eyeDY_filt(trial.microSaccades.Y.offsets),'c*');
end
