
%% On-line image processing core

% This script performs the necessary image processing tasks from 
% microfluidic experiment images to obtain the cell citrine levels on real
% time. It is devided in 4 sections, Addition of required libraries and
% functions, Generation of ROI indexces to cut images, On-Line processing
% and Off-line postprocessing (which in the future will be included on-line

%% Include necessary paths for the tasks
addpath('FunctionsOnLine');
addpath('Temp_Masks');
addpath('Temp_Track');

%% Get index for ROI

disp('Generate an initial image to obtain the ROI and select:')
% K=input(' Enter full path directory for the image :\n', 's');
[fil,K] = uigetfile('*');

cutcor = DICindexROI(K);
% cutcor = DICindexROIpre2018b(K);

%% On-line processing (during experiment)

% Get path of the file containing the input design
disp('Select the text file containing the input design')
[file1,path1] = uigetfile('*.txt');

% Get the input values and step durations to compute the maximum time of
% the experiment in seconds
fid = fopen([path1,file1]);
inputs = strsplit(fgetl(fid), ' ');
fclose(fid);
inputs = inputs(~cellfun('isempty',inputs));

% Maximum time of the experiment
maxt = str2double(inputs{1})*(length(inputs)-1);
DicFreq = 2.5;

% Matrix with inputs and corresponding time vector to be included in the
% final plot
timeIn=0:(str2double(inputs{1})/60):((str2double(inputs{1})/60)*(length(inputs)-1));
inp = zeros(1,length(timeIn));
for i=1:length(inputs)-1
    inp(i) = str2double(inputs{i+1});
end
inp(end) = str2double(inputs{length(inputs)});
INP = zeros(2,length(inp));
INP(1,:)=inp; INP(2,:)=timeIn;

% Select directory where microscope images will be saved
disp('Select the directory where the images are going to be saved')
pDIC = uigetdir;

subs = genpath(pDIC);
addpath(subs);

% Type identifier to be used for files
ident=input(' Enter desired identifier for files :\n', 's');
% Select location of the RSA file for the instance
% disp('Select the location of the RSA key file')
% [file2,path2] = uigetfile('*.pem');
RSA = 'D:\David\OED_invivo-master\ImageProcessing\ExtractFluorescenceMicrofluidics\lin002Test.pem';

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
IP = '129.215.193.61'; % Floating IP of the instance
Cmod = 'CChNewFin3'; % Name of the weights file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WriteMacroSegmentation(pDIC,ident,IP,Cmod,RSA,cutcor); % Write macro ImageJ script for segmentation

% Add ImageJ to the path
addpath 'D:\David\fiji-win64\Fiji.app\scripts'
ImageJ;

% Structures that will contain the temporary results for
% on-line check
tfluo = nan(2,(maxt)/(5*60));
save([pDIC,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');
tBKGround = nan(1,(maxt)/(5*60));
save([pDIC,'\Segmentation\TemporaryBackground.mat'],'tBKGround');
tBKGroundS = nan(1,(maxt)/(5*60));
save([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');


t = timer;
t.Period = 30;%DicFreq*60; % Time delay in seconds
t.TasksToExecute = 1800;%(maxt+150)/(DicFreq*60); % Number of times that the function will be executed
t.ExecutionMode = 'fixedRate';
t.TimerFcn = {@ImProcSegm,cutcor,pDIC,ident,INP};

message = sprintf('Ready to start??');
mh = msgbox(message, 'Waiting...', 'warn');     %create msgbox
th = findall(mh, 'Type', 'Text');                   %get handle to text within msgbox
th.FontSize = 14;   
uiwait(mh);

disp('                         ************************************************');
disp('                        *      **      EXPERIMENT STARTED!      **      *');
disp('                         ************************************************');
disp('                                  ******************************         ');
disp('                                            **********                   ');
disp('                                                **                       ');

                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %      *      START EXPERIMENT      *      %
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pause(300)% Wait 30 seconds for images to be taken
start(t)
wait(t)
stop(t)

disp('Experiment Finished!')

% Quit ImageJ
ij.IJ.run("Quit","");


%% Off-line processing (after experiment)

% Save necessary images in matlab structures to be used
disp('Extracting necessary images.....')
[CDs, CCs, Segs, BGMask] = SaveImgMat(pDIC,ident);
disp('Finished!')


% Move Indexed masks to the temporeraly directory
if ~exist([pwd,'\Temp_Masks'],'dir')
    mkdir([pwd,'\Temp_Masks']);
    addpath([pwd,'\Temp_Masks']);
end

if ~exist([pwd,'\Temp_Track'],'dir')
    mkdir([pwd,'\Temp_Track']);
    addpath([pwd,'\Temp_Track']);
end

masks = [pDIC,'\Segmentation\Components\img_*'];
copyfile(masks,'Temp_Masks')
disp('Images Moved!')

% Perform cell trking with Lineage Mapper
% Increase Java memory in Matlab --> https://imagej.net/MATLAB_Scripting
LineageMapperTrackingOnLine(pDIC,ident);

% Check when tracking is finished
Folder=['Temp_Track'];
filePattern = fullfile(Folder, strcat('trk-img*'));
Files2 = dir(filePattern);
% Get number of frames for channel
maxidT=length(Files2);

while length(Segs)~=maxidT
    Files2 = dir(filePattern);
    % Get number of frames for channel
    maxidT=length(Files2);
end

disp('Tracking Finished!')


% Move tracking masks and empty Temp_Masks directory
tempT = [pwd,'\Temp_Track\*'];
finalT = [pDIC, '\Tracking'];

rmpath([pwd,'\Temp_Track\trk-lineage-viewer'])
movefile(tempT, finalT)
delete([pwd,'\Temp_Masks\img_*'])
disp('Masks moved')


% Fluorescence data extraction

disp('Extracting Single-Cell fluorescence ...')
[sct,sct2,scts] = SingleCellDataOnLine(pDIC, ident);
disp('Finished!')

disp('Curating Traces ...')
[dat,sct6,sct62] = SingleCellDataCurationOnLine(pDIC, ident);
disp('Finished!')


% Plot comparison between full traces and curated traces

fina = [];
for i=1:length(sct6)
    fina = [fina;sct6{i}];
end

t = 1:5:(length(dat(:,1))*5);
figure
hold on
yyaxis left
shadedErrorBar(t, dat(:,1)', dat(:,2)','lineprops', '-r','transparent', 0)
shadedErrorBar(t, mean(fina,'omitnan'), std(fina, 'omitnan'),'lineprops', '-g','transparent', 1)

xlabel('time(min)')
ylabel('Fluorescence (AU)')
title(['All Cells (',num2str(length(sct2)),' traces) VS Final Filter (',num2str(length(sct6)),' traces)'])

yyaxis right
stairs(INP(2,:), INP(1,:), 'b') % Input design
ylabel('IPTG(uM)')

legend('All Cells', 'Filtered', 'Input')

hold off
savefig([pDIC, '\',ident,'_FluorescencePlot.fig']);

% Make a CSV file containing the experimental data
swt = timeIn(1:end-1)';
ft = repelem(timeIn(end),length(swt))';
iptg = inp(1:end-1)';
datMat = [swt,ft,iptg];
header = strings(1,3);
header(1) = 'SwitchTime';
header(2) = 'FinalTime';
header(3) = 'IPTG';

% Write CSV file
cHeader = num2cell(header); %dummy header
for i=1:length(cHeader)
cHeader{i} = char(cHeader{i});
end
textHeader = strjoin(cHeader, ',');

%write header to file
fid = fopen([pDIC,'\',ident,'-Inputs.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([pDIC,'\',ident,'-Inputs.csv'],datMat,'-append');

% Generate CSV files with the results of the experiment
disp('Generating CSV files ...')
ExtractDataAsCSVOnLine(pDIC, ident)
disp('Finished!')


disp('                         ************************************************');
disp('                        *      **      EXPERIMENT FINISHED!      **      *');
disp('                         ************************************************');
disp('                                  ******************************         ');
disp('                                            **********                   ');
disp('                                                **                       ');
     
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %      **      THE END      **      %
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








