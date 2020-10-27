function [rgb]=cdpms2gun(screen,candelaVal,colorAsk)
% ----------------------------------------------------------------------
% [rgb]=cdpms2gun(screen,const,candelaVal,colorAsk)
% ----------------------------------------------------------------------
% Goal of the function :
% Give the triplet gun values for the desired gray or RGB in candela/m2
% ----------------------------------------------------------------------
% Input(s) :
% screen : window pointer struct
% const : struct containing previous constant configurations.
% candelaVal = desired candela val
% colorAsk = color wanted ('red','green','blue','gray')
% ----------------------------------------------------------------------
% Output(s):
% [rgb] = Gun values in RGB (0->255)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

switch colorAsk
    case 'red'
        if candelaVal > screen.tabCalibRed(end,end) 
            candelaVal = screen.tabCalibRed(end,end);
        end
        rgb = [1 0 0]*InvertGammaExtP([screen.RGBparamGamma(1,1),screen.RGBparamGamma(2,1)],255,candelaVal/screen.tabCalibRed(end,end));
    case 'green'
        if candelaVal > screen.tabCalibGreen(end,end)
            candelaVal = screen.tabCalibGreen(end,end);
        end
        rgb = [0 1 0]*InvertGammaExtP([screen.RGBparamGamma(1,2),screen.RGBparamGamma(2,2)],255,candelaVal/screen.tabCalibGreen(end,end));
    case 'blue'
        if candelaVal > screen.tabCalibBlue(end,end)
            candelaVal = screen.tabCalibBlue(end,end);
        end
        rgb = [0 0 1]*InvertGammaExtP([screen.RGBparamGamma(1,3),screen.RGBparamGamma(2,3)],255,candelaVal/screen.tabCalibBlue(end,end));
    case 'gray'
        if candelaVal > screen.tabCalibGray(end,end)
            candelaVal = screen.tabCalibGray(end,end);
        end
        rgb = [1 1 1]*InvertGammaExtP([screen.GRAYparamGamma(1),screen.GRAYparamGamma(2)],255,candelaVal/screen.tabCalibGray(end,end));
end

end