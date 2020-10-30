function instructions(screen,const,keys,text,button)
% ----------------------------------------------------------------------
% instructions(screen,const,keys,text,button)
% ----------------------------------------------------------------------
% Goal of the function :
% Display instructions write in a specified matrix.
% ----------------------------------------------------------------------
% Input(s) :
% screen : main window pointer.
% const : struct containing all the constant configurations.
% text : library of the type {}.
% ----------------------------------------------------------------------
% Output(s):
% (none)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------
while KbCheck; end 
KbName('UnifyKeyNames');

push_button = 0;
while ~push_button
    
    FlushEvents ;
    [ keyIsDown, ~, keyCode ] = KbCheck(-1);
    
    if ~isfield(const,'text_size')
        const.text_size = 25;    
        const.my_font = 'Arial';
    end
    if ~isfield(const,'colBG')
        const.colBG = 127;
        const.orange = [255,150,0];
        screen.white = 255;
        screen.black = 0;
        screen.gray = 127;
    end
    
    Screen('Preference', 'TextAntiAliasing',1);
    Screen('TextSize',screen.main, const.text_size);
    Screen('TextFont', screen.main, const.my_font);
    Screen('FillRect', screen.main, const.colBG);
    
    sizeT = size(text);
    sizeB = size(button);
    lines = sizeT(1)+sizeB(1)+2;
    bound = Screen('TextBounds',screen.main,button{1,:});
    espace = ((const.text_size)*1.50);
    first_line = screen.y_mid - ((round(lines/2))*espace);
    
    addi = 0;
    for t_lines = 1:sizeT(1)
        Screen('DrawText',screen.main,text{t_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, screen.white);
        addi = addi+1;
    end
    addi = addi+2;
    for b_lines = 1:sizeB(1)
        Screen('DrawText',screen.main,button{b_lines,:},screen.x_mid-bound(3)/2,first_line+addi*espace, const.orange);
    end
    Screen('Flip',screen.main);

    if keyIsDown
        if keyCode(keys.space)
            push_button=1;
        elseif keyCode(keys.escape)
            sca;
            ListenChar(0);
        end
    end
end