function PTBdraw_bulleye(screen, center, radiusOUT, radiusIN, colorOUT, colorIN)
% DRAW CALIBRATION BULL EYE draws to ovals. Bull eye used for DPI setup and
%   calibration 
%   PK, 22/10/2019
%   INPUTS: screen    - structure containing screen info
%         positions - all position(s) where Bull Eye should be drawn
%         radius    - radius of the outer/inner bulleye - needs 2 values
%         color     - color of outer/inner bulleye circle - needs 2 colors

%% OUTER OVAL
radiusOUT_PX = radiusOUT * screen.x_ppd;
left         = center(1) - radiusOUT_PX;
right        = center(1) + radiusOUT_PX;
top          = center(2) - (radiusOUT_PX*screen.pixelRatio);
bottom       = center(2) + (radiusOUT_PX*screen.pixelRatio);
position_out = [left top right bottom];        
Screen('FillOval', screen.window, colorOUT, position_out);


%% INNER OVAL
radiusIN_PX  = radiusIN * screen.ppd;
left         = center(1) - radiusIN_PX;
right        = center(1) + radiusIN_PX;
top          = center(2) - (radiusIN_PX*screen.pixelRatio);
bottom       = center(2) + (radiusIN_PX*screen.pixelRatio);
position_in  = [left top right bottom];        
Screen('FillOval', screen.window, colorIN, position_in);




end

