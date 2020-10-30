function [screen]=gammaCalib(screen,const,keys)
% ----------------------------------------------------------------------
% [screen]=gammaCalib(screen,const,keys,textExp,button)
% ----------------------------------------------------------------------
% Measure gamma correction for luminance, main file.
% ----------------------------------------------------------------------
% Input(s):
% screen: window pointer struct
% const:  struct containing previous constant configurations.
% keys:   struct containing button response configurations. 
% ----------------------------------------------------------------------
% Output(s):
% screen : struct containing window pointer configuration
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

close('all'),
dirC = screen.dirCalib;

[textExp, button]      = instructionConfig; 						        % Instruction page for Calibration Procedure


ListenChar(2)
if screen.calibType == 1         % Gray linearized calibration done

    [screen,f]  = grayLinCalib(screen,const,keys,textExp,button);         % Linearized screen on gray values
    [screen]    = grayCheckCalib(screen,const,keys,textExp,button,f);     % Check correct linearization and get gray params
    [screen]    = getRGBcalibVal(screen,const,keys,textExp,button);       % Get RGB values 

elseif screen.calibType == 2     % RGB linearized calibration done

    [screen,f]  =rgbLinCalib(screen,const,keys,textExp,button);           % Linearized screen on RGB values
    [screen]    =rgbCheckCalib(screen,const,keys,textExp,button,f);       % Check correct linearization and get RGB params
    [screen]    =getGRAYcalibVal(screen,const,keys,textExp,button);       % Get gray values

end


%% SAVING FILE
if screen.calibType == 1
    calibFileDir = sprintf('%s/Gamma/%s/%i/GRAY_Lin/GammaCalibration.txt',dirC,screen.name,screen.dist);
    typeCal = 'GRAY linearized';
elseif screen.calibType == 2
    calibFileDir = sprintf('%s/Gamma/%s/%i/RGB_Lin/GammaCalibration.txt',dirC,screen.name,screen.dist);
    typeCal = 'RGB linearized';
end

fid = fopen(calibFileDir,'w');

fprintf(fid,'\n\n\t ----------------------------------- \n');
fprintf(fid,'\t|         Gamma calibration           |\n');
fprintf(fid,'\t ----------------------------------- \n');

fprintf(fid,sprintf('\n\t Screen ID : \t\t\t%s',screen.name));
fprintf(fid,sprintf('\n\t Screen distance : \t\t%i cm',screen.dist));
fprintf(fid,sprintf('\n\t Calibration type : \t%s',typeCal));
fprintf(fid,sprintf('\n\t Creation date : \t\t%s',date));
my_clock = clock;
fprintf(fid,sprintf('\n\t Creation time : \t\t%i:%i',my_clock(4),my_clock(5)));
fprintf(fid,sprintf('\n\n\t Max RED lum. : \t\t%i',screen.tabCalibRed(end,end)));
fprintf(fid,sprintf('\n\t Max GREEN lum. : \t\t%i',screen.tabCalibGreen(end,end)));
fprintf(fid,sprintf('\n\t Max BLUE lum. : \t\t%i',screen.tabCalibBlue(end,end)));
fprintf(fid,sprintf('\n\t Max GRAY lum. : \t\t%i',screen.tabCalibGray(end,end)));

