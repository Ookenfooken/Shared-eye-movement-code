% FUNCTION to convert eye data from pixels to visual degrees
% history
% 07-2012       JE created pixels2degrees.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 
% input: pixX --> x-pixel values
%        pixY --> y-pixel values
% output: degrees.X/Y --> structure containing converted data
% Notice: pixX and pixY should start from the center of the screen, 
% since position matters; to calculate a length centered in the screen, 
% first use half of the pixels to get the degree, then multiply by 2; 
% to calculate a peripheral length, for example a line from eccentricity 
% 7 (say the center of screen is 0, and the position of the start of 
% the line in pixel is x1) to eccentricity 9 (position in pixel is x2), 
% calculate degrees of 0 to x2 first (should be 9), then minus the 
% degrees of 0 to x1 (should be 7)
%
% Aug-2018 HK changed the calculation to get more accurate degrees.
% 11/22/2018 XiuyunWu changed the calculation again, for more accurate
% degrees, this time not using degree per pixel

function [degrees] = pixels2degrees(pixX, pixY)

% get resolution and distance necessary for conversion from main working
% directory
evalin('base', 'screenSizeX');
evalin('base', 'screenSizeY');
evalin('base', 'screenResX');
evalin('base', 'screenResY');
evalin('base', 'distance');
% calculate the size of a pixel in cm
pixSizeCmX = screenSizeX./screenResX; 
pixSizeCmY = screenSizeY./screenResY;

%%%%%%%%%% New: Not using degPerPix %%%%%%%%%%
% calculate the size of x and y in cm
cmX = pixX.*pixSizeCmX;
cmY = pixY.*pixSizeCmY;

% convert from cm to degrees
degrees.degX = atan(cmX./distance).*(180/pi);
degrees.degY = atan(cmY./distance).*(180/pi)


end