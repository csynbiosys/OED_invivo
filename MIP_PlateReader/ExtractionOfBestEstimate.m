% Extract the iteration yielding the minimum SSE over the test set.

% Folder = '../MIP_PlateReader/PE/SimulationsMatFiles';
% cd   '../MIP/Data/SimulationsMatFiles';
Folder = '.';
cd '.';

filePattern = fullfile(Folder, strcat('Sim-PlateReaderPE_Reduced_expmean','-','*.mat'));
filePattern2 = fullfile(Folder, strcat('PlateReaderPE_Reduced_expmean','-','*.mat'));
Files = dir(filePattern); 
Files2 = dir(filePattern2); 
%% Plot convergence curves for PE as a check
hold on
for i=1:length(Files2)
    x = load(Files2(i).name);
    plot(x.pe_results.nlpsol.neval, x.pe_results.nlpsol.conv_curve(:,2)')
    set(gca, 'YScale', 'log')
end
xlabel('Iteration')
ylabel('Cost Function')
title('PE Plate reader data Reduced')
hold off

%% Create a matrix with the SSE values over the test set for each PE iteration
SSE_Mat = zeros(length(Files),4);
for i=1:length(Files)
    FileName = Files(i).name;
    load(FileName);
    SSE_Mat(i,:) = SSE;
end
%% Plot the values of the SSE, summed over the test set, for each iteration
SSE_vect = sum(SSE_Mat,2);
figure; 
plot([1:1:length(Files)]',SSE_vect);hold on; 
plot(find(SSE_vect == min(SSE_vect)),SSE_vect(find(SSE_vect == min(SSE_vect))),'*r')
xlabel('iteration index')
ylabel('SSE on the test set')
%% Load the file corresponding to the minimum SSE
load(Files(find(SSE_vect == min(SSE_vect))).name);
exps_indexTest = [2 5 6 4]
% Plot simulations over the test set for the best parameter estimate
for i=1:sim_exps.n_exp
    figure;
    errorbar(sim_exps.t_s{1,i}/60,sim_exps.exp_data{1,i},sim_exps.error_data{1,i},'ok'); hold on; 
    plot(sim_results.sim.tsim{1,i}/60,sim_results.sim.obs{1,i},'b','LineWidth',2)
    title(int2str(exps_indexTest(i)))
    legend('experimental data', 'best fit')
    xlabel('Time (hours)')
    ylabel('Citrine (mol)')
end
%% Extract by best cost function value, not SSE
bestf = zeros(1,100);
for i=1:100
    x = load(Files2(i).name);
    disp(Files2(i).name)
    best = x.pe_results.nlpsol.fbest;
    bestf(i) = best;
end
result = find(bestf==min(bestf));

y = load((Files2(result).name));

bestPE = y.best_global_theta;

load(Files(result).name);
exps_indexTest = [2 4 5 6 9 10]
exps_indexTest = [1 8 7 3]
% Plot simulations over the test set for the best parameter estimate
for i=1:4%sim_exps.n_exp
    figure;
    errorbar(sim_exps.t_s{1,i}/60,sim_exps.exp_data{1,i},sim_exps.error_data{1,i},'ok'); hold on; 
    plot(sim_results.sim.tsim{1,i}/60,sim_results.sim.obs{1,i},'b','LineWidth',2)
    title(int2str(exps_indexTest(i)))
    legend('experimental data', 'best fit')
    xlabel('Time (hours)')
    ylabel('Citrine (mol)')
end

%%
disp('The best estimate is')
best_global_theta
save('BestTheta.mat', 'best_global_theta')

%% Confidence intervals of best theta
x = load(Files2(find(SSE_vect == min(SSE_vect))).name);

sdtheta = (x.pe_results.fit.conf_interval/2);
sdtheta./best_global_theta'





