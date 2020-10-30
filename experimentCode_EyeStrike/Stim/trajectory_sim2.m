function traj = trajectory_sim2(trajectoryParameter,index)
% simulate stimulus trajectory
% v_    initial velocity
% q     initial angle (in degree)
    vi   = trajectoryParameter.vi(index);
    acc1 = trajectoryParameter.acc1(index);
    t1   = trajectoryParameter.t1(index);
    t2   = trajectoryParameter.t2(index);
    offset = trajectoryParameter.offset(index);
    
    options = odeset ('MaxStep', 1.0e-3);

    %% (1) simulate trajectory:
    % a) initial movement (no acceleration):
    if t1 ~= 0
        y0 = [vi 0]; % intial values for [velX posX]
        [tsim, ysim] = ode23t(@(t,y)dotfun(t,y,0), [0 t1], y0, options);
    
        tplot = tsim(1):0.001:tsim(end);
        yplot = interp1(tsim, ysim, tplot, 'spline');
    
        traj_ini = [tplot', yplot(:,1:2)]; % this contains Time, X-velocity, & X-position
    end
    
     % b) accelerating movement:
     y1 = [vi 0]; % initial values
     [tsim2, ysim2] = ode23t(@(t,y)dotfun(t,y,acc1), [0 3], y1, options);
    
     tplot2 = tsim2(1):0.001:tsim2(end);
     yplot2 = interp1(tsim2, ysim2, tplot2, 'spline');
     
     traj_fini = [tplot2', yplot2(:,1:2)]; % this contains Time, X-velocity, & X-position   

     
     % putting both together:
     if t1 == 0
         traj_ = traj_fini;
     else
         traj_fini(:,1) = traj_fini(:,1) + t1;
         traj_fini(:,3) = traj_fini(:,3) + traj_ini(end,3);
         traj_      = [traj_ini(:,:); traj_fini(2:end,:)];
     end
     
     traj_(:,4) = 0; % this is Y-position (should be 0)                                     
     traj      = traj_(:,[1 3 4]); % we don't need the velocity anymore, so get rid of it.
    
    
%     %% Add a small step before the ramp:
%     traj(2:end,2) = traj(2:end,2) + offset;                         % add a step, set in const.
%     
    
end

%% subfunction for ode23t:
function ydot = dotfun(t,y,a)
    
    ydot(1) = + a; % velocity over time - first order
    ydot(2) = y(1);  % position over time - second order
    
    ydot=ydot';
end

