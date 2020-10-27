function [b, ret] = check_eye_fixated_to(const, eyelink, screen, pos, dur, control) %pos is given as center coordinate
%check if eye is fixated to the position for a certain amount of time

t = eyelink.Data.time;
x = eyelink.Data.coord;

d = PTBcenter_to_screen(pos,screen) - x;

[b, ret] = check_fixated(control, t, d, const.fixationRadiusEyePX, dur, 'tEyeFixToStart');

end

