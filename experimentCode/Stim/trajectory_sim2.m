function traj = trajectory_sim2(trajectoryParameter,step)
% simulate stimulus trajectory
% v_    initial velocity
% q     initial angle (in degree)
    vi   = trajectoryParameter;

    options = odeset ('MaxStep', 1.0e-3);

    %% (1) simulate trajectory:
     y0 = [vi 0]; % intial values for [velX posX]
    [tsim, ysim] = ode23t(@(t,y)dotfun(t,y,0), [0 3], y0, options);

    tplot = tsim(1):0.001:tsim(end);
    yplot = interp1(tsim, ysim, tplot, 'spline');

    traj = [tplot', yplot(:,1:2)];                                          % this contains Time, X-velocity, & X-position
    traj(:,4) = yplot(:,2);                                                          % this is Y-position (should be 0)
    traj      = traj(:,[1 3 4]);                                            % we don't need the velocity anymore, so get rid of it.
    
    %% Add a small step before the ramp:
    traj(2:end,2) = traj(2:end,2) - step;                         % add a step, set in const.
    traj(2:end,3) = traj(2:end,3) - step; 
    
end

%% subfunction for ode23t:
function ydot = dotfun(t,y,a)
    
    ydot(1) = + a; % velocity over time - first order
    ydot(2) = y(1);  % position over time - second order
    
    ydot=ydot';
end

