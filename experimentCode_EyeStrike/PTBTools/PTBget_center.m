function screenCenter = PTBget_center(el)

    [screenWidth, screenHeight] = WindowSize(el.window);
    screenCenter = [round(screenWidth / 2), round(screenHeight / 2)];
end