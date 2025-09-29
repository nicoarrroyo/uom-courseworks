% C1

function [p, T, rho, a] = APD1(H)

p0 = 101325;
T0 = 288.15;
L0 = -0.0065; % lapse rate (temp. gradient) for up to 11km

if (H <= 11000)
    T = (T0 + (H*L0));
    a = sqrt(1.4*287.05287*T);
    p = p0*(1+H*L0/T0)^(-9.8065/(287.05287*L0));
    rho = p/(287.05287*T);
elseif (H > 11000)
    T = 216.65;
    a = sqrt(1.4*287.05287*T);
    p = 22632.559*exp(-9.8065/(287.05287*216.65)*(H-11000));
    rho = p/(287.05287*T);
end
