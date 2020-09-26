% Short MATLAB program that shows how to incorporate the Eyelink into
% Psychophysics
%
% History
% 18-07-18  JF created EyelinkPTB_example.m
%           jolande.fooken@rwth-aachen.de

function result=EyelinkPTB_example

clear all;
commandwindow;

try
    
    fprintf('Dummy code to show how to use Eyelink with PTB\n\n\t');
    
    dummymode=0;       % set to 1 to initialize in dummymode (e.g. when running without Eyelink)

    % STEP 1
    % Open a graphics window on the main screen
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber);
    
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);
   
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % open file for recording data
    edfFile='demo.edf'; % this will have to be changed so you can input subject info for file names
    dataPath = 'data/'; % common practice: save data in separate folder
    Eyelink('Openfile', edfFile);
 
    % STEP 4
    % Do setup and calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % do a final check of calibration using driftcorrection
    % You have to hit esc before return.
    EyelinkDoDriftCorrection(el);
    
    % STEP 5
    % Start recording eye position
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    WaitSecs(0.5);

    % STEP 6
    % run your experiment here
    %*******************
    % E.G. PRESENT READING TEXT       
    %********************
    
    % mark any events in the data file
    Eyelink('Message', 'SYNCTIME'); %e.g. this will write the message synctime in the edf file
    % wait a while to record a bunch of samples  
    WaitSecs(2); %recording for 2 seconds e.g.     
    Eyelink('Message', 'TRIAL_END');
    
    % STEP 7
    % finish up: stop recording eye-movements, 
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    Eyelink('CloseFile');   
    % download eyelink data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        % this command downloads the file and saves it locally
        status=Eyelink('ReceiveFile', edfFile, dataPath, 1);
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    cleanup;
    myerr;
    myerr.message
    myerr.stack
end %try..catch.


% Cleanup routine:
function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
commandwindow;
% Restore keyboard output to Matlab:
ListenChar(0);
