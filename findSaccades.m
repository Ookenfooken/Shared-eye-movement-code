% FUNCTION to find saccade on and offsets

% history
% 07-2012       developed by Janick Edinger
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de and/or 
%                     janick.edinger@uni-mannheim.de
% 26-04-2018    XW added acceleration threshold for saccades, in case
% sometimes part of the pursuit right after saccades was included, or
% sometimes pursuit to the opposite direction (such as for low coherence 
% motion) was counted as saccades.
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

function [onsets, offsets] = findSaccades(stim_onset, stim_offset, speed, acceleration, threshold, stimulusSpeed)
% set up data
startFrame = stim_onset;
endFrame = stim_offset;
upperThreshold = stimulusSpeed + threshold;
lowerThreshold = stimulusSpeed - threshold;
speed = speed(startFrame:endFrame);
acceleration = acceleration(startFrame:endFrame);
accelerationThreshold = 0; % set according to your needs; 0 equals none

% check eye velocity against threshold to find when the eye is much faster 
% than the moving stimulus (or just compared to 0) and read out the
% relevant frames, i.e. the frames in which the eye supposedly is in a
% saccade
middle = speed<lowerThreshold | speed>upperThreshold;
predecessor = [middle(2:end); 0];
successor = [0; middle(1:end-1)];

% OPTION 1: use less strict criterion: 3 consecutive frames have to exceed
% the speed criterion
%relevantFrames = middle+predecessor+successor == 3;
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
signSwitches = find((middle .* predecessor) < 0)+1;
accelerationAbs = find(abs(acceleration)<accelerationThreshold)+1;
% use acceleration to judge rapid change of speed; these are frames preceeded by frames below
% the acceleration threshold, so could serve as onset/offset

onsets = NaN(1,length(speedOnsets));
offsets = NaN(1,length(speedOnsets));

% make use of sign switch in eye acceleration profile
for i = 1:length(speedOnsets)   
    % make sure, that there is always both, an onset and an offset
    % otherwise, skip this saccade
    if speedOnsets(i) < min(signSwitches) || speedOffsets(i) > max(signSwitches) ...
            || abs(acceleration(speedOnsets(i)))<accelerationThreshold ...
            || abs(acceleration(speedOffsets(i)))<accelerationThreshold
        continue
    end
    
    onsets(i) = max([signSwitches(signSwitches <= speedOnsets(i)); ...
       accelerationAbs(accelerationAbs < speedOnsets(i))]);
    offsets(i) = min([signSwitches(signSwitches >= speedOffsets(i)); ...
        accelerationAbs(accelerationAbs > speedOffsets(i))])-1;
end

% trim to delete NaNs
onsets = onsets(~isnan(onsets))+startFrame;
offsets = offsets(~isnan(offsets))+startFrame;

% make sure that saccades don't overlap. This is, find overlapping saccades and delete intermediate onset/offset
earlyOnsets = find(diff(reshape([onsets;offsets],1,[]))<0)/2+1;
previousOffsets = earlyOnsets - 1;
onsets(earlyOnsets) = [];
offsets(previousOffsets) = [];

end