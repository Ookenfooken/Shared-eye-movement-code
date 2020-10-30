function [trakstar] = trakstar_recalibration(control,const,trakstar,el,screen,forceCalib)
%Recalibration of the Trakstar between Blocks
%   PK 27/03/2019

recalibrate = 0;

for i_ = 1:numel(const.numTrialsPerBlock)                                   % starts from 2 because we assume we don't do any calibration after training (= the first block)
    if control.currentTrial == sum(const.numTrialsPerBlock(1:i_)) + 1       % check for recalibration between blocks
        recalibrate = 1;
        break;
    end
end

if forceCalib                                                               % recalibrate if this is forced by experimenter
    recalibrate = 1;
end
            
if recalibrate
    [trakstar] = trakstar_calibration(trakstar,el,screen);                  % perform recalibration
    [trakstar] = trakstar_getStartPos(trakstar);                            % get start position again (maz have changed bz recalibration)
end

end

