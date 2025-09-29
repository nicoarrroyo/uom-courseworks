clear; % FIX IN REAL CODE = FIRC
%% Tutorial 5 - Power and Mass Budget Analysis
%% *Introduction*
% In this final tutorial, I will conduct a power and mass budget analysis, calculating 
% total masses and power requirements for the spacecraft's nominal operation. 
% This tutorial is tightly linked with all previous tutorials, and once it is 
% finished, it will dictate final values to provide to the launch team as this 
% will decide crucial aspects of the launch such as ascent profile or launch windows. 
%% *Initial Tasks*
% *Define Constants*

R_earth = 6371000; % [m] Earth Radius
h = 600000; % [m] Orbital altitude
mu = 3.986*10^14; % [m^3s^-2] Earth Gravitational Parameter
V_B = 28; % [V] Output voltage of the chosen satellite bus
recharge_cycles = 30000;
DOD = 50; % [%] Operational Depth of Discharge
energy_density = 120; % check for multiplication in other code
power_payload = 350; % [W]
power_thermal = 150; % [W]
power_heater = 2; % [W] - from Tutorial 2
power_comms = 240; % [W]
power_antenna = 54; % [W] - from Tutorial 3
power_ADCS = 110; % [W]
power_reaction_wheel = 0.58;
power_other = 150;
% Task 1 - Estimate Mission Lifetime
% To find mission lifetime, we first have to calculate orbital period, which 
% we can do using the equation found in the coursenotes. The battery will be mostly 
% in use during the eclipse period, so we can use the calculation from tutorial 
% 2 to find how much time the spacecraft spend in an eclipse over a period. 
% 
% Equation (3.9)
% $$\tau =2\pi \sqrt{\frac{r^3 }{\mu }}$$
% Orbital radius $r$
% 
% $$\begin{array}{l}r=R_{\textrm{Earth}} +\textrm{altitude}\\r=6371+1336=7707\textrm{km}\end{array}$$
% 
% Earth's Gravitational Parameter $\mu$
% 
% $$\mu =398600{\textrm{km}}^3 s^{-2}$$
% 
% Orbital Period $\tau$
% 
% $$\begin{array}{l}\tau =2\pi \sqrt{\frac{{7707}^3 }{398600}}\\\tau =6733\;\textrm{seconds}\end{array}$$

period = 2*pi*sqrt((R_earth+h)^3/mu); % [s] Orbital period
%% 
% 
% 
% To find eclipse time, we first need to know how much of the orbit is taken 
% up by the eclipse in terms of angles. 
% $$\theta =2*\arcsin \left(\frac{R_{\textrm{Earth}} }{R_{\textrm{Earth}} +\textrm{altitude}}\right)$$
% The angle $\theta$ in this equation is half the angle at which the spacecraft 
% will be in eclipse, assuming that the start of the eclipse is at 0 radians and 
% the end is θ radians. 
% 
% $$\begin{array}{l}\theta =2*\arcsin \left(\frac{6371}{6371+1336}\right)\\\theta 
% =1\ldotp 946\textrm{radians}\end{array}$$
% 
% 
% 
% $$\textrm{Eclipse}\;\textrm{Fraction}=\frac{\theta }{2\pi }$$
% 
% $$\begin{array}{l}\textrm{Eclipse}\;\textrm{Time}=\frac{\theta }{2\pi }*\tau 
% =\frac{0\ldotp 9731}{2\pi }*6733\\\textrm{Eclipse}\;\textrm{Time}=2084\textrm{seconds}\end{array}$$

theta = 2*asin(R_earth/(R_earth+h)); % [radians] Angle of eclipse
eclipse_time = theta*period/(2*pi); % [s] Time spent in eclipse
%% 
% The battery will have to recharge once every orbit, so we can take the number 
% of recharge cycles to be the same as the number of orbits in the mission. Therefore, 
% the mission lifetimeis dominated by how many recharges the battery can do and 
% the period of one orbit. I have also converted to years instead of seconds, 
% and rounded up to the nearest year using MATLAB's built-in *ceil* function. 

lifetime = ceil(period*recharge_cycles/(60*60*24*364.25)); % [years] Lifetime
%% 
% 
% Task 2 - Estimate Power Demands
% In the worst case, where every element of the spacecraft is on, there will 
% be maximum power draw, meaning that the maximum power demand is the sum of all 
% power terms. 

max_power = 70; % [W]
%% 
% However, in eclipse, it has been stated that :
%% 
% * all scientific measurements are paused, 
% * communications power is halved as there will be no data processing
% * attitude control is halved
% * all other sub-systems are halved
% * every other system is at full power
%% 
% Therefore, the power in an eclipse is as follows: 

eclipse_power = 30; % [W]
%% 
% Both maximum and eclipse powers have been rounded up to the nearest Watt [W]. 
% 
% 
% Task 3 - Identify Battery Capacity Equation
% Total capacity is given in the coursenotes:
% 
% Equation (7.4d) (P167)
% 
% $$C=\frac{P_{\textrm{ecl}} *t_{\textrm{ecl}} }{\textrm{DOD}*V_B }=\frac{455*2084}{0\ldotp 
% 5*18}=10540A$$

