function PTBdraw_cross(el, pos, rad, rgb)
    x1 = [pos(1)-rad, pos(2)];
    x2 = [pos(1)+rad, pos(2)];
    x3 = [pos(1), pos(2)+rad];
    x4 = [pos(1), pos(2)-rad];


    Screen('DrawLine', el.window, rgb, pos(1)-rad, pos(2), pos(1)+rad, pos(2), 1);
    Screen('DrawLine', el.window, rgb, pos(1), pos(2)-rad, pos(1), pos(2)+rad, 1);
end