function [eyelink] = eyelink_dataAcquisition(el, eyelink, trialData,trialNum)
% Data Acquisition for Eyelink.
%   PK 28/03/2019

if Eyelink( 'NewFloatSampleAvailable') ~= 0
    evt = Eyelink( 'NewestFloatSample');
    evt.time = Eyelink('TrackerTime') - trialData.tMainSync(trialNum);      % TODO: this is not accurate, find a way to convert eyelink time to system time
                                                                            % check for presence of a new sample update and event
                                                                            % get the sample in the form of an event structure
                                                                            % if we do, get current gaze position from sample
    eye_used = Eyelink('EyeAvailable');
    x = evt.gx(eye_used+1);                                                 % +1 as we're accessing MATLAB array
    y = evt.gy(eye_used+1);

    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0

        if isfield(eyelink.Data, 'coord')
            dc                  = ([x, y] - eyelink.Data.coord);
            dt                  = (eyelink.Data.time - evt.time);
        else
            dc                  = [0 0];
            dt                  = 1;
        end

        eyelink.Data.vcoord     =  dc / dt;
        eyelink.Data.coord      = [x, y];
        eyelink.Data.time       = evt.time;

    end

end

