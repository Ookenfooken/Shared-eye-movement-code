function eyelink_recalibration(control,const,el,forceCalib)
%Recalibration of the Eyelink between Blocks:
%   PK 27/03/2019


recalibrate = 0;

for i = 1:numel(const.numTrialsPerBlock)                                  % starts from 2 because we assume we don't do any calibration after training (= the first block)
    if control.currentTrial == sum(const.numTrialsPerBlock(1:i)) + 1 
        recalibrate = 1;
        break;
    end
end

if forceCalib
    recalibrate = 1;
end


if recalibrate
    disp('EYECATCH: Recalibrate / Validate the eye tracker');
    EyelinkDoTrackerSetup(el);
end


end

