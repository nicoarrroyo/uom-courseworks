%% NOTES
% if a variable is plural, it should be an array of the data samples
% if a variable is singular, it should be either a normal variable or the 
    % mean value of an array
% if a variable has .0000 at the end it is an assumption or guess
%% BEGIN
clear;
%% initial definitions
error = 0.1;
power_in = 70; % W
MIMIR_ADCS_power = 22; % W
MIMIR_computer_power = 10; % W
battery_capacity = 15; % Ah OR coulombs/(60*60)

power_max = power_in-MIMIR_ADCS_power-MIMIR_computer_power; % W
mass_available = 100; % kg
sides_available = 5; % one side dedicated to engine and solar array mechanisms
%% lists of commercial options
camera_list = ["Komodo Imager" "DragonEye" "iSIM-170" "SpaceView 24" "MultiScape100 CIS"];
camera_TRLs = [9 5 9 5.0000 9];
ADCS_list = ["iADCS400" "Arcus" "RW400" "iADCS200" "READY 6-U"];
ADCS_TRLs = [9.0000 9 9 9 9.0000];
SOAR_list = ["SOAR Shuttlecock" "SOAR Feathered"];
SOAR_TRLs = [9 4.0000];
%% camera definitions
images_per_hour = 30.0000; % ASSUMPTION 120 seconds per image
imaging_duration = 5.0000; % ASSUMPTION 5 seconds to take an image
imaging_time = images_per_hour*imaging_duration/(60*60);
idle_time = 1-imaging_time;
idle_duration = idle_time*60*60/images_per_hour; % 115 seconds idle

camera_bit_depth_min = [8 10 8 8 12];
camera_bit_depth_max = [12 12 12 12 12];
camera_image_resolutions = [3840*2160*2 3840*2160*1.2 4096*3072 4096*3072*0.7 3840*2160];
%% ADCS definitions
ADCS_peak_time = 5.0000/10; % 5 seconds of test
ADCS_idle_time = 1-ADCS_peak_time; % 5 seconds of idle
%% SOAR definitions
SOAR_peak_time = 8.0000/10; % ASSUMPTION
SOAR_idle_time = 1-SOAR_peak_time;
%% power envelope in W
disp('Power Envelope [W]')
disp('--------------')

camera_powers_imaging = [45 45 30.5 10 5.8];
camera_power_imaging = mean(camera_powers_imaging)
camera_powers_idle = [25 25 18.0000 5.0000 2.5];
camera_power_idle = mean(camera_powers_idle)
camera_powers = camera_powers_imaging*imaging_time + camera_powers_idle*idle_time;

camera_voltages = [28 28 34 10.0000 5];

ADCS_powers_peak = [5 1.4 1.9 4.5 8];
ADCS_power_peak = mean(ADCS_powers_peak)
ADCS_powers_idle = [0.9 0.940 1 1.150 1.0000];
ADCS_power_idle = mean(ADCS_powers_idle)
ADCS_powers = ADCS_powers_peak*ADCS_peak_time + ADCS_powers_idle*ADCS_idle_time;

ADCS_voltages = [5 5 5 5 5.0000];

SOAR_power_peak = 5*SOAR_peak_time; % SOAR is always active during EOL
SOAR_power_idle = 5*SOAR_idle_time; % no idle time in EOL
SOAR_power = SOAR_power_peak + SOAR_power_idle

