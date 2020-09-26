% FUNCTION to find saccade on and offsets

% history
% 07-2012       developed by Janick Edinger
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de and/or 
%                     janick.edinger@uni-mannheim.de
% 26-04-2018    XW added acceleration threshold for saccades, in case
% sometimes part of the pursuit right before or after saccades was 
% included, or sometimes pursuit to the opposite direction (such as 
% for low coherence motion) was counted as saccades.
% for questions email xiuyunwu5@gmail.com
% 
% input: stim_onset --> start of the period you want to find saccades in
%        stim_offset --> end of the period you want to find saccades in
%        speed --> eye speed
%        acceleration --> eye acceleration
%        threshold --> saccade threshold as defined in working directory
%        stimulusSpeed --> stimulus speed for moving stimulus; othersiwe 0
% output: onsets --> saccade onsets
%         offsets --> saccade offsets

function [onsets, offsets] = findSaccades(stim_onset, stim_offset, speed, acceleration, jerk, threshold, stimulusSpeed)
global trial
% set up data
startFrame = stim_onset; % fixation onset
rdkOnFrame = trial.stim_onset+ms2frames(100); % rdk onset+100ms
rdkOffFrame =  trial.stim_offset; % rdk offset
endFrame = stim_offset;
upperThreshold = stimulusSpeed + threshold;
lowerThreshold = stimulusSpeed - threshold;
speed = speed(startFrame:endFrame);
endSpeedF = length(speed);
acceleration = acceleration(startFrame:endFrame);
accelerationThreshold = 200; % 200 for all exp2; 300 for exp3 (the old exp2)
jerk = jerk(startFrame:endFrame);
jerkThreshold = 30000; % 30000 for all exps; 50000 for exp3 (the old exp2)

% check eye velocity against threshold to find when the eye is much faster 
% than the moving stimulus (or just compared to 0) and read out the
% relevant frames, i.e. the frames in which the eye supposedly is in a
% saccade
middle(1:rdkOnFrame-startFrame, 1) = speed(1:rdkOnFrame-startFrame)<-threshold | speed(1:rdkOnFrame-startFrame)>threshold; % when there isn't motion
middle(rdkOnFrame-startFrame+1:rdkOffFrame-startFrame+1, 1) = speed(rdkOnFrame-startFrame+1:rdkOffFrame-startFrame+1)<lowerThreshold | speed(rdkOnFrame-startFrame+1:rdkOffFrame-startFrame+1)>upperThreshold; % when there is motion
middle(rdkOffFrame-startFrame+1:endSpeedF, 1) = speed(rdkOffFrame-startFrame+1:end)<-threshold | speed(rdkOffFrame-startFrame+1:end)>threshold; % when there is no motion again

predecessor = [middle(2:end); 0];
successor = [0; middle(1:end-1)];

% OPTION 1: use less strict criterion: 3 consecutive frames have to exceed
% the speed criterion
relevantFrames = middle+predecessor+successor == 3;
%****

% OPTION 2: stricter criterion: 5 consecutive frames have to exceed 
% the speed criterion
prepredecessor = [predecessor(2:end); 0];
sucsuccessor = [0; successor(1:end-1)];
relevantFrames = middle+predecessor+successor+sucsuccessor+prepredecessor == 5;
%****

relevantFramesDiff = diff(relevantFrames);
relevantFramesOnsets = [relevantFramesDiff; 0];
relevantFramesOffsets = [0; relevantFramesDiff];

speedOnsets = relevantFramesOnsets == 1;
speedOffsets = relevantFramesOffsets == -1;

speedOnsets = find(speedOnsets);
speedOffsets = find(speedOffsets);

% now check eye acceleration to next find exact onset and offset
middle = acceleration/1000;
predecessor = [middle(2:end); 0];
signSwitches = find((middle .* predecessor) <= 0)+1; % either sign switch, or rapid change of speed
% only count if consecutive 25 frames acceleration are all below the
% threshold; to ensure that the tails of saccades do not survive...
accelerationAbs = abs(acceleration)<accelerationThreshold;
accDiff = diff(accelerationAbs);
validFrameN = 25;
ii = 1;
while ii <= length(accDiff)
    if accDiff(ii)==1 % change from 0 to 1, check if frames of 1 meets the requirement
        validIdx = min([validFrameN; length(accDiff)-ii+1]); % length of frames left or consecutive number of frames required
        if sum(accelerationAbs(ii+1:ii+validIdx, 1))~=validIdx
            % less that the defined consecutive frames is below threshold,
            % treat it as tails of saccades, change to above threshold (0)
            idx = find(accelerationAbs(ii+1:ii+validIdx, 1)==0);
            idx = idx(1);
            accelerationAbs(ii+1:ii+idx, 1) = 0;
            ii = ii+idx;
        else
            ii = ii+1;
        end
    else
        ii = ii+1;
    end
