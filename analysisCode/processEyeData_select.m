function [eyeData] = processEyeData_select(eyeData,filtOrder,filtCutoffPosition,filtCutoffVelocity,sampleRate,method)

% processEyeData_select

% This function allows one to process raw position with select filtering
% parameters and method

% INPUT:
% - eyeData (.X for horizontal data; .Y for vertical data)
% - filtOrder (butterworth)
% - filtCutOffPosition (criterion for Position data filtering)
% - filtCutOffVelocity (criterion for Velocity data filtering)
% - sampleRate (data sampling rate)
% - method: 
% --- 0: butterworth filtering of position and velocity
% --- 1: butterworth filtering of position only (velocity from filtered)
% --- 2: butterworth filtering of velocity only (no position filtering)

% OUTPUT:
% - eyeData (X_filt, DX, DX_filt, DDX, DDX_filt, DDDX) - same for y

% UPDATE RECORD:
% 01/13/2021 (DC): separate from analysis_interactive script
% 12/30/2020 (DC): incoporated Kerzel et al (2010)
% 12/14/2020 (DC): incorporated Goettker et al (2018)

% TO-DO:
% - add new filtering methods + references

%%
%eyeData = rmfield(eyeData,{'X_filt','Y_filt','DX','DY','DX_filt','DY_filt','DDX','DDY','DDDX','DDDY'}); %'DDX_filt','DDY_filt',
filtFrequency = sampleRate/2;

%%
switch method
    case 0 % in house option
        
        [a,b] = butter(filtOrder,filtCutoffPosition/filtFrequency);
        [c,d] = butter(filtOrder,filtCutoffVelocity/filtFrequency);
        
        %% position
        eyeData.X_filt = filtfilt(a,b,eyeData.X);
        eyeData.Y_filt = filtfilt(a,b,eyeData.Y);
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        DX_tmp = diff(eyeData.X_filt)*sampleRate;
        eyeData.DX_filt = filtfilt(c,d,DX_tmp);
        
        DY_tmp = diff(eyeData.Y_filt)*sampleRate;
        eyeData.DY_filt = filtfilt(c,d,DY_tmp);
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX)*sampleRate;
        eyeData.DDY = diff(eyeData.DY)*sampleRate;
        
        DDX_tmp = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDX_filt = filtfilt(c,d,DDX_tmp);
        
        DDY_tmp = diff(eyeData.DY_filt)*sampleRate;
        eyeData.DDY_filt = filtfilt(c,d,DDY_tmp);
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX_filt)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY_filt)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];
        eyeData.DDX_filt = [eyeData.DDX_filt; NaN; NaN];
        eyeData.DDY_filt = [eyeData.DDY_filt; NaN; NaN];
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
        
    case 1 % Goettker et al (2018)
        
        % We analyzed only the horizontal eye position. First, we filtered the
        % eye position traces with a second-order Butterworth filter with
        % a cutoff frequency of 30 Hz and calculated the horizontal eye
        % velocity as the first derivative of the filtered position traces.
        % Saccades were detected with a speed threshold of 30°/s and an
        % acceleration threshold of 4,000°/s2. During pursuit the speed
        % threshold was adjusted by the average speed over the last 40 ms.

        [a,b] = butter(filtOrder,filtCutoffPosition/filtFrequency);
        
        %% position
        eyeData.X_filt = filtfilt(a,b,eyeData.X);
        eyeData.Y_filt = filtfilt(a,b,eyeData.Y);
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        eyeData.DX_filt = diff(eyeData.X_filt)*sampleRate;
        eyeData.DY_filt = diff(eyeData.Y_filt)*sampleRate;
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDY = diff(eyeData.DY_filt)*sampleRate;
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];
        eyeData.DDX_filt = [eyeData.DDX; NaN; NaN]; % save for easier use
        eyeData.DDY_filt = [eyeData.DDY; NaN; NaN]; % save for easier use
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
        
    case 2 % Kerzel et al (2010)
        
        % To identify saccades, the output of the EyeLink II eye movement
        % parser was used. The criterion used to detect saccade onset was
        % acceleration larger than 4,000°/s2 and velocity larger than 22°/s.
        % Velocity traces were filtered with a 40-Hz low-pass, zero-phase-shift
        % Butterworth filter. Saccades and four samples (16 ms) before and after
        % each saccade were removed from the velocity traces
        
        [c,d] = butter(filtOrder,filtCutoffVelocity/filtFrequency);
        
        %% position
        eyeData.X_filt = eyeData.X; % did not filter
        eyeData.Y_filt = eyeData.Y; % did not filter
        
        %% velocity
        eyeData.DX = diff(eyeData.X)*sampleRate;
        eyeData.DY = diff(eyeData.Y)*sampleRate;
        
        DX_tmp = diff(eyeData.X_filt)*sampleRate;
        eyeData.DX_filt = filtfilt(c,d,DX_tmp);
        
        DY_tmp = diff(eyeData.Y_filt)*sampleRate;
        eyeData.DY_filt = filtfilt(c,d,DY_tmp);
        
        %% acceleration
        eyeData.DDX = diff(eyeData.DX_filt)*sampleRate;
        eyeData.DDY = diff(eyeData.DY_filt)*sampleRate;
        
        %% jerk for detecting saccades and quick phases
        eyeData.DDDX = diff(eyeData.DDX)*sampleRate;
        eyeData.DDDY = diff(eyeData.DDY)*sampleRate;
        
        %% make sure all data series have the same length
        eyeData.DX = [eyeData.DX; NaN];
        eyeData.DY = [eyeData.DY; NaN];
        eyeData.DX_filt = [eyeData.DX_filt; NaN];
        eyeData.DY_filt = [eyeData.DY_filt; NaN];
        
        eyeData.DDX = [eyeData.DDX; NaN; NaN];
        eyeData.DDY = [eyeData.DDY; NaN; NaN];
        eyeData.DDX_filt = [eyeData.DDX; NaN; NaN]; % save for easier use
        eyeData.DDY_filt = [eyeData.DDY; NaN; NaN]; % save for easier use
        
        eyeData.DDDX = [eyeData.DDDX; NaN; NaN; NaN];
        eyeData.DDDY = [eyeData.DDDY; NaN; NaN; NaN];
end

end
