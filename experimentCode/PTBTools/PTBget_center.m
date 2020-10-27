function screenCenter = PTBget_center(screen)

    [screenWidth, screenHeight] = WindowSize(screen.window);
    screenCenter = [round(screenWidth / 2), round(screenHeight / 2)];
end