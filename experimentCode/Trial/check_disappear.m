% function b = check_disappear(control, trialData)
% % check whether the target has already disappeared from screen
% 
% b = control.tElapse >= trialData.tDisappear(control.currentTrial) && ...
%     trialData.tDisappear(control.currentTrial) ~= -1;
% 
% end