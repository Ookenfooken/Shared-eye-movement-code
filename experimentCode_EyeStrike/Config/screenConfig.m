function [screen] = screenConfig(const)
% ===============================================================
% screenConfig(const)
% ===============================================================
% written by: Philipp KREYENMEIER (philipp.kreyenmeier@gmail.com)
% 
% Last Changes:
%
% ---------------------------------------------------------------
% Inputs: 
% const: structure containing different constant settings
% keys: strucrure containing defined keys
% ---------------------------------------------------------------
% 
% Overview setups in the lab:
% EyeStrike: w = 418, h = 334, wp = 1280, hp = 1024, d = 44
% Backroom : w = 396, h = 297, wp = 1600, hp = 1200, d = XX
% ---------------------------------------------------------------

% Screen name:
screen.name                = 'EyeStrike';

% Enter desired Screen Settings:
% !!! EYESTRIKE:
% screen.desired_Hertz       = 120;											% desired Refresh Rate (Hz) of the Screen
% screen.desired_widthPX     = 1280;											% desired width (pixels) of the Screen
% screen.desired_heightPX    = 1024;											% desired height(pixels) of the Screen
% 
% screen.widthMM             = 418;                                           % measured size (in mm)
% screen.heightMM            = 334;                                           % measured size (in mm)
% screen.widthCM             = 41.8;
% screen.heightCM            = 33.4;
% screen.dist                = 44;                                            % measured distance Subject-Screen (in cm)

% !! HOME-external Display:
screen.desired_Hertz       = 60;											% desired Refresh Rate (Hz) of the Screen
screen.desired_widthPX     = 1920;											% desired width (pixels) of the Screen
screen.desired_heightPX    = 1080;											% desired height(pixels) of the Screen

screen.widthMM             = 540;                                           % measured size (in mm)
screen.heightMM            = 389;                                           % measured size (in mm)
screen.widthCM             = 54.0;
screen.heightCM            = 38.9;
screen.dist                = 44;                                            % measured distance Subject-Screen (in cm)

% % !! HOME-Mac:
% screen.desired_Hertz       = 60;											% desired Refresh Rate (Hz) of the Screen
% screen.desired_widthPX     = 1440;											% desired width (pixels) of the Screen
% screen.desired_heightPX    = 900;											% desired height(pixels) of the Screen
% 
% screen.widthMM             = 304;                                           % measured size (in mm)
% screen.heightMM            = 212;                                           % measured size (in mm)
% screen.widthCM             = 30.4;
% screen.heightCM            = 21.2;
% screen.dist                = 44;   

Screen('Preference', 'SkipSyncTests', 1);

% Get Screen from PTB:
if ~const.startExp && ~const.runScreenCalib
    PsychDebugWindowConfiguration(0,0.5); 									% when in debugging, set transparency to 50%	
     screen.number = min(Screen('Screens'));
%    screen.number = 1;
    sca
    
else
    screen.number = min(Screen('Screens'));  %screen.number = 1; %
%   screen.number = 1; 
end

% Validate Screen Size:
[screen.widthPX, screen.heightPX] = Screen('WindowSize', screen.number);
if (screen.widthPX ~= screen.desired_widthPX || screen.heightPX ~= screen.desired_heightPX(1)) && const.startExp
    error('Incorrect screen resolution => Please restart the program after changing the resolution to [%i,%i]',screen.desired_widthPX(1),screen.desired_heightPX(1));
end
% Screen Center:
screen.x_mid               = screen.widthPX/2;
screen.y_mid               = screen.heightPX/2;
screen.mid                 = [screen.x_mid screen.y_mid];

% Pix2Deg and Deg2Pix conversions:
screen.width_deg          = 2 * (180/pi) * atan2(screen.widthCM  / 2, screen.dist);
screen.height_deg         = 2 * (180/pi) * atan2(screen.heightCM  / 2, screen.dist);
screen.x_ppd              = screen.widthPX / screen.width_deg;
screen.y_ppd              = screen.heightPX / screen.height_deg;
screen.pixelRatio         = screen.x_ppd / screen.y_ppd;

screen.ppd                = exp(mean(log([screen.x_ppd screen.y_ppd])));
screen.dpp                = 1 / screen.ppd;


% Validate Refresh Rate:
screen.refreshRate         = 1/(Screen('FrameRate',screen.number));
if screen.refreshRate == inf
    screen.refreshRate     = 1/60;
elseif screen.refreshRate == 0
    screen.refreshRate     = 1/60;
end
screen.hertz = 1/(screen.refreshRate);
if (screen.hertz >= 1.1*screen.desired_Hertz || screen.hertz <= 0.9*screen.desired_Hertz) && const.startExp
    error('Incorrect refresh rate => Please restart the program after changing the refresh rate to %i Hz',screen.desired_Hertz);
end

% Pixel Size:
screen.clr_depth           = Screen('PixelSize', screen.number);


% Load in Gamma Calibration, if Screen is not being calibrated:
screen.calibFlag           = 1;                                             % 1 = use gamma Calibration (recommanded); 0 = run experiment w/o screen calibration
screen.calibType           = 1;                                             % 1 = Gray linearized; 2 = RGB linearized
screen.dirCalib            = 'GammaCalib';
screen.desiredValue        = 16;                                            % number of test colors/grey scales
if ~const.runScreenCalib
    if screen.calibFlag  == 1                                               % Load gamma calibration
        if screen.calibType == 1                                            % Gray linearized calibration loaded
            [screen]           = loadGRAYLinCalib(screen);
        elseif screen.calibType == 2                                         % RGB linearized calibration loaded
            [screen]           = loadRGBLinCalib(screen);
        end
        loadgammaCalib(screen);
    end
end


% Color and Luminance Settings:
screen.background          = 220;                                            % Background luminance 1
screen.background2         = 220;                                            % Background luminance 2
screen.occluderColor       = [175 175 175];
screen.white               = 255;
screen.black               = 0;
screen.gray                = 127;
screen.orange              = [255,150,0];
screen.green20             = [0 33.977 0];

end

