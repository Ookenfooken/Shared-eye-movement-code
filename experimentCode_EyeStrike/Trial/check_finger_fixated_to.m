function [b, ret] = check_finger_fixated_to(const, trakstar, control, pos, dur) %pos is given as center coordinate
%note that this is in 3D

t = trakstar.Data.time;
x = trakstar.Data.coord;

% d = PTBcenter_to_screen(pos,el)  - x;                                       % coordinates in 3D
d = pos  - x;  
% d = [d(1) d(3)];                                                            % fixation check only in x and z plane

[b, ret] = check_fixated(control, t, d, const.fixationRadiusFingerPX, dur, 'tFingerFixToStart');

end