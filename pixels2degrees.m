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

function [degrees] = pixels2degrees(pixX, pixY)
% get resolution and distance necessary for conversion from main working
% directory
screenSizeX = evalin('base', 'screenSizeX');
screenSizeY = evalin('base', 'screenSizeY');
screenResX = evalin('base', 'screenResX');
screenResY = evalin('base', 'screenResY');
distance = evalin('base', 'distance');
% calculate the size of a pixel in cm
pixSizeCmX = screenSizeX./screenResX; 
pixSizeCmY = screenSizeY./screenResY;
% calculate degree per pixel value
degperpixX=(2*atan(pixSizeCmX./(2*distance))).*(180/pi);
degperpixY=(2*atan(pixSizeCmY./(2*distance))).*(180/pi);
% convert from pixel to degrees
degrees.degX = degperpixX.*pixX;
degrees.degY = degperpixY.*pixY;

end