function [] = run_off_lineOED_Designer_MIP(resultBase, numExperiments, inputDesign)

% cd ('../../');
% AMIGO_Startup();
% 
% cd ('Examples/In_Silico_Loop');

% Selected boundaries for the parameters
% theta_min = [0.179859426552874   1.260646416864342   4.267615363754567   0.009882755012854   0.549362669279248   0.016942506210535   0.001225578917072];
% theta_max = [0.794322720790688   1.834968636065552   5.428332172110064   0.100591767503240  11.954116096218414   0.128697502471072   0.022774421083016];

% Create a matrix of initial guesses for the parameters, having as many
% rows as the number of PE iterations (numExperiments) 
% Each vector is passed as input to the computing function
% M_norm = lhsdesign(numExperiments,length(theta_min));
% M = zeros(size(M_norm));
% for c=1:size(M_norm,2)
%     for r=1:size(M_norm,1)
%         M(r,c) = 10^(M_norm(r,c)*(log10(theta_max(1,c))-log10(theta_min(1,c)))+log10(theta_min(1,c))); % log exploration
%     end
% end 
% 
% ParFull = M; % in this case I am fitting all the values
% save('MatrixParameters_OED.mat','ParFull');

switch inputDesign
    case 1
        load('D:\PhD\Year_1\2019_07_31_OEDinVivo\Scripts\MIP_PlateReader\MatrixParameters.mat');disp('1');
    case 2
        load('MatrixParametersOED1.mat');disp('2');
    case 3
        load('MatrixParametersOED2.mat');disp('3');
    otherwise
        disp('Which input are you trying to design???');
        return
end
Folder='.';
filePattern = fullfile(Folder, strcat('OED_offline_3-OptstepseSS-1_loops','-','*.mat'));
Files = dir(filePattern);
fi = strings(1,length(Files));
for i=1:length(Files)
    fi(i) = Files(i).name;
end
% load('MatrixParameters.mat');

parfor epcc_exps=1:numExperiments
    stepd = 180;
    numLoops=1;
    epccNumLoops = 1;
    m = ['OED_offline_3-OptstepseSS-1_loops-',num2str(epcc_exps),'.mat'];
    if ~ismember(m,fi)
        
        try
            global_theta_guess = ParFull(epcc_exps,:);
            epccOutputResultFileNameBase = [resultBase,'-','OptstepseSS-',num2str(numLoops),'_loops-',num2str(epcc_exps)];
            [out]=off_lineOED_Designer_MIP(epccOutputResultFileNameBase,epccNumLoops,stepd,epcc_exps,global_theta_guess);

        catch err
            %open file
            errorFile = [resultBase,'-','OptstepseSS-',num2str(numLoops),'_loops-',num2str(epcc_exps),'.errorLog'];
            fid = fopen(errorFile,'a+');
            fprintf(fid, '%s', err.getReport('extended', 'hyperlinks','off'));
            % close file
            fclose(fid);
        end
    end
end

