

% Extract the iteration yielding the minimum SSE over the test set.

% Folder = '../MIP_PlateReader/PE/SimulationsMatFiles';
% cd   '../MIP/Data/SimulationsMatFiles';
Folder = '.\Reduced_t50';
% cd '.\Reduced_t50';

filePattern = fullfile(Folder, strcat('Sim-PlateReaderPE_Reduced_expmean','-','*.mat'));
filePattern2 = fullfile(Folder, strcat('PlateReaderPE_Reduced_expmean','-','*.mat'));
Files = dir(filePattern); 
Files2 = dir(filePattern2); 

%% Create a matrix with the SSE values over the test set for each PE iteration
SSE_Mat = zeros(length(Files),4);
for i=1:length(Files)
    FileName = Files(i).name;
    load(FileName);
    SSE_Mat(i,:) = SSE;
end

SSE_vect = sum(SSE_Mat,2);

bestexp = load(Files2(find(SSE_vect == min(SSE_vect))).name);

pars = bestexp.pe_results.nlpsol.vbest';

%% Plot Dose-Response curve (real data) at t=42

Data = load('PlateReaderData');

Means = zeros(1,10);
Errors = zeros(1,10);
IPTG = zeros(1,10);

for i=1:10
    Means(i)=Data.Data.exp_data{i}(42);
    Errors(i)=Data.Data.error_data{i}(42);
    IPTG(i)=Data.Data.u{i};
end

figure;
errorbar(IPTG, Means, Errors, 'o')
set(gca, 'XScale', 'log')

%% Plot Dose-Response curve (real data) at t=21

Means2 = zeros(1,10);
Errors2 = zeros(1,10);
IPTG2 = zeros(1,10);

for i=1:10
    Means2(i)=Data.Data.exp_data{i}(21);
    Errors2(i)=Data.Data.error_data{i}(21);
    IPTG2(i)=Data.Data.u{i};
end

figure;
errorbar(IPTG2, Means2, Errors2, 'o')
set(gca, 'XScale', 'log')

%% Simulate data

inpu1 = 0:0.5:25;
inpu2 = 30:5:100;
inpu3 = 150:50:1000;

inpu = [inpu1,inpu2,inpu3];

sim1 = SimulateDataDoseResponse(pars,inpu(1:20));
sim2 = SimulateDataDoseResponse(pars,inpu(21:40));
sim3 = SimulateDataDoseResponse(pars,inpu(41:60));
sim4 = SimulateDataDoseResponse(pars,inpu(61:80));
sim5 = SimulateDataDoseResponse(pars,inpu(81:84));

sts = zeros(1,84);
for i=1:20
    sts(i) = sim1.sim.states{i}(end,4);
    sts(i+20) = sim2.sim.states{i}(end,4);
    sts(i+40) = sim3.sim.states{i}(end,4);
    sts(i+60) = sim4.sim.states{i}(end,4);
end
for i=1:4
    sts(i+80) = sim5.sim.states{i}(end,4);
end


%% Dose-response curve at steady state
figure;
hold on
errorbar(IPTG, Means, Errors, 'o')
plot(inpu, sts)
set(gca, 'XScale', 'log')
xlabel('IPTG')
ylabel('Citrine')
title('Steady State')
hold off

%% Dose Response curve at mid exponential
figure;
hold on
errorbar(IPTG2, Means2, Errors2, 'o')
plot(inpu, sts)
set(gca, 'XScale', 'log')
xlabel('IPTG')
ylabel('Citrine')
title('Mid-Exponential')
hold off

%% Dose response curves at mid exponential and half steady state 
figure;
hold on
errorbar(IPTG2, Means2, Errors2, 'o')
plot(inpu, sts/2)
set(gca, 'XScale', 'log')
xlabel('IPTG')
ylabel('Citrine')
title('Mid-Exponential and Half Steady-State')
hold off









