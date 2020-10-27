function [b, ret] = check_fixated(control, t, d, dmax, duration, fieldname)
%
% if norm(d) < dmax for duration, b = 1
% menawhile, store the start time of checking 
% in a temporary field 'fieldname' in Eyecatch.Control

if norm(d) <= dmax
    if isfield(control, fieldname)
        if t - control.(fieldname) > duration
            b = 1;
            %Eyecatch.Control = rmfield(Eyecatch.Control, fieldname);
             ret = control;

            return;
        else
            b = 0;
             ret = control;
            return;
        end
    else
        b = 0;
        control.(fieldname) = t;
        ret = control;
        return;
    end
else
    b = 0;
    if isfield(control, fieldname)
        control = rmfield(control, fieldname);
    end

    ret = control;
    return;
end

end