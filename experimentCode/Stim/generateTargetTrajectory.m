function [const] = generateTargetTrajectory(const,screen)
% Generate the trajectory of FastPursuit:
% PK 31/03/2019


%% (1) set/calculate necessary parameters:
% All these parameters are set in va, va/s, va/s2
% ramp parameters (velocity)
v_i             = const.StimVelocity; % in va/s
v_xy            = sqrt((v_i^2)/2); % pythagoras for if vel_x and vel_y are the same. 
% step parameter (position step):
step_i          = const.stepRamp;
step_xy         = sqrt((step_i^2)/2);
% second fixation offset:
startOffsetX    = const.startOffsetX; % in va
startOffsetXY   = sqrt((startOffsetX^2)/2);
startOffsetXYpix = screen.x_ppd*startOffsetXY; % in pix


%% (2) Simulate the defined trajectory:
traj = trajectory_sim2(v_xy,step_xy);

%% (3) Convert from va to pix:
for i = 1:length(traj)
    traj(i,2) = screen.x_ppd*traj(i,2)-startOffsetXYpix;
    traj(i,3) = screen.y_ppd*traj(i,3)-startOffsetXYpix;
end

const.INTERP_TXY{1} = traj; % x vel positive, y vel positive
const.INTERP_TXY{2} = const.INTERP_TXY{1}; const.INTERP_TXY{2}(:,2) = const.INTERP_TXY{2}(:,2)*(-1);   % x vel negative, y vel positive
const.INTERP_TXY{3} = const.INTERP_TXY{1}; const.INTERP_TXY{3}(:,3) = const.INTERP_TXY{3}(:,3)*(-1);   % x vel positive, y vel negative
const.INTERP_TXY{4} = const.INTERP_TXY{1}; const.INTERP_TXY{4}(:,2) = const.INTERP_TXY{4}(:,2)*(-1); const.INTERP_TXY{4}(:,3) = const.INTERP_TXY{4}(:,3)*(-1); % x vel negative, y vel negative


% this is a bug fix; allows to index, rather than interpolate position at time t
const.INTERP_TXY{1}(:,1) = round(const.INTERP_TXY{1}(:,1)*1000)/1000; %round(const.INTERP_TXY{1}(:,1),3);
const.INTERP_TXY{2}(:,1) = round(const.INTERP_TXY{2}(:,1)*1000)/1000; %round(const.INTERP_TXY{2}(:,1),3);
const.INTERP_TXY{3}(:,1) = round(const.INTERP_TXY{3}(:,1)*1000)/1000; %round(const.INTERP_TXY{2}(:,1),3);
const.INTERP_TXY{4}(:,1) = round(const.INTERP_TXY{4}(:,1)*1000)/1000; %round(const.INTERP_TXY{2}(:,1),3);
% 
% %% (4) Save the Trajectory:
% save('./Stim/INTERP_TXY', 'INTERP_TXY')


end