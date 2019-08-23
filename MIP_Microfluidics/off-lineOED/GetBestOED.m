% This script works as  a check for the OED results, where convergence
% plots can be generated and extraction of the best OID can also be
% performed

%% Plot convergence curves from OED
hold on
for i=1:100
    x = load(['Input1\IPTG1000_MoreIter\OED_offline_2-OptstepseSS-1_loops-',int2str(i),'.mat']);
    plot(x.oed_results{1}.nlpsol.neval, x.oed_results{1}.nlpsol.conv_curve(:,2))
    set(gca, 'YScale', 'log')
end
hold off

%% Extract best OED from the 100 runs

bestf = zeros(1,100);
for i=1:100
    x = load(['Input1\IPTG1000\OED_offline_2-OptstepseSS-1_loops-',int2str(i),'.mat']);
    best = x.oed_results{1}.nlpsol.fbest;
    bestf(i) = best;
end
result = find(bestf==min(bestf));

y = load(['Input1\IPTG1000\OED_offline_1-OptstepseSS-1_loops-',int2str(result),'.mat']);

bestOED = y.oed_results{1};

save('BestOEDSmallInput.mat', 'bestOED');












