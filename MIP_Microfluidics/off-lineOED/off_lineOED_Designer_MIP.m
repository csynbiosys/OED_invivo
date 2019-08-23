%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In silico experiment OID script - runs PE, OED, mock experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out]=off_lineOED_Designer_MIP(epccOutputResultFileNameBase,epccNumLoops,stepd,epcc_exps,global_theta_guess)

    resultFileName = [strcat(epccOutputResultFileNameBase),'.dat'];
    rng shuffle;
    rngToGetSeed = rng;

    % Write the header information of the .dat file in which the results of
    % PE (estimates, relative confidence intervals, residuals, relative
    % residuals and the time required for computation) will be stored.
    fid = fopen(resultFileName,'w');
    fprintf(fid,'HEADER DATE %s\n', datestr(datetime()));
    fprintf(fid,'HEADER RANDSEED %d\n',rngToGetSeed.Seed);
    fclose(fid);

    startTime = now;

    clear model;
    clear exps;
    clear best_global_theta_log;
    clear pe_results;
    clear ode_results;

    results_folder = strcat('InduciblePromoter_offLineOED',datestr(now,'yyyy-mm-dd-HHMMSS'));
    short_name     = strcat('IndPromOEDoff',int2str(epcc_exps));

    % Read the model into the model variable
    M3D_load_model_Microfluidics;

    % We start with no experiments
    exps.n_exp=0;

    % Defining boundaries for the parameters (taken from scientific literature)
    global_theta_min = [3.88e-5,3.88e-2,0.5,2,7.7e-3,0.2433,5.98e-5,0.012,10]; % 1/min
    global_theta_max = [0.4950,0.4950,4.9,10,0.23,6.8067,0.2449,0.0217,100];
    
    global_theta_guess = global_theta_guess';


    % Specify the parameters to be calibrated.
    % The selection depends on the identifiability analysis preceding the
    % comparison: parameters that are not identifiable will fixed to the best
    % estimate available for them.
    % In our case, all parameters are identifiable.
    param_including_vector = [true,true,true,true,true,true,true,true,true];

    % Compile the model
    clear inputs;
    inputs.model = model;
    inputs.pathd.results_folder = results_folder;
    inputs.pathd.short_name     = short_name;
    inputs.pathd.runident       = 'initial_setup';

    % Fixed parts of the experiment
    totalDuration = 21*60;               % Duration in of the experiment (minutes)
    numLoops = epccNumLoops;             % Number of OID loops
    duration = totalDuration/numLoops;   % Duration of each loop (in our case the number is 1)
    stepDuration = stepd;                % Duration of each step (minutes). Note that the value passed to the function exceeds the response time, quantified in 80 mins for MPLac,r


