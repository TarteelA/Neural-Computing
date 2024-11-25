%Adaptive Exponential Leaky Integrate And Fire Model
%Part B: Simulate Model For 5s With Range Of 20 Different Levels Of Constant Applied Current
%Clear Previous Runs And Environment
clf;
clear;
close all;
clc;

%LIF Neuron Parameters
%Leak Reversal Potential (mV)
E_L = -75.0e-3;

%Threshold Potential (mV)
V_th = -50.0e-3;

%Reset Potential (mV)
V_reset = -80.0e-3;

%Voltage Range For Spike Uptick
Delta_th = 2.0e-3;

%Membrane Resistance (MΩ)
R_m = 100.0e6;

%Membrane Capacitance (uF/cm^2)
C_m = 100.0e-12;

%Potassium Reversal Potential
E_K = -80.0e-3;

%Leak Conductance (mS/cm^2)
gL = 10.0e-9;

%I_sra Control Term
a = 2.0e-9;

%I_sra Current Step
b = 2.0e-11;

%Time Constant For G_sra
T_sra = 0.2;

%Time Parameters
%Time Step (ms)
dt = 0.0001;

%Total Simulation Time (ms)
T = 5;

%Time Vector (ms)
t = 0:dt:T;  

%Applied Current Of 500 (pA)
I_app = 240:5:550;
I_app = I_app * 1e-12;

%Array For Storing 1/First ISI
Start_rate = zeros(size(I_app));

%Array For Storing 1/Last ISI
Last_rate = zeros(size(I_app));

%Array For Storing "One" For Just One Spike
Single_spike = zeros(size(I_app));

for I = 1:length(I_app)
    %Initialize Membrane Potential
    V = zeros(1, length(t));
    V(1) = E_L;     

    %Spike Rate Adaptation Conductunce
    I_sra = zeros(1, length(t));

    %Initialize Spike Train
    Spike_train = zeros(size(t));

    %Time Vector Simulation Loop
    for i = 1:length(t)-1
        if (V(i) > V_th)
            V(i) = V_reset;                 
            I_sra(i) = I_sra(i) + b;
            Spike_train(i) = 1;
        end
        %Update Membrane Potential Using Euler Method
        V(i+1) = V(i) + dt * (gL * (E_L - V(i) + Delta_th * exp((V(i) - V_th)/Delta_th)) - I_sra(i) + I_app(I))/C_m;
        I_sra(i+1) = I_sra(i) + dt * (a * (V(i) - E_L) - I_sra(i))/T_sra;
    end
    %Extract Spike Times
    Spike_times = dt*find(Spike_train);

    if (length(Spike_times) > 1)
        %Interval Between Spikes
        ISI_s = diff(Spike_times);
    
        %Inverse Of First ISI
        Start_rate(I) = 1/ISI_s(1);
        if (length(ISI_s) > 1)
            %Inverse Of Last ISI
            Last_rate(I) = 1/ISI_s(end);
        end

    else
        if(isscalar(Spike_times))
            Single_spike(I) = 1;
        end
    end
end

figure(4);

hold on;

%Plot Applied Current And Spike Rate
plot(I_app*1e12, Last_rate, 'k');

ISI_indes = find(Start_rate);
plot(1e12*I_app(ISI_indes), Start_rate(ISI_indes), 'ok');

ISI_indes = find(Single_spike);
plot(1e12*I_app(ISI_indes), 0*Single_spike(ISI_indes), '*k');

xlabel('I app (nA)');
ylabel('Spike Rate (Hz)');

legend('Last Rate', '1/ISI(1)', 'Single Spike');

title('Applied Current And Spike Rate');

hold off;