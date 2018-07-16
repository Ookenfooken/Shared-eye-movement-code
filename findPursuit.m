% FUNCTION to find pursuit onset by detecting direction change in x/y
% pursuit traces; requires changeDetect.m, evalPWL.m, and ms2frames.m

% history
% ancient past  MS created SOCCHANGE probably in C
% 23-02-09      MS checked and corrected SOCCHANGE
% 07-2012       JE edited socchange.m
% 05-2014       JF edited and renamed function to findPursuit.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
% output: pursuit --> structure containing info about pursuit onset

function [pursuit] = findPursuit(trial)

anticipatoryPeriod = 260; % when should we start looking for pursuit onset
pursuitSearchEnd = 140; % this means we stop searching for pursuit onset 140 ms after stimulus onset
% x-value: TIME
if trial.stim_onset > anticipatoryPeriod
    startTime = trial.stim_onset-anticipatoryPeriod;
    % we want to make sure the end point is before the catch up saccade
    endTime = min([trial.stim_onset+ms2frames(pursuitSearchEnd) trial.saccades.onsets(1)]);
else
    startTime = trial.stim_onset-(trial.stim_onset-1);
    endTime = min([trial.stim_onset-1+ms2frames(pursuitSearchEnd) trial.saccades.onsets(1)]);
end

% this is basically saying there is no pursuit
if endTime-startTime < 10
    pursuit.onset = NaN;
else   
    time = startTime:endTime;
    fixationInterval = 275; % chose an interval before stimulus onset that
    % we will use as fixation window; needs to be at least 201 ms
    if trial.stim_onset > fixationInterval
        fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-100)));
        fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-100)));
    else
        fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-200)));
        fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-200)));
    end    
    % 2. calculate 2D vector relative to fixation position
    dataxy_tmp = sqrt( (trial.eyeDX_filt-fix_x).^2 + (trial.eyeDY_filt-fix_y).^2 );
    XY = dataxy_tmp(time);       
    % run changeDetect.m
    [cx,cy,ly,ry] = changeDetect(time,XY);  
    pursuit.onset = round(cx);
    % this next part has been written by JF to make sure that the pursuit
    % onset is ligit (e.g. not in an undetected saccade or during a
    % fixation --> there was no pursuit at all
    mark = pursuit.onset;
    % in this first part we're getting the first saccade onset after the
    % stimulus starts moving to make sure that the pursuit onset is before
    if isempty(trial.saccades.onsets)
        on = NaN;
        off = NaN;
        idx = 0;
        idy = 0;
    else
        on = trial.saccades.onsets(1);
        off = trial.saccades.offsets(1);
        if isempty(trial.saccades.X.onsets(1))
            idx = 0;
            idy = find(trial.saccades.Y.onsets == trial.saccades.Y.onsets(1))-1;
        elseif isempty(trial.saccades.Y.onsets(1))
            idx = find(trial.saccades.X.onsets == trial.saccades.X.onsets(1))-1;
            idy = 0;
        else
            idx = find(trial.saccades.X.onsets == trial.saccades.X.onsets(1))-1;
            idy = find(trial.saccades.Y.onsets == trial.saccades.Y.onsets(1))-1;
        end
    end
    if idx == 0 && idy == 0
        earlyOn = NaN;
        earlyOff = NaN;
    elseif idx == 0 && idy > 0
        earlyOn = trial.saccades.Y.onsets(idy);
        earlyOff = trial.saccades.Y.offsets(idy);
    elseif idx > 0 && idy == 0
        earlyOn = trial.saccades.X.onsets(idx);
        earlyOff = trial.saccades.X.offsets(idx);
    elseif idx > 0 && idy > 0
        earlyOn = max([trial.saccades.X.onsets(idx) trial.saccades.Y.onsets(idy)]);
        earlyOff = max([trial.saccades.X.offsets(idx) trial.saccades.Y.offsets(idy)]);
    end
    endMark = min([(mark+240) trial.saccades.onsets(1)]); %indicates end of open loop phase
    checkX = mean(trial.eyeDX_filt(mark:endMark));
    checkY = mean(trial.eyeDY_filt(mark:endMark));
    % first check, if the pursuit onset is inside the first saccade
    if mark >= on && mark <= off
        pursuit.onset = pursuit.onset + 50;
        pursuit.saccadeType = 1;
        % check if it is not inside the previous saccade that happens during
        % target onset
    elseif mark >= earlyOn && mark <= earlyOff ||...
            mark <= earlyOn
        pursuit.onset = earlyOff;
        pursuit.saccadeType = -1;
        if pursuit.onset < trial.stim_onset-280 || isnan(pursuit.onset)
            pursuit.onset = off;
            pursuit.saccadeType = -2;
        end
    elseif sqrt(((abs(trial.eyeDX_filt(mark))).^2+(abs(trial.eyeDY_filt(mark))).^2)) > 18
        pursuit.onset = pursuit.onset + 50;
        pursuit.saccadeType = -1;
        if pursuit.onset < trial.stim_onset-280 || isnan(pursuit.onset)
            pursuit.onset = pursuit.onset + 50;
            pursuit.saccadeType = -2;
        end
    % check if the pursuit onset is not just a fixation
    elseif ceil(sqrt(checkX.^2+checkY.^2)*10)/10 < 1.5
        pursuit.onset = endMark;
        pursuit.saccadeType = 2;
    else %everything fine
        pursuit.saccadeType = 0;
    end    
    % just mark the pursuit onset types to later count what's going on
    if mark < trial.stim_onset
        pursuit.onsetType = -1;
    elseif mark == trial.stim_onset
        pursuit.onsetType = 0;
    else
        pursuit.onsetType = 1;
    end
end

end