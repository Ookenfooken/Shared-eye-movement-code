% FUNCTION to analyze micro saccade parameters; pretty much equivalent to
% analyzeSaccades.m

% history
% 12-06-2018    JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%        saccades --> output from findSaccades.m; contains on- & offsets
% output: trial --> structure containing relevant current trial information
%                   with saccades added
%         saccades --> edited saccade structure

function [trial, saccades] = analyzeMicroSaccades(trial, saccades)
% store microSaccades in trial information
% in X
trial.microSaccades.X.onsets = [];
trial.microSaccades.X.offsets = [];
for i = 1:length(saccades.X.onsets)
    trial.microSaccades.X.onsets(i,1) = saccades.X.onsets(i);
    trial.microSaccades.X.offsets(i,1) = saccades.X.offsets(i);
end
% and same for Y
trial.microSaccades.Y.onsets = [];
trial.microSaccades.Y.offsets = [];
for i = 1:length(saccades.Y.onsets)
    trial.microSaccades.Y.onsets(i,1) = saccades.Y.onsets(i);
    trial.microSaccades.Y.offsets(i,1) = saccades.Y.offsets(i);
end

% get onsets and offsets
trial.microSaccades.X.onsets = sort([trial.saccades.X.fixOnsets; trial.microSaccades.X.onsets]);
trial.microSaccades.Y.onsets = sort([trial.saccades.Y.fixOnsets; trial.microSaccades.Y.onsets]);
trial.microSaccades.onsets = [trial.microSaccades.X.onsets; trial.microSaccades.Y.onsets];
trial.microSaccades.X.offsets = sort([trial.saccades.X.fixOffsets; trial.microSaccades.X.offsets]);
trial.microSaccades.Y.offsets = sort([trial.saccades.Y.fixOffsets; trial.microSaccades.Y.offsets]);
trial.microSaccades.offsets = [trial.microSaccades.X.offsets; trial.microSaccades.Y.offsets];

% calculate saccade amplitudes
% if there are no x- or y-microSaccades use x and y position of y- or
% x- microSaccades, respectively
% otherwise sort the onsets and offsets and combine them to 1
xSac = length(trial.microSaccades.X.onsets);
ySac = length(trial.microSaccades.Y.onsets);
if isempty(ySac)
    trial.microSaccades.amplitudes = sqrt((trial.eyeX_filt(trial.microSaccades.X.offsets) - trial.eyeX_filt(trial.microSaccades.X.onsets)).^2 ...
        + (trial.eyeY_filt(trial.microSaccades.X.offsets) - trial.eyeY_filt(trial.microSaccades.X.onsets)).^2);
elseif isempty(xSac)
    trial.microSaccades.amplitudes = sqrt((trial.eyeX_filt(trial.microSaccades.Y.offsets) - trial.eyeX_filt(trial.microSaccades.Y.onsets)).^2 ...
        + (trial.eyeY_filt(trial.microSaccades.Y.offsets) - trial.eyeY_filt(trial.microSaccades.Y.onsets)).^2);
elseif numel(trial.microSaccades.onsets) == 0
    trial.microSaccades.amplitudes = NaN;
else
    testOnsets = sort(trial.microSaccades.onsets);
    testOffsets = sort(trial.microSaccades.offsets);
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
    if length(onsets) ~= length(offsets)
        trial.microSaccades.amplitudes = sqrt((trial.eyeX_filt(trial.microSaccades.X.offsets) - trial.eyeX_filt(trial.microSaccades.X.onsets)).^2 ...
            + (trial.eyeY_filt(trial.microSaccades.X.offsets) - trial.eyeY_filt(trial.microSaccades.X.onsets)).^2);
    else
        trial.microSaccades.amplitudes = sqrt((trial.eyeX_filt(offsets) - trial.eyeX_filt(onsets)).^2 ...
            + (trial.eyeY_filt(offsets) - trial.eyeY_filt(onsets)).^2);
    end
    trial.microSaccades.onsets = onsets;
    trial.microSaccades.offsets = offsets;
