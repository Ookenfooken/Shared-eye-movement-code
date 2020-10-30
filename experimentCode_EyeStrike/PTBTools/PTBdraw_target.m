function PTBdraw_target(el, pos, rgb, const) % target is in center coordinate

    if isnan(pos)
        return;
    end

    [screenWidth, screenHeight] = WindowSize(el.window);

    pos_ = PTBcenter_to_screen(pos,el);

%     PTBdraw_circles(el, [pos_; pos_], [const.StimRadPX ; 2], [rgb; 2 2 2]);
    PTBdraw_circles(el, [pos_; pos_], [const.StimRadPX ; 2], [rgb; 0 0 0]);
end