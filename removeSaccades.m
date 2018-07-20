% FUNCTION to remove saccades from eye movement data; this may be necessary
% when e.g. analyzing smooth eye movement phase

% history
% 07-2012       JE created analyzeSaccades.m
% 2012-2018     JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
% output: trial --> structure containing relevant current trial information
%                   de-saccaded eye movements added

function [trial] = removeSaccades(trial)
% open eye movement data structure
trial.X_noSac = trial.eyeX_filt;
trial.Y_noSac = trial.eyeY_filt;
trial.DX_noSac = trial.eyeDX_filt;
trial.DY_noSac = trial.eyeDY_filt;
trial.X_interpolSac = trial.eyeX_filt;
trial.Y_interpolSac = trial.eyeY_filt;
trial.DX_interpolSac = trial.eyeDX_filt;
trial.DY_interpolSac = trial.eyeDY_filt;
trial.DDX_noSac = trial.eyeDDX_filt;
trial.DDY_noSac = trial.eyeDDY_filt;
trial.quickphases = false(trial.length,1);
% now remove saccadic phase
for i = 1:length(trial.saccades.X.onsets)
    % first we calculate the slope between the eye position at saccade on-
    % to saccade offset
    lengthSacX = trial.saccades.X.offsets(i) - trial.saccades.X.onsets(i);
    slopeX = (trial.eyeX_filt(trial.saccades.X.offsets(i))-trial.eyeX_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeDX = (trial.eyeDX_filt(trial.saccades.X.offsets(i))-trial.eyeDX_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeY = (trial.eyeY_filt(trial.saccades.X.offsets(i))-trial.eyeY_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    slopeDY = (trial.eyeDY_filt(trial.saccades.X.offsets(i))-trial.eyeDY_filt(trial.saccades.X.onsets(i)))./lengthSacX;
    % now we can add a completely de-saccaded variable in trial
    trial.X_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.Y_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DX_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DY_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DDX_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    trial.DDY_noSac(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i)) = NaN;
    % and finally interpolate the eye position if we later want to plot
    % smoot eye movement traces
    for j = 1:lengthSacX+1
        trial.X_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeX_filt(trial.saccades.X.onsets(i)) + slopeX*j;
        trial.Y_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeY_filt(trial.saccades.X.onsets(i)) + slopeY*j;
        trial.DX_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeDX_filt(trial.saccades.X.onsets(i)) + slopeDX*j;
        trial.DY_interpolSac(trial.saccades.X.onsets(i)-1+j) = trial.eyeDY_filt(trial.saccades.X.onsets(i)) + slopeDY*j;
    end   
end
% do the exact same thing for y
for i = 1:length(trial.saccades.Y.onsets)
    
    lengthSacY = trial.saccades.Y.offsets(i) - trial.saccades.Y.onsets(i);
    slopeY = (trial.eyeY_filt(trial.saccades.Y.offsets(i))-trial.eyeY_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
    slopeDY = (trial.eyeDY_filt(trial.saccades.Y.offsets(i))-trial.eyeDY_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
    slopeX = (trial.eyeX_filt(trial.saccades.Y.offsets(i))-trial.eyeX_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
    slopeDX = (trial.eyeDX_filt(trial.saccades.Y.offsets(i))-trial.eyeDX_filt(trial.saccades.Y.onsets(i)))./lengthSacY;
    
    trial.X_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    trial.Y_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    trial.DX_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    trial.DY_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    trial.DDX_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    trial.DDY_noSac(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i)) = NaN;
    
    for j = 1:lengthSacY+1
        trial.Y_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeY_filt(trial.saccades.Y.onsets(i)) + slopeY*j;
        trial.X_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeX_filt(trial.saccades.Y.onsets(i)) + slopeX*j;
        trial.DY_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeDY_filt(trial.saccades.Y.onsets(i)) + slopeDY*j;
        trial.DX_interpolSac(trial.saccades.Y.onsets(i)-1+j) = trial.eyeDX_filt(trial.saccades.Y.onsets(i)) + slopeDX*j;
    end    
end
% done
end
