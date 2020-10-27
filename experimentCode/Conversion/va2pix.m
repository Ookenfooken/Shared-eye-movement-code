function [pixX, pixY] = va2pix(screen, va)
% Calculates a distance in VA into Pixels
%   PK 31/03/2019

% screen.widthMM             = 435;
% screen.hightMM             = 347;
% screen.widthPX             = 1280;
% screen.hightPX             = 1024;
% screen.distanceCM          = 44;

cm = (2*screen.dist*tan(0.5*pi/180))*va;

pix_by_mmX = screen.widthPX/screen.widthMM;
pix_by_mmY = screen.heightPX/screen.heightMM;

pixX = cm.*10.*pix_by_mmX;
pixY = cm.*10.*pix_by_mmY;




end

