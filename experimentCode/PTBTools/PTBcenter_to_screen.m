function screenCoord = PTBcenter_to_screen(centerCoord,screen)
    screenCoord = centerCoord;
    screenCoord(1:2) = [centerCoord(1), -centerCoord(2)] + PTBget_center(screen);
end

