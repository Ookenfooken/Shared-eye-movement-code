function bPressed = PTBcheck_key_press(keyname)
% if key named <keyname> is pressed, return 1
    [~, ~, keyCode] = KbCheck;

    if keyCode(KbName(keyname))        
        KbReleaseWait;            
        disp(['EXP: ' keyname ' pressed']);
        bPressed = 1;
    else
        bPressed = 0;
    end
end
