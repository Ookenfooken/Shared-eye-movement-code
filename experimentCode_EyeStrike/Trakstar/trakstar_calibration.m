function [trakstar] = trakstar_calibration(trakstar,el,screen)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calibrate Trakstar by shyeo 2013-01-16
%
% <input>
%   Experiment.Trakstar     Trakstar structure returned by trackstar_module
%                           this should be initialized
%                           additionally, should have sensorIdx field
% <output>
%   CalFcn.screen_2_world   from [1 x 3] screen coordinate to [1 x 3] world coordinate
%   CatFcn.world_2_screen   from [1 x 3] world coordinate to  [1 x 3] screen coordinate
%
% <calibration>
%   {o} reference frame for trnasmitter
%   {t} frame attached to the sensor
%   {s} reference frame for screen
%   {f} frame attched to the finger tip
%
%   find a [1 x 1], w_os [3 x 1], p_os [3 x 1], p_tf [3 x 1] that minimize norm(err), where
%
%   err = a * expm([w_os]) * p_sf + p_os - (R_ot * p_tf + p_ot)
%
%   R_ot, p_ot    : given from trakstar data
%   p_sf          : given by user (screen coordinate)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('EXP: Calibrate trakStar');

PTBinstruction_page(0, el, screen);
disp('<Trakstar calibration> started');


CAL_NUM_POINT = 5;
CAL_NUM_SAMPLE = 1; % per point

window = el.window;

[screenWidth, screenHeight] = WindowSize(window);

% use five point calibration
screenPoints = zeros(CAL_NUM_POINT, 2);

offset(1) = round(screenWidth / 3);
offset(2) = round(screenHeight / 3);

%%%% sequence: for five point calibration
% top-left
% top-right
% bottom-left
% bottom-right
% center
screenPoints([1 3],1) = offset(1);
screenPoints([2 4],1) = screenWidth - offset(1);
screenPoints([1 2],2) = offset(2);
screenPoints([3 4],2) = screenHeight - offset(2);
screenPoints(5,1) = round(screenWidth/2);
screenPoints(5,2) = round(screenHeight/2);

%%% measure samples
P_ot = zeros(3, CAL_NUM_POINT);
R_ot = zeros(3, 3, CAL_NUM_POINT);



for i = 1:CAL_NUM_POINT
    fprintf('EXP:<Trakstar calibration> show target %d\n', i);
    PTBdraw_blank(el);
    PTBdraw_target_screen(el, screenPoints(i,:), [0 0 0]);
    Screen('Flip', window, [], 1);
    Beeper;           

    %%% sample n-points before space is pressed and take average
    ret = zeros(CAL_NUM_SAMPLE, 6);

    tempIdx = 0;

    while 1
        dat = trakstar_getData(trakstar);
        ret(tempIdx + 1,:) = [dat.pos, dat.ori];
        tempIdx = mod(tempIdx + 1, CAL_NUM_SAMPLE);

        if PTBcheck_anykey_press()
            break; 
        end
        WaitSecs(0.001);
    end
    
    P_ot(:,i) = mean(ret(:,1:3), 1)';
    R_ot(:,:,i) = ang2R(mean(ret(:,4:6), 1));
end

skew = inline('[0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0]');    
P_sf = [screenPoints'; zeros(1, size(screenPoints,1))];    
    
    
%%% initial guesses
a0 = norm(P_ot(:,1) - P_ot(:,2)) / norm(P_sf(:,1) - P_sf(:,2));
ux0 = (P_ot(:,2) - P_ot(:,1)) / norm(P_ot(:,2) - P_ot(:,1));
uy0 = (P_ot(:,3) - P_ot(:,1)) / norm(P_ot(:,3) - P_ot(:,1));
uz0 = cross(ux0, uy0);
 temp = logm([ux0, uy0, uz0]);
w_os0 = [temp(3,2), temp(1,3), temp(2,1)]';
p_os0 = P_ot(:,1);
p_tf0 = [0, 0, 0]';

param0 = [a0, w_os0', p_os0', p_tf0'];

options = optimset('Display', 'iter', 'TolFun', 1e-12);
optim = lsqnonlin(@errfun, param0, [], [], options);

a = optim(1);
w_os = optim(2:4)';
p_os = optim(5:7)';
p_tf = optim(8:10)';

R_os = expm(skew(w_os));


% save the calibration functions:
trakstar.CalFcn.world_2_screen = @(x) (R_os' * (ang2R(x(4:6)) * p_tf + x(1:3)' - p_os) / a)';
trakstar.CalFcn.screen_2_world = @(x) (a * R_os * x' + p_os)';   
CalFcn = trakstar.CalFcn;
save trakstar_calibration.mat CalFcn;
trakstar.CalFcnAll{1} = CalFcn;

%% subfunctions:
function err = errfun(param)

    a = param(1);
    w_os = param(2:4)';
    p_os = param(5:7)';
    p_tf = param(8:10)';

    R_os = expm(skew(w_os));

    % for CAL_NUM_POINT calibration points,
    P_os = repmat(p_os, 1, CAL_NUM_POINT);

    R_ot_p_tf = zeros(3, CAL_NUM_POINT);

    for j = 1:CAL_NUM_POINT
        R_ot_p_tf(:,j) = R_ot(:,:,j) * p_tf;
    end

    err = a * expm(skew(w_os)) * P_sf + P_os - (R_ot_p_tf + P_ot);
end

end

function R = ang2R(ang)
%     q = pi / 180 * ang([3 2 1]);
%     c = cos(q);
%     s = sin(q);
%     R = zeros(3);
%     
%     R(1,1) = c(2) * c(3);
%     R(1,2) = -c(2) * s(3);
%     R(1,3) = s(2);
%     
%     R(2,1) = c(1) * s(3) + c(3) * s(1) * s(2);
%     R(2,2) = c(1) * c(3) - s(1) * s(2) * s(3);
%     R(2,3) = -c(2) * s(1);
%     
%     R(3,1) = s(1) * s(3) - c(1) * c(3) * s(2);
%     R(3,2) = c(3) * s(1) + c(1) * s(2) * s(3);
%     R(3,3) = c(1) * c(2);
    
    q = pi / 180 * ang([1 2 3]);
    c = cos(q);
    s = sin(q);
    R = zeros(3);
    
    R(1,1) = c(1) * c(2);
    R(1,2) = c(1) * s(2) * s(3) - c(3) * s(1);
    R(1,3) = s(1) * s(3) + c(1) * c(3) * s(2);
    
    R(2,1) = c(2) * s(1);
    R(2,2) = c(1) * c(3) + s(1) * s(2) * s(3);
    R(2,3) = c(3) * s(1) * s(2) - c(1) * s(3);
    
    R(3,1) = -s(2);
    R(3,2) = c(2) * s(3);
    R(3,3) = c(2) * c(3);
end
