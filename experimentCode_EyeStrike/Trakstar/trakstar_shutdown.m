function trakstar_shutdown()
    clear Record;
    clear pRecord;

    % Turn off Transmitter
    Error     = calllib('ATC3DG64', 'SetSystemParameter', 0, -1, 2);
    errorHandler(Error);

    % Close tracker 
    Error  = calllib('ATC3DG64', 'CloseBIRDSystem');
    errorHandler(Error);
end
