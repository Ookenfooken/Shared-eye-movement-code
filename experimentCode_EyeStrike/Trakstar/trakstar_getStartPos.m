function [trakstar] = trakstar_getStartPos(trakstar)
% get individual start position for trakstar, used for later fixation
% check.

%% first, get sample when at fixation spot:
while 1
    if PTBcheck_key_press('SPACE')
        trakstarData = trakstar_getData(trakstar);
        trakstar.Data.raw = trakstarData;
        trakstar.startPos = trakstar.CalFcn.world_2_screen([trakstarData.pos, trakstarData.ori]);
        break;
    end
end

end

