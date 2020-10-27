function PTBinstruction_page(msg,screen)
% Function draws blank screen, presents instruciton message and waits for
% keypress.
% INPUT: screen-Structure (backgroundcolour & window) and a message

switch msg
    
    case 0         
        calibScreen_l1   = '----------------- Calibrate trakSTAR  -----------------';
        calibScreen_l2   = '';
        calibScreen_l3   = '    Put finger on dot and leave it there   ';
        calibScreen_l4   = '              until next dot appears               ';
        calibScreen_l5   = '';
        calibScreen_l6   = '';
        calibScreen_l7   = '';
        calibScreen_l8   = '';
        calibScreen_l9   = '';
        calibScreen_l10  = '';
        calibScreen_l11  = '';
        calibScreen_l12  = '';
        calibScreen_l13  = '';
        calibScreen_l14  = '';
        calibScreen_l15  = '';
        calibScreen_l16  = '';
        calibScreen_b1   = '----------------  PRESS [ESC] TO CONTINUE  ---------------';
        
        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                       calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                       calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
        
    case 1                                                                  % Initial Experiment Instructions
        
        calibScreen_l1   = '----------------- Experiment Instructions  -----------------';
        calibScreen_l2   = '';
        calibScreen_l3   = '    A white disk will appear in the center of the Screen.   ';
        calibScreen_l4   = '              Fixate the disk with your eyes.               ';
        calibScreen_l5   = '';
        calibScreen_l6   = '   At some point, the disk will jump to the left or right.  ';
        calibScreen_l7   = '       Move your eyes to the new location of the disk       ';
        calibScreen_l8   = '';
        calibScreen_l9   = '         After a while, the disk will start to move,        ';
        calibScreen_l10  = '   follow the disk as closely as possible with your eyes.   ';
        calibScreen_l11  = '';
        calibScreen_l12  = '  In some trials, a white square will be briefly flashed.   ';
        calibScreen_l13  = ' This can happen ANY time above or below the moving target. ';
        calibScreen_l14  = '      When a flash is present, move your eyes QUICKLY       ';
        calibScreen_l15  = '               to the location of the flash.                ';
        calibScreen_l16  = '';
        calibScreen_b1   = '----------------  PRESS [SPACE] TO CONTINUE  ---------------';

        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                       calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                       calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
    
        
    case 2                                                                  % Instruction that is shown before each block
        calibScreen_l1   = ' ---------------- Calibration Instructions  ----------.-----';
        calibScreen_l2   = '';
        calibScreen_l3   = '     From now on, please DO NOT move your head or speak.    ';
        calibScreen_l4   = '';
        calibScreen_l5   = '';
        calibScreen_l6   = ' (1) we will setup the eyetracker. This will take a few     ';
        calibScreen_l7   = '           minutes. Please fixate the central dot.          ';
        calibScreen_l8   = '';
        calibScreen_l9   = '';
        calibScreen_l10  = ' (2) when instructed, please follow the dots with your eyes.';
        calibScreen_l11  = '                Do not move your eyes too early             ';
        calibScreen_l12  = '              (move only after the dot relocated)           ';
        calibScreen_l13  = '';
        calibScreen_l14  = '';
        calibScreen_l15  = '';
        calibScreen_l16  = '';
        calibScreen_b1   = '---------------  PRESS [SPACE] TO CONTINUE  --------------- ';
        
        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                        calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                        calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
end

%% Show Instructions:
textSize = 25;
textFont = 'Courier';
Screen('TextSize', screen.window, textSize);
Screen('TextFont', screen.window, textFont);
Screen('Preference', 'TextAntiAliasing',1);
Screen('FillRect', screen.window, screen.background);

sizeT = size(text);
sizeB = size(button);
lines = sizeT(1)+sizeB(1)+2;
bound = Screen('TextBounds',screen.window,button{1,:});

espace = ((textSize)*1.70);
first_line = screen.y_mid - ((round(lines/2))*espace);


addi = 0;
for t_lines = 1:sizeT(1)
    Screen('DrawText',screen.window,text{t_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, screen.white);
    addi = addi+1;
end
addi = addi+2;
for b_lines = 1:sizeB(1)
    Screen('DrawText',screen.window,button{b_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, screen.orange);
end

    
Screen('Flip',  screen.window, [], 1);
PTBwait_anykey_press; 
Screen('FillRect', screen.window, screen.background);
Screen('Flip',  screen.window, [], 1);
end
