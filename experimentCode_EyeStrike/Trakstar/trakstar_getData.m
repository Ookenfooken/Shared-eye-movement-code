function ret = trakstar_getData(trakstar)
    % [shyeo 2013-01-15] for unknown reason, this does not work. Have 
    % to read all four sensors
    %
    % Record = libstruct('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD', sm);
    % temp = calllib('ATC3DG', 'GetSynchronousRecord',  1, Record, 64);
    
    % this is data acquisition structure    
    
    temp            = calllib('ATC3DG64', 'GetAsynchronousRecord',  hex2dec('ffff'), trakstar.pRecord, 4 * 64);
    destroyfunction(); %added according to the MATLAB support, this emptry function induces a minimal delay but prevent crash
    errorHandler(temp);

    sensorIdx_from0 = trakstar.sensorIdx - 1;

    ret.pos         = zeros(1,3);
    ret.ori         = zeros(1,3);

    ret.time        = trakstar.Record.(['time', num2str(sensorIdx_from0)]);
    ret.pos(1)      = trakstar.Record.(['x', num2str(sensorIdx_from0)]);
    ret.pos(2)      = trakstar.Record.(['y', num2str(sensorIdx_from0)]);
    ret.pos(3)      = trakstar.Record.(['z', num2str(sensorIdx_from0)]);
    ret.ori(1)      = trakstar.Record.(['a', num2str(sensorIdx_from0)]);
    ret.ori(2)      = trakstar.Record.(['e', num2str(sensorIdx_from0)]);
    ret.ori(3)      = trakstar.Record.(['r', num2str(sensorIdx_from0)]);        
    ret.quality     = trakstar.Record.(['quality', num2str(sensorIdx_from0)]);
end
