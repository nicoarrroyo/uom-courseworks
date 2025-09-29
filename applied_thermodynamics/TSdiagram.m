clear;

%% constants & data import

Cp_air = 1010;
Cp_combustion = 1140;
R = 287;

data = readtable('Group03b_CSV.csv', 'VariableNamingRule', 'preserve');

P_range = [16, 18, 19, 20, 16];
P = table2array(data(4, P_range));
T(1) = 288.15;
for i = 2:5
    T(i) = table2array(data(4, 21+i));
end

%% real entropy changes

S_change = [0 0 0 0 0];
S = [0 0 0 0 0];
for i = 2:5
    if i == 2
        S_change(i) = (Cp_air*log(T(i)/T(i-1))) - (287*log(P(i)/P(i-1)));
    else
        S_change(i) = (Cp_combustion*log(T(i)/T(i-1))) - (287*log(P(i)/P(i-1)));
    end
    S(i) = S(i-1) + S_change(i);
end

%% idealised engine entropy changes

% TI = [T(1) 0 T(3) 0 T(1)];
% TI(2) = TI(1)*exp(R*log(P(2)/P(1))/(Cp_air));
% TI(4) = TI(3)*exp(R*log(P(5)/P(4))/(Cp_air));
% 
% S_changeI(3) = Cp_combustion*log(T(3)/T(1));
% S_changeI = [0 0 S_changeI(3) 0 0];
% 
% SI(1) = 0;
% for i = 2:4
%     SI(i) = SI(i-1) + S_changeI(i);
% end
% SI(5) = 0;

plot(S, T, '-o');
% hold on
% plot(SI, TI, '-o');
grid on
title("T-S Diagram for 49000 RPM")
xlabel("Entropy (kJ/K)")
ylabel("Temperature (K)")
