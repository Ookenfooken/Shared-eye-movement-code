function centerCoord = PTBscreen_to_center(screenCoord,el)
    centerCoord = screenCoord;
    centerCoord(1:2) = [screenCoord(1), screenCoord(2)] - PTBget_center(el);
    centerCoord(2) = -centerCoord(2);
end

