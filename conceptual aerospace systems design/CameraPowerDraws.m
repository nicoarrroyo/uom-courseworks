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
%% lists of commercial options
camera_list = ["High Power Camera" "Low Power Camera"];
%% camera definitions
images_per_hour = 30.0000; % ASSUMPTION 120 seconds per image
imaging_duration = 5.0000; % ASSUMPTION 5 seconds to take an image
imaging_time = images_per_hour*imaging_duration/(60*60);
idle_time = 1-imaging_time;
idle_duration = idle_time*60*60/images_per_hour; % 115 seconds idle

camera_bit_depth_min = [8 12];
camera_bit_depth_max = [12 12];
camera_image_resolutions = [3840*2160*2 3840*2160];
%% power envelope in W

camera_powers_imaging = [45 5.8];
camera_power_imaging = mean(camera_powers_imaging)
camera_powers_idle = [25 2.5];
camera_power_idle = mean(camera_powers_idle)
camera_powers = camera_powers_imaging*imaging_time + camera_powers_idle*idle_time;

camera_voltages = [28 5];

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
%% plotting camera details
figure()
x = 1:simulation_time+1;
y1 = charge(:, 1); y2 = charge(:, 2);
p  = plot(x, y1, x, y2);
legend (camera_list, 'Location', 'best')
title('Simulation Time [s] vs Charge Capacity [Ah] of five optical cameras'); grid on;
xlabel('Time [s]'); ylabel('Charge Capacity [Ah]');
xlim([0 simulation_time]); ylim([0.9*min(min(charge)) 1.1*max(max(charge))]);
%% END