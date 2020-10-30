function [const] = generateTargetTrajectory(const,screen)
% Generate the trajectory of FastPursuit:
% PK 31/03/2019



%% (1) set/calculate necessary parameters:
% All these parameters are set in va, va/s, va/s2
v_t             = const.StimVelocity; % in va/s
t2              = const.presTime./1000; % in s
t1              = [0 0]; %[.5 .3 0];
acc1            = const.accelerations; % if change either initial velocity OR the acceleration perturbation, also need to change start positions accordingly (in set_stimuli_eyecceleration.m!
 
counter = 1;
for i = 1:1 % presTimes
    for j = 1:3 % accelerations
        
        v_i = v_t-acc1(j)*t2(i); % given a set v_t and different acc & acc_times, 
        
        s = (v_i*t1(i)) + (v_i*t2(i) + .5*acc1(j)*t2(i)^2);
        v_avg = s/(t1(i)+t2(i));
        
        trajParams.startPos(counter,1) = const.targetTrajOffset(i);
        trajParams.t1(counter,1)     = t1(i);
        trajParams.t2(counter,1)     = t2(i);
        trajParams.acc1(counter,1)   = acc1(j);
        trajParams.vi(counter,1)     = v_i;
        trajParams.vt(counter,1)     = v_t;
        trajParams.v_avg(counter,1)  = v_avg;
        trajParams.s(counter,1)      = s;
        
        switch i
            case 1 
                trajParams.offset(counter,1) = trajParams.s(1,1) - s;
            case 2
                trajParams.offset(counter,1) = trajParams.s(4,1) - s;
        end
        
        
        startOffsetXpix(counter)     = trajParams.offset(counter)*screen.ppd; % in pix
        
        % Simulate the defined trajectory:
        traj_tmp         = trajectory_sim2(trajParams,counter);
        traj_tmpPIX      = traj_tmp;
        % transform into pixels:
        traj_tmpPIX(:,2) = (traj_tmp(:,2).*screen.ppd) + startOffsetXpix(counter) - trajParams.startPos(counter,1);
        
        traj{counter}    = traj_tmpPIX;
        
        
        counter = counter + 1;
        clear traj_tmp
    end
end

for i = 1:size(traj,2)
    const.INTERP_TXY{i} = traj{i};
    % this is a bug fix; allows to index, rather than interpolate position at time t
    const.INTERP_TXY{i}(:,1) = round(const.INTERP_TXY{i}(:,1),3);
end
 
% %% (4) Save the Trajectory:
% save('./Stim/INTERP_TXY', 'INTERP_TXY')

end