C = (eclipse_power*eclipse_time)/(V_B*DOD/100); % [A] Battery Capacity
%% 
% 
% Task 4 - Estimate Total Energy for Storage System
% Total energy equation is given in the coursenotes, just under the previous 
% equation:
% 
% Equation (7.4e) (P167)
% 
% $$\varepsilon ={\textrm{CV}}_B =10\ldotp 54*{10}^3 *18=189700\;J$$

energy_total = C*V_B; % [J]
%% 
% 
% Task 5 - Estimate Total Battery Mass
% The equation for total battery mass combines total battery energy and energy 
% density and is given in the coursenotes: 
% 
% Equation (7.4f) (P167)
% 
% $m_{\textrm{batt}} =\frac{\varepsilon }{\overset{-}{\varepsilon} }$, where 
% $\varepsilon$ is total energy and $\overset{-}{\varepsilon}$ is energy density, 
% given as a constant at the start of the tutorial. 
% 
% Since our battery capacity was calculate using seconds, we have to convert 
% energy density to Watt-seconds from Watt-hours. 

energy_density = energy_density*3600; % [Jkg^-1]
%% 
% Now simply input the terms into the equation: 
% 
% $$m_{\textrm{batt}} =\frac{1\ldotp 89*{10}^6 }{432000}=4\ldotp 38\;\textrm{kg}$$

m_batt = ceil(energy_total/energy_density); % [kg] Battery mass
%% Follow-On Tasks
% Task 1 - Identify Constants

q_s = 1400; % [Wm^-2] Power from the sun near to earth
cell_efficiency = 0.2;
D_yr = 0.05; % degradation per year from initial baseline
packing_efficiency = 0.9;
sun_angle = 40; % [degrees]
V_A = 24; % [V] Array output voltage
%% 
% 
% Task 2 - Calculate Charge Rate
% The equation required for this calculation is also provided in the coursenotes. 
% 
% Equation (7.5c) (P167)
% 
% $$R_{\textrm{ch}} =\frac{\textrm{DOD}*C}{\textrm{sun}\;\textrm{time}}$$
% 
% Clearly, before we can find charge rate, we have to first find the time the 
% spacecraft spends in the sun, which was already calculated in the second tutorial 
% and was found by subtracting the eclipse time by total period time. 
% 
% $$\textrm{sun}\;\textrm{time}=\textrm{period}-\textrm{eclipse}\;\textrm{time}$$

sun_time = period-eclipse_time; % [s]
%% 
% Now we simply input the remaining terms into the equation. 
% 
% $$R_{\textrm{ch}} =\frac{0\ldotp 5*10540}{4\ldotp 64*{10}^3 }=11\ldotp 4$$

R_ch = (DOD*C/(sun_time*100)); % [As^-1]
%% 
% 
% Task 3 - Calculate Total Power Required From Array
% The power required by the solar array during sun exposure is the total power 
% draw from all components aside from the heater but including the recharge of 
% the batteries. The equation for this is given in the coursenotes. 
% 
% Equation (7.5d) (P167)
% 
% $P=P_{\textrm{total}} +R_{\textrm{ch}} *V_A$, where total power $P_{\textrm{total}}$ 
% excludes the heater. 

sun_power = ceil(max_power - power_heater + (R_ch*V_A)); % [W]
%% 
% 
% Task 4 - Estimate Solar Array Area
% This equation for solar array area is given in the coursenotes: 
% 
% Equation (7.5e) (P167)
% 
% $$A_{\textrm{array}} =\frac{P_{\textrm{sun}} }{q_s *\eta *\eta_p *\left(1-D\right)*\cos 
% \left(\theta \right)}$$
% 
% Power in sun exposure $P_{\textrm{sun}}$
% 
% $$P_{\textrm{sun}} =1327W$$
% 
% Solar power per square metre near Earth $q_s$
% 
% $$q_s =1400{\textrm{Wm}}^{-2}$$
% 
% Cell efficiency $\eta$
% 
% $$\eta =0\ldotp 2$$
% 
% Packing efficiency $\eta_p$
% 
% $$\eta_p =0\ldotp 9$$
% 
% Degradation per year from baseline perfromance $D_{\textrm{yr}}$
% 
% $$D_{\textrm{yr}} =0\ldotp 05$$
% 
% Average incident sun angle $\theta$
% 
% $$\theta =40\;\textrm{degrees}$$
% 
% Array area required $A_{\textrm{array}}$
% 
% $$\begin{array}{l}A_{\textrm{array}} =\frac{1327}{1400*0\ldotp 2*0\ldotp 9*\left(1-0\ldotp 
% 05\right)*\cos \left(40\right)}\\A_{\textrm{array}} =5\ldotp 75m^2 \end{array}$$

