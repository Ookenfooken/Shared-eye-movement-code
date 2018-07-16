% FUNCTION to analyze saccade parameters

% history
% 07-2012       JE created analyzeSaccades.m
% 2012-2018     JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%        saccades --> output from findSaccades.m; contains on- & offsets
% output: trial --> structure containing relevant current trial information
%                   with saccades added
%         saccades --> edited saccade structure

function [trial, saccades] = analyzeSaccades(trial, saccades)
% add saccades to trial information
% for x
trial.saccades.X.onsets = [];
trial.saccades.X.offsets = [];
for i = 1:length(saccades.X.onsets)
    trial.saccades.X.onsets(i,1) = saccades.X.onsets(i);
    trial.saccades.X.offsets(i,1) = saccades.X.offsets(i);
end
% and for y
trial.saccades.Y.onsets = [];
trial.saccades.Y.offsets = [];
for i = 1:length(saccades.Y.onsets)    
    trial.saccades.Y(i,1) = saccades.Y.onsets(i);
    trial.saccades.Y(i,1) = saccades.Y.offsets(i);
end
% store all found on and offsets together
trial.saccades.onsets = [trial.saccades.X.onsets; trial.saccades.Y.onsets];
trial.saccades.offsets = [trial.saccades.X.offsets; trial.saccades.Y.offsets];

% calculate saccade amplitudes
% if there are no y-saccades, use x and y position of x saccades and vice
% versa; otherwise use the earlier onset and later offset; basically we
% assume that the eye is making a saccade and x- and y-position should be
% affected equally
xSac = length(trial.saccades.X.onsets);
ySac = length(trial.saccades.Y.onsets);
if isempty(ySac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets) - trial.eyeX_filt(trial.saccades.X.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets) - trial.eyeY_filt(trial.saccades.X.onsets)).^2);
elseif isempty(xSac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.Y.offsets) - trial.eyeX_filt(trial.saccades.Y.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.Y.offsets) - trial.eyeY_filt(trial.saccades.Y.onsets)).^2);
elseif numel(trial.saccades.onsets) == 0
    trial.saccades.amplitudes = NaN;
else
    testOnsets = sort(trial.saccades.onsets);
    testOffsets = sort(trial.saccades.offsets);
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
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets) - trial.eyeX_filt(trial.saccades.X.onsets)).^2 ...
            + (trial.eyeY_filt(trial.saccades.X.offsets) - trial.eyeY_filt(trial.saccades.X.onsets)).^2);
    else
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(offsets) - trial.eyeX_filt(onsets)).^2 ...
            + (trial.eyeY_filt(offsets) - trial.eyeY_filt(onsets)).^2);
    end
    trial.saccades.onsets = onsets;
    trial.saccades.offsets = offsets;
end

% caluclate mean and max amplitude, mean duration, total number, &
% cumulative saccade amplitude (saccadic sum)
if isempty(trial.saccades.onsets)
    trial.saccades.meanAmplitude = [];
    trial.saccades.maxAmplitude = [];   
    trial.saccades.X.meanDuration = [];
    trial.saccades.Y.meanDuration = [];
    trial.saccades.meanDuration = [];
    trial.saccades.number = [];
    trial.saccades.sacSum = [];
else
    trial.saccades.meanAmplitude = nanmean(trial.saccades.amplitudes);
    trial.saccades.maxAmplitude = max(trial.saccades.amplitudes);
    trial.saccades.X.meanDuration = mean(trial.saccades.X.offsets - trial.saccades.X.onsets);
    trial.saccades.Y.meanDuration = mean(trial.saccades.Y.offsets - trial.saccades.Y.onsets);
    trial.saccades.meanDuration = nanmean(sqrt(trial.saccades.X.meanDuration.^2 + ...
                                               trial.saccades.Y.meanDuration.^2));
    trial.saccades.number = length(trial.saccades.onsets);
    trial.saccades.sacSum = sum(trial.saccades.amplitudes);
end

% calculate mean and peak velocity for each saccade; then find average
trial.saccades.X.peakVelocity = [];
trial.saccades.Y.peakVelocity = [];
trial.saccades.X.meanVelocity = [];
trial.saccades.Y.meanVelocity = [];
saccadesXXpeakVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXYpeakVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXXmeanVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXYmeanVelocity = NaN(length(trial.saccades.X.onsets),1);
for i = 1:length(trial.saccades.X.onsets)
    saccadesXXpeakVelocity(i) = max(abs(trial.eyeDX_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXYpeakVelocity(i) = max(abs(trial.eyeDY_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
end
saccadesYYpeakVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYXpeakVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYYmeanVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYXmeanVelocity = NaN(length(trial.saccades.Y.onsets),1);
for i = 1:length(trial.saccades.Y.onsets)
    saccadesYYpeakVelocity(i) = max(abs(trial.eyeDY_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYXpeakVelocity(i) = max(abs(trial.eyeDX_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
end
trial.saccades.X.peakVelocity = max([saccadesXXpeakVelocity; saccadesYXpeakVelocity]);
trial.saccades.Y.peakVelocity = max([saccadesXYpeakVelocity; saccadesYYpeakVelocity]);
trial.saccades.X.meanVelocity = nanmean([saccadesXXmeanVelocity; saccadesYXmeanVelocity]);
trial.saccades.Y.meanVelocity = nanmean([saccadesXYmeanVelocity; saccadesYYmeanVelocity]);

trial.saccades.peakVelocity = nanmean(sqrt(trial.saccades.X.peakVelocity.^2 + trial.saccades.Y.peakVelocity.^2));
trial.saccades.meanVelocity = nanmean(sqrt(trial.saccades.X.meanVelocity.^2 + trial.saccades.Y.meanVelocity.^2));

end
