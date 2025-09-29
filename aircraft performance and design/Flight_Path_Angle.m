% C3.1, C3.4
clear
%hello :(
load('BIG_GUY_variables.mat', 'mach', 'TAS_ISA', 't0');
get_Constants;
BIG_GUY;
load('G16_NicolasArroyo.mat');
timestamp = table2array(G16ArroyoNicolas(:,1));
flight_time = timestamp - timestamp(1);
alt = table2array(G16ArroyoNicolas(:, 5));
index = length(alt);
gamma_FP = [];
delta_weight = [];
delta_weight(1) = MTOW_N;


for i = 1:index-1
    dt = flight_time(i+1) - flight_time(i);
    d_alt = alt(i+1) - alt(i);
    dx = 0.5*(TAS_ISA(i) + TAS_ISA(i+1)) * dt;
    gamma_FP(i) = asind(d_alt/dx);

    [CL_Trim, CD_Trim] = get_TrimCLCD(gamma_FP(i), delta_weight(i), mach(i), alt(i));
    [ps, ~, ~, ~] = APD1(alt(i));
    q = 0.5*ps*1.4*mach(i)^2;
    TR(i) = (q*S*CD_Trim) + (delta_weight(i)*sind(gamma_FP(i)));
    [fuel_flow_rate] = get_FlowRate(mach(i), TR(i), alt(i));
    delta_weight(i+1) = delta_weight(i) - (fuel_flow_rate*dt*9.8065);
end

gamma_FP(end+1) = gamma_FP(end);
TR(end+1) = TR(end);


f = figure;
plot(flight_time, gamma_FP);
xlabel('Flight Time (s)');
ylabel('Flight Path Angle');

% figure(2);
% plot(flight_time, delta_weight, "b");
% xlabel('Flight Time in seconds');
% ylabel('Aircraft weight in Newtons');
