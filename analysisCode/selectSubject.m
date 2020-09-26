% FUNCTION to select a target folder containing eye movement data
% history
% 07-2012       JF created selectSubject.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 
% input: dataPath --> general data path
% output: selectedSubject --> folder path of selected subject/data folder

function selectedSubject = selectSubject(dataPath)
% specify your working directory
currentLocation = pwd;
% go into general data folder
cd(dataPath);
folder = pwd;
% go back into working directory
cd(currentLocation);
% Get subject data file
[selectedSubject] = uigetdir(folder,'select subject in Data');
end