% find stall speed
clear;
airports = ['SBGL', 'TLPC', 'SBSP', 'SBFR', 'DNMM', 'OMAA'];
airport_altitudes = ['9', '7', '802', '10', '135', '27'];
airport_values = [];

for i = 1:length(airport_altitudes)
    [~, ~, rho, ~] = APD1(airport_altitudes(i));
    airport_values(i) = rho;
end

airport_values