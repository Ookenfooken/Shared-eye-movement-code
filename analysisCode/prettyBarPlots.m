%% This script is a template on how to plot bar plots with data points on top
% created by JF in 2017
% commented and edited by JF on 21.11.2018
%%
% Load your data
allData = load('dada');
% if you have several conditions you can separate them
% e.g.condition is stored in first column, variable in second
data_condition1 = allData(allData(:,1) == 1,:);
data_condition2 = allData(allData(:,1) == 2,:);
% define your number of subjects/individual data points
numSubjects = 10;

%%
% find mean and std of your variable to plot bar plot
bar_variable1 = [mean(data_condition1(:,2)); mean(data_condition2)];
std_variable1 = [std(data_condition1(:,2)); std(data_condition2)];

% if you have more conditions, e.g. a 2x2 design you can split further here
% e.g. (in this example you also have 3 manilupations that are 
% stored in the second column and your variable in the third
bar_variable2 = [mean(data_condition1(data_condition1(:,1) == 1, 3)); mean(data_condition1(data_condition1(:,1) == 2, 3)); ...
    mean(data_condition1(data_condition1(:,1) == 3, 3)); mean(data_condition2(data_condition2(:,1) == 1, 3)); ...
    mean(data_condition2(data_condition2(:,1) == 2, 3)); mean(data_condition2(data_condition2(:,1) == 3, 3))];
std_variable2 = [std(data_condition1(data_condition1(:,1) == 1, 3)); std(data_condition1(data_condition1(:,1) == 2, 3)); ...
    std(data_condition1(data_condition1(:,1) == 3, 3)); std(data_condition2(data_condition2(:,1) == 1, 3)); ...
    std(data_condition2(data_condition2(:,1) == 2, 3)); std(data_condition2(data_condition2(:,1) == 3, 3))];

%% Plot all this in a pretty way
figure(1)
% 2 bars for condition 1 and 2 (1 manipulation)
H1=bar([bar_variable1(1,2) bar_variable1(2,2)]); 
box off
set(H1,'EdgeColor',[0.25 0.25 0.25],'FaceColor',[0.75,0.75,0.75],'LineWidth',1.5) 
% error bars
hold on
xVect = [1 2]';
for i=1:length(bar_variable1)
  plot([xVect(i), xVect(i)],[bar_variable1(i,2)-std_variable1(i,2), bar_variable1(i,2)+std_variable1(i,2)],'-k','LineWidth',3)
end
% add raw data points
temp = [data_condition1(1:numSubjects,2) data_condition2(1:numSubjects,2)];
for j=1:length(bar_variable1)
    x = repmat(xVect(j),1,length(temp)); %the x axis location
    x = x+(rand(size(x))-0.5)*0.05; %add a little random "jitter" to aid visibility

    plot(x,temp(:,j),'.k', 'MarkerSize', 10)
end
hold off

% plot 6 bars for condition 1 and 2 (3 manipulations)
figure(2)
% bar plots
H2 = bar([bar_variable2(1:3,2) bar_variable2(4:6,2)]); 
box off
set(H2,'EdgeColor',[0.25 0.25 0.25],'FaceColor',[0.75,0.75,0.75],'LineWidth',1.5) 
% error bars
hold on
xVect = [0.85 1.85 2.85 1.15 2.15 3.15]';
for i=1:length(bar_variable2)
  plot([xVect(i), xVect(i)],[bar_variable2(i,2)-std_variable2(i,2), bar_variable2(i,2)+std_variable2(i,2)],'-k','LineWidth',3)
end
% add raw data points
temp = [data_condition1(1:numSubjects,2) data_condition1(numSubjects+1:2*numSubjects,2) data_condition1(2*numSubjects+1:end,2) ...
    data_condition2(1:numSubjects,2) data_condition2(numSubjects+1:2*numSubjects,2) data_condition2(2*numSubjects+1:end,2)];
for j=1:length(bar_variable2)
    x = repmat(xVect(j),1,length(temp)); %the x axis location
    x = x+(rand(size(x))-0.5)*0.05; %add a little random "jitter" to aid visibility

    plot(x,temp(:,j),'.k', 'MarkerSize', 10)
end
hold off