% simulation of camera power battle
simulation_time = 150; % s
power_available = power_max; % W
step = 1; % s
charge = zeros(simulation_time+1, length(camera_voltages)); % Ah
charge(1, :) = 15; % starting at full battery Ah
for camera = 1:length(camera_voltages)
    imaging_draw = camera_powers_imaging(camera);
    idle_draw = camera_powers_idle(camera);
    voltage = camera_voltages(camera);
    charge_delta = 0;
    loop_time = 0;
    for time = 1:step:simulation_time
        charge(time+1, camera) = charge(time, camera)+charge_delta;
        loop_time = loop_time+step;
        if loop_time <= imaging_duration % if imaging
            power_delta = power_available - imaging_draw;
            charge_delta = power_delta*step/voltage;
        elseif loop_time >= imaging_duration && loop_time <= imaging_duration+idle_duration % if idle
            power_delta = power_available - idle_draw;
            charge_delta = power_delta*step/voltage;
        else
            loop_time = 0;
            charge_delta = 0;
        end
        if charge(time, camera) > 15
            charge_delta = 0; charge(time, camera) = 15;
        elseif charge(time+1, camera) > 15
            charge_delta = 0; charge(time+1, camera) = 15;
        end
    end
end
%% mass envelope in kg
disp('Mass Envelope [kg]')
disp('--------------')

camera_masses = [12 18 15 10 12.1];
camera_mass = mean(camera_masses)

SOAR_mass = 3355.4e-3

ADCS_masses = [1.7 0.715 0.375 0.470 1.9];
ADCS_mass = mean(ADCS_masses)

total_mass = camera_mass+SOAR_mass+ADCS_mass
total_mass_error = linspace(total_mass*(1-error), total_mass*(1+error), 10);
%% data envelope in Mb/hr
disp('Data Envelope')
disp('--------------')

camera_image_sizes_min = camera_bit_depth_min.*camera_image_resolutions.*10^-6; % convert to Mb with 10^-6
camera_image_sizes_max = camera_bit_depth_max.*camera_image_resolutions.*10^-6; % convert to Mb with 10^-6

for i = 1:length(camera_image_sizes_min)
    camera_image_sizes(i) = mean([camera_image_sizes_min(i), camera_image_sizes_max(i)]);
end

camera_image_size = mean(camera_image_sizes);
camera_data_output = camera_image_size*images_per_hour

ADCS_data_output = 1000/24 % ASSUMPTION

SOAR_data_output = 1000/24 % ASSUMPTION
total_data = camera_data_output+ADCS_data_output+SOAR_data_output
%% configuration analysis
min_payloads = 2;    % Minimum number of payloads
max_payloads = 20;   % Maximum number of payloads
max_total_mass = 100; % Maximum total payload mass in kg
max_payload_mass = 20; % Maximum mass of a single payload (kg)
min_payload_mass = 1;  % Minimum mass of a single payload (kg)
num_configurations = 1000; % Number of configurations to generate
percentage_increment = 5;

previous_percentage = -1; % Start with a value outside the possible range (0 to 100)

valid_configurations = {};
payload_counts = [];  % To store number of payloads
total_masses = [];    % To store total mass of each configuration
disp('Configuration Calculation Completion Percentage');
disp('===============================================');
for i = 1:num_configurations
    % Randomly decide the number of payloads (between 2 and 20)
    num_payloads = randi([min_payloads, max_payloads]);
    % Generate random masses for the payloads
    payload_masses = randi([min_payload_mass, max_payload_mass], 1, num_payloads);
    % Check if the total mass is under the max limit
    total_mass = sum(payload_masses);
    
    while total_mass > max_total_mass
        % Regenerate random masses for the payloads
        payload_masses = randi([min_payload_mass, max_payload_mass], 1, num_payloads);
        % Re-check if the total mass is under the max limit
        total_mass = sum(payload_masses);
    end
    if total_mass <= max_total_mass
        % Store the valid configuration (payload masses and number of payloads)
        valid_configurations{end+1} = struct('num_payloads', num_payloads, 'payload_masses', payload_masses);
        % Store the number of payloads and total mass for plotting
        payload_counts = [payload_counts, num_payloads];
        total_masses = [total_masses, total_mass];
    end
    % Calculate the current percentage
    current_percentage = 100*i/num_configurations;
    
    % Only print when the percentage increases
    if mod(current_percentage, percentage_increment) == 0
        fprintf('%d %%\n', current_percentage);
        previous_percentage = current_percentage;
    end
