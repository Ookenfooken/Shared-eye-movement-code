function [trakstar] = trakstar_init(trakstar)
%Initialize Trakstar
%   PK, 21 / 03 / 2019
disp('Initialize Trakstar');

trakstar.touchThreshold  = 10; % if the distance between finger and screen is smaller than this value, the program assumes that finger is touching the screen.
trakstar.startPos        = [0 -1125 -510];% initial ready position for fingers (coord from the center of the screen, +x:right/ +y:up / +z:above screen)
trakstar.sensorIdx       = 2;
trakstar.rate            = 255;


%% this is the initialize function taken from trakstar_module (by SHYEO)

% this is data acquisition structure
sm = [];
Record = [];
pRecord = [];

warning('off');

%%% load ARC3DG library (from tracker_setup.m)
disp('TRAKSTAR: Load ARC3DG64 libaray')
loadlibrary('ATC3DG64', 'ATC3DG.h');

if ~libisloaded('ATC3DG64')
    error('TRAKSTAR: ATC3DG64 library cannot be loaded');
end

%%% initialize the system (from tracker_setup.m)
disp('TRAKSTAR: Start InitializeBIRDSystem');
tempInit  = calllib('ATC3DG64', 'InitializeBIRDSystem');
errorHandler(tempInit);

%%% set measurment rate (added by shyeo)
fprintf('TRAKSTAR: Set measurment rate to %d\n', trakstar.rate);
pRate   = libpointer('doublePtr', trakstar.rate);
temp    =  calllib('ATC3DG64', 'SetSystemParameter', 3, pRate, 8);
errorHandler(temp);
clear pRate;

%%% load system configuration to sysConfig (from tracker_setup.m)
sysConfig         = libstruct('tagSYSTEM_CONFIGURATION'); 
sysConfig.agcMode = 0;
pSysConfig        = libpointer('tagSYSTEM_CONFIGURATION', sysConfig);
temp              = calllib('ATC3DG64', 'GetBIRDSystemConfiguration', pSysConfig);
errorHandler(temp);

% For now, we assume that there is only one board (by shyeo)
if sysConfig.numberBoards ~= 1
    error('TRAKSTAR: no or more than 1 boards are attached');
end

%%% Turn ON Transmitter (from tracker_setup.m)
disp('TRAKSTAR: Turn on transmitter');
temp = calllib('ATC3DG64', 'SetSystemParameter', 0, 0, 2);
errorHandler(temp);

%%% Set sensor parameters (from tracker_setup.m)
disp('TRAKSTAR: Set sensor parameter');
var = int32(26);%(19);

for i = 0:3
    temp = calllib('ATC3DG64', 'SetSensorParameter', i, 0, var, 4);
    errorHandler(temp);
end

if (tempInit == 0)
    disp('TRAKSTAR: System initialized')
else
    error('TRAKSTAR: Problem initialising the system: InitializeBIRDSystem');
end

% prepare for the data acquisition structure
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

trakstar.Record  = libstruct('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', sm);
trakstar.pRecord = libpointer('tagDOUBLE_POSITION_ANGLES_TIME_Q_RECORD_AllSensors_Four', trakstar.Record);

%%% clear pointers
clear pSysConfig;

warning('on');
end

