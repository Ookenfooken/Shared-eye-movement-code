function [screen, el] = psych_init(screen, eyelink)
% Open Screen window and get some information about screen we are on.
%   PK 22/03/2019
AssertOpenGL;   % We use PTB-3

disp(['EXP: Open a graphics window on the main screen ' , ...
 'using the PsychToolbox Screen function.']);

[screen.window, screen.wRect] = Screen('OpenWindow', screen.number, [0 0 0], [], screen.clr_depth, 2);
Screen(screen.window, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
priorityLevel = MaxPriority(screen.window);
Priority(priorityLevel);


el                           = [];
if ~eyelink.mode
    el.window                = screen.window;
    el.backgroundcolour      = screen.background;
    el.backgroundcolour2     = screen.background2;
    el.foregroundcolour      = WhiteIndex(el.window);
    el.msgfontcolour         = WhiteIndex(el.window);
    el.msgfontcolour2        = WhiteIndex(el.window);
    el.msgfontcolour3        = BlackIndex(el.window);
    el.imgtitlefontcolour    = WhiteIndex(el.window);
    el.imgtitlecolour        = BlackIndex(el.window); 
    el.wRect                 = screen.wRect;
end

