function [textExp,button] = instructionConfig
% ----------------------------------------------------------------------
% [textExp,button] = instructionConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Write text of calibration and general instruction for the experiment.
% ----------------------------------------------------------------------
% Input(s) :
% (none)
% ----------------------------------------------------------------------
% Output(s):
% textExp : struct containing all text of general instructions.
% button : struct containing all button instructions.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

%% Screen gamma linearisation calibration
calibScreen_l1  = 'Gamma linearisation :';
calibScreen_l2  = '';
calibScreen_l3  = 'A white dot on a black square will appear, focus the photometer,';
calibScreen_l4  = 'to this white dot and press any button.';
calibScreen_l5  = '';
calibScreen_l6  = 'A colored screen will appear, measure it s luminance,';
calibScreen_l7  = 'then press [RETURN] button. ';
calibScreen_l8  = 'Enter the measured values, then press again [RETURN] button.';
calibScreen_l9  = '';
calibScreen_l10  = 'Keep continue until a new screen appears, telling you that';
calibScreen_l11  = 'the calibration is done.';
calibScreen_l12  = '';
calibScreen_b1 = '-----------------  PRESS [SPACE] TO CONTINUE  -----------------';

textExp.calibScreen = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                       calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11;calibScreen_l12};
button.calibScreen = {calibScreen_b1};

%% Screen gamma linearisation calibration end :
calibScreenEnd_l1 = 'Gamma linarisation measurments correctly done.' ;
calibScreenEnd_b1 = '--------------------  PRESS [SPACE] TO CONTINUE  -------------------';

textExp.calibScreenEnd = {calibScreenEnd_l1};
button.calibScreenEnd =  {calibScreenEnd_b1};

end