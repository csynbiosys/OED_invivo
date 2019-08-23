function [] = Run_fit_to_MIP_PlateReader( resultBase, numExperiments )
% This function runs the script for the identification of the M3D structure
% to the Plate Reader experimental data. It takes two inputs:
% - a string with the identifier of the output files
% - the number of iterations of parameter estimation. 
% In the paper we used numExperiments = 100.

% cd ('../../');
% AMIGO_Startup();
% 
% cd ('Examples/PLacCDC2018/MIP/Scripts');

% Specify the allowed boundaries for the parameters (parameters expressed in 1/s as. The last parameter is taken from ref 7 of the paper)
theta_min = [3.88e-5,3.88e-2,0.5,2,7.7e-3,0.2433,5.98e-5,0.012,10]; % 1/min
theta_max = [0.4950,0.4950,4.9,10,0.23,6.8067,0.2449,0.0217,1000];

% % Create a matrix of initial guesses for the parameters, having as many
% % rows as the number of PE iterations (numExperiments)
% % Each vector is passed as input to the computing function
% M_norm = lhsdesign(numExperiments,length(theta_min));
% M = zeros(size(M_norm));
% for c=1:size(M_norm,2)
%     for r=1:size(M_norm,1)
%         M(r,c) = 10^(M_norm(r,c)*(log10(theta_max(1,c))-log10(theta_min(1,c)))+log10(theta_min(1,c))); % log exploration
%     end
% end 
% 
% ParFull = M; % in this case I am fitting all the values
% save('MatrixParameters2.mat','ParFull');

load('MatrixParameters.mat');   

% This is to run the for loop for initial guesses that have not been
% considered yet (to solve issues with the parfor stopping because it lost
% connection to a worker)
Folder='.';
filePattern = fullfile(Folder, strcat('PlateReaderPE_Reduced_expmean','-','*.mat'));
Files = dir(filePattern);
fi = strings(1,length(Files));
for i=1:length(Files)
    fi(i) = Files(i).name;
end
%


parfor epcc_exps=1:numExperiments
    % Continuation of the exception to solve loos of workers
    m = ['PlateReaderPE_Reduced_expmean-',num2str(epcc_exps),'.mat'];
    if ~ismember(m,fi)
    %
        try
            global_theta_guess = ParFull(epcc_exps,:);
            epccOutputResultFileNameBase = [resultBase,'-',num2str(epcc_exps)];
            [out] = fit_to_MIP_PlateReader(epccOutputResultFileNameBase,epcc_exps,global_theta_guess);
        catch err
            %open file
            errorFile = [resultBase,'-',num2str(epcc_exps),'.errorLog'];
            fid = fopen(errorFile,'a+');
            fprintf(fid, '%s', err.getReport('extended', 'hyperlinks','off'));
            % close file
            fclose(fid);
        end
    end
end

