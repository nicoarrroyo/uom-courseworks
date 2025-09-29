% C3.3

function [fuel_flow_rate] = get_FlowRate(Mach, TR, alt)
get_Constants;

[~, T, ~, ~] = APD1(alt);
rel_temp = T/288.15;
% TSFC = (c_t2*(Mach^n_2)*sqrt(rel_temp)/(9.81*3600)); 
TSFC = 1.54*10^-5;
fuel_flow_rate = TSFC * TR;

end