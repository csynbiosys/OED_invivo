
%% Load data

csvDat = readtable('D:\PhD\Year_1\2019_07_31_OEDinVivo\Scripts\ImageProcessing\ExtractFluorescenceMicrofluidics\Data\IntuitionDriven1\Steps-3\exp_01\chamber001\Steps3-Average_Data.csv');
InpDat = readtable('D:\PhD\Year_1\2019_07_31_OEDinVivo\Scripts\ImageProcessing\ExtractFluorescenceMicrofluidics\Data\IntuitionDriven1\Steps-3\exp_01\chamber001\StepInputs.csv');

% Experimental Conditions strings
ecs = unique(table2array(csvDat(:,2)),'stable');

tag = 'Steps3';
di = 'IntuitionDriven';

%% Generate data structure

Data = struct('exp_type',[],'n_obs',[],'obs_names',[],'obs',[],'u_interp',[],'n_steps',[],'n_s',[],'t_f',...
    [],'t_s',[],'t_con',[],'u',[],'exp_data',[],'error_data',[],'data_type',[],'noise_type',[]);
for i=1:1
    Data.exp_type{i} = 'fixed';
    Data.n_obs{i}=1;
    Data.obs_names='Fluorescence';
    Data.obs{i}='Fluorescence=Cit_AU';
    Data.u_interp{i}='step';
    Data.n_steps{i}=length(ecs);                         % Number of steps
    Data.n_s{i}=length(table2array(csvDat(:,1)));       % Number of sampling points
    Data.t_f{i}=table2array(csvDat(end,3));             % Final time (min)
    Data.t_s{i}=table2array(csvDat(:,3))';               % Sampling times (min)
    Data.t_con{i}=[table2array(InpDat(:,1))', Data.t_f{i}];       % Switching times (min)
    Data.u{i}=table2array(InpDat(:,3))';                 % Input
    Data.exp_data{i}=table2array(csvDat(:,4))';
    Data.error_data{i}=table2array(csvDat(:,5))';
    Data.data_type = 'real';
    Data.noise_type = 'homo';
end

%% Save results
save([di,'\',tag,'-MicroFluidicsData.mat'],'Data')





































