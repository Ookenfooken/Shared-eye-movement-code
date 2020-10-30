function [trakstar] = trakstar_dataAcquisition(trakstar, trialData, trialNum)
% Data Acquisition for trakstar:
%   PK 28/03/2019

%%% Sample and plot finger tracking data
% screen coordinate of finger
trakstarData = trakstar_getData(trakstar);
trakstarData.time = trakstarData.time - trialData.tTrakstarSync(trialNum);
trakstar.Data.raw = trakstarData;


new_coord = trakstar.CalFcn.world_2_screen([trakstarData.pos, trakstarData.ori]);

% finger shown in screen coordinate
if isfield(trakstar.Data, 'coord')
    dc = (new_coord - trakstar.Data.coord);
    dt = (trakstar.Data.time - trakstarData.time);
else
    dc = 0;
    dt = 1;
end

trakstar.Data.vcoord = dc / dt;
trakstar.Data.time   = trakstarData.time;
trakstar.Data.coord  = new_coord;


end

