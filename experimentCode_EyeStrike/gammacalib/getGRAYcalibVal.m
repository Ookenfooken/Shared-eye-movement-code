function [screen]=getGRAYcalibVal(screen,const,keys,textExp,button)
% ----------------------------------------------------------------------
% [screen]=getGRAYcalibVal(screen,const,keys,textExp,button)
% ----------------------------------------------------------------------
% Goal of the function :
% get RGB params
% ----------------------------------------------------------------------
% Input(s) :
% screen : window pointer struct
% const : struct containing previous constant configurations.
% keys : struct containing button response configurations. 
% textExp : struct containing instruction text.
% button :  struct containing button text.
% ----------------------------------------------------------------------
% Output(s):
% screen : struct containing window pointer configuration
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% modified by Philipp KREYENMIER(philipp.kreyenmeier@gmail.com)
% Last update : 31 / 07 / 2019
% ----------------------------------------------------------------------

% initial setting
dirC = screen.dirCalib;
if ~isdir(sprintf('%s/Gamma/',dirC));mkdir(sprintf('%s/Gamma/',dirC));end
if ~isdir(sprintf('%s/Gamma/%s/',dirC,screen.name));mkdir(sprintf('%s/Gamma/%s/',dirC,screen.name));end
if ~isdir(sprintf('%s/Gamma/%s/%i/',dirC,screen.name,screen.dist));mkdir(sprintf('%s/Gamma/%s/%i/',dirC,screen.name,screen.dist));end
if ~isdir(sprintf('%s/Gamma/%s/%i/RGB_Lin/',dirC,screen.name,screen.dist));mkdir(sprintf('%s/Gamma/%s/%i/RGB_Lin/',dirC,screen.name,screen.dist));end

ListenChar(2);
tabCalibGray         = [];
valTest = round(linspace(0,255,screen.desiredValue));
black=[0,0,0];red=[1,0,0];green=[0,1,0];blue=[0,0,1];
light_black = [0.5,0.5,0.5]; light_red = [1,0.5,0.5];light_green = [0.5,1,0.5];light_blue = [0.5,0.5,1];

% Load linearized gamma table
loadgammaCalib(screen)

% Open a screen
[screen.main,screen.rect] = Screen('OpenWindow',screen.number,[0 0 0],[], screen.clr_depth,2);
Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
priorityLevel = MaxPriority(screen.main);Priority(priorityLevel);

% Instruction
instructions(screen,const,keys,textExp.calibScreen,button.calibScreen);

% Take the values linearized
for t = 1:screen.desiredValue
    press_enter = 0;
    while ~press_enter
        while KbCheck; end
        colDisplay = valTest(t)*[1 1 1];
        Screen(screen.main,'FillRect',colDisplay);
        Screen('Flip',screen.main);
        if CharAvail
            if GetChar(0,1) == 13 %% 10
                press_enter = 1;
            end
        end
    end
    [lineCalib]=waitValues(screen,const,colDisplay);
    tabCalibGray  = [tabCalibGray;lineCalib];
end

% Save and quit the screen
csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/Ini_GrayGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),tabCalibGray);

screen.tabCalibGray = tabCalibGray;
instructions(screen,const,keys,textExp.calibScreenEnd,button.calibScreenEnd);
Screen('closeAll');


% Display results
col_b  =  black;

gunValues       = valTest;
lumValues(:,1) = tabCalibGray(:,4);

typicalGammaInput = gunValues';
typicalGammaData = NormalizeGamma(lumValues(:,1:end)); % nomalize measures
output = [0:255]';

f2=figure();
name = ('Gamma Linearisation - GRAY params');
set(f2, 'Name', name,'PaperOrientation', 'portrait','PaperUnits','points','PaperPosition', [0,400,600,250]);
figSize_X = 600;
figSize_Y = 1000;res = figSize_X/figSize_Y;
start_X = 0;start_Y = 0;
set(f2,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

for t = 1:4
    subplot(4,2,t)    
    
    plot(gunValues,typicalGammaData(:,1),'Color',col_b,'Marker','s','MarkerEdgeColor',black,'MarkerSize',6,'MarkerFaceColor',col_b,'LineStyle','none');
    hold on;

    xlabel('Gun');
    ylabel('Normalized luminance');
    title('Measured values normalized');
    set(gca,'XLim',[-5,260],'YLim',[-0.1,1.1])

    % Fit different functions
    [valFit,paramFit] = FitGamma(typicalGammaInput,typicalGammaData,output,t);

    plot(output,valFit(:,1),'--','Color',col_b,'LineWidth',1.2);
    hold on;

    switch t
        case 1;nameFit = '1 = Power function';
        case 2;nameFit = '2 = Extended power function';
        case 3;nameFit = '3 = Sigmoid';
        case 4;nameFit = '4 = Weibull';
%         case 5;nameFit = '5 = Modified polynomial';
%         case 6;nameFit = '6 = Linear interpolation';
%         case 7;nameFit = '7 = Cubic spline';
    end
    title(nameFit);
end

% Get the gray params
[gammaTable,paramFit]= FitGamma(typicalGammaInput,typicalGammaData,output,2);
screen.GRAYparamGamma = paramFit;

csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/GRAY_GammaTabExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),gammaTable);
csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/GRAY_ParamFitExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),paramFit);

% Save figure
plot_file= sprintf('%s/Gamma/%s/%i/RGB_Lin/GRAY_GammaCurves_%s_%i',dirC,screen.name,screen.dist,screen.name,screen.dist);
saveas(f2,plot_file);


end