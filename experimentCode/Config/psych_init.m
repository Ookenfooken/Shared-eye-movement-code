function [screen] = psych_init(screen)
% Open Screen window and get some information about screen we are on.
%   PK 22/03/2019

AssertOpenGL;   % We use PTB-3

disp(['EXP: Open a graphics window on the main screen ' , ...
 'using the PsychToolbox Screen function.']);

[screen.window, screen.wRect] = Screen('OpenWindow', screen.number, [0 0 0], [], screen.clr_depth, 2);
Screen(screen.window, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
priorityLevel = MaxPriority(screen.window);
Priority(priorityLevel);


screen.foregroundcolour      = WhiteIndex(screen.window);
screen.msgfontcolour         = WhiteIndex(screen.window);
screen.msgfontcolour2        = WhiteIndex(screen.window);
screen.imgtitlefontcolour    = WhiteIndex(screen.window);
screen.imgtitlecolour        = BlackIndex(screen.window); 
screen.wRect                 = screen.wRect;

end