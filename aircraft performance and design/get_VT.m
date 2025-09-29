% C2.2

l_T = 28.6;
mac = 7.26;
S = 58*7.26;
S_T = 45.2;
CM0 = -0.0016;
h0 = 0.25;

a1 = 5.1;
%estimated, pre-provided value for tailplane lift curve slope
a = 5.8;
%estimated, pre-provided value for wing mean lift curve slope
drf = 0.11;
%estimated, pre-provided value for downwash reduction factor (drf)

VT = (S_T*l_T)/(S*mac);