%% script creating a new button to end the clicking through process
% runs saveErrors.m 

% history
% 07-2015       JF created finishButton.m
% 16-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

if currentTrial == numTrials
    buttons.finish = uicontrol(fig, 'String', 'Save Errors', 'Position',[100,75,100,60],...
       'callback','saveErrors;');
end

% % if you have included saccade adjustements
% if currentTrial == numTrials
%     buttons.finish = uicontrol(fig, 'String', 'Save Errors', 'Position',[100,75,100,60],...
%        'callback','cd(currentSubjectPath); save adjustments adjustedSacs; cd(analysisPath); saveErrors;');
% end

