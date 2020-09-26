function [onsets, offsets] = findSaccades(stim_onset, stim_offset, speed, acceleration, jerk, threshold)
% FUNCTION to find saccade on and offsets based on acceleration criterion;
% not using speed/jerk now, but can use them for sanity check if needed;
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
% for questions email xiuyunwu5@gmail.com; try plotting the acceleration 
% traces to make sense of what I'm saying below...
% Note that blinks cannot be excluded using this algorithm; if you have
% blinks at the end of the trial (and you didn't exclude that trial), 
% you cannot use interpol saccades as only part of the blink will be
% interpolated; need to throw the last part of the time window

% set up data
global trial
startFrame = stim_onset; % fixation onset
endFrame = stim_offset;
speed = speed(startFrame:endFrame);
acceleration = acceleration(startFrame:endFrame); 
jerk = jerk(startFrame:endFrame);
jerkThreshold = -1; % if dont't want to use, set to a negative value 
thresholdAccTail = 2000; % see below for explanation; adjust this value to 
% decide how much of the fluctuation around saccade onset/offset you want
% to include (or ignore this by setting the threshold to a very large value
% and then simply add some fixed time around saccades, as people usually do)

% % first, separate acceleration by sign switch points (crossing zero) and get all peak
% % magnitudes; usually zero-crossing point would be enough:
signSwitches = find(acceleration.*[acceleration(1); acceleration(1:end-1)]<=0);
signSwitches(signSwitches==1) = [];
signSwitches(signSwitches==length(acceleration)) = [];
% indices for the time window of acceleration peak n is from binEdges(n) to binEdges(n+1)-1
binEdges = [1; signSwitches; length(acceleration)+1];

% However, sometimes acceleration may drop to around zero but then
% increase again, not crossing zero, then two peaks could be counted as
% one; to account for this, we could find the minimum absolute
% value point within sections below a threshold (between two zero-crossing points) 
% as an addition separation point of different peaks
switchPoints = abs(acceleration)<=200;
switchPointsDiff = diff(switchPoints);
secStart = find(switchPointsDiff==1)+1;
secEnd = find(switchPointsDiff==-1);
if ~isempty(secStart) && ~isempty(secEnd)
    if secEnd(1)<secStart(1)
        secStart = [1; secStart];
    end
    if length(secStart)>length(secEnd)
        secEnd = [secEnd; length(switchPoints)];
    end
    tempLength = length(binEdges)-1;
    for ii = 1:tempLength
        lowIdx = find(secStart>binEdges(ii) & secEnd<binEdges(ii+1)-1);
        if ~isempty(lowIdx) % the low acceleration period didn't cross zero
            minTemp(:, 1) = find(abs(acceleration(secStart(lowIdx(1)):secEnd(lowIdx(end))))==min(abs(acceleration(secStart(lowIdx(1)):secEnd(lowIdx(end))))));
            binEdges = [binEdges; secStart(lowIdx(1))+minTemp-1]; % put at the end for now
        end
    end
    binEdges = sort(binEdges);
end

% the edge of peak n is binEdge(n) to binEdge(n+1)-1
peakAccs = nan([length(binEdges)-1 1]); % magnitude of peak accelerations
for idx = 1:length(binEdges)-1
    startI = binEdges(idx);   
    endI = binEdges(idx+1)-1;
    peakAccs(idx, 1) = max(abs(acceleration(startI:endI)));
end

largePeaks = peakAccs>threshold;
successor = [0; largePeaks(1:end-1)];
relevantPeaks = (largePeaks+successor==2);

relevantPeaksDiff = diff(relevantPeaks);
onsetIntervals = find(relevantPeaksDiff==1); 
offsetIntervals = find(relevantPeaksDiff==-1);
if length(offsetIntervals)<length(onsetIntervals) % the last interval is an onset interval
    offsetIntervals = [offsetIntervals; onsetIntervals(end)]; % making the same interval to be the offset of itself
end
% these are index of the peak intervals, not the time frames
% if half of a saccade is at the beginning or the end, currently could
% not detect... should not be a problem, just be aware (could just make the
% findSaccade time window longer than the analysis time window)

% this chunk not in use now... too much assumptions
% % the only issue to be solved: if two saccades are just next to each other,
% % such as two consecutive pairs of acceleration peaks, would be count as
% % one saccade; if threshold is large enough, could use the following to
% % separate them: (not sure if there will be >2 consecutive saccades...
% % here we just assume only saccade peaks but not tail peaks are included)
% overlapIdx = find(offsetIntervals-onsetIntervals>=3);
% if ~isempty(overlapIdx)
%     added = 0;
%     for ii = 1:length(overlapIdx)
%         newOnsets(:, 1) = [onsetIntervals(overlapIdx(ii)+added):2:offsetIntervals(overlapIdx(ii)+added)];
%         newOffsets = newOnsets+1;
%         if newOffsets(end)>offsetIntervals(overlapIdx(ii))
%             newOnsets(end) = [];
%             newOffsets(end) = [];
%         end
%         newOnsets(1) = [];
%         newOffsets(end) = [];
%         onsetIntervals = [onsetIntervals(1:(overlapIdx(ii)+added)); newOnsets; onsetIntervals((overlapIdx(ii)+added+1):end)];
%         offsetIntervals = [offsetIntervals(1:(overlapIdx(ii)+added-1)); newOffsets; offsetIntervals((overlapIdx(ii)+added):end)];
%         added = added+length(newOnsets);
%     end
% end

onsets = NaN(1,length(onsetIntervals));
offsets = NaN(1,length(offsetIntervals));

% now loop through all marked intervals to define the saccade onset and offset
for ii = 1:length(onsets)
    % just use the acceleration sign switch point, aka the edge of the
    % intervals as the saccade onset and offset
    onsets(ii) = binEdges(onsetIntervals(ii));
    offsets(ii) = binEdges(offsetIntervals(ii)+1)-1;
    
    % In addition, can use an acceleration threshold to decide how much of the extra tail
    % intervals you want to include (fluctuation around the saccade)
    % For example, below we included the peaks of the tail intervals but exclude
    % rest of the interval (the further "leg" of the whole peak) where
    % acceleration magnitude is below the threshold for the "tail"
    if onsetIntervals(ii)>1
        if peakAccs(onsetIntervals(ii)-1) > thresholdAccTail 
            onset = find(abs(acceleration(binEdges(onsetIntervals(ii)-1):(binEdges(onsetIntervals(ii))-1)))>=thresholdAccTail);
            onsets(ii) = binEdges(onsetIntervals(ii)-1)+onset(1)-1;
            if ii>1 && onsets(ii)<offsets(ii-1) % if overlap with the previous saccade
                onsets(ii) = binEdges(onsetIntervals(ii)); % don't count the tail twice
            end
        end
    end
    if offsetIntervals(ii)+1<=length(peakAccs)
        if peakAccs(offsetIntervals(ii)+1) > thresholdAccTail
            offset = find(abs(acceleration(binEdges(offsetIntervals(ii)+1):(binEdges(offsetIntervals(ii)+2)-1)))>=thresholdAccTail);
            offsets(ii) = binEdges(offsetIntervals(ii)+1)+offset(end)-1;
            if ii<length(onsets) && offsets(ii)>binEdges(onsetIntervals(ii+1))% if overlap with a potential next saccade
                offsets(ii) = binEdges(offsetIntervals(ii)+1)-1;
            end
        end
    end
    
    % can use jerk as a sanity check
    if max(abs(jerk(onsets(ii):offsets(ii))))<=jerkThreshold
        onsets(ii) = NaN;
        offsets(ii) = NaN;
    end
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