function [const] = generateStationaryStimuli(const, screen)
% Pre-define stimuli that will be presented during the trial
%   this should reduce work load during the main WHILE-loop.
%   Stimuli are then saved in and can be called from the const-structure.
% 
% 
% Last Changes:
% 12/09/2019 (PK)
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings and stimuli
% screen:    strucrure containing screen settings
% -------------------------------------------------------------------------

xCenter = screen.mid(1);    
yCenter = screen.mid(2);

%% (1) Draw the Default Occluder:
baseRect = [0 0 const.OccluderSizeX(1) const.OccluderSizeY(1)];             % Make a base Rect in the size defined in const
            
OccluderXpos = (xCenter + const.OccluderOffset(1));
OccluderYpos = yCenter;

const.Occluder(1,:) = CenterRectOnPointd(baseRect, OccluderXpos, OccluderYpos);


%% (2) Draw the Test Occluders:
% 2
baseRect = [0 0 const.OccluderSizeX(2) const.OccluderSizeY(2)];             % Make a base Rect in the size defined in const
            
OccluderXpos = (xCenter + const.OccluderOffset(2));
OccluderYpos = yCenter;

const.Occluder(2,:) = CenterRectOnPointd(baseRect, OccluderXpos, OccluderYpos);

% 3
baseRect = [0 0 const.OccluderSizeX(3) const.OccluderSizeY(3)];             % Make a base Rect in the size defined in const
            
OccluderXpos = (xCenter + const.OccluderOffset(3));
OccluderYpos = yCenter;

const.Occluder(3,:) = CenterRectOnPointd(baseRect, OccluderXpos, OccluderYpos);

% 4
baseRect = [0 0 const.OccluderSizeX(4) const.OccluderSizeY(4)];             % Make a base Rect in the size defined in const
            
OccluderXpos = (xCenter + const.OccluderOffset(4));
OccluderYpos = yCenter;

const.Occluder(4,:) = CenterRectOnPointd(baseRect, OccluderXpos, OccluderYpos);

% 5
baseRect = [0 0 const.OccluderSizeX(5) const.OccluderSizeY(5)];             % Make a base Rect in the size defined in const
            
OccluderXpos = (xCenter + const.OccluderOffset(5));
OccluderYpos = yCenter;

const.Occluder(5,:) = CenterRectOnPointd(baseRect, OccluderXpos, OccluderYpos);

end

