function PTBdraw_target(screen, pos, rgb, const) % target is in center coordinate

    if isnan(pos)
        return;
    end

    [screenWidth, screenHeight] = WindowSize(screen.window);

    pos_ = PTBcenter_to_screen(pos,screen);

%     PTBdraw_circles(el, [pos_; pos_], [const.StimRadPX ; 2], [rgb; 2 2 2]);
    PTBdraw_circles(screen, [pos_; pos_], [const.flashSizePX  ; 3], [rgb; rgb]);
end