% FUNCTION to find pursuit onset
% find the change in y(x), by fitting a piecewise linear model
% with one break. x is time (frames), y is the 2D velocity vector
%  ly\    
%     \  /ry 
%      \/
%       (cx,cy)
% It works for the curve with either shape (pointing down or up).
% If you want you can also use this function to find the steady-state 
% phase onset (for that before the break point should only include 
% the open-loop phase, since this only assumes one break point), 
% although a fixed open-loop duration of 140ms works just fine under 
% most conditions. You can also modify the function to fit a piecewise
% linear model with two breaks for finding both onsets.
% History
% this function was written by Dinesh Pai some time ago
% 26-04-2018    XW added some comments
% for questions email xiuyunwu5@gmail.com

function [cx,cy,ly,ry] = changeDetect(x,y)
warning off; 
% initialize parameters, p0, to reasonable values
w = ceil(length(x)/10);% small window
ly = mean(y(1:w)); % y value of the most left point
ry = mean(y(end-w+1:end)); % y value of the most right point
cy = mean(y(w+1:end-w)); % y value of the break point
cx = mean(x(w+1:end-w)); % the time point of the break, which is pursuit onset
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

