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
ADCS_power_peak = mean(ADCS_powers_peak);
ADCS_powers_idle = [0.9 0.940 1 1.150 1.0000];
ADCS_power_idle = mean(ADCS_powers_idle);
ADCS_powers = ADCS_powers_peak*ADCS_peak_time + ADCS_powers_idle*ADCS_idle_time;

ADCS_voltages = [5 5 5 5 5.0000];

SOAR_power_peak = 5*SOAR_peak_time; % SOAR is always active during EOL
SOAR_power_idle = 5*SOAR_idle_time; % no idle time in EOL
SOAR_power = SOAR_power_peak + SOAR_power_idle;
%% mass envelope in kg
disp('Mass Envelope [kg]')
disp('--------------')

camera_masses = [12 18 15 10 12.1];
camera_mass = mean(camera_masses);

SOAR_mass = 3355.4e-3;

ADCS_masses = [1.7 0.715 0.375 0.470 1.9];
ADCS_mass = mean(ADCS_masses);

total_mass = camera_mass+SOAR_mass+ADCS_mass;
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
camera_data_output = camera_image_size*images_per_hour;

ADCS_data_output = 1000/24.0000;

SOAR_data_output = 1000/24.0000;
total_data = camera_data_output+ADCS_data_output+SOAR_data_output;

