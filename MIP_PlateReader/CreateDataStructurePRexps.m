
%% Load data

csvDat = readtable('PlateReaderData.csv');

% Experimental Conditions strings
ecs = unique(table2array(csvDat(:,1)),'stable');

% Experimental Conditions Values
IPTG = zeros(1,length(ecs));

for i=1:length(ecs)
    newStr = erase(ecs{i},'2% Glu,');
    newStr = erase(newStr,' IPTG');
    IPTG(i) = str2num(newStr);
end

%% Extract data by Experimental Conditions
preData = cell(1,length(ecs));

for h=1:length(ecs)
    ip = [];
    tp = [];
    mp = [];
    vp = [];

    for i=1:length(table2array(csvDat(:,1)))

        tempstr = table2array(csvDat(i,1));
        if strcmp(tempstr{1}, ecs{h})
            tempval1 = table2array(csvDat(i,1));
            tempval2 = table2array(csvDat(i,2));
            tempval3 = table2array(csvDat(i,3));
            tempval4 = table2array(csvDat(i,4));


            newStr = erase(tempval1{1},'2% Glu,');
            newStr = erase(newStr,' IPTG');
            IPTG = str2num(newStr);


            ip = [ip,IPTG];
            tp = [tp,tempval2];
            mp = [mp,tempval3];
            vp = [vp,tempval4];
        end
        preData{h} = zeros(length(ip),4);
        preData{h}(:,1) = ip;preData{h}(:,2) = tp;preData{h}(:,3) = mp;preData{h}(:,4) = vp;
    end
end

%% Plot for check
hold on
for i=1:length(ecs)
    errorbar(preData{i}(:,2),preData{i}(:,3),sqrt(preData{i}(:,4)))
    
end
legend({num2str(preData{1}(1,1)),num2str(preData{2}(1,1)), num2str(preData{3}(1,1)), num2str(preData{4}(1,1)), num2str(preData{5}(1,1)),... 
    num2str(preData{6}(1,1)), num2str(preData{7}(1,1)), num2str(preData{8}(1,1)), num2str(preData{9}(1,1)), num2str(preData{10}(1,1))})
hold off

%% Generate data structure

Data = struct('exp_type',[],'n_obs',[],'obs_names',[],'obs',[],'u_interp',[],'n_steps',[],'n_s',[],'t_f',...
    [],'t_s',[],'t_con',[],'u',[],'exp_data',[],'error_data',[],'data_type',[],'noise_type',[]);
for i=1:length(ecs)
    Data.exp_type{i} = 'fixed';
    Data.n_obs{i}=1;
    Data.obs_names='Fluorescence';
    Data.obs{i}='Fluorescence=Cit_AU';
    Data.u_interp{i}='step';
    Data.n_steps{i}=1;                         % Number of steps
    Data.n_s{i}=length(preData{i}(:,2));       % Number of sampling points
    Data.t_f{i}=preData{i}(end,2);             % Final time (min)
    Data.t_s{i}=preData{i}(:,2)';               % Sampling times (min)
    Data.t_con{i}=[0 preData{i}(end,2)];       % Switching times (min)
    Data.u{i}=preData{i}(1,1);                 % Input
    Data.exp_data{i}=preData{i}(:,3);
    Data.error_data{i}=sqrt(preData{i}(:,4));
    Data.data_type = 'real';
    Data.noise_type = 'homo';
end

%% Save results
save('PlateReaderData.mat','Data')


%% Reduced data to maximum citritne level

% Fine maximum point for all experiments

mcl = zeros(1,length(ecs));

for i=1:length(mcl)
    exp_data=preData{i}(:,3)';
    ma = find(exp_data==max(exp_data));
    mcl(i) = ma;
end

% Cut point
cp = round(mean(mcl));

% Reduced data structure
DataRed = struct('exp_type',[],'n_obs',[],'obs_names',[],'obs',[],'u_interp',[],'n_steps',[],'n_s',[],'t_f',...
    [],'t_s',[],'t_con',[],'u',[],'exp_data',[],'error_data',[],'data_type',[],'noise_type',[]);
for i=1:length(ecs)
    DataRed.exp_type{i} = 'fixed';
    DataRed.n_obs{i}=1;
    DataRed.obs_names='Fluorescence';
    DataRed.obs{i}='Fluorescence=Cit_AU';
    DataRed.u_interp{i}='step';
    DataRed.n_steps{i}=1;                         % Number of steps
    DataRed.n_s{i}=length(preData{i}(1:cp,2));       % Number of sampling points
    DataRed.t_f{i}=preData{i}(cp,2);             % Final time (min)
    DataRed.t_s{i}=preData{i}(1:cp,2)';               % Sampling times (min)
    DataRed.t_con{i}=[0 preData{i}(cp,2)];       % Switching times (min)
    DataRed.u{i}=preData{i}(1,1);                 % Input
    DataRed.exp_data{i}=preData{i}(1:cp,3);
    DataRed.error_data{i}=sqrt(preData{i}(1:cp,4));
    DataRed.data_type = 'real';
    DataRed.noise_type = 'homo';
end

%% Save reduced data
save('PlateReaderDataReduced.mat','DataRed')




































