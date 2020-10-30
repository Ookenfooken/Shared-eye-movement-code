function PTBdraw_target_screen(el, pos, rgb) % target is in screen coordinate
        
if isnan(pos)
    return;
end

PTBdraw_circles(el, [pos; pos], [10; 2], [rgb; 255 255 255]);
end
