% FUNCTION to remove saccades from eye movement data; this may be necessary
% when e.g. analyzing smooth eye movement phase

% history
% 07-2012       JE created analyzeSaccades.m
% 2012-2018     JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
% output: trial --> structure containing relevant current trial information
%                   de-saccaded eye movements added

function [trial] = removeSaccades(trial, saccades)
% add saccades to trial information
% for x
trial.saccades.X.onsets = [];
trial.saccades.X.offsets = [];
duringIdx = 1;

trial.saccades.X_left.onsets = [];
trial.saccades.X_left.offsets = [];
trial.saccades.X_right.onsets = [];
trial.saccades.X_right.offsets = [];

for i = 1:length(saccades.X.onsets)
    trial.saccades.X.onsets(i,1) = saccades.X.onsets(i); % ?... why use the loop
    trial.saccades.X.offsets(i,1) = saccades.X.offsets(i);
    if trial.saccades.X.onsets(i,1)>=trial.stim_onset && trial.saccades.X.offsets(i,1)<=trial.stim_offset
        trial.saccades.X.onsetsDuring(duringIdx, 1) = trial.saccades.X.onsets(i,1);
        trial.saccades.X.offsetsDuring(duringIdx, 1) = trial.saccades.X.offsets(i,1);
        duringIdx = duringIdx + 1;
    end
    peakV = max( abs( trial.eyeDX_filt(saccades.X.onsets(i):saccades.X.offsets(i)) - mean([trial.eyeDX_filt(saccades.X.onsets(i));trial.eyeDX_filt( saccades.X.offsets(i))]) ) );
    % minus mean velocity of onset and offset to move the baseline, so that the position of max velocity is
    % the true peak
    peakVIdx = find(abs( trial.eyeDX_filt - mean([trial.eyeDX_filt(saccades.X.onsets(i));trial.eyeDX_filt( saccades.X.offsets(i))]) )==peakV);
    if length(peakVIdx)>1
        for ii = 1:length(peakVIdx)
            if peakVIdx(ii) > saccades.X.onsets(i) && peakVIdx(ii) < saccades.X.offsets(i)
                peakVIdx = peakVIdx(ii);
                break
            end
        end
    end
    if trial.eyeDX_filt(peakVIdx) < 0 % whether velocity is positive or negative
        trial.saccades.X_left.onsets = [trial.saccades.X_left.onsets; saccades.X.onsets(i)];
        trial.saccades.X_left.offsets = [trial.saccades.X_left.offsets; saccades.X.offsets(i)];
    else
        trial.saccades.X_right.onsets = [trial.saccades.X_right.onsets; saccades.X.onsets(i)];
        trial.saccades.X_right.offsets = [trial.saccades.X_right.offsets; saccades.X.offsets(i)];
    end
end
if duringIdx>1 
    trial.saccades.firstSaccadeOnset = trial.saccades.X.onsetsDuring(1, 1);
else
    trial.saccades.firstSaccadeOnset = [];
    trial.saccades.X.onsetsDuring = [];
    trial.saccades.X.offsetsDuring = [];
end

% and for y
trial.saccades.Y.onsets = [];
trial.saccades.Y.offsets = [];
duringIdxY = 1;
for i = 1:length(saccades.Y.onsets)    
    trial.saccades.Y.onsets(i,1) = saccades.Y.onsets(i);
    trial.saccades.Y.offsets(i,1) = saccades.Y.offsets(i);
    if trial.saccades.Y.onsets(i,1)>=trial.stim_onset && trial.saccades.Y.offsets(i,1)<=trial.stim_offset
        trial.saccades.Y.onsetsDuring(duringIdxY, 1) = trial.saccades.Y.onsets(i,1);
        trial.saccades.Y.offsetsDuring(duringIdxY, 1) = trial.saccades.Y.offsets(i,1);
        duringIdxY = duringIdxY + 1;
    end
end
if duringIdxY>1
    trial.saccades.firstSaccadeOnset = min(trial.saccades.firstSaccadeOnset, trial.saccades.Y.onsetsDuring(1, 1));
else
    trial.saccades.Y.onsetsDuring = [];
    trial.saccades.Y.offsetsDuring = [];
end

% store all found on and offsets together
trial.saccades.onsets = [trial.saccades.X.onsets; trial.saccades.Y.onsets];
trial.saccades.offsets = [trial.saccades.X.offsets; trial.saccades.Y.offsets];
trial.saccades.onsetsDuring = [trial.saccades.X.onsetsDuring; trial.saccades.Y.onsetsDuring];
trial.saccades.offsetsDuring = [trial.saccades.X.offsetsDuring; trial.saccades.Y.offsetsDuring];
% merge saccades on X and Y that are actually the same...
xSac = length(trial.saccades.X.onsets);
ySac = length(trial.saccades.Y.onsets);
if ~isempty(ySac) && ~isempty(xSac) && numel(trial.saccades.onsets) ~= 0
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
    trial.saccades.onsets = onsets;
    trial.saccades.offsets = offsets;
end
xSac = length(trial.saccades.X.onsetsDuring);
ySac = length(trial.saccades.Y.onsetsDuring);
if ~isempty(ySac) && ~isempty(xSac) && numel(trial.saccades.onsetsDuring) ~= 0
    testOnsets = sort(trial.saccades.onsetsDuring);
    testOffsets = sort(trial.saccades.offsetsDuring);
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
    trial.saccades.onsetsDuring = onsets;
    trial.saccades.offsetsDuring = offsets;
end

% open eye movement data structure
trial.X_noSac = trial.eyeX_filt;
trial.Y_noSac = trial.eyeY_filt;
trial.DX_noSac = trial.eyeDX_filt;
trial.DY_noSac = trial.eyeDY_filt;
trial.X_interpolSac = trial.eyeX_filt;
trial.Y_interpolSac = trial.eyeY_filt;
trial.DX_interpolSac = trial.eyeDX_filt;
trial.DY_interpolSac = trial.eyeDY_filt;
trial.quickphases = false(trial.length,1);
% now remove saccadic phase
% only do it for horizontal...
for i = 1:length(trial.saccades.X.onsets)
    % first we calculate the slope between the eye position at saccade on-
    % to saccade offset
    lengthSacX = trial.saccades.X.offsets(i) - trial.saccades.X.onsets(i);
    slopeX = (trial.eyeX_filt(trial.saccades.X.offsets(i))-trial.eyeX_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeDX = (trial.eyeDX_filt(trial.saccades.X.offsets(i))-trial.eyeDX_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeY = (trial.eyeY_filt(trial.saccades.X.offsets(i))-trial.eyeY_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeDY = (trial.eyeDY_filt(trial.saccades.X.offsets(i))-trial.eyeDY_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    % now we can add a completely de-saccaded variable in trial
    trial.X_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.Y_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DX_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DY_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    % and finally interpolate the eye position if we later want to plot
    % smooth eye movement traces
    for j = 1:lengthSacX+1
        trial.X_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeX_filt(trial.saccades.X.onsets(i)) + slopeX*j;
        trial.Y_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeY_filt(trial.saccades.X.onsets(i)) + slopeY*j;
        trial.DX_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeDX_filt(trial.saccades.X.onsets(i)) + slopeDX*j;
        trial.DY_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeDY_filt(trial.saccades.X.onsets(i)) + slopeDY*j;
    end   
end
% % do the exact same thing for y
% for i = 1:length(trial.saccades.Y.onsets)
%     
%     lengthSacY = trial.saccades.Y.offsets(i) - trial.saccades.Y.onsets(i);
%     slopeY = (trial.eyeY_filt(trial.saccades.Y.offsets(i))-trial.eyeY_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
%     slopeDY = (trial.eyeDY_filt(trial.saccades.Y.offsets(i))-trial.eyeDY_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
%     slopeX = (trial.eyeX_filt(trial.saccades.Y.offsets(i))-trial.eyeX_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
%     slopeDX = (trial.eyeDX_filt(trial.saccades.Y.offsets(i))-trial.eyeDX_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
%     
%     trial.X_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
%     trial.Y_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
%     trial.DX_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
%     trial.DY_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
%     
%     for j = 1:lengthSacY+1
%         trial.Y_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeY_filt(trial.saccades.Y.onsets(i)) + slopeY*j;
%         trial.X_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeX_filt(trial.saccades.Y.onsets(i)) + slopeX*j;
%         trial.DY_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeDY_filt(trial.saccades.Y.onsets(i)) + slopeDY*j;
%         trial.DX_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeDX_filt(trial.saccades.Y.onsets(i)) + slopeDX*j;
%     end    
% end
% done
end
