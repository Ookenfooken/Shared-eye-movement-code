function PTBdraw_target_gaussian(screen, pos, const, ~)


% % Define the Gaussian:
% gaussSize     = 120;
% gaussVar      = 8;
% gaussTexture  = zeros(gaussSize, gaussSize, 4);                             %RGBA
% gaussCenter   = [(gaussSize + 1) / 2, (gaussSize + 1) / 2];
% 
% for ii = 1:gaussSize
%     for jj = 1:gaussSize
%         gaussTexture(ii,jj,4) = exp(-((ii - gaussCenter(1))^2 + (jj - gaussCenter(1))^2) / (2 * gaussVar^2)) * 255;
%     end
% end
% 
% for ii = 1:gaussSize
%     for jj = 1:gaussSize
%         gaussTexture(ii,jj,1:3) = 255;
%     end
% end
% 
% gaussIdx      = Screen( 'MakeTexture', screen.window, gaussTexture);
gaussIdx = const.gaussIdx;
gaussCenter = const.gaussCenter;

pos_ = PTBcenter_to_screen(pos,screen);

Screen( 'DrawTexture', screen.window, gaussIdx, [], [ pos_(1) - gaussCenter(1), pos_(2) - gaussCenter(2), pos_(1) + gaussCenter(1), pos_(2) + gaussCenter(2) ] );
end