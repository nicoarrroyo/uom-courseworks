clear;

TT1 = 288; % [K] ambient temperature
gamma = 1.4; % for air

data = readtable('Group03b_CSV.csv', 'VariableNamingRule', 'preserve'); % take table data
RPM = table2array(data([3 11 21 31], 27));

% rows = [4 12 22 32]; % rows for the necessary data
TT3 = table2array(data([4 12 22 32], 23)); % [K] stagnation temp at compressor exit
PT3 = table2array(data([4 12 22 32], 18)); % [Pa] stagnation pressure at compressor exit
PS1 = table2array(data([4 12 22 32], 16)); % [Pa] static pressure at inlet

for i = 1:4
    TT3_isentropic(i) = TT1*((PT3(i)/PS1(i))^((gamma-1)/gamma)); % [K] temp compressor exit temp assuming isentropic
    efficiency(i) = 100*(TT3_isentropic(i) - TT1)/(TT3(i)-TT1); % [%] compressor efficiency
end

p = polyfit(RPM, efficiency, 2);
RPM_range = linspace(RPM(1), RPM(end));
poly_efficiency = polyval(p, RPM_range);

% plot(RPM, efficiency, '-o');
scatter(RPM, efficiency); % plots only data points
hold on
plot (RPM_range, poly_efficiency) % polynomial curve (order 2) to fit to the points
hold off

grid on
title('RPM vs Compressor Efficiency')
xlabel('RPM')
ylabel('Compressor Efficiency η (%)')
