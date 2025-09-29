% C1
load('DAIKOvalues.mat');
dtraj = table2array(DAIKOtrajectoryv2);
index = length(dtraj);
t0 = dtraj(:,1);
treal = t0/60;

%defining constants
g = 9.8065;
R = 287.05287;
L0 = -0.0065;
L11 = 0;
T0 = 288.15;
T11 = 216.65;
p0 = 101325;
p11 = 22632.559;

m_temp = dtraj(:,6)/T0;

%finding values of variables
for i = 1:index
    alt = dtraj(i,4);
    qc = dtraj(i, 5);
    [p, T, rho, a] = APD1(alt);
    pres(i,:) = p/p0;
    temp(i,:) = T/T0;
    dens(i,:) = rho/1.225;
    speed_sound(i,:) = a;
    mach(i,:) = sqrt((2/(1.4-1)) * (((qc/p)+1).^((1.4-1)/1.4)-1));
    TAS_ISA(i,:) = mach(i,:) * a;
    TAS_M(i,:) = mach(i,:) * sqrt(R*temp(i,:)*1.4);
end

%plotting
figure;
plot(treal, pres, "c");
hold on;
plot(treal, temp, "r");
plot(treal, dens, "k");
plot(treal, mach, "-.m");
plot(treal, m_temp, "--b");

%labelling
set(gca, "XTick", 0:60:300);
set(gca, "YTick", 0:0.2:1);

title("Variation of Relative Atmospheric Properties and Mach Number along Flight Path");
xlabel("Flight time elapsed (min)");
ylabel("Relative property value or Mach Number");

legend("Pressure", "Density", "Mach Number", "Measured Temperature");

save('BIG_GUY_variables');