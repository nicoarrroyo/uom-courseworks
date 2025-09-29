% C3.2

function [CL_Trim, CD_Trim] = get_TrimCLCD(gamma_FP, weight, Mach, alt)

get_Constants
[p, ~, ~, ~] = APD1(alt);

L = weight*cosd(gamma_FP);
q = 0.5*p*1.4*Mach^2;
CL_Trim = L/(q*S);
CD_Trim = q*S*(C_D0+k*CL_Trim^2);

end