%% script saving flagged errors

% history
% 07-2015       JF saveErrors.m
% 16-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

% add all flagged trials to existing csv file containing previously flagged
% trials
csvwrite('errors.csv', errors)   

close all
clear all