for i=1:numLoops
    
    %Compute the steady state considering the initial theta guess and 0 IPTG
    y0 = M3D_steady_state_Microfluidics(global_theta_guess,0);
    
    
    % Need to determine the starting state of the next part of the
    % experiment we wish to design the input for. If there are multiple loops,
    % We get this state by simulating the model using the current best theta
    % for the duration for which we have designed input.
    if exps.n_exp == 0
        oid_y0 = [y0]; 
        best_global_theta = global_theta_guess;
    else
        % Simulate the experiment without noise to find end state
        clear inputs;
        inputs.model = model;
        inputs.model.par = best_global_theta;
        inputs.exps = exps;
        
        inputs.plotd.plotlevel='noplot';
        inputs.pathd.results_folder = results_folder;
        inputs.pathd.short_name     = short_name;
        inputs.pathd.runident       = strcat('sim-',int2str(i));
        
        sim = AMIGO_SData(inputs);
        
        oid_y0 = [sim.sim.states{1}(end,:)];
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Optimal experiment design
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear inputs;
    inputs.model = model;
    inputs.exps  = exps;
    format long g
    
    
    % Add new experiment that is to be designed
    inputs.exps.n_exp = inputs.exps.n_exp + 1;                      % Number of experiments
    iexp = inputs.exps.n_exp;                                       % Index of the experiment
    inputs.exps.exp_type{iexp}='od';                                % Specify the type of experiment: 'od' optimally designed
    inputs.exps.n_obs{iexp}=1;                                      % Number of observables in the experiment
    inputs.exps.obs_names{iexp}=char('Fluorescence');               % Name of the observables in the experiment
    inputs.exps.obs{iexp}=char('Fluorescence = Cit_AU');            % Observation function
    
    
    % Fixed parts of the experiment
    inputs.exps.exp_y0{iexp}=oid_y0;                                % Initial conditions
    inputs.exps.t_f{iexp}=duration;                                 % Duration of the experiment (minutes)
    inputs.exps.n_s{iexp}=duration/5+1;                             % Number of sampling times - sample every 5 min
    
    % OED of the input
    inputs.exps.u_type{iexp}='od';
    inputs.exps.u_interp{iexp}='stepf';                             % Stimuli definition for experiment: 'stepf' steps of constant duration
    inputs.exps.n_steps{iexp}=round(duration/stepDuration);         % Number of steps in the input
    inputs.exps.t_con{iexp}=0:stepDuration:(duration);            % Switching times
    inputs.exps.u_min{iexp}=0*ones(1,inputs.exps.n_steps{iexp});    % Lower boundary for the input value
    inputs.exps.u_max{iexp}=1000*ones(1,inputs.exps.n_steps{iexp}); % Upper boundary for the input value
    
    inputs.PEsol.id_global_theta=model.par_names(param_including_vector,:);
    inputs.PEsol.global_theta_guess=transpose(global_theta_guess(param_including_vector));
    inputs.PEsol.global_theta_max=global_theta_max(param_including_vector);  % Maximum allowed values for the parameters
    inputs.PEsol.global_theta_min=global_theta_min(param_including_vector);  % Minimum allowed values for the parameters
    
    
    inputs.exps.noise_type='homo_var';           % Experimental noise type: Homoscedastic: 'homo'|'homo_var'(default)
    inputs.exps.std_dev{iexp}=[0.10];
    inputs.OEDsol.OEDcost_type='Dopt';
    
    
    % SIMULATION
    inputs.ivpsol.ivpsolver='cvodes';                     % [] IVP solver: 'cvodes'(default, C)|'ode15s' (default, MATLAB, sbml)|'ode113'|'ode45'
    inputs.ivpsol.senssolver='cvodes';                    % [] Sensitivities solver: 'cvodes'(default, C)| 'sensmat'(matlab)|'fdsens2'|'fdsens5'
    inputs.ivpsol.rtol=1.0D-8;                            % [] IVP solver integration tolerances
    inputs.ivpsol.atol=1.0D-8;
    
    % OPTIMIZATION
    %oidDuration=600;
    inputs.nlpsol.nlpsolver='eSS';
    inputs.nlpsol.eSS.maxeval = 6e5;
    inputs.nlpsol.eSS.maxtime = 1e5;
    inputs.nlpsol.eSS.local.solver = 'fminsearch'; 
    inputs.nlpsol.eSS.local.finish = 'fmincon';
    
    inputs.nlpsol.eSS.local.nl2sol.maxiter  =     1000;     % max number of iteration
    inputs.nlpsol.eSS.local.nl2sol.maxfeval =     1000;     % max number of function evaluation
    inputs.nlpsol.eSS.log_var=1:inputs.exps.n_steps{iexp};
    inputs.plotd.plotlevel='noplot';
    
    inputs.pathd.results_folder = results_folder;
    inputs.pathd.short_name     = short_name;
    inputs.pathd.runident       = strcat('oed-',int2str(i));
        
    AMIGO_Prep(inputs);
    
    oed_start = now;
    
    results = AMIGO_OED(inputs);
    oed_results{i} = results;
    oed_end = now;
    
    results.plotd.plotlevel = 'noplot';

save([strcat(epccOutputResultFileNameBase),'.mat'], 'oed_results','exps','inputs','best_global_theta');

out= 1;
end
