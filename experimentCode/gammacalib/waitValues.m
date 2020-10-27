function [lineCalib] = waitValues(screen,const,colDisplay)
% ----------------------------------------------------------------------
% [returnVal] = waitValues(screen,const,colDisplay)
% ----------------------------------------------------------------------
% Goal of the function :
% Display values of the just measured and diplayed color, and wait for 
% entering measured values.
% ----------------------------------------------------------------------
% Input(s) :
% screen : window pointer struct
% const : structure containing all constant configurations
% colDisplay : values of the color displayed
% ----------------------------------------------------------------------
% Output(s):
% lineCalib : returned measured value and color displayed
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

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

while KbCheck(-1); end
FlushEvents('KeyDown');
inputVal = '';
text_l1 = ('Displayed color :');
text_l2 = ('Measured Values :');
res_l1 = sprintf('[%i,%i,%i]',colDisplay(1),colDisplay(2),colDisplay(3));

text = {text_l1;text_l2};
espace = ((const.text_size)*1.50);
first_line = screen.y_mid - (1*espace);

Screen('FillRect',screen.main,screen.white)
Screen('Preference', 'TextAntiAliasing',1);
Screen('TextSize',screen.main, const.text_size);
Screen ('TextFont', screen.main, const.my_font);

press_enter = 0;
valPress = '';

while ~press_enter

    res_l2 = valPress;
    res = {res_l1;res_l2};

    addi = 0;
    for t_lines = 1:2
        Screen('DrawText',screen.main,text{t_lines,:},screen.x_mid-300,first_line+addi*espace, screen.black);
        Screen('DrawText',screen.main,res{t_lines,:}, screen.x_mid+200,first_line+addi*espace, screen.black);
        addi = addi+1;
    end
    if CharAvail
        char = GetChar(0,1);
        valPress = [valPress,char];
        switch char 
            case 10 % 13    %% 10
                if isnan(str2double(valPress))
                    
                    valPress = valPress(1:end-1);
                else
                    
                    press_enter =1;
                end
            case 8;     if size(valPress,2)>1;valPress = valPress(1:end-2);end
        end
    end

    Screen('Flip',screen.main);
    
end
returnVal = str2double(valPress);
lineCalib = [colDisplay,returnVal];

end