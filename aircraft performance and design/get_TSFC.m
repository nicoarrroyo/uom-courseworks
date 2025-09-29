% C4.1

function [ctp] = get_TSFC(Mach,theta)

% Declare known constants
n2 = 0.432;     % TSFC exponent, -
ct2 = 0.611;  % TSFC constant, s-1
g0 = 9.8065; % Gravitational accelerational at sea-level

% Determine TSFC at this relative temp, Mach, kg/s/N
ctp = (1/(3600*g0))*ct2*sqrt(theta)*Mach^n2;

end