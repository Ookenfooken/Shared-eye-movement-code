% this function is called by changeDetect.m
% it's part of the piecewise linear fit
function y = evalPWL(x,lx,ly,cx,cy,rx,ry)
warning off;
if x <= cx
    alpha = (x - cx)/(lx - cx);
    y = alpha*ly + (1-alpha)*cy;
else
    alpha = (x - cx)/(rx - cx);
    y = alpha*ry + (1-alpha)*cy;
end
end
    
