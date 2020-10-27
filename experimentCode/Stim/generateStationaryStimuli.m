function [const] = generateStationaryStimuli(const, screen, trialData)
% Pre-define stimuli that will be presented during the trial
%   this should reduce work load during the main WHILE-loop.
%   Stimuli are then saved in and can be called from the const-structure.
% 
% 
% Last Changes:
% 12/09/2019 (PK)  - started writing function - incomplete/currently not
% used
% -------------------------------------------------------------------------
% Inputs: 
% const:     structure containing different constant settings and stimuli
% screen:    strucrure containing screen settings
% -------------------------------------------------------------------------

xCenter = screen.mid(1);    
yCenter = screen.mid(2);

% control.eyeTarget   = const.INTERP_TXY{control.PursuitDir}(const.INTERP_TXY{control.PursuitDir}(:,1)==round(tElapse,+3),2:3); % Now the target moves, thus we update the current stim position according to its trajectory...

%% (1) FLASH locations: 

const.allFlash        = cell(max(trialData.PursuitDir),max(trialData.FlashDir));


% Define the flash:
baseRect = [0 0 const.flashSizePX const.flashSizePX];                       % Make a base Rect in the size defined in const

% flash offset is now defined as a x-& y-offset (w/o additional offset on
% one particular direction)

const.flashOffsetXY = sqrt((const.flashOffsetHorizPX^2)/2); % calculate how large offset has to be for x and y.

for pursuitDir = 1:max(trialData.PursuitDir)
    for flashDir = 1:max(trialData.FlashDir)
        for pos = 1:length(const.INTERP_TXY{1,1})

            switch pursuitDir
                case 1
                    switch flashDir
                        case 1                                              % leftdown->rightup, down
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) - const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter + const.flashOffsetPX));
                        case 2                                              % leftdown->rightup, up
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) - const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) + const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter - const.flashOffsetPX));                            
                    end
                    
                case 2
                    switch flashDir
                        case 1                                              % rightdown->leftup, down
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) - const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) - const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter + const.flashOffsetPX));
                        case 2                                              % rightdown->leftup, up
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) + const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter - const.flashOffsetPX));                            
                    end
                    
               case 3
                   switch flashDir
                      case 1                                              % leftup->rightdown, down
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) - const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) - const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter + const.flashOffsetPX));
                       case 2                                              % leftup->rightdown, up
                            const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetXY), ...
                                (const.INTERP_TXY{pursuitDir}(pos,3) + const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter - const.flashOffsetPX));                            
                   end
                
               case 4
                switch flashDir
                  case 1                                              % rightup->leftdown, down
                          const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetXY), ...
                            (const.INTERP_TXY{pursuitDir}(pos,3) - const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter + const.flashOffsetPX));
                   case 2                                              % rightup->leftdown, up
                        const.allFlash{pursuitDir,flashDir}(pos,:) = [(const.INTERP_TXY{pursuitDir}(pos,2) - const.flashOffsetXY), ...
                            (const.INTERP_TXY{pursuitDir}(pos,3) + const.flashOffsetXY)];
%                             const.allFlash{pursuitDir,flashDir}(pos,:) = CenterRectOnPointd(baseRect,...
%                             (xCenter + const.INTERP_TXY{pursuitDir}(pos,2) + const.flashOffsetHorizPX),...
%                             (yCenter - const.flashOffsetPX));                            
               end
                
            end
        end
    end
end


%% (2) A gaussian dot:

% Define the Gaussian:
gaussSize     = 80;
gaussVar      = 5;
gaussTexture  = zeros(gaussSize, gaussSize, 4);                             %RGBA
gaussCenter   = [(gaussSize + 1) / 2, (gaussSize + 1) / 2];

for ii = 1:gaussSize
    for jj = 1:gaussSize
        gaussTexture(ii,jj,4) = exp(-((ii - gaussCenter(1))^2 + (jj - gaussCenter(1))^2) / (2 * gaussVar^2)) * 255;
    end
end

for ii = 1:gaussSize
    for jj = 1:gaussSize
        gaussTexture(ii,jj,1:3) = 150; %255;
    end
end

const.gaussIdx      = Screen( 'MakeTexture', screen.window, gaussTexture);
const.gaussCenter   = gaussCenter;







%% old stuff: 
% Draw the Flash-Frames:
% Flash Frames presented below and above traj (3?? from traj) in the x-center 
% [xCenter, yCenter] = RectCenter(el.wRect);                                  % Get the centre coordinate of the window
% baseRect = [0 0 const.flashSizePX const.flashSizePX];                       % Make a base Rect in the size defined in const
% flashYpos = [yCenter+const.flashOffsetPX yCenter-const.flashOffsetPX];
% flashXpos = [xCenter-const.flashOffsetPX xCenter xCenter+const.flashOffsetPX];
% allFlash = nan(4, length(flashYpos)*length(flashXpos));
% 
% counter = 1;
% for i = 1:length(flashYpos)
%     for j = 1:length(flashXpos)
%         const.allFlash(:,counter) = CenterRectOnPointd(baseRect, flashXpos(j), flashYpos(i));
%         counter = counter + 1;
%     end
% end


% % This is to check Saccade (here we want to be a bit more tolerant:
% baseRectSacc = [0 0 const.saccSizePX const.saccSizePX];                     % Make a base Rect in the size defined in const
% saccYpos     = [yCenter+const.flashOffsetPX yCenter-const.flashOffsetPX];
% saccXpos     = [xCenter-const.flashOffsetPX xCenter xCenter+const.flashOffsetPX];
% allSacc      = nan(4, length(saccYpos)*length(saccXpos));
% 
% counter2 = 1;
% for i = 1:length(saccYpos)
%     for j = 1:length(saccXpos)
%         const.allSacc(:,counter2) = CenterRectOnPointd(baseRectSacc, saccXpos(j), saccYpos(i));
%         counter2 = counter2+1;
%     end
% end


end

