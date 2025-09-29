function [Aircraft,Constraints] = ConstraintsAnalysis(Aircraft,Constraints,MissionTable)

CruiseAltM = Aircraft.CruiseAlt * 0.3048;
CeilingAltM = Aircraft.Constraints(5).Altitude * 0.3048;
H = [0,CruiseAltM,CeilingAltM];
g = 9.8065;
WSArray = linspace(1000,15000,100);

for i = 1:length(H)
[~,~,rho(i),a(i)] = AtmosProperties(H(i),0);
end

for i = 1:5
    Aircraft.Constraints(i).WS = WSArray;
end

%% Takeoff Constraint - i = 1
s_to = Aircraft.Constraints(1).Distance * 0.5;
Aircraft.Constraints(1).TW = (1/(Aircraft.CL_TO * rho(1) * g * s_to )) .* WSArray;

%% Climb Constraint
OEIFlag = Aircraft.Engines / (Aircraft.Engines - 1);
gamma = (Aircraft.Constraints(2).ClimbGradient/100);
CL_climb = sqrt(Aircraft.CD0 / Aircraft.K);
CD_climb = Aircraft.CD0 + (Aircraft.K * CL_climb^2);
LD_climb = 0.3 * (CL_climb/CD_climb);
%LD_climb = sqrt(1/(4 * Aircraft.CD0 * Aircraft.K));
Aircraft.Constraints(2).TW = gamma + (1/LD_climb);

%% Landing Constraint - i = 1

s_l = Aircraft.Constraints(3).Distance;
V_L = 1.2 * sqrt((2/(rho(1)*Aircraft.CL_Ld))*Aircraft.WS);
a_L = (V_L^2) / (2 * s_l);
mu = 0.3;

Aircraft.Constraints(3).TW = linspace(0,0.8,100);
Aircraft.Constraints(3).WS = ((1/Aircraft.Constraints(3).Beta) * (0.6*(s_l - 300)* mu * g * rho(1) * Aircraft.CL_Ld)) / (1.2^2);

%% Cruise - i = 2
Beta_c = table2array(MissionTable(3,3));
V_Cruise = Aircraft.Constraints(4).Mach * a(2);
qc_cruise = 1/2 * rho(2) * (V_Cruise^2);
Aircraft.Constraints(4).TW = (Beta_c/Aircraft.Constraints(4).alpha) .* (((Aircraft.CD0 * qc_cruise)./(Beta_c*WSArray)) + (((Beta_c * Aircraft.K)/qc_cruise).*WSArray));

%% Absolute Ceiling - i = 3
Beta_ce = table2array(MissionTable(4,3));
V_Ceiling = Aircraft.Constraints(5).Mach * a(3);
qc_ceiling = 1/2 * rho(3) * (V_Ceiling^2);
Aircraft.Constraints(5).TW = (Beta_ce/Aircraft.Constraints(5).alpha) .* (((Aircraft.CD0 * qc_ceiling)./(Beta_ce.*WSArray)) + (((Beta_ce * Aircraft.K)/qc_ceiling).*WSArray));

Constraints = Aircraft.Constraints;
end