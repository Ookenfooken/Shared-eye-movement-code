function bPressed = PTBcheck_anykey_press()
    bPressed = 0;

    while KbCheck
        bPressed = 1;
    end

    if bPressed
        disp('EXP: key pressed');
    end
end
