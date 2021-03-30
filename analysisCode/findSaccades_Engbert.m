function [ms] = findSaccades_Engbert(eyeData, analysisParams)

% findSaccades_Engbert

% This function allows one to detect saccades (using velocity-based criterion)
% using E&M (2006) developed by PK
% read anaEyeMovements #5 for more information

% INPUT:
% - eyeData (containing x,y data)
% - analysisParams (containing relevant params for detection

% OUTPUT:
% - ms
% (ms,1) = saccade onset
% (ms,2) = saccade offset
% (ms,3) = saccade duration
% (ms,4) = peak velocity
% (ms,5) = saccade distance
% (ms,6) = distance angle
% (ms,7) = saccade amplitude
% (ms,8) = amplitude angle

% UPDATE RECORD:
% 03/30/2021 (DC): Development

% TO-DO:
% - to be integrated with findSaccades_select

%%
x = [eyeData.X eyeData.Y]; % use raw data
v = vecvel(x, analysisParams.sampleRate, 2);
ms = microsaccMerge(x, v, analysisParams.sac.velSD, analysisParams.sac.minDur, analysisParams.sac.mergeInt);
ms = saccpar(ms);


end

function [msac, radius] = microsaccMerge(x,vel,VFAC,MINDUR,mergeInterval)
%-------------------------------------------------------------------
%
%  FUNCTION microsacc.m
%  Detection of monocular candidates for microsaccades;
%  Please cite: Engbert, R., & Mergenthaler, K. (2006) Microsaccades 
%  are triggered by low retinal image slip. Proceedings of the National 
%  Academy of Sciences of the United States of America, 103: 7192-7197.
%
%  (Version 2.1, 03 OCT 05)
%
%-------------------------------------------------------------------
%
%  INPUT:
%
%  x(:,1:2)         position vector
%  vel(:,1:2)       velocity vector
%  VFAC             relative velocity threshold
%  MINDUR           minimal saccade duration
%  mergeInterval    merge interval for subsequent saccade candidates
%
%  OUTPUT:
%
%  sac(1:num,1)   onset of saccade
%  sac(1:num,2)   end of saccade
%  sac(1:num,3)   peak velocity of saccade (vpeak)
%  sac(1:num,4)   horizontal component     (dx)
%  sac(1:num,5)   vertical component       (dy)
%  sac(1:num,6)   horizontal amplitude     (dX)
%  sac(1:num,7)   vertical amplitude       (dY)
%
%---------------------------------------------------------------------

% compute threshold
msdx = sqrt( median(vel(:,1).^2) - (median(vel(:,1)))^2 );
msdy = sqrt( median(vel(:,2).^2) - (median(vel(:,2)))^2 );
if msdx<realmin
    msdx = sqrt( mean(vel(:,1).^2) - (mean(vel(:,1)))^2 );
    if msdx<realmin
        %error('msdx<realmin in microsacc.m');
    end
end
if msdy<realmin
    msdy = sqrt( mean(vel(:,2).^2) - (mean(vel(:,2)))^2 );
    if msdy<realmin
        %error('msdy<realmin in microsacc.m');
    end
end
radiusx = VFAC*msdx;
radiusy = VFAC*msdy;
radius = [radiusx radiusy];

% compute test criterion: ellipse equation
test = (vel(:,1)/radiusx).^2 + (vel(:,2)/radiusy).^2;
indx = find(test>1);

% determine saccades
N = length(indx); 
sac = [];
nsac = 0;
dur = 1;
a = 1;
k = 1;
while k<N
    if indx(k+1)-indx(k)==1
        dur = dur + 1;
    else
        if dur>=MINDUR
            nsac = nsac + 1;
            b = k;
            sac(nsac,:) = [indx(a) indx(b)];
        end
        a = k+1;
        dur = 1;
    end
    k = k + 1;
end

% check for minimum duration
if dur>=MINDUR
    nsac = nsac + 1;
    b = k;
    sac(nsac,:) = [indx(a) indx(b)];
end

% merge saccades
if ~isempty(sac)
    msac = sac(1,:);    % merged saccade matrix
    s    = 1;           % index of saccades in sac
    sss  = 1;           % boolean for still same saccade
    nsac = 1;           % number of saccades after merge
    while s<size(sac,1)
        if ~sss
            nsac = nsac + 1;
            msac(nsac,:) = sac(s,:);
        end
        if sac(s+1,1)-sac(s,2) <= mergeInterval
            msac(nsac,2) = sac(s+1,2);
            sss = 1;
        else
            sss = 0;
        end
        s = s+1;
    end
    if ~sss
        nsac = nsac + 1;
        msac(nsac,:) = sac(s,:);
    end
else
    msac = [];
    nsac = 0;
end

% compute peak velocity, horizonal and vertical components
for s=1:nsac
    % onset and offset
    a = msac(s,1); 
    b = msac(s,2); 
    % saccade peak velocity (vpeak)
    vpeak = max( sqrt( vel(a:b,1).^2 + vel(a:b,2).^2 ) );
    msac(s,3) = vpeak;
    % saccade vector (dx,dy)
    dx = x(b,1)-x(a,1); 
    dy = x(b,2)-x(a,2); 
    msac(s,4) = dx;
    msac(s,5) = dy;
    % saccade amplitude (dX,dY)
    i = msac(s,1):msac(s,2);
    [minx, ix1] = min(x(i,1));
    [maxx, ix2] = max(x(i,1));
    [miny, iy1] = min(x(i,2));
    [maxy, iy2] = max(x(i,2));
    dX = sign(ix2-ix1)*(maxx-minx);
    dY = sign(iy2-iy1)*(maxy-miny);
    msac(s,6:7) = [dX dY];
end
end

function v = vecvel(xx,SAMPLING,TYPE)
%------------------------------------------------------------
%
%  VELOCITY MEASURES
%  - EyeLink documentation, p. 345-361
%  - Engbert, R. & Kliegl, R. (2003) Binocular coordination in
%    microsaccades. In:  J. Hyona, R. Radach & H. Deubel (eds.) 
%    The Mind's Eyes: Cognitive and Applied Aspects of Eye Movements. 
%    (Elsevier, Oxford, pp. 103-117)
%
%  (Version 1.2, 01 JUL 05)
%-------------------------------------------------------------
%
%  INPUT:
%
%  xy(1:N,1:2)     raw data, x- and y-components of the time series
%  SAMPLING        sampling rate
%
%  OUTPUT:
%
%  v(1:N,1:2)     velocity, x- and y-components
%
%-------------------------------------------------------------
N = length(xx);            % length of the time series
v = zeros(N,2);

switch TYPE
    case 1
        v(2:N-1,:) = SAMPLING/2*[xx(3:end,:) - xx(1:end-2,:)];
    case 2
        v(3:N-2,:) = SAMPLING/6*[xx(5:end,:) + xx(4:end-1,:) - xx(2:end-3,:) - xx(1:end-4,:)];
        v(2,:) = SAMPLING/2*[xx(3,:) - xx(1,:)];
        v(N-1,:) = SAMPLING/2*[xx(end,:) - xx(end-2,:)];
end
end

function sac = saccpar(sac)
%-------------------------------------------------------------------
%
%  FUNCTION saccpar.m
%
%  (Version 1.0, 01 AUG 05)
%
%-------------------------------------------------------------------
%
%  INPUT: binocular saccade matrix from FUNCTION binsacc.m
%
%  sac(:,1:7)       monocular microsaccades (from microsacc.m)
%
%  OUTPUT:
%
%  sac(:,1:8)       Parameters 
%
%---------------------------------------------------------------------
if size(sac,1)>0
    % 1. Onset
    a = sac(:,1);

    % 2. Offset
    b = sac(:,2);

    % 3. Duration
    D = ((b-a));

    % 4. Peak velocity
    vpeak = sac(:,3);

    % 6. Saccade distance
    dist = sqrt(sac(:,4).^2+sac(:,5).^2);
    angd = atan2(sac(:,5),sac(:,4));

    % 7. Saccade amplitude
    ampl = sqrt(sac(:,6).^2+sac(:,7).^2);
    anga = atan2(sac(:,7),sac(:,6));

    sac = [a b D vpeak dist angd ampl anga];
else
    sac = [];
end
end