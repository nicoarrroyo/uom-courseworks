% C2.1

function [CL_T] = get_tailCL(CL_Trim, eta_T)
% CL_Trim is the coefficient of lift (assumed to be the same as the main
% wing's lift coefficient) to keep the aircraft in trimmed flight

%eta_T is the angle of the tailplane with respect to the main wing's zero
%lift line

get_VT;

CL_T = (CL_Trim*(a1/a)*(1-drf)+(a1*eta_T));

end
