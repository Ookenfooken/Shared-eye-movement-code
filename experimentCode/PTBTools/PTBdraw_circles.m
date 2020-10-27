function PTBdraw_circles(screen, pos, rad, rgb)
% use rect functions provided by PsychToolbox
% try 'help PsychRects'
%
% pos, rad, rgb are all row_wise

rect = zeros(length(rad),4);

for i = 1:length(rad)
    rect(i,:) = [pos(i,1)-rad(i), pos(i,2)-rad(i), pos(i,1)+rad(i), pos(i,2)+rad(i)];
end

% CAUTION: FillOval accepts columns of colore and rects
Screen('FillOval', screen.window, rgb', rect');
Screen('FillOval', screen.window, rgb', rect');
end