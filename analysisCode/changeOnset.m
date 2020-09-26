function [inputX]=changeOnset(trial,pPos,pVel,color)
   
   o=(ginput(1));
   inputX=round(o(1));
   temp=plot(pVel,inputX,trial.eyeDX_filt(inputX),color, 'MarkerSize',8);
   temp2=plot(pPos,inputX,trial.eyeX_filt(inputX),color, 'MarkerSize',8);
   prompt = 'Keep Onset? Y/n [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
       str = 'Y';
    end
   
   if strcmp(str,'Y')
       disp('keep')
       
   elseif strcmp(str,'n') 
       delete(temp);
       delete(temp2);
       inputX=changeOnset(trial,pPos,pVel,color);
   else
       inputX=-999;
       delete(temp);
       delete(temp2);
   end
   
end