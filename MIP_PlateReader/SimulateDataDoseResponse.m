function [sim] = SimulateDataDoseResponse(best_global_theta,inpu)


    global epccOutputResultFileNameBase;
    epccOutputResultFileNameBase = 'SimulatedDataDVID';
    % global IPTGe; 

    resultFileName = [epccOutputResultFileNameBase,'.dat'];
    clear model;
    clear exps;
    clear sim;

    results_folder = strcat('MIP_rep',datestr(now,'yyyy-mm-dd-HHMMSS'));
    short_name     = 'MIP';

    % Read the model into the model variable
    M3D_load_model_PlateReader;
%     load(['PlateReaderPE_Reduced_1-',int2str(expr),'.mat'])%('BestTheta.mat')
    model.par = [best_global_theta];

    % Compile the model
    clear inputs;
    inputs.model = model;
    inputs.pathd.results_folder = results_folder;                        
    inputs.pathd.short_name     = short_name;
    inputs.pathd.runident       = 'initial_setup';
    % AMIGO_Prep(inputs);

    %randi([0 1000],1,round(duration/Stepd));    
    load('PlateReaderData.mat')
    clear newExps;
    newExps.n_exp = length(inpu);

    for i=1:newExps.n_exp
        newExps.n_obs{i}=1;                                     % Number of observables per experiment                         
        newExps.obs_names{i}='Fluorescence';                 % Name of the observables 
        newExps.obs{i}='Fluorescence=Cit_AU';          % Observation function
        newExps.exp_y0{i}=M3D_steady_state_PlateReader(model.par, 0);    
        newExps.t_f{i}=Data.t_f{1};                % Experiment duration
        newExps.u_interp{i}='step';
        newExps.n_s{i}=Data.n_s{1};                             % Number of sampling times
        newExps.t_s{i}=Data.t_s{1};                              % Times of samples
        newExps.n_steps{i}=Data.n_steps{1};                  % Number of steps in the input

        newExps.t_con{i}=Data.t_con{1};                     % Switching times
        newExps.u{i}= inpu(i);   
%         inputs.exps.std_dev{i}=[0.1];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mock an experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs.exps = newExps;
    inputs.exps.data_type='pseudo';
    inputs.exps.noise_type='homo_var';

    inputs.plotd.plotlevel='null';

    inputs.pathd.results_folder = results_folder;                        
    inputs.pathd.short_name     = short_name;
    inputs.pathd.runident       = strcat('sim-',int2str(i));

    % SIMULATION
    inputs.ivpsol.ivpsolver='cvodes';
    inputs.ivpsol.senssolver='cvodes';
    inputs.ivpsol.rtol=1.0D-7;
    inputs.ivpsol.atol=1.0D-7;


    AMIGO_Prep(inputs);

    sim = AMIGO_SModel(inputs);

end
