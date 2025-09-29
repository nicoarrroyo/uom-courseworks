%% Aerospace Structures 3 COURSEWORK
% Nicolas Renato Arroyo 11091029
clearvars; close all;

%% Q3 a
% AI 2024 T3 material properties
sigma_u = 470e6;   %ultimate tensile strength [Pa]
sigma_Y = 325e6;   %yield strength [Pa]
E = 73e9;   %young's modulus [Pa]
v = 0.33;   %poisson's ratio
K_IC = 18e6;   %fracture toughness [Pa m^1/2]
sigma_e = 140e6;   %fatigue endurance [Pa]
ss = 280e6;   %shear strength [Pa]
bus = 815e6;   %bearing ultimate strength [Pa]

% Geometric properties of fuselage
t = 0.02;   %thickness [m]
d = 0.02;   %bolt diameter [m]
W = 0.15;   %width [m]

% 3 a i
p_i = 0.5e6;
syms a_cr;   %defining symbolic function for half critical crack length
eq = K_IC == ((p_i / t) * sqrt(W * tan((pi * a_cr) / W)));
a_cr_sol = vpasolve(eq, a_cr, [0, W/2]);
crack_size_1 = 2 * a_cr_sol;
fprintf('Critical crack size %.6f m\n',crack_size_1)

% 3 a ii
p_ii = 0.8e6;
syms a_cr;   %defining symbolic function for half critical crack length
eq = K_IC == ((p_ii / t) * sqrt(W * tan((pi * a_cr) / W)));
a_cr_sol = vpasolve(eq, a_cr, [0, W/2]);
crack_size_2 = 2 * a_cr_sol;
fprintf('Critical crack size %.6f m\n',crack_size_2)

%% QUESTION 3a - Critical Crack Size
sigma_u = 470e6; % Ultimate tensile strength [Pa]
sigma_Y = 325e6; % Yield strength [Pa]
v = 0.33; % Poisson's ratio
K_IC = 18e6; % Fracture toughness [Pa m^1/2]

% Fuselage dimensions
t = 0.02; % Thickness [m]
W = 0.15; % Width [m]

% Loading conditions (converted from kN/mm to MPa)
P_norm = 0.5; % kN/mm (Normal service load)
P_acci = 0.8; % kN/mm (Accidental peak load)

sigma_norm = (P_norm * 1e3) / t; % Normal service stress [Pa]
sigma_accidental = (P_acci * 1e3) / t; % Accidental peak stress [Pa]

%% 3ai & 3aii - Normal Service and Accidental Peak Loads

% Define symbolic variables
syms a_c K_I_sym

% Function for solving crack length
eq = K_IC == ((p_i / t) * sqrt(W * tan((pi * a_cr) / W)));
getCriticalCrackSize = @(sigma, P) vpasolve(sub(K_I_sym == ((P / t) * ... 
    sqrt(W * tan((pi * a_cr) / W)))));
% getCriticalCrackSize = @(sigma, P) vpasolve(subs(K_I_sym == 0.5 * ... 
%     ((tan((pi * a_c) / W) / ((pi * a_c) / W))^0.5) * ...
%     (sigma * sqrt(pi * a_c)) + 0.5 * (P / sqrt(pi * a_c)), K_I_sym, K_IC), a_c, [0, W]);

% Compute and display results
a_c_critical_norm = double(getCriticalCrackSize(sigma_norm, P_norm));
fprintf('Critical crack size for no accidental peak load: %.3f m\n', a_c_critical_norm);

a_c_critical_acci = double(getCriticalCrackSize(sigma_accidental, P_acci));
fprintf('Critical crack size for accidental peak load: %.3f m\n', a_c_critical_acci);

%% QUESTION 3B - Crack Size and Shape

syms r_p theta

% Plane Stress and Plane Strain Plastic Zone Equations
eq_plane_stress = r_p == (K_IC^2 / (2 * pi * sigma_Y^2)) * ... 
    (cos(theta/2))^2 * (1 + 3 * sin(theta/2)^2);
eq_plane_strain = r_p == (K_IC^2 / (2 * pi * sigma_Y^2)) * ... 
    (cos(theta/2))^2 * ((1 - 2 * v)^2 + 3 * sin(theta/2)^2);

% Solve for max stress concentration at theta = 0
r_p_plane_stress = double(subs(rhs(eq_plane_stress), theta, 0));
r_p_plane_strain = double(subs(rhs(eq_plane_strain), theta, 0));

% Display results
fprintf('Plastic zone radius for plane stress: %.4f mm\n', r_p_plane_stress * 1e3);
fprintf('Plastic zone radius for plane strain: %.4f mm\n', r_p_plane_strain * 1e3);

% Plotting in Polar Coordinates
theta_vals = linspace(0, 2*pi, 100);
r_p_stress_vals = double(subs(rhs(eq_plane_stress), theta, theta_vals));
r_p_strain_vals = double(subs(rhs(eq_plane_strain), theta, theta_vals));

figure;
polarplot(theta_vals, r_p_stress_vals, 'b', 'LineWidth', 2);
hold on;
polarplot(theta_vals, r_p_strain_vals, 'r', 'LineWidth', 2);
hold off;

title('Plastic Zone Radius in Polar Coordinates');
legend('Plane Stress', 'Plane Strain');