end

% % only five frames
% preAccAbs = [accelerationAbs(2:end); 0];
% sucAccAbs = [0; accelerationAbs(1:end-1)];
% prepreAccAbs = [preAccAbs(2:end); 0];
% sucsucAccAbs = [0; sucAccAbs(1:end-1)];
% relevantAcc = accelerationAbs+preAccAbs+sucAccAbs+prepreAccAbs+sucsucAccAbs ==5;
% 
% accelerationThres = find(relevantAcc==1);

accelerationThres = find(accelerationAbs==1); %

% use acceleration to judge rapid change of speed; these are frames preceeded by frames below
% the acceleration threshold, so could serve as onset/offset

onsets = NaN(1,length(speedOnsets));
offsets = NaN(1,length(speedOnsets));

% make use of sign switch in eye acceleration profile
for i = 1:length(speedOnsets)   
    % make sure, that there is always both, an onset and an offset
    % otherwise, skip this saccade
    if speedOnsets(i) < min(signSwitches) || speedOffsets(i) > max(signSwitches) ...
            || isempty(find(accelerationAbs(speedOnsets(i):speedOffsets(i))==0))...
            || speedOnsets(i) < min(accelerationThres) ...
            % || speedOffsets(i) > max(accelerationThres) ...
%             || max(abs(jerk(speedOnsets(i):speedOffsets(i))))<30000
        continue
    end
    
    if accelerationAbs(speedOffsets(i))==1 && accelerationAbs(speedOnsets(i))==1 % saccade is included in between
        idx = find(accelerationAbs==0);
        idx(idx<speedOnsets(i) | idx>speedOffsets(i))=[];
        onsets(i) = min(idx);
        offsets(i) = max(idx);
    elseif accelerationAbs(speedOffsets(i))==1 % if offset is too far, which could happen during initiation phase
        onsets(i) = max(accelerationThres(accelerationThres <= speedOnsets(i)));
        offsets(i) = min(accelerationThres(accelerationThres > onsets(i)));
    else % otherwise locate saccade offset first, which is usually more accurate
        offsets(i) = min([accelerationThres(accelerationThres >= speedOffsets(i)); ...
            endFrame]);
        onsets(i) = max(accelerationThres(accelerationThres < offsets(i)));
    end
    % for saccades that are really close, separate...
    if length(signSwitches(signSwitches >= onsets(i) & signSwitches <= offsets(i)))>4
        if i>1 && onsets(i)<=offsets(i-1) % the second in overlapping saccades
            onsets(i) = max([signSwitches(signSwitches < speedOnsets(i)); ...
                offsets(i-1)+10])-10;
        else
            onsets(i) = max([signSwitches(signSwitches < speedOnsets(i))-10; ...
                stim_onset+1]);
        end
        offsets(i) = min([signSwitches(signSwitches > speedOffsets(i))+10; ...
            stim_offset]);
    end
    % check jerk again...
    if onsets(i)>=offsets(i)
        onsets(i) = NaN;
        offsets(i) = NaN;
    elseif max(abs(jerk(onsets(i):offsets(i))))<jerkThreshold
        onsets(i) = NaN;
        offsets(i) = NaN;
    elseif i>1 && onsets(i)<offsets(i-1)
        onsets(i) = NaN;
        offsets(i) = NaN;
    end
    
    %     onsets(i) = max([signSwitches(signSwitches <= speedOnsets(i)); ...
    %        accelerationThres(accelerationThres < speedOnsets(i))]);
    %     offsets(i) = min([signSwitches(signSwitches >= speedOffsets(i)); ...
    %         accelerationThres(accelerationThres > speedOffsets(i))])-1;    
end

% trim to delete NaNs
onsets = onsets(~isnan(onsets))+startFrame;
offsets = offsets(~isnan(offsets))+startFrame;

% make sure that saccades don't overlap. This is, find overlapping saccades and delete intermediate onset/offset
earlyOnsets = find(diff(reshape([onsets;offsets],1,[]))<=0)/2+1;
previousOffsets = earlyOnsets - 1;
onsets(earlyOnsets) = [];
offsets(previousOffsets) = [];
% for i = 1:length(onsets) % if there is pursuit right after saccades before the sign switch, find earlier offset
%     if abs(speed(offsets(i)-startFrame)-speed(onsets(i)-startFrame))>8
%         offsets(i) = max(find(abs(speed(onsets(i)-startFrame:offsets(i)-startFrame)-speed(onsets(i)-startFrame))<=2))+onsets(i)-1; % just define the offset to be around the same speed as the onset
%     end
% end
end