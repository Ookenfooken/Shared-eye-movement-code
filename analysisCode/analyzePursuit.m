% FUNCTION to analyze open and closed loop pursuit when viewing moving
% stimuli; requires ms2frames.m
% history
% 07-2012       JE created analyzePursuit.m
% 2012-2018     JF added stuff to and edited analyzePursuit.m
% 14-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%        pursuit --> structure containing pursuit onset
% output: pursuit --> structure containing relevant all open and closed
%                     loop pursuit measures

function [trial] = analyzePursuit(trial, pursuit)

trial.pursuit = [];
if pursuit.onset >= trial.saccades.onsets(1)
    trial.pursuit.onset = trial.saccades.offsets(1)+1;
else
    trial.pursuit.onset = pursuit.onset;
end
% define the window you want to analyze pursuit in
openLoopLength = 140;
openLoopDuration = ms2frames(openLoopLength);
pursuitOff = trial.target.offset; % may want to adjust if target has already disappeard 
% analyze open-loop phase first
startFrame = nanmin([trial.target.onset trial.pursuit.onset]); % if there is no pursuit onset we still want to analyze eye. movement quaility 
endFrame = nanmin([(startFrame+openLoopDuration) trial.saccades.allOnsets(1)]);
% If subjects were fixating in the beginning (saccadeType = 2) or if purusit onset
% was inside a saccade (saccadeType = -2) there is no open loop values
% first analyze initial pursuit in X
meanVelocityX = trial.DX_noSac(startFrame:endFrame);
remove = isnan(meanVelocityX);
meanVelocityX(remove) = [];
pursuit.initialMeanVelocity.X = mean(abs(meanVelocityX));
if length(meanVelocityX) < ms2frames(40) % if open loop pursuit is less than 40 ms before catch up saccde pursuit was not truely initiated
    pursuit.initialMeanVelocity.X = NaN;
end
peakVelocityX = trial.DX_noSac(startFrame:endFrame);
remove = isnan(peakVelocityX);
peakVelocityX(remove) = [];
pursuit.initialPeakVelocity.X = max(abs(peakVelocityX));
if length(peakVelocityX) < ms2frames(40)
    pursuit.initialPeakVelocity.X = NaN;
end
meanAccelerationX = trial.eye.DDX_filt(startFrame:endFrame);
remove = isnan(meanAccelerationX);
meanAccelerationX(remove) = [];
pursuit.initialMeanAcceleration.X = mean(abs(meanAccelerationX));
if length(meanAccelerationX) < ms2frames(40)
    pursuit.initialMeanAcceleration.X = NaN;
end

peakAccelerationX = trial.eye.DDX_filt(startFrame:endFrame);
remove = isnan(peakAccelerationX);
peakAccelerationX(remove) = [];
pursuit.initialPeakAcceleration.X = max(abs(peakAccelerationX));
if length(peakAccelerationX) < ms2frames(40)
    pursuit.initialPeakAcceleration.X = NaN;
end
% next analyze initial pursuit in y
meanVelocityY = trial.DY_noSac(startFrame:endFrame);
remove = isnan(meanVelocityY);
meanVelocityY(remove) = [];
pursuit.initialMeanVelocity.Y = mean(abs(meanVelocityY));
if length(meanVelocityY) < 40
    pursuit.initialMeanAcceleration.Y = NaN;
end
peakVelocityY = trial.DY_noSac(startFrame:endFrame);
remove = isnan(peakVelocityY);
peakVelocityY(remove) = [];
pursuit.initialPeakVelocity.Y = max(abs(peakVelocityY));
if length(peakVelocityY) < 40
    pursuit.initialPeakVelocity.Y = NaN;
end
meanAccelerationY = trial.eye.DDY_filt(startFrame:endFrame);
remove = isnan(meanAccelerationY);
meanAccelerationY(remove) = [];
pursuit.initialMeanAcceleration.Y = mean(abs(meanAccelerationY));
if length(meanAccelerationY) < 40
    pursuit.initialMeanAcceleration.Y = NaN;
end
peakAccelerationY = trial.eye.DDY_filt(startFrame:endFrame);
remove = isnan(peakAccelerationY);
peakAccelerationY(remove) = [];
pursuit.initialPeakAcceleration.Y = max(abs(peakAccelerationY));
if length(peakAccelerationY) < 40
    pursuit.initialPeakAcceleration.Y = NaN;
end
% combine x and y
if isempty(pursuit.initialMeanVelocity.X) || isempty(pursuit.initialMeanVelocity.Y)
    pursuit.initialMeanVelocity = NaN;
else
    pursuit.initialMeanVelocity = nanmean(sqrt(pursuit.initialMeanVelocity.X.^2 + pursuit.initialMeanVelocity.Y.^2));
end
if isempty(pursuit.initialPeakVelocity.X) || isempty(pursuit.initialPeakVelocity.Y)
    pursuit.initialPeakVelocity = NaN;
else
    pursuit.initialPeakVelocity = nanmean(sqrt(pursuit.initialPeakVelocity.X.^2 + pursuit.initialPeakVelocity.Y.^2));
end
if isempty(pursuit.initialMeanAcceleration.X) || isempty(pursuit.initialMeanAcceleration.Y)
    pursuit.initialMeanAcceleration = NaN;
else
    pursuit.initialMeanAcceleration = nanmean(sqrt(pursuit.initialMeanAcceleration.X.^2 + pursuit.initialMeanAcceleration.Y.^2));
end
if isempty(pursuit.initialPeakAcceleration.X) || isempty(pursuit.initialPeakAcceleration.Y)
    pursuit.initialPeakAcceleration = NaN;
else
    pursuit.initialPeakAcceleration = nanmean(sqrt(pursuit.initialPeakAcceleration.X.^2 + pursuit.initialPeakAcceleration.Y.^2));
end

% now analyze closed loop
% if there is no pursuit onset, use stimulus onset as onset 
bin1 = trial.target.onset+openLoopLength:trial.target.minima(1)-openLoopLength;
bins = [];
for i = 1:length(trial.target.minima)
    currentBin = trial.target.minima(i)+openLoopLength:trial.target.maxima(i)-openLoopLength;
    bins = [bins; currentBin];
end
closedLoop = [bin1; bins];
clear bin1 bins
% calculate gain first
speedXY_noSac = sqrt((trial.DX_noSac).^2 + (trial.DY_noSac).^2);
absoluteVel = sqrt(trial.target.Xvel.^2 + trial.target.Yvel.^2);
idx = absoluteVel < 0.05;
absoluteVel(idx) = NaN;
pursuitGain = (speedXY_noSac(closedLoop))./absoluteVel(closedLoop);
zScore = zscore(pursuitGain(~isnan(pursuitGain)));
pursuitGain((zScore > 3 | zScore < -3)) = NaN;
pursuit.gain= nanmean(pursuitGain);
if pursuit.gain > 2.5
    pursuit.gain = NaN;
end

% calculate position error
horizontalError = trial.X_noSac(closedLoop)-trial.target.X(closedLoop);
verticalError = trial.target.Y(closedLoop)-trial.Y_noSac(closedLoop);
pursuit.positionError = nanmean(sqrt(horizontalError.^2+ verticalError.^2));
% calculate velocity error
pursuit.velocityError = nanmean(sqrt((trial.target.Xvel(closedLoop) - trial.DX_noSac(closedLoop)).^2 + ...
    (trial.target.Yvel(closedLoop) - trial.DY_noSac(closedLoop)).^2)); %auch 2D

trial.pursuit = pursuit;
end