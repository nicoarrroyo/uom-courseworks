clear;

%% Finding Mass Matrix
% Youngs Modulus in Pa
E = 200e9;

% Poisson's ratio
v = 0.25;

% Shear Modulus in Pa
G = E/(2*(1+v));

% Density in kg/m^3
rho = 7800;

% Lengths in m
L1 = 0.582; L2 = 0.615; L3 = 0.645;
l1 = 0.166; l2 = 0.200;
LA = L2; LB = 2*l2;

% Widths in m
wA = 0.06376; wB = 0.06369;

% Thicknesses in m
tA = 0.00673; tB = 0.00649;

% Beam masses in kg
MA = LA*wA*tA*rho; MB = LB*wB*tB*rho;

% Mass matrix elements in kg
m1 = MA*5/18; m2 = MA*1/4; m3 = MA*2/9;
m4 = (MA*1/9) + (MB*1/2); m5 = MB*1/4; m6 = MB*1/4;
Mass_Matrix = [m1 0 0 0 0 0
              0 m2 0 0 0 0
              0 0 m3 0 0 0
              0 0 0 m4 0 0
              0 0 0 0 m5 0
              0 0 0 0 0 m6];
disp("Mass Matrix:")
disp(Mass_Matrix)

%% Finding Flexibility Matrix
% Moments of inertia in kgm^2 and torsional constant in kgm^2
Ia = wA*tA^3/12;
Ib = wB*tB^3/12;
ca = wA*tA^3/3;

% Calculating matrix components
a11 = (125*(LA^3))/(17496*E*Ia);
a12 = (625*(LA^3))/(34992*E*Ia);
a13 = (925*(LA^3))/(34992*E*Ia);
a14 = (1225*(LA^3))/(34992*E*Ia); a15 = a14; a16 = a14;

a21 = a12;
a22 = (125*(LA^3))/(2187*E*Ia);
a23 = (200*(LA^3))/(2187*E*Ia);
a24 = (275*(LA^3))/(2187*E*Ia); a25 = a24; a26 = a24;

a31 = a13; a32 = a23;
a33 = (343*(LA^3))/(2187*E*Ia);
a34 = (490*(LA^3))/(2187*E*Ia); a35 = a34; a36 = a34;

a41 = a14; a42 = a24;  a43 = a34; 
a44 = (LA^3)/(3*E*Ia); a45 = a44; a46 = a44;

a51 = a15; a52 = a25; a53 = a35; a54 = a45;
a55 = ((LA^3)/(3*E*Ia))+(LA*(LB^2))/(4*G*ca)+(LB^3)/(24*E*Ib);
a56 = (LA^3)/(3*E*Ia)-(LA*(LB^2))/(4*G*ca);

a61 = a16; a62 = a26; a63 = a36; a64 = a46; a65 = a56; a66 = a55;

a = [a11 a12 a13 a14 a15 a16;
 a21 a22 a23 a24 a25 a26;
 a31 a32 a33 a34 a35 a36;
 a41 a42 a43 a44 a45 a46;
 a51 a52 a53 a54 a55 a56;
 a61 a62 a63 a64 a65 a66];
disp("Flexibility Matrix:")
disp(a)

%% Finding Dynamical Matrix
[D] = a*Mass_Matrix;
disp("Dynamical Matrix:")
disp(D)

%% Finding eigenvalues/eigenvectors
[R, J] = eig(D);
[JS, n] = sort(diag(J), 'descend');

% Eigenvectors
R = R(:, n);

wn = sqrt(1./JS);
fn = wn/(2*pi);

% Node positions on beams and their displacements
nodesA = LA.*[5/18 10/18 14/18 1];
nodesB = [-LB*0.5 0 LB*0.5];

%% Plotting Predicted Mode Shapes
for i = 1:6
 % Beam A coordinates
 yA = [0 0 0 0 0];
 xA = [0 nodesA];
 zA = [0 R(1:4,i)'];
 zA0 = [0 0 0 0 0];
 % Beam B coordinates
 yB = nodesB;
 xB = [L2 L2 L2];
 zB = [R(5,i) R(4,i) R(6,i)];
 zB0 = [0 0 0];
 % Converting to relative displacement
 maxz = max(max(abs(zA)), max(abs(zB)));
 zA = zA/maxz;
 zB = zB/maxz;
 
 % Plotting values
 figure(i)
 plot3(xA,yA,zA,'r',xB,yB,zB,'r')
 hold on;
 plot3(xA,yA,zA0,'b',xB,yB,zB0,'b')

 % Plot details
 grid on
 title(['Theoretical Mode Shape Number ' num2str(i)])
 xlabel('x (m)');
 ylabel('y (m)');
 zlabel('Relative Displacement')
end
