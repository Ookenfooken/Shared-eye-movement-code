% FUNCTION to update trial information in a text box when clicking through
% trials using viewEyeData.m
% history
% 07-2012       JE created updatePlots.m
% 2012-2018     JF added stuff to and edited updatePlots.m
% 16-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%                  (remember by now we have stored saccade information in
%                   trial as well)
% output: this will plot in the open figure

function [] = updateText(trial, fig)

screenSize = get(0,'ScreenSize');
name = evalin('base', 'name');
% chose position of the text box
xPosition = 10; 
yPosition = screenSize(4)-screenSize(4)*2/3; 
% how large should it be?
verticalDistance = 20;
width = 180 ;
height = 20;
textblock = 0;

% now we can add all infos we want in a text box each
subjectIdText = uicontrol(fig,'Style','text',...
    'String', ['subject ID: ' trial.log.subject],...
    'Position',[xPosition yPosition width height],...
    'HorizontalAlignment','left'); %#ok<*NASGU>

textblock = textblock+1;
trialNoText = uicontrol(fig,'Style','text',...
    'String', ['Trial No.: ' trial.log.trialNumber],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

end


