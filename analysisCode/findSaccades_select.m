function [onsets, offsets, isMax] = findSaccades_select(stim_onset, stim_offset, speed, acceleration, jerk, analysisParams)

% This is work in progress - trying to combine XW's findSaccades after
% properly understanding how it works

% INPUT:
% analysisParams.sac.useAcc
% - 0: velocity (for numSuccessiveFrames); acceleration to detect
% onset/offset
% - 1: velocity and acceleration combined
% - 2: acceleration and jerk combined

% UPDATE RECORD:
% 01/13/2021 (DC): Separate from analysis_interactive.m
% 01/05/2021 (DC): incorporate XW's findSaccades

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
    
    if analysisParams.sac.method == 0
        
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
        
    elseif analysisParams.sac.method == 1
        
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
        
    elseif analysisParams.sac.method == 2
        
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