end
fprintf('\nNumber of valid configurations: %d\n', length(valid_configurations));

p = polyfit(payload_counts, total_masses, 1); % Linear fit (degree 1)
fitted_line = polyval(p, payload_counts);

%% plotting configurations details
figure;
scatter(payload_counts, total_masses, 20, 'filled'); hold on;
plot(payload_counts, fitted_line, '-k', 'LineWidth', 1); hold on;
xline(5, ':r', 'LineWidth', 1);
xline(10, ':r', 'LineWidth', 1);
xline(15, ':r', 'LineWidth', 1);
xlabel('Number of Payloads'); ylabel('Total Payload Mass (kg)');
title('MIMIR Payload Configurations');
grid on; legend('Configurations', 'Best Fit Line', 'Location', 'best');
%% plotting camera details
figure()
scatter(camera_powers_imaging, camera_masses, 'filled')
hold on; scatter(camera_power_imaging, camera_mass, 'filled')
title('Imaging Power [W] vs Mass [kg] of five optical cameras'); grid on;
xlabel('Power [W]'); ylabel('Mass [kg]'); xlim([0 1.1*max(camera_powers_imaging)]); ylim([0 1.1*max(camera_masses)]);
text(camera_powers_imaging, camera_masses, camera_list, 'Vert','bottom', 'Horiz','left', 'FontSize',7);
text(camera_power_imaging, camera_mass, "AVG", 'Vert','bottom', 'Horiz','left', 'FontSize',5);

figure()
scatter(camera_powers_imaging, camera_image_sizes_min, 'filled')
hold on; scatter(camera_power_imaging, camera_image_size, 'filled')
hold on; scatter(camera_powers_imaging, camera_image_sizes_max, 'filled')
legend ('Minimum bit depth', 'Mean bit depth', 'Maximum bit depth', 'Location', 'best')
title('Imaging Power [W] vs Image Size [Mb] of five optical cameras'); grid on;
xlabel('Power [W]'); ylabel('Image Size [Mb]'); xlim([0 max(1.1*camera_powers_imaging)]); ylim([0 1.1*max(camera_image_sizes_max)]);
text(camera_powers_imaging, camera_image_sizes_min, camera_list, 'Vert','bottom', 'Horiz','left', 'FontSize',7);
text(camera_powers_imaging, camera_image_sizes_max, camera_list, 'Vert','bottom', 'Horiz','left', 'FontSize',7);
text(camera_power_imaging, camera_image_size, "AVG", 'Vert','bottom', 'Horiz','left', 'FontSize',5);

figure()
x = 1:simulation_time+1;
y1 = charge(:, 1);
y2 = charge(:, 2);
y3 = charge(:, 3);
y4 = charge(:, 4);
y5 = charge(:, 5);
p  = plot(x, y1, x, y2, x, y3, x, y4, x, y5);
legend (camera_list, 'Location', 'best')
title('Simulation Time [s] vs Charge Capacity [Ah] of five optical cameras'); grid on;
xlabel('Time [s]'); ylabel('Charge Capacity [Ah]');
xlim([0 simulation_time]); ylim([0.5*battery_capacity 1.2*battery_capacity]);
%% plotting ADCS details
figure()
scatter(ADCS_powers_peak, ADCS_masses, 'filled')
hold on; scatter(ADCS_power_peak, ADCS_mass, 'filled')
title('Peak Power [W] vs Mass [kg] of five ADCS'); grid on;
xlabel('Power [W]'); ylabel('Mass [kg]'); xlim([0 1.1*max(ADCS_powers_peak)]); ylim([0 1.1*max(ADCS_masses)]);
text(ADCS_powers_peak, ADCS_masses, ADCS_list, 'Vert','bottom', 'Horiz','left', 'FontSize',7);
text(ADCS_power_peak, ADCS_mass, "AVG", 'Vert','bottom', 'Horiz','left', 'FontSize',5);
%% END
