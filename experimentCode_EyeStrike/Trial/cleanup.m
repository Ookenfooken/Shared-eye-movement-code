function [] = cleanup(eyelink, trakstar, responsePixx)
% Cleanup function, called either when experiment is done or if something
% failed in th initialization:
% PK 21/03/2019

fprintf('Start Cleanup');

% Shutdown Eyelink:
if eyelink.mode
    Eyelink('Shutdown');
end

% Shutdown Trakstar:
if trakstar.mode
    trakstar_shutdown();
end

% Close datapixx
if responsePixx.mode
    Datapixx('StopDinLog');
    Datapixx('RegWrRd');
    Datapixx('Close');
end

% Close Psychtoolbox:
sca;
% Restore keyboard output to Matlab:
ListenChar(0);


end

