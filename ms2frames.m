% FUNCTION to convert ms to frames; important if the eye tracker has a
% samling rate other than 1000 Hz

% history
% 07-2012       JE created ms2frames.m
% 14-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: milliseconds --> time interval in ms
% output: frames --> equivalent values of frames (or samples) tracker has
%                    recorded during the input ms
function [frames] = ms2frames(milliseconds)

sampleRate = evalin('base','sampleRate');
frames = round(milliseconds / (1000/sampleRate));

end