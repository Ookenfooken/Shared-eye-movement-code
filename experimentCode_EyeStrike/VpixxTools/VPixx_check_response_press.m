function bPressed = Vpixx_check_response_press()

Datapixx('RegWrRd');
status = Datapixx('GetDinStatus');
if (status.newLogFrames > 0)
    bPressed = 1;
    Datapixx('StopDinLog');
    Datapixx('RegWrRd');
else
    bPressed = 0;
end
end