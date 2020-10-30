loadlibrary('ATC3DG');

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

i=0;

while 1   
    %tic;
    calllib('ATC3DG', 'GetAsynchronousRecord',  hex2dec('ffff'), pRecord, 4*64);
    destroyfunction();  % finite yet a very small delay!!!
    %toc;
end

whos
unloadlibrary('ATC3DG');
disp('Done!');