function [vaX, vaY] = pix2va(screen, pix)
% Calculates pixel value in degrees visual angle
%   PK, 31/03/2019

% screen.widthMM             = 435;
% screen.hightMM             = 347;
% screen.widthPX             = 1280;
% screen.hightPX             = 1024;
% screen.distanceCM          = 44;


pix_by_mmX = screen.widthPX/screen.widthMM;
pix_by_mmY = screen.heightPX/screen.heightMM;


cmX = pix./pix_by_mmX./10;
cmY = pix./pix_by_mmY./10;

vaX = cmX./(2*screen.dist*tan(0.5*pi/180));
vaY = cmY./(2*screen.dist*tan(0.5*pi/180));

end

