function b = check_reappear(control, trialData)
% check whether the target has already reappeared

b = control.tElapse >= control.tReappear && control.tElapse < control.tReappear + 0.101 && ...
    trialData.tDisappear(control.currentTrial) ~= -1;

end