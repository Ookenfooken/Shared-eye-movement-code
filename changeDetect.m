% FUNCTION to find pursuit onset
% find the change in y(x), by fitting a piecewise linear model
% with one break. 
%  ly\    
%     \  /ry 
%      \/
%       (cx,cy)
% history
% this function was written by Dinesh Pai some time ago
% if you have questions you are on your own!

function [cx,cy,ly,ry] = changeDetect(x,y)
warning off; 
% initialize parameters, p0, to reasonable values
w = ceil(length(x)/10);% small window
ly = mean(y(1:w));
ry = mean(y(end-w+1:end));
cy = mean(y(w+1:end-w));
cx = mean(x(w+1:end-w));
p0 = [cx,cy,ly,ry];
% minimize residual
options = optimset('Display', 'off');
p = lsqnonlin(@myfun,p0,[],[],options);
cx = p(1); cy = p(2); ly = p(3); ry = p(4);
return;
% inner function for computing residual errors
    function residual = myfun (p)
        cx = p(1); cy = p(2); ly = p(3); ry = p(4);
        residual = zeros(size(x));
        for i = 1:length(x)
            residual(i) = y(i) - evalPWL(x(i),x(1),ly,cx,cy,x(end),ry);
        end
    end

end

