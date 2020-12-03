% Find separation time based on  each subject saccade rate for go vs. nogo
subjectList = [4 8 16 23 35:37 39 40 43:58 100 102:104 107:108 110:113 115:120 122];
numSubjects = length(subjectList);
load('saccadeRate_ROC')
% remove players that move their hand in > 80 % of the trials
saccadeRate(saccadeRate(:,1) == 6 | saccadeRate(:,1) == 105 | saccadeRate(:,1) == 121, :) = [];
%saccadeRate = saccadeRate(saccadeRate(:,2) == 1, :);
minNogo = 50;
% find subject average saccade rate for each condition
% 1. separate by outcome, i.e. go vs. no-go
goData = saccadeRate(saccadeRate(:,4) == 1, :); %column 4 contains outcome
nogoData = saccadeRate(saccadeRate(:,4) == 0, :);
% 2. for each subject test at which point of time the difference becomes
% significant 
% data will be downsampled to smooth noise
n = 2;
numAverage = 3*n-1;
numSamples = 900;
startFrame = 1;
pValue_sub = NaN(numSubjects, numSamples/n-2);
goRates = NaN(numSubjects, numSamples/n-2);
nogoRates = NaN(numSubjects, numSamples/n-2);
for i = 1:numSubjects
    currentSubject_go = goData(goData(:,1) == subjectList(i), startFrame+5:end);
    currentSubject_nogo = nogoData(nogoData(:,1) == subjectList(i), startFrame+5:end);
    % downsample data to get moving average
    currentSubject_go_ds = NaN(size(currentSubject_go,1), numSamples/n-2);
    currentSubject_nogo_ds = NaN(size(currentSubject_nogo,1), numSamples/n-2);
    for k = 1:size(currentSubject_go,1)
        c = 1;
        for l = 1:n:(numSamples-numAverage);
            currentSubject_go_ds(k,c) = nanmean(currentSubject_go(k,l:l+numAverage));
            c = c+1;
        end
    end
    for k = 1:size(currentSubject_nogo,1)
        c = 1;
        for l = 1:n:(numSamples-numAverage);
            currentSubject_nogo_ds(k,c) = nanmean(currentSubject_nogo(k,l:l+numAverage));
            c = c+1;
        end
    end
    for j = 1:numSamples/n-2
        pValue_sub(i,j) = ranksum(currentSubject_go_ds(:,j), currentSubject_nogo_ds(:,j));
    end
    goRates(i,:) = nanmean(currentSubject_go_ds);
    nogoRates(i,:) = nanmean(currentSubject_nogo_ds);
end

% find first p-value that is reliably under 0.01
separationTime = NaN(numSubjects, 1);
for i = 1:numSubjects
    if sum(isnan(pValue_sub(i,:))) == 223
        continue
    end
    pIdx = find(pValue_sub(i,:) < 0.01);
    separationTime(i) = pIdx(1)*n;
        % check that at least n = 10 consecutive numbers are lower that .05
%     dIdx = diff(pIdx) == 1;
%     n = 20;
%     pChanges = find([false,dIdx]~=[dIdx,false]);
%     cIdx = find(pChanges(2:2:end)-pChanges(1:2:end-1)>=n,1,'first');
     %separationTime(i) = pIdx(pChanges(2*cIdx-1))+100;
    
end

%%
screenSize = get(0,'ScreenSize');
fig = figure('Position', [50 50 screenSize(3)-200, screenSize(4)-250],'Name','Separation Time');
currentSubject = 2;
plotPvaluesSeparationTime;

buttons.previous = uicontrol(fig,'string','<< Previous','Position',[0,70,100,30],...
    'callback','currentSubject = max(currentSubject-1,1);plotPvaluesSeparationTime');

buttons.next = uicontrol(fig,'string','Next (0) >>','Position',[0,105,100,30],...
    'callback','clc;currentSubject = currentSubject+1;plotPvaluesSeparationTime');

buttons.adjustP = uicontrol(fig,'string','!Adjust separation!','Position',[0,220,100,30],...
    'callback', 'currentSubject = currentSubject;adjustSeparationTime');


%%
handOnset = csvread('handOnset.csv');
load('separationTime');
eyeHand = [separationTime handOnset]; 
eyeHand = eyeHand(~isnan(eyeHand(:,1)),:);

figure(2)
hold on
for i = 1:length(eyeHand)
    y1 = eyeHand(i,1);
    y2 = eyeHand(i,2);
    plot(1, y1, 'ko')
    plot(2, y2, 'ko')
    if y1 < y2
        color = [77,175,74]./255;
    else
        color = [0 0 128]./255;
    end
    line([1 2],[y1 y2], 'Color', color)
end
xlim([0 3])