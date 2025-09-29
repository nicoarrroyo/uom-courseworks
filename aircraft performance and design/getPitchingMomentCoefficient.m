% C2.3

function [CM] = getPitchingMomentCoefficient(CL_Trim, CL_T, h)

get_VT;

CM = CM0 + CL_Trim*(h-h0)-(CL_T*VT);
%pitching moment coefficient with aircraft in trimmed flight
end
