% Aerospace Structures 3 COURSEWORK
% Nicolas Renato Arroyo 11091029
clc, clear

%% Q3 a
v = 0.33; % poisson's ratio
K_IC = 18e6; % fracture toughness [Pa√m]

% Geometric properties of fuselage
t = 0.020; % thickness [m]
W = 0.150; % width [m]

p1 = 0.5e6; % N/m (normal in-service load)
p2 = 0.8e6; % N/m (accidental peak load)

% Convert loads to stresses
sigma1 = p1 / t; % Normal service stress
sigma2 = p2 / t; % Accidental peak stress

% Define the function to solve for a_c
syms a_c
Y_expr = sqrt(tan(pi * (a_c / W)) / (pi * (a_c / W)));

eq1 = K_IC == Y_expr * sigma1 * sqrt(pi * a_c);
eq2 = K_IC == Y_expr * sigma2 * sqrt(pi * a_c);

% Solve for a_c
a_c1 = vpasolve(eq1, a_c, [0, W/2]); % Critical crack size without peak load
a_c2 = vpasolve(eq2, a_c, [0, W/2]); % Critical crack size with peak load

% Display results
fprintf('Critical crack size without accidental peak load: %.3f m\n', (a_c1));
fprintf('Critical crack size with accidental peak load: %.3f m\n', (a_c2));
%% Q3 b
sigma_u = 470e6; % ultimate tensile strength [Pa]
sigma_Y = 325e6; % yield strength [Pa]

% Define symbolic variables
syms r_p theta

% Plane Stress Plastic Zone Calculation
eq_plane_stress = r_p == (K_IC^2/(2*pi*sigma_Y^2))*(cos(theta/2))^2*(1+3*sin(theta/2)^2);

% Plane Strain Plastic Zone Calculation
eq_plane_strain = r_p == (K_IC^2/(2*pi*sigma_Y^2))*(cos(theta/2))^2*((1-2*v)^2+3*sin(theta/2)^2);

% Solve at theta = 0 degrees (maximum stress concentration)
r_p_plane_stress = double(subs(rhs(eq_plane_stress), theta, 0));
r_p_plane_strain = double(subs(rhs(eq_plane_strain), theta, 0));

% Display results
fprintf('Plastic zone radius for plane stress: %.6f mm\n', r_p_plane_stress * 1e3);
fprintf('Plastic zone radius for plane strain: %.6f mm\n', r_p_plane_strain * 1e3);
