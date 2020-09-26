% function to match target to eye data
% Since the target data and the eye data are recorded at different frames
% we need to extrapolate target data
function target = createTargetData(targetPosition, trialNo, eyeData, currentSubject, task)

sampleRate = evalin('base', 'sampleRate');

currentTrial = trialNo(end-4);
name = {['trial' currentTrial]};
if strcmp(task, 'smoothPursuit') % for smooth pursuit
    currentTarget = targetPosition.(name{1});
    onset = currentTarget;
    trialLength = size(eyeData.X_filt,1);
    offset = trialLength;
    targetLength = offset-onset;
    
    target.onset = onset;
    target.offset = offset;
    
    % generate target data in the same time frame as eye movement data
    if currentSubject == 82 || currentSubject == 34 || currentSubject == 28 || currentSubject == 70
        if str2double(currentTrial) == 1 || str2double(currentTrial) == 3
            frequency = 0.4;
        else
            frequency = 1;
        end
    elseif  currentSubject == 60
        if str2double(currentTrial) == 1 || str2double(currentTrial) == 3
            frequency = 0.2;
        else
            frequency = 0.5;
        end
    else
        frequency = targetPosition.frequency(str2double(currentTrial));
    end
    amplitude = 400; %in pixels
    t = 0:1/sampleRate:targetLength/sampleRate-0.001;
    if str2double(currentTrial) < 3
        x = amplitude*sin(2*pi*frequency*t);
        target.Xpixel = x';
        target.Ypixel = zeros(targetLength,1);
    else
        target.Xpixel = zeros(targetLength,1);
        y = amplitude*sin(2*pi*frequency*t);
        target.Ypixel = y';
    end
    targetXY = pixels2degrees(target.Xpixel, target.Ypixel);
    
    target.Xdeg = [zeros(onset,1); targetXY.degX; zeros(trialLength-offset,1)];
    target.Ydeg = [zeros(onset,1); targetXY.degY; zeros(trialLength-offset,1)];
    
    target.Xvel = [zeros(onset,1); diff(targetXY.degX)*sampleRate; zeros(trialLength-offset+1,1)];
    target.Yvel = [zeros(onset,1); diff(targetXY.degY)*sampleRate; zeros(trialLength-offset+1,1)];
    
    if sum(target.Ydeg) == 0
        target.cycle.maxima = find(target.Xdeg == max(target.Xdeg));
        target.cycle.minima = find(target.Xdeg == min(target.Xdeg));
    elseif sum(target.Xdeg) == 0
        target.cycle.maxima = find(target.Ydeg == max(target.Ydeg));
        target.cycle.minima = find(target.Ydeg == min(target.Ydeg));
    end
    
    crossing = target.onset;
    extrema = sort([target.cycle.maxima; target.cycle.minima]);
    for i = 2:length(extrema)
        crossing(i) = crossing(i-1) + (extrema(i) - extrema(i-1));
    end
    target.cycle.crossing = crossing;
elseif strcmp(task, 'predictivePursuit')% for predictive pursuit
    currentTrial = str2num(trialNo(end-6:end-4));
    trialLength = size(eyeData.X_filt,1);
    target.onset = find(eyeData.timeStamp==targetPosition.time(currentTrial, 1));
    validIdx = find(targetPosition.time(currentTrial, :)~=0);
    target.offset = find(eyeData.timeStamp==targetPosition.time(currentTrial, validIdx(end)))+1;
    
    timePoints = [targetPosition.time(currentTrial, 1):1:targetPosition.time(currentTrial, validIdx(end))]; % interpolate the same length
    target.Xpxl = interp1(targetPosition.time(currentTrial, 1:validIdx(end)), targetPosition.posX(currentTrial, 1:validIdx(end)), timePoints);
    target.Ypxl = interp1(targetPosition.time(currentTrial, 1:validIdx(end)), targetPosition.posY(currentTrial, 1:validIdx(end)), timePoints);
    degXY= pixels2degrees(target.Xpxl-targetPosition.screenX(currentTrial, 1)/2, target.Ypxl-targetPosition.screenY(currentTrial, 1)/2); % right and down is positive, center is 0
    
    target.Xdeg = [zeros(target.onset-1,1); degXY.degX'; zeros(trialLength-target.offset+1,1)];
    target.Ydeg = [zeros(target.onset-1,1); -degXY.degY'; zeros(trialLength-target.offset+1,1)];% flip to make up positive
    
    target.Xpxl = [zeros(target.onset-1,1); target.Xpxl'; zeros(trialLength-target.offset+1,1)];
    target.Ypxl = [zeros(target.onset-1,1); target.Ypxl'; zeros(trialLength-target.offset+1,1)];
    
    velX = diff(degXY.degX')*sampleRate;
    velX = repmat(round(mean(velX)), size(velX));   % just round to the average...
    velY = diff(degXY.degY')*sampleRate;
    velY = repmat(round(mean(velY)), size(velY));   % just round to the average...
    target.Xvel = [zeros(target.onset,1); velX; zeros(trialLength-target.offset+1,1)];
    target.Yvel = [zeros(target.onset,1); velY; zeros(trialLength-target.offset+1,1)];
end
end