A_array = sun_power/(1400*0.2*0.9*(1-0.05)*cosd(40)); % [m^2]
%% 
% 
% Task 5 - Estimate Solar Array Mass
% Table 4 shows that Sentinel 6A had a 150kg solar array which had a surface 
% area of 15m^2, meaning that we can assume that Sentinel 6B will have the same 
% mass:area ratio of 10:1. 
% 
% Therefore, calculating solar array mass is quite simple and does not require 
% any rounding as all terms involved are integers. We just have to multiply our 
% found solar array area and multiply it by 10 to yield our total solar array 
% mass for Sentinel 6B. 

mass_array = 10*A_array; % [kg]
%% 
% 
%% Discussion
%% 
% # Below there are both power and mass budget analysis tables for both Sentinel 
% missions. 
% Table showing the Power Budget of both Sentinel Missions
% $$\left[\matrix{\textbf{Sub-System Element}& \textbf{Sentinel 6-A [W]} & \quad& 
% \textbf{Sentinel 6-B [W]} & \quad \cr\textrm{Payload} & 350 & \quad & 350 \cr\textrm{Thermal 
% Subsystem} & 150 & \quad & 150 \cr\textrm{Heater} & N/A & \quad & 2 \cr\textrm{Communications 
% Subsystem} & 240 & \quad & 240 \cr\textrm{Transmission Power} & 30 & \quad & 
% 54 \cr\textrm{ADCS Subsystem} & 110 & \quad & 110 \cr\textrm{Reaction Wheels} 
% & N/A & \quad & 1 \cr\textrm{All Other Subsystems} & 150 & \quad & 150 \cr\textrm{\textbf{Total}} 
% & 1030 & \quad & 1057 \cr}\right]$$
% 
% 2. Below is the mass budget analysis for both Sentinel Missions. 
% Table showing the Mass Budget of both Sentinel Missions
% $$\left[\matrix{\textbf{Sub-System Element}& \textbf{Sentinel 6-A [/kg]} & 
% \quad& \textbf{Sentinel 6-B [/kg]} & \quad \cr\textrm{Payload and Structure} 
% &465 & \quad & 465 \cr\textrm{Thrusters} & 50 & \quad & 50 \cr\textrm{Manouvering 
% Fuel} & 130 & \quad & 130 \cr\textrm{De-Orbit Fuel} & N/A & \quad & 858\cr\textrm{Thermal 
% Subsystem} & 40 & \quad & 40 \cr\textrm{Heater} & N/A & \quad & 5 \cr\textrm{Communications 
% Subsystem} & 70 & \quad & 70 \cr\textrm{Transmission Antenna} & 30 & \quad & 
% 2 \cr\textrm{ADCS Subsystem} & 60 & \quad & 60 \cr\textrm{Reaction Wheels} & 
% N/A & \quad & 1 \cr\textrm{Power Distribution System} & 50 & \quad & 50 \cr\textrm{Power 
% Regulation and Control System} & 70 & \quad & 70 \cr\textrm{Energy Storage System} 
% & 15 & \quad & 5 \cr\textrm{Solar Array} & 150 & \quad & 80\cr\textrm{\textbf{Total}} 
% & 1130 & \quad & 1886 \cr}\right]$$
% 
% 
% 
% 3. I have conducted sensitivity analyses, provided suggestions on whether 
% some assumptions were valid, and made critical design decisions that may have 
% decided the fate of the Sentinel 6B mission. 
% 
% I have made a number of decisions in each tutorial that I have outlined below. 
%% 
% * Tutorial 1 required a sensitivity analysis on specific impulse and Δv, meaning 
% that I had to find the ideal fuel mass to be able to conduct a crucial de-orbit 
% burn, freeing up the space environment of unnecessary space debris. 
% * Tutorial 2 was an analysis on the thermal requirements of the spacecraft, 
% and I created and proved the functionality of a heating system without which 
% the spacecraft would have been doomed to fail within hours of nominal orbital 
% insertion. 
% * Tutorial 3 demanded a choice of antenna and I narrowed down the options 
% to the only logical remaining one - the horn antenna. This antenna was lighter 
% than the rest and - crucially - was the only antenna that could communicate 
% with the ground station at all times. Without this adjustment, there would have 
% been now way for the spacecraft to send or receive instructions to or from the 
% ground station, nullifying the mission scope altogether. 
% * Tutorial 4 was about ADCS, and I optimised and critically analysed the torque 
% requirements of the Sentinel 6B. There was only one reaction wheel that was 
% sufficiently powerful for the job, so any other decision would have not been 
% appropriate. I also disagreed with the assumption that magnetic field torque 
% was a valid term to exclude and a higher level analysis would need to consider 
% this. 
% * Tutorial 5 required me to find the ideal solar array mass and area to be 
% able to power the Sentinel 6B spacecraft. I believe I chose the ideal array 
% area, as any smaller and the spacecraft would have been insufficiently powered 
% during the eclipse period, shortenining the lifespan of the mission. A larger 
% array would have suffered from too much mass, which would then create problems 
% with how much fuel is required for the deorbit burn, thereby changing fundamental 
% properties of the spacecraft and potentially causing large delays. 
%% 
% 
% 
%