loadlibrary('ATC3DG');
%calllib('ATC3DG', 'InitializeBIRDSystem');
% ts = trakstar_module(255, 2);
% ts.initialize();

for kk = 0:3
   sm.(['x' num2str(kk)]) = 0;
   sm.(['y' num2str(kk)]) = 0;
   sm.(['z' num2str(kk)]) = 0;
   sm.(['a' num2str(kk)]) = 0;
   sm.(['e' num2str(kk)]) = 0;
   sm.(['r' num2str(kk)]) = 0;
   sm.(['time' num2str(kk)]) = 0;
   sm.(['quality' num2str(kk)]) = 0;  
end

Record  = libstruct('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', sm);  
pRecord = libpointer('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', Record);

while 1
    tic
    calllib('ATC3DG', 'GetAsynchronousRecord',  hex2dec('ffff'), Record, 4*64);

    destroyfunction;
    toc
end

%%
loadlibrary('ATC3DG', 'ATC3DG.h');

calllib('ATC3DG', 'InitializeBIRDSystem');

pRate   = libpointer('doublePtr', 255);
temp    =  calllib('ATC3DG', 'SetSystemParameter', 3, pRate, 8);

sysConfig         = libstruct('tagSYSTEM_CONFIGURATION'); 
sysConfig.agcMode = 0;
pSysConfig        = libpointer('tagSYSTEM_CONFIGURATION', sysConfig);
temp              = calllib('ATC3DG', 'GetBIRDSystemConfiguration', pSysConfig);

temp = calllib('ATC3DG', 'SetSystemParameter', 0, 0, 2);
    

 var = int32(26);%(19);

        for i = 0:3
            temp = calllib('ATC3DG', 'SetSensorParameter', i, 0, var, 4);
            errorHandler(temp);
        end

for kk = 0:3
   sm.(['x' num2str(kk)]) = 0;
   sm.(['y' num2str(kk)]) = 0;
   sm.(['z' num2str(kk)]) = 0;
   sm.(['a' num2str(kk)]) = 0;
   sm.(['e' num2str(kk)]) = 0;
   sm.(['r' num2str(kk)]) = 0;
   sm.(['time' num2str(kk)]) = 0;
   sm.(['quality' num2str(kk)]) = 0;  
end

Record  = libstruct('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', sm);  
pRecord = libpointer('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', Record);

while 1
    tic
    calllib('ATC3DG', 'GetAsynchronousRecord',  hex2dec('ffff'), Record, 4*64);
    Record.x1
    %pause(0.00000000000001);
    toc
end