function [screen]=rgbCheckCalib(screen,const,keys,textExp,button,f)
% ----------------------------------------------------------------------
% [screen]=rgbCheckCalib(screen,const,keys,textExp,button)
% ----------------------------------------------------------------------
% Goal of the function :
% Check correct linearization and get RGB params.
% ----------------------------------------------------------------------
% Input(s) :
% screen : window pointer struct
% const : struct containing previous constant configurations.
% keys : struct containing button response configurations. 
% textExp : struct containing instruction text.
% button :  struct containing button text.
% f : figure handle
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
tabCalibRed      = [];
tabCalibGreen    = [];
tabCalibBlue     = [];

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

% Take the linearized values
for t = 1:screen.desiredValue
    for timeCol =1:3
        press_enter = 0;
        while ~press_enter
            while KbCheck; end
            switch timeCol
                case 1;colDisplay = [valTest(t),0,0];
                case 2;colDisplay = [0,valTest(t),0];
                case 3;colDisplay = [0,0,valTest(t)];
            end

            Screen(screen.main,'FillRect',colDisplay);
            Screen('Flip',screen.main);
            if CharAvail
                if GetChar(0,1) == 13 %% 10
                    press_enter = 1;
                end
            end
        end
        [lineCalib]=waitValues(screen,const,colDisplay);
        switch timeCol
            case 1; tabCalibRed     = [tabCalibRed;lineCalib];
            case 2; tabCalibGreen   = [tabCalibGreen;lineCalib];
            case 3; tabCalibBlue    = [tabCalibBlue;lineCalib];
        end
    end
end

% Save and quit the screen

csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_RedGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),tabCalibRed);
csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_GreenGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),tabCalibGreen);
csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/Lin_BlueGammaTable_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),tabCalibBlue);
screen.tabCalibRed   = tabCalibRed;
screen.tabCalibGreen = tabCalibGreen;
screen.tabCalibBlue  = tabCalibBlue;



instructions(screen,const,keys,textExp.calibScreenEnd,button.calibScreenEnd);
Screen('closeAll');


% Display results
col_b  =  black;
col_r  =  light_red;
col_g  =  light_green;
col_bl =  light_blue;

gunValues       = valTest;
lumValues(:,1) = tabCalibRed(:,4);
lumValues(:,2) = tabCalibGreen(:,4);
lumValues(:,3) = tabCalibBlue(:,4);
typicalGammaInput = gunValues';
typicalGammaData = NormalizeGamma(lumValues(:,1:end)); % nomalize measures
output = [0:255]';


for t = 1:4
    subplot(4,2,t)    
    plot(gunValues,typicalGammaData(:,1),'Color',col_r,'Marker','s','MarkerEdgeColor',red,'MarkerSize',6,'MarkerFaceColor',col_r,'LineStyle','none');
    hold on;
    plot(gunValues,typicalGammaData(:,2),'Color',col_g,'Marker','s','MarkerEdgeColor',green,'MarkerSize',6,'MarkerFaceColor',col_g,'LineStyle','none');
    plot(gunValues,typicalGammaData(:,3),'Color',col_bl,'Marker','s','MarkerEdgeColor',blue,'MarkerSize',6,'MarkerFaceColor',col_bl,'LineStyle','none');


    xlabel('Gun');
    ylabel('Normalized luminance');
    title('Measured values normalized');
    set(gca,'XLim',[-5,260],'YLim',[-0.1,1.1])

    % Fit different functions
    [valFit,paramFit] = FitGamma(typicalGammaInput,typicalGammaData,output,t);

    plot(output,valFit(:,1),'--','Color',col_r,'LineWidth',1.2);
    hold on;
    plot(output,valFit(:,2),'--','Color',col_g,'LineWidth',1.2);
    plot(output,valFit(:,3),'--','Color',col_bl,'LineWidth',1.2);

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
screen.RGBparamGamma = paramFit;

csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/RGB_GammaTabExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),gammaTable);
csvwrite(sprintf('%s/Gamma/%s/%i/RGB_Lin/RGB_ParamFitExtPowerFun_%s_%i.csv',dirC,screen.name,screen.dist,screen.name,screen.dist),paramFit);

% Save figure
plot_file= sprintf('%s/Gamma/%s/%i/RGB_Lin/RGB_GammaCurves_%s_%i',dirC,screen.name,screen.dist,screen.name,screen.dist);
saveas(f,plot_file);

end