end

% calculate saccade directions
if ~isempty(trial.microSaccades.X.onsets)
    for i = 1:length(trial.microSaccades.X.onsets)
        if trial.eyeX_filt(trial.microSaccades.X.onsets(i)+ 25) - trial.eyeX_filt(trial.microSaccades.X.onsets(i)) > 0
            trial.microSaccades.direction(i,1) = 1;
        else
            trial.microSaccades.direction(i,1) = 0;
        end
    end
else
    trial.microSaccades.direction(i,1) = NaN;
end

% caluclate mean and max amplitude, mean duration, total number, &
% cumulative saccade amplitude (saccadic sum)
if isempty(trial.microSaccades.onsets)
    trial.microSaccades.meanAmplitude = [];
    trial.microSaccades.maxAmplitude = [];
    trial.microSaccades.X.meanDuration = [];
    trial.microSaccades.Y.meanDuration = [];
    trial.microSaccades.meanDuration = [];
    trial.microSaccades.number = [];
    trial.microSaccades.sacSum = [];
else
    trial.microSaccades.meanAmplitude = nanmean(trial.microSaccades.amplitudes);
    trial.microSaccades.maxAmplitude = max(trial.microSaccades.amplitudes);
    trial.microSaccades.X.meanDuration = mean(trial.microSaccades.X.offsets - trial.microSaccades.X.onsets);
    trial.microSaccades.Y.meanDuration = mean(trial.microSaccades.Y.offsets - trial.microSaccades.Y.onsets);
    trial.microSaccades.meanDuration = nanmean(sqrt(trial.microSaccades.X.meanDuration.^2 + ...
        trial.microSaccades.Y.meanDuration.^2));
    trial.microSaccades.number = length(trial.microSaccades.onsets);
    trial.microSaccades.sacSum = sum(trial.microSaccades.amplitudes);
end

% calculate mean and peak velocity for each micro-saccade; then average
trial.microSaccades.X.velocity = [];
trial.microSaccades.Y.velocity = [];
microSaccadesXXvelocity = NaN(length(trial.microSaccades.X.onsets),1);
microSaccadesXYvelocity = NaN(length(trial.microSaccades.X.onsets),1);
for i = 1:length(trial.microSaccades.X.onsets)
    microSaccadesXXvelocity(i) = max(abs(trial.eyeDX_filt(trial.microSaccades.X.onsets(i):trial.microSaccades.X.offsets(i))));
    microSaccadesXYvelocity(i) = max(abs(trial.eyeDY_filt(trial.microSaccades.X.onsets(i):trial.microSaccades.X.offsets(i))));
end
microSaccadesYYvelocity = NaN(length(trial.microSaccades.Y.onsets),1);
microSaccadesYXvelocity = NaN(length(trial.microSaccades.Y.onsets),1);
for i = 1:length(trial.microSaccades.Y.onsets)
    microSaccadesYYvelocity(i) = max(abs(trial.eyeDY_filt(trial.microSaccades.Y.onsets(i):trial.microSaccades.Y.offsets(i))));
    microSaccadesYXvelocity(i) = max(abs(trial.eyeDX_filt(trial.microSaccades.Y.onsets(i):trial.microSaccades.Y.offsets(i))));
end
trial.microSaccades.X.velocity = [microSaccadesXXvelocity; microSaccadesYXvelocity];
trial.microSaccades.Y.velocity = [microSaccadesXYvelocity; microSaccadesYYvelocity];

trial.microSaccades.velocities = sqrt(trial.microSaccades.X.velocity.^2 + trial.microSaccades.Y.velocity.^2);
trial.microSaccades.peakVelocity = nanmean(sqrt(trial.microSaccades.X.peakVelocity.^2 + trial.microSaccades.Y.peakVelocity.^2));
trial.microSaccades.meanVelocity = nanmean(sqrt(trial.microSaccades.X.meanVelocity.^2 + trial.microSaccades.Y.meanVelocity.^2));

end
