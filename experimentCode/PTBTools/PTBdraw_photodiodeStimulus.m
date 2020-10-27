function PTBdraw_photodiodeStimulus(screen, size, rgb)
% PTB DRAW CIRCLE. Draws a cicle on the screen.
% size in pixels
% rgb value
% position in pixels
%
% pos, rad, rgb are all row_wise

% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 size size];
% Center the rectangle on the centre of the screen
centeredRect = CenterRectOnPointd(baseRect, screen.widthPX-(size/2), screen.heightPX-(size/2));
% Draw the rect to the screen
Screen('FillRect',  screen.window, rgb, centeredRect);
% Screen('FrameRect',  screen.window, screen.black, centeredRect,5);
end