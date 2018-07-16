%% script flagging errors when you hit "dicard trial" in GUI

% history
% 07-2015       JF created markError.m
% 16-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

cd(currentSubjectPath);
% flagging errors depends on each experiment (e.g. in EyeStrike we flag if
% participants hit outside the strike box etc.
errorType = ['Signal loss ' num2str(currentTrial) '\n'];
errorNum = 999;
% we currently create a text file for each participant in case something
% goes wrong while saving the csv file we have a text file containing the
% info of which trials made problems
fid = fopen([currentSubject 'errors.txt'],'a');
fprintf(fid, char(errorType), 'char');
fclose(fid);
cd(analysisPath);
% no add the current error to the overall error matrix
currentError = [trial.log.subject, errorNum, str2double(trial.number)];
errors = [errors; currentError];