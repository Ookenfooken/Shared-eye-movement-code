%% script running functions to update plots and text fields in open figure
% we need this script so we can call it every time we click on "next" or
% "previous trial"; requires updatePlots.m and updateText.m

% history
% 07-2012       JE created plotResults.m
% 16-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

% for general structure
updatePlots(trial);
updateText(trial, fig);

% % if pursuit analysis is included
% updatePlots(trial, pursuit);
% updateText(trial, pursuit, fig);