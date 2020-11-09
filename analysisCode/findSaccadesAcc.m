function [onsets, offsets] = findSaccades(stim_onset, stim_offset, speed, acceleration, jerk, threshold)
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
switchPoints = abs(acceleration)<=200; % first, find sections below a certain threshold
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

largePeaks = abs(peakAccs)>threshold;
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