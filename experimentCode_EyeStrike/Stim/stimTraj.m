function ret = stimTraj(t, trajIdx, INTERP_TXY)
% read out the position of the target at time t. This uses interpolation of
% the pre-defined stimulus trajectory and reads out the position at time t. 
% PK 26/03/2019
ret = interp1(INTERP_TXY{trajIdx}(:,1), INTERP_TXY{trajIdx}(:,2:3), t, 'spline');
end
