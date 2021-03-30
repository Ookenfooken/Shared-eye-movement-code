function [eyeData, saccades] = removeSaccades_select(eyeData, saccades, analysisParams)

% removeSaccades_select

% This function allows one to remove saccades from velocity trace for
% smooth pursuit computation to match with Kerzel et al (2010)

% Note: Saccades and four samples (16ms) before and after each saccade were
% removed from velocity traces. Additionally, we removed episodes with eye
% gain outside the range from -0.2 to 2.2 that reflect slowing or
% acceleration of the eye that were not detected as saccades. The discarded
% episodes were replaced by linear interpolation between the last sample
% before the gap and the first sample after the gap. (Kerzel et al., 2010)

% INPUT:
% - eyeData (contains eye velocity)
% - saccades (contains detected onsets and offsets)
% - analysisParams (contains parameters)

% OUTPUT:
% - eyeData

% UPDATE RECORD:
% 01/13/2021 (DC): separate from analysis_interactive.m, see section
% headers for more description about small differences from removeSaccades
% 12/31/2020 (DC): created from removeSaccades

% TO-DO:



%% Process saccades onsets/offsets

% Modified from removeSaccades with the following key changes:
% - all saccades detected happened during stimulus presentation, no need to
% differentiate between onsets vs. onsetsDuring
% - removed codes about characterizing saccades (e.g., velocity, direction), 
% which should not belong here
% - should this be incorporated with findSaccades? This is technically
% still about saccade onset/offset organization

% min intersaccade interval duration
minISIFrames = 40./1000.*analysisParams.sampleRate; % 40 ms

% store all found on and offsets together
% Note: if using Engbert method, saccades are detected 2D already

if isfield(saccades,'onsets') == 0
    
    saccades.onsets = [saccades.X.onsets, saccades.Y.onsets];
    saccades.offsets = [saccades.X.offsets, saccades.Y.offsets];
    
    % merge saccades on X and Y that are actually the same...
    xSac = length(saccades.X.onsets);
    ySac = length(saccades.Y.onsets);
    if ~isempty(ySac) && ~isempty(xSac) && numel(saccades.onsets) ~= 0
        testOnsets = sort(saccades.onsets);
        testOffsets = sort(saccades.offsets);
        count1 = 1;
        tempOnset1 = [];
        tempOffset1 = [];
        count2 = 1;
        tempOnset2 = [];
        tempOffset2 = [];
        for i = 1:length(testOnsets)-1
            if testOnsets(i+1)-testOnsets(i) < minISIFrames
                tempOnset1(count1) = testOnsets(i);
                tempOffset1(count1) = testOffsets(i);
                count1 = length(tempOnset1) +1;
            else
                tempOnset2(count2) = testOnsets(i+1);
                tempOffset2(count2) = testOffsets(i+1);
                count2 = length(tempOnset2) +1;
            end
        end
        onsets = unique([tempOnset1 tempOnset2 testOnsets(1)])';
        offsets = unique([tempOffset1 tempOffset2 testOffsets(1)])';
        saccades.onsets = onsets;
        saccades.offsets = offsets;
    end    
end

%% Remove and interpolate data

% Modified from removeSaccades with the following key changes:
% - incorporated analysisParams.noSac.removeFrames
% - updated interpolation using simplier codes
% - added control for which saccades (x, y, xy comined) to remove

% load data for new fields
eyeData.X_noSac = eyeData.X_filt;
eyeData.Y_noSac = eyeData.Y_filt;
eyeData.DX_noSac = eyeData.DX_filt;
eyeData.DY_noSac = eyeData.DY_filt;
eyeData.X_interpolSac = eyeData.X_filt;
eyeData.Y_interpolSac = eyeData.Y_filt;
eyeData.DX_interpolSac = eyeData.DX_filt;
eyeData.DY_interpolSac = eyeData.DY_filt;

% control for which saccades (x, y, xy comined) to remove
if analysisParams.sac.method == 3
    tmpOnsets = saccades.onsets; % saccades.X.onsets, saccades.Y.onsets, or saccades.onsets
    tmpOffsets = saccades.offsets; % saccades.X.offsets, saccades.Y.offsets, or saccades.offsets
else
    tmpOnsets = saccades.X.onsets; % saccades.X.onsets, saccades.Y.onsets, or saccades.onsets
    tmpOffsets = saccades.X.offsets; % saccades.X.offsets, saccades.Y.offsets, or saccades.offsets
end

for i = 1:length(tmpOnsets)     
    % determine discard onset/offset incorporating analysisParams
    startFrame = max(tmpOnsets(i) - analysisParams.noSac.removeFrames, 2); % can't be smaller than 2 (need 1 frame prior to interpolate)
    endFrame = min(tmpOffsets(i) + analysisParams.noSac.removeFrames, length(eyeData.DX_filt)-1); % can't be longer than data length-1, need 1 frame after to interpolate 
    
    % remove data
    eyeData.X_noSac(startFrame:endFrame) = NaN;
    eyeData.Y_noSac(startFrame:endFrame) = NaN;
    eyeData.DX_noSac(startFrame:endFrame) = NaN;
    eyeData.DY_noSac(startFrame:endFrame) = NaN;    
    
    % determine position/velocity values for interpolation
    t = [startFrame-1 endFrame+1];
    x = [eyeData.X_filt(startFrame-1) eyeData.X_filt(endFrame+1)];
    y = [eyeData.Y_filt(startFrame-1) eyeData.Y_filt(endFrame+1)];
    vx = [eyeData.DX_filt(startFrame-1) eyeData.DX_filt(endFrame+1)];
    vy = [eyeData.DY_filt(startFrame-1) eyeData.DY_filt(endFrame+1)];
    
    % interpolation, to be modified for more methods
    eyeData.X_interpolSac(startFrame:endFrame) = interp1(t,x,[startFrame:endFrame],analysisParams.noSac.method);
    eyeData.Y_interpolSac(startFrame:endFrame) = interp1(t,y,[startFrame:endFrame],analysisParams.noSac.method);    
    eyeData.DX_interpolSac(startFrame:endFrame) = interp1(t,vx,[startFrame:endFrame],analysisParams.noSac.method);
    eyeData.DY_interpolSac(startFrame:endFrame) = interp1(t,vy,[startFrame:endFrame],analysisParams.noSac.method);    
end

end
