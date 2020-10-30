function PTBinstruction_page(msg,el,screen)
% Function draws blank screen, presents instruciton message and waits for
% keypress.
% INPUT: el-Structure (backgroundcolour & window) and a message

switch msg
    
    case 0         
        calibScreen_l1   = '----------------- Calibrate trakSTAR  -----------------';
        calibScreen_l2   = '';
        calibScreen_l3   = '        Put finger on dot and leave it there   ';
        calibScreen_l4   = '                until next dot appears               ';
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
        calibScreen_b1   = '-------------------------------------------------------';
        
        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                       calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                       calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
        
    case 1                                                                  % Initial Experiment Instructions
        
        calibScreen_l1   = '----------------- Experiment Instructions  -----------------';
        calibScreen_l2   = '';
        calibScreen_l3   = '    A black target will appear on the left of the Screen.   ';
        calibScreen_l4   = '  Fixate on the target and keep your finger on the Velcro.  ';
        calibScreen_l5   = '';
        calibScreen_l6   = '              When the target starts moving,                ';
        calibScreen_l7   = '         try to pursue it as closely as possible            ';
        calibScreen_l8   = '';
        calibScreen_l9   = '        After some time the target will disappear           ';
        calibScreen_l10  = '         behind a grey bar and reappear behind it           ';
        calibScreen_l11  = '';
        calibScreen_l12  = '         Anticipate the targets reappearance and            ';
        calibScreen_l13  = '  try to tap it right after it appears behind the occluder. ';
        calibScreen_l14  = '  To do that you will have to take the targets acceleration ';
        calibScreen_l15  = '                      into account                          ';
        calibScreen_l16  = '';
        calibScreen_b1   = '------------------------------------------------------------';

        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                       calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                       calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
    
        
    case 2                                                                  % Instruction that is shown before each block
        calibScreen_l1   = ' ------------------- Block Instructions  -------------------';
        calibScreen_l2   = '';
        calibScreen_l3   = '';
        calibScreen_l4   = '';
        calibScreen_l5   = '';
        calibScreen_l6   = '';
        calibScreen_l7   = '                         Next Block                         ';
        calibScreen_l8   = '';
        calibScreen_l9   = '';
        calibScreen_l10  = '';
        calibScreen_l11  = '';
        calibScreen_l12  = '';
        calibScreen_l13  = '';
        calibScreen_l14  = '';
        calibScreen_l15  = '';
        calibScreen_l16  = '';
        calibScreen_b1   = '----------------------------------------------------------- ';
        
        text = {calibScreen_l1;calibScreen_l2;calibScreen_l3;calibScreen_l4;calibScreen_l5;...
                        calibScreen_l6;calibScreen_l7;calibScreen_l8;calibScreen_l9;calibScreen_l10;calibScreen_l11; ...
                        calibScreen_l12;calibScreen_l13;calibScreen_l14;calibScreen_l15;calibScreen_l16};
        button = {calibScreen_b1};
end

%% Show Instructions:
textSize = 25;
textFont = 'Courier';
Screen('TextSize', el.window, textSize);
Screen('TextFont', el.window, textFont);
Screen('Preference', 'TextAntiAliasing',1);
Screen('FillRect', el.window, el.backgroundcolour2);

sizeT = size(text);
sizeB = size(button);
lines = sizeT(1)+sizeB(1)+2;
bound = Screen('TextBounds',el.window,button{1,:});

espace = ((textSize)*1.70);
first_line = screen.y_mid - ((round(lines/2))*espace);


addi = 0;
for t_lines = 1:sizeT(1)
    Screen('DrawText',el.window,text{t_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, screen.black);
    addi = addi+1;
end
addi = addi+2;
for b_lines = 1:sizeB(1)
    Screen('DrawText',el.window,button{b_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, screen.orange);
end

    
Screen('Flip',  el.window, [], 1);
PTBwait_anykey_press; 
Screen('FillRect', el.window, el.backgroundcolour2);
Screen('Flip',  el.window, [], 1);
end
