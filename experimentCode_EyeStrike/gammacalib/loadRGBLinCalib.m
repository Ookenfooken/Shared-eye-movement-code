function [screen] = loadRGBLinCalib(screen)
% ----------------------------------------------------------------------
% [screen] = loadGRAYLinCalib[screen]
% ----------------------------------------------------------------------
% Goal of the function :
% Load necessary values to specified RGB and Gray Values in candela/m2 
% and load the linearisation on gray values.
% ----------------------------------------------------------------------
% Input(s) :
% screen : window pointer struct
% ----------------------------------------------------------------------
% Output(s):
% screen : window pointer struct
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

dirC = screen.dirCalib;
screen.invGammaTable = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/InvertGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));

screen.RGBparamGamma  = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/RGB_ParamFitExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
screen.GRAYparamGamma = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/GRAY_ParamFitExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));

screen.tabCalibRed   = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_RedGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
screen.tabCalibGreen = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_GreenGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
screen.tabCalibBlue  = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_BlueGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));
screen.tabCalibGray  = csvread(sprintf('%s/Gamma/%s/%i/RGB_Lin/Ini_GrayGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist));

end