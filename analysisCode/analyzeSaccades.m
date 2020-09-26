% FUNCTION to analyze saccade parameters

% history
% 07-2012       JE created analyzeSaccades.m
% 2012-2018     JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 26-04-2018    XW modified the way to find peak velocity--take "baseline"
% velocity the saccade is based on into account; for example, if the
% saccade occur during pursuit at 10 deg/s, and the peak velocity is -5
% deg/s, then simply using max(abs(velocity)) would not find the correct
% peak.
% for questions email xiuyunwu5@gmail.com
%
% input: trial --> structure containing relevant current trial information
%        saccades --> output from findSaccades.m; contains on- & offsets
% output: trial --> structure containing relevant current trial information
%                   with saccades added
%         saccades --> edited saccade structure

function [trial, saccades] = analyzeSaccades(trial)
% define the window you want to analyze saccades in
% all saccade properties are within this window, using onsets_pursuit and
% offsets_pursuit
startFrame = nanmax(trial.stim_onset+trial.timeWindow.APpositive, trial.pursuit.onset);
endFrame = trial.stim_offset-trial.timeWindow.excludeEndDuration;
% then find the proper onsets and offsets
xIdx = find(trial.saccades.X.onsets>=startFrame & trial.saccades.X.onsets<=endFrame);
yIdx = find(trial.saccades.Y.onsets>=startFrame & trial.saccades.Y.onsets<=endFrame);
trial.saccades.X.onsets_pursuit = trial.saccades.X.onsets(xIdx);
trial.saccades.X.offsets_pursuit = trial.saccades.X.offsets(xIdx);
trial.saccades.Y.onsets_pursuit = trial.saccades.Y.onsets(yIdx);
trial.saccades.Y.offsets_pursuit = trial.saccades.Y.offsets(yIdx);
trial.saccades.onsets_pursuit = [trial.saccades.X.onsets_pursuit; trial.saccades.Y.onsets_pursuit];
trial.saccades.offsets_pursuit = [trial.saccades.X.offsets_pursuit; trial.saccades.Y.offsets_pursuit];

xIdxL = find(trial.saccades.X_left.onsets>=startFrame & trial.saccades.X_left.onsets<=endFrame);
xIdxR = find(trial.saccades.X_right.onsets>=startFrame & trial.saccades.X_right.onsets<=endFrame);
trial.saccades.X_left.onsets_pursuit = trial.saccades.X_left.onsets(xIdxL);
trial.saccades.X_left.offsets_pursuit = trial.saccades.X_left.offsets(xIdxL);
trial.saccades.X_right.onsets_pursuit = trial.saccades.X_right.onsets(xIdxR);
trial.saccades.X_right.offsets_pursuit = trial.saccades.X_right.offsets(xIdxR);

% calculate saccade amplitudes
% if there are no y-saccades, use x and y position of x saccades and vice
% versa; otherwise use the earlier onset and later offset; basically we
% assume that the eye is making a saccade and x- and y-position should be
% affected equally
xSac = length(trial.saccades.X.onsets_pursuit);
ySac = length(trial.saccades.Y.onsets_pursuit);
if numel(trial.saccades.onsets_pursuit) == 0
    trial.saccades.amplitudes = NaN;
elseif isempty(ySac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X.onsets_pursuit)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets_pursuit) - trial.eyeY_filt(trial.saccades.X.onsets_pursuit)).^2);
elseif isempty(xSac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.Y.offsets_pursuit) - trial.eyeX_filt(trial.saccades.Y.onsets_pursuit)).^2 ...
        + (trial.eyeY_filt(trial.saccades.Y.offsets_pursuit) - trial.eyeY_filt(trial.saccades.Y.onsets_pursuit)).^2);
else
    if length(trial.saccades.onsets_pursuit) ~= length(trial.saccades.offsets_pursuit)
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X.onsets_pursuit)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets_pursuit) - trial.eyeY_filt(trial.saccades.X.onsets_pursuit)).^2);
    else
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.offsets_pursuit) - trial.eyeX_filt(trial.saccades.onsets_pursuit)).^2 ...
            + (trial.eyeY_filt(trial.saccades.offsets_pursuit) - trial.eyeY_filt(trial.saccades.onsets_pursuit)).^2);
    end
end
if ~isempty(xSac)
    trial.saccades.X.amplitudes = abs(trial.eyeX_filt(trial.saccades.X.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X.onsets_pursuit));
end

xSacL = length(trial.saccades.X_left.onsets_pursuit);
xSacR = length(trial.saccades.X_right.onsets_pursuit);
if ~isempty(xSacL)
    trial.saccades.X_left.amplitudes = abs(trial.eyeX_filt(trial.saccades.X_left.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X_left.onsets_pursuit));
    % trial.saccades.X_left.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X_left.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X_left.onsets_pursuit)).^2 ...
    %         + (trial.eyeY_filt(trial.saccades.X_left.offsets_pursuit) - trial.eyeY_filt(trial.saccades.X_left.onsets_pursuit)).^2);
else
    trial.saccades.X_left.amplitudes = NaN;
end
if ~isempty(xSacR)
    trial.saccades.X_right.amplitudes = abs(trial.eyeX_filt(trial.saccades.X_right.offsets_pursuit) - trial.eyeX_filt(trial.saccades.X_right.onsets_pursuit));
else
    trial.saccades.X_right.amplitudes = NaN;
end

% caluclate mean and max amplitude, mean duration, total number, &
% cumulative saccade amplitude (saccadic sum)
if isempty(trial.saccades.onsets_pursuit)
    trial.saccades.meanAmplitude = NaN;
    trial.saccades.maxAmplitude = NaN;   
    trial.saccades.X.meanDuration = NaN;
    trial.saccades.Y.meanDuration = NaN;
    trial.saccades.meanDuration = NaN;
    trial.saccades.number = NaN;
    trial.saccades.sacSum = NaN;
else
    trial.saccades.meanAmplitude = nanmean(trial.saccades.amplitudes);
    trial.saccades.maxAmplitude = max(trial.saccades.amplitudes);
    trial.saccades.X.meanDuration = mean(trial.saccades.X.offsets_pursuit - trial.saccades.X.onsets_pursuit);
    trial.saccades.Y.meanDuration = mean(trial.saccades.Y.offsets_pursuit - trial.saccades.Y.onsets_pursuit);
    trial.saccades.meanDuration = nanmean(sqrt(trial.saccades.X.meanDuration.^2 + ...
                                               trial.saccades.Y.meanDuration.^2));
    trial.saccades.number = length(trial.saccades.onsets_pursuit);
    trial.saccades.sacSum = sum(trial.saccades.amplitudes);
end
if isempty(trial.saccades.X.onsets_pursuit)
    trial.saccades.X.number = NaN;
    trial.saccades.X.sacSum = NaN;
    trial.saccades.X.meanAmplitude = NaN;
    trial.saccades.X.maxAmplitude = NaN;
else
    trial.saccades.X.meanAmplitude = nanmean(trial.saccades.X.amplitudes);
    trial.saccades.X.maxAmplitude = max(trial.saccades.X.amplitudes);
    trial.saccades.X.meanDuration = mean(trial.saccades.X.offsets_pursuit - trial.saccades.X.onsets_pursuit);
    trial.saccades.X.number = length(trial.saccades.X.onsets_pursuit);
    trial.saccades.X.sacSum = sum(trial.saccades.X.amplitudes);
end
if isempty(trial.saccades.X_left.onsets_pursuit)
    trial.saccades.X_left.number = NaN;
    trial.saccades.X_left.meanAmplitude = NaN;
    trial.saccades.X_left.meanDuration = NaN;
    trial.saccades.X_left.sumAmplitude = NaN;
else
    trial.saccades.X_left.number = length(trial.saccades.X_left.onsets_pursuit);
    trial.saccades.X_left.meanAmplitude = nanmean(trial.saccades.X_left.amplitudes);
    trial.saccades.X_left.meanDuration = mean(trial.saccades.X_left.offsets_pursuit - trial.saccades.X_left.onsets_pursuit);
    trial.saccades.X_left.sumAmplitude = sum(trial.saccades.X_left.amplitudes);
end
if isempty(trial.saccades.X_right.onsets_pursuit)
    trial.saccades.X_right.number = NaN;
    trial.saccades.X_right.meanAmplitude = NaN;
    trial.saccades.X_right.meanDuration = NaN;
    trial.saccades.X_right.sumAmplitude = NaN;
else
    trial.saccades.X_right.number = length(trial.saccades.X_right.onsets_pursuit);
    trial.saccades.X_right.meanAmplitude = nanmean(trial.saccades.X_right.amplitudes);
    trial.saccades.X_right.meanDuration = mean(trial.saccades.X_right.offsets_pursuit - trial.saccades.X_right.onsets_pursuit);
    trial.saccades.X_right.sumAmplitude = sum(trial.saccades.X_right.amplitudes);
end

% calculate mean and peak velocity for each saccade; then find average
trial.saccades.X.peakVelocity = NaN;
trial.saccades.Y.peakVelocity = NaN;
trial.saccades.X.meanVelocity = NaN;
trial.saccades.Y.meanVelocity = NaN;
saccadesXXpeakVelocity = NaN(length(trial.saccades.X.onsets_pursuit),1);
saccadesXYpeakVelocity = NaN(length(trial.saccades.X.onsets_pursuit),1);
saccadesXXmeanVelocity = NaN(length(trial.saccades.X.onsets_pursuit),1);
saccadesXYmeanVelocity = NaN(length(trial.saccades.X.onsets_pursuit),1);
if ~isempty(trial.saccades.X.onsets_pursuit)
    for i = 1:length(trial.saccades.X.onsets_pursuit)
        % calculate baseline velocity this saccade is based on
        baseX = mean([trial.eyeDX_filt(trial.saccades.X.onsets_pursuit(i)); trial.eyeDX_filt(trial.saccades.X.offsets_pursuit(i))]);
        baseY = mean([trial.eyeDY_filt(trial.saccades.X.onsets_pursuit(i)); trial.eyeDY_filt(trial.saccades.X.offsets_pursuit(i))]);
        % when looking for max abs velocity values--peak in the velocity curve, count in the baseline
        % velocity first; then after finding the value correct for the baseline
        % to get the true value of the peak
        saccadesXXpeakVelocity(i) = nanmax( abs( trial.eyeDX_filt(trial.saccades.X.onsets_pursuit(i):trial.saccades.X.offsets_pursuit(i)) - baseX ) ) - abs(baseX);
        saccadesXYpeakVelocity(i) = nanmax( abs( trial.eyeDY_filt(trial.saccades.X.onsets_pursuit(i):trial.saccades.X.offsets_pursuit(i)) - baseY ) ) - abs(baseY);
        saccadesXXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.X.onsets_pursuit(i):trial.saccades.X.offsets_pursuit(i))));
        saccadesXYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.X.onsets_pursuit(i):trial.saccades.X.offsets_pursuit(i))));
    end
end
saccadesYYpeakVelocity = NaN(length(trial.saccades.Y.onsets_pursuit),1);
saccadesYXpeakVelocity = NaN(length(trial.saccades.Y.onsets_pursuit),1);
saccadesYYmeanVelocity = NaN(length(trial.saccades.Y.onsets_pursuit),1);
saccadesYXmeanVelocity = NaN(length(trial.saccades.Y.onsets_pursuit),1);
if ~isempty(trial.saccades.Y.onsets_pursuit)
    for i = 1:length(trial.saccades.Y.onsets_pursuit)
        baseX = mean([trial.eyeDX_filt(trial.saccades.Y.onsets_pursuit(i)); trial.eyeDX_filt(trial.saccades.Y.offsets_pursuit(i))]);
        baseY = mean([trial.eyeDY_filt(trial.saccades.Y.onsets_pursuit(i)); trial.eyeDY_filt(trial.saccades.Y.offsets_pursuit(i))]);
        saccadesYYpeakVelocity(i) = nanmax( abs( trial.eyeDY_filt(trial.saccades.Y.onsets_pursuit(i):trial.saccades.Y.offsets_pursuit(i)) - baseY ) ) - abs(baseY);
        saccadesYXpeakVelocity(i) = nanmax( abs( trial.eyeDX_filt(trial.saccades.Y.onsets_pursuit(i):trial.saccades.Y.offsets_pursuit(i)) - baseX ) ) - abs(baseX);
        saccadesYYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.Y.onsets_pursuit(i):trial.saccades.Y.offsets_pursuit(i))));
        saccadesYXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.Y.onsets_pursuit(i):trial.saccades.Y.offsets_pursuit(i))));
    end
end
if ~isempty(trial.saccades.X.onsets_pursuit) || ~isempty(trial.saccades.Y.onsets_pursuit)
    trial.saccades.X.peakVelocity = nanmax([saccadesXXpeakVelocity; saccadesYXpeakVelocity]);
    trial.saccades.Y.peakVelocity = nanmax([saccadesXYpeakVelocity; saccadesYYpeakVelocity]);
    trial.saccades.X.meanVelocity = nanmean([saccadesXXmeanVelocity; saccadesYXmeanVelocity]);
    trial.saccades.Y.meanVelocity = nanmean([saccadesXYmeanVelocity; saccadesYYmeanVelocity]);
end
trial.saccades.peakVelocity = nanmean(sqrt(trial.saccades.X.peakVelocity.^2 + trial.saccades.Y.peakVelocity.^2));
trial.saccades.meanVelocity = nanmean(sqrt(trial.saccades.X.meanVelocity.^2 + trial.saccades.Y.meanVelocity.^2));

end
