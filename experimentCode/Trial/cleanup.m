function [] = cleanup(eyelink)
% Cleanup function, called either when experiment is done or if something
% failed in th initialization:
% PK 21/03/2019

fprintf('Start Cleanup');

% Shutdown Eyelink:
if eyelink.mode
    Eyelink('Shutdown');
end

% Close Psychtoolbox:
sca;
% Restore keyboard output to Matlab:
ListenChar(0);


end

