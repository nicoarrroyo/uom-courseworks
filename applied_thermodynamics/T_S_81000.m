clear
clc
T1 = 25+273; %ATM
T3=  338.9;
T4=  775.8;
T5=  744.3;
T6=  728.5;
Patm = 101325; %Pascals
P1 = -0.2264*6895 + Patm; %Static
PT1 = Patm;
P3 = 5.3198*6895 + Patm; %Static
PT3= 5.3121*6895 + Patm; %Stagnation
PT4= 5.0898*6895 + Patm; %Stagnation
PT5= 0.7717*6895 + Patm; %Stagnation
PT6 = Patm;

R = 287;
CpAir = 1.01*1000;
CpGas = 1.14*1000;
S13 = CpAir*log(T3/T1) - R*log(PT3/PT1);
S34 = CpGas*log(T4/T3) - R*log(PT4/PT3);
S45 = CpGas*log(T5/T4) - R*log(PT5/PT4);
S56 = CpGas*log(T6/T5) - R*log(PT6/PT5);

S1 = 0;
S3 = S1+S13;
S4 = S3 + S34;
S5 = S4 + S45;
S6 = S5 + S56;
Entropy = [S1 S3 S4 S5 S6];
Temps = [T1 T3 T4 T5 T6];
plot(Entropy,Temps,'-o')
for i = 1:5
    ii = i;
    if i > 1
        ii = i + 1;
    end
    text(Entropy(i)+10,Temps(i)-10,num2str(ii));
end
hold on

%Ideal
T3 = T1*exp(R*log(PT3/PT1)/(CpAir));
S34 = CpGas*log(T4/T3);
T5 = T4*exp(R*log(PT5/PT4)/(CpAir));
T6 = T1;
S1 = 0;
S3 = 0;
S4 = S3 + S34;
S5 = S4;
S6 = S1;
Entropy = [S1 S3 S4 S5 S6];
Temps = [T1 T3 T4 T5 T6];
%plot(Entropy,Temps,'--')

 plot([S1 S3],[T1 T3],'r--');
% 

 PTemps = interp1([S3 (S3+S4)/2 S4],[T3 -30+(T3+T4)/2 T4],linspace(S3,S4),'spline'); % Plotting a Curve
 plot(linspace(S3,S4),PTemps,'r--')

 plot([S4 S5],[T4 T5],'r--');
 
 PTemps2 = interp1([S6 (S5+S6)/2 S5],[T6 -30+(T5+T6)/2 T5],linspace(S6,S5),'spline');
 plot(linspace(S6,S5),PTemps2,'r--')

hold off

title('T-S Diagram 49000RPM')
xlabel('Entropy (J K^-^1)')
ylabel('Temprature (K)')
legend('Measured','Ideal','Location','southeast')


ax = gca;

ax.XMinorTick = "on";
ax.XGrid = "on";

ax.YMinorTick = "on";
ax.YGrid = "on";
