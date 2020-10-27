function loadgammaCalib(screen)
% ----------------------------------------------------------------------
% loadgammaCalib(wPtr,const)
% ----------------------------------------------------------------------
% Goal of the function :
% Measure/Find and load gamma correction for luminance
% ----------------------------------------------------------------------
% Input(s) :
% wPtr : window pointer struct
% const : struct containing all constant settings
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------
dirC = screen.dirCalib;
if screen.calibType == 1
    screen.invGammaTable = csvread(sprintf('%s/Gamma/%s/%2.0f/GRAY_Lin/InvertGammaTable_%s_%2.0f.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
elseif screen.calibType == 2
    screen.invGammaTable = csvread(sprintf('%s/Gamma/%s/%2.0f/RGB_Lin/InvertGammaTable_%s_%2.0f.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
end
Screen('LoadNormalizedGammaTable', screen.number, screen.invGammaTable);
WaitSecs(1);
end