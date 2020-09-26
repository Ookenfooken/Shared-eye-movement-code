% FUNCTION to filter raw eye movement data and calculate velocity,
% acceleration, and jerk
% history
% ancient past  MS created SOCSCALEXY probably in C
% 31-05-11      MS checked and corrected SOCSCALEXY
% 07-2012       JE edited socscalexy.m
% 05-2014       JF edited and renamed function to processEyeData.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 
% input: eyeData --> structure containing raw eye data in pixels and degs
% output: eyeData --> structure now containing filtered data and velocity
%                     and acceleration etc. 

function [eyeData] = processEyeData(eyeData)
%% set up filter
sampleRate = evalin('base', 'sampleRate');
filtFrequency = sampleRate/2;
filtOrder = 2;
filtCutoffPosition = 15;
filtCutoffVelocity = 30;
% we currently use a butterworth filter which seems to be commonly used
[a,b] = butter(filtOrder,filtCutoffPosition/filtFrequency);
[c,d] = butter(filtOrder,filtCutoffVelocity/filtFrequency);

%% position
eyeData.X_filt = filtfilt(a,b,eyeData.X);
eyeData.Y_filt = filtfilt(a,b,eyeData.Y);

%% velocity
eyeData.DX = diff(eyeData.X)*sampleRate;
eyeData.DY = diff(eyeData.Y)*sampleRate;
% also fiter velocity traces
DX_tmp = diff(eyeData.X_filt)*sampleRate;
eyeData.DX_filt = filtfilt(c,d,DX_tmp);
DY_tmp = diff(eyeData.Y_filt)*sampleRate;
eyeData.DY_filt = filtfilt(c,d,DY_tmp);

%% acceleration
% same procedure for acceleration
DDX_tmp = diff(eyeData.DX_filt)*sampleRate;
eyeData.DDX_filt = filtfilt(c,d,DDX_tmp);
DDY_tmp = diff(eyeData.DY_filt)*sampleRate;
eyeData.DDY_filt = filtfilt(c,d,DDY_tmp);

%% jerk for detecting saccades and quick phases
eyeData.DDDX = diff(eyeData.DDX_filt)*sampleRate;
eyeData.DDDY = diff(eyeData.DDY_filt)*sampleRate;

%% make sure all data series have the same length
eyeData.DX = [eyeData.DX; NaN];
eyeData.DY = [eyeData.DY; NaN];
eyeData.DX_filt = [eyeData.DX_filt; NaN];
eyeData.DY_filt = [eyeData.DY_filt; NaN];

eyeData.DDX_filt = [eyeData.DDX_filt; NaN; NaN];
eyeData.DDY_filt = [eyeData.DDY_filt; NaN; NaN];

eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];

end
