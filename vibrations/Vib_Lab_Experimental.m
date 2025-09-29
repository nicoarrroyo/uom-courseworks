%% Plotting FRFs

clc
clear

data_location = input("What is your chosen data location? Please input 1-32:");
while data_location <= 0 || data_location > 32
    data_location = input("Try again. What is your chosen data location? Please input 1-32:");
end

% Read data from spreadsheets

data = readtable("Location - " + data_location + ".xlsx");

% Creates arrarys of data

frequency = table2array(data(:,1));
amplitude = table2array(data(:,2));
phase = table2array(data(:,3));

% Calculates real and imaginary components

real = amplitude .* cosd(phase);
imaginary = amplitude .* sind(phase);

% Plot FRFs

figure;
subplot(2,2,1);
plot(frequency,amplitude);
grid on
grid minor
whole_title = sprintf('Amplitudes for Beam point %d', data_location);
title(whole_title)
xlabel("Frequency")
ylabel("Amplitude")
set(gcf,'position',[1,49,1280,420])

subplot(2,2,2); 
plot(frequency,imaginary);
grid on
grid minor
whole_title = sprintf('Imaginary components for Beam point %d', data_location);
title(whole_title)
xlabel("Frequency")
ylabel("Imaginary component")
set(gcf,'position',[1,49,1280,720])

subplot(2,2,3); 
plot(frequency,phase);
grid on
grid minor
whole_title = sprintf('Phases for Beam point %d', data_location);
title(whole_title)
xlabel("Frequency")
ylabel("Phase")
set(gcf,'position',[1,49,1280,420])

subplot(2,2,4); 
plot(frequency,real);
grid on
grid minor
whole_title = sprintf('Real components for Beam point %d', data_location);
title(whole_title)
xlabel("Frequency")
ylabel("Real component")
set(gcf,'position',[1,49,1280,420])

%% Calculate Mode Shapes

%Information about the beams

L1 = 582;
l2 = 200;

Beam_1x=linspace(0,L1,1000);
Beam_1y=zeros(1000);
Beam_1z=zeros(1000);

Beam_2x=linspace(L1,L1,1000);
Beam_2y=linspace(-l2,l2,1000);
Beam_2z=zeros(1000);

% These natural frequencies are the averages that were found by hand from
% the FRF plots

nat_fre = [7.5169;31.3305;70.1460;182.3566;226.7791;430.3641];

% For each natural frequency, plot mode shape data

for j = 1:length(nat_fre)

    % Plot the beams

    figure;
    plot3(Beam_1x,Beam_1y,Beam_1z,'b');
    hold on;
    plot3(Beam_2x,Beam_2y,Beam_2z,'b');
    grid on;

    Mode_Shape_Data=zeros(32,3);

    for i = 1:32
    
        % Read data from spreadsheets

        data = readtable("Location - " + i + ".xlsx");
    
        % Creates arrarys of data

        frequency = table2array(data(:,1));
        amplitude = table2array(data(:,2));
        phase = table2array(data(:,3));
    
        [ d, ix ] = min( abs( frequency-nat_fre(j) ) );
    
        % Calculating mode shapes

        if (i <= 18)
            Mode_Shape_Data(i,1) = i*(L1/18);
            Mode_Shape_Data(i,2) = 0;
        else
            Mode_Shape_Data(i,1) = L1;
            Mode_Shape_Data(i,2) = l2-(2*l2/13)*(i-19);
        end
    
        if(phase(ix) > 0 && phase(ix) < 180)
            Mode_Shape_Data(i,3) = amplitude(ix);
        else
            Mode_Shape_Data(i,3) = -amplitude(ix);
        end
    end
    
    % Plots the mode shapes

    plot3(Mode_Shape_Data(1:18,1),Mode_Shape_Data(1:18,2),Mode_Shape_Data(1:18,3),'r');
    plot3(Mode_Shape_Data(19:end,1),Mode_Shape_Data(19:end,2),Mode_Shape_Data(19:end,3),'r');
    title(["Mode Shape " j])
    xlabel("X Location");
    ylabel("Y Location");
    zlabel("Deflection");
end