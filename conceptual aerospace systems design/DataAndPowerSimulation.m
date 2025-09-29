%% BEGIN
clear;
%% Definitions
% Payload-specific parameters
payloads = struct( ...
    'EO', struct('power_imaging', 27.26, 'power_idle', 15.1, 'data_output', 3532.9), ...
    'ADCS', struct('power_peak', 4.16, 'power_idle', 0.998, 'data_output', 1000 / 24), ...
    'SOAR', struct('power', 5, 'data_output', 1000 / 24));

% Miscellaneous parameters
hours_per_day = 24;
days = 40;
testing_schedule = {'EO', 'EO', 'SOAR', 'SOAR', 'SOAR', 'EO', 'EO', 'ADCS', 'ADCS', 'EO'};
%% Simulation Initialization
power_draw = zeros(1, days);
data_generated = zeros(1, days);
data_max = 1000*1000; % 1 Tb toatl storage
data_min = 128*1000; % 128 Gb for MIMIR OS
data_used = zeros(1, days); data_used(1, 1) = data_min;
revisit_period = 10; % days between data downlinks
downlink_day = 1;
%% Simulation Loop
for day = 1:days
    if day <= 10
        day_sched = day;
    elseif day <= 20 && day > 10
        day_sched = day - 10;
    elseif day <= 30 && day > 20
        day_sched = day-20;
    elseif day <= 40 && day > 30
        day_sched = day-30;
    elseif day <= 50 && day > 40
        day_sched = day-40;
    end
    payload = payloads.(testing_schedule{day_sched});
    if strcmp(testing_schedule{day_sched}, 'EO')
        daily_power = (payload.power_imaging*0.2 + payload.power_idle*0.8)*hours_per_day;
    elseif strcmp(testing_schedule{day_sched}, 'ADCS')
        daily_power = (payload.power_peak*0.5 + payload.power_idle*0.5)*hours_per_day;
    else % SOAR
        daily_power = payload.power*hours_per_day;
    end

    power_draw(day) = daily_power;
    data_generated(day) = payload.data_output*hours_per_day;
    if mod(day, revisit_period) == 0
        data_used(day) = data_min;
        downlink_day = day;
    else
        data_used(day) = data_min+sum(data_generated(downlink_day:day));
    end
end
%% Plotting Results
figure;
% Power Draw Plot
subplot(2, 1, 1);
bar(1:days, power_draw); grid on;
title(['Daily Power Draw Over ' num2str(days), ' Days']);
xlabel('Day'); ylabel('Power Draw (Wh)');
xticks(0:5:days);
yline(38*24, 'b')
legend('Power Draw', 'Power Generated', 'Location', 'best');

% Data Generation and Usage Plot
subplot(2, 1, 2); hold on;
plot(1:days, cumsum(data_generated), '-o');
plot(1:days, data_used, '-s');
yline(data_max, 'r', 'label', 'Max. Data Storage');
yline(data_min, 'b', 'label', 'Storage for MIMIR OS');
ylim([0, inf]);
hold off;
grid on;
title(['Data Generated and Storage Used Over ' num2str(days) ' Days']);
xlabel('Day'); ylabel('Data (Mb)');
legend('Total Data Generated', 'Storage Used', 'Location', 'best');
%% END