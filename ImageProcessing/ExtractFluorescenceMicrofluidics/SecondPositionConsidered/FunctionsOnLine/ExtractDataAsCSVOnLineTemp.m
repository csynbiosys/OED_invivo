%% Extract data as CSV

% This script exrtacts the experimental results as well as the experimental
% information (time, inputs) and generates a csv file.

% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> fic: Name of the CSV file containing the information of the
% inputs for an experiment

function [] = ExtractDataAsCSVOnLineTemp(direct, INP, CitFreq, ident)

% Load data
load([direct,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');

%% Single-cell data

% Get time vector
time = INP(2,1):CitFreq:INP(2,end)-CitFreq;

% Generate IPTG vector
IPTG = nan(1,length(time));
for i=1:length(INP(1,:))
    for j=1:length(time)
        if time(j) >= INP(2,i)
            IPTG(j) = INP(1,i);
        end
    end
end

IPTGpre = zeros(1,length(time));

% Generate matrix with all data to be converted into CSV

finMat = zeros(length(time),5);

finMat(:,1) = IPTGpre;
finMat(:,2) = IPTG;
finMat(:,3) = time;
finMat(:,4) = tfluo(1,:);
finMat(:,5) = tfluo(2,:);

% Write the heathers for the CSV file
header2 = strings(1,5);
header2(1) = 'IPTGpre';
header2(2) = 'IPTG';
header2(3) = 'time(min)';
header2(4) = 'Mean';
header2(5) = 'StandardDeviation';

% Write CSV file
cHeader2 = num2cell(header2); %dummy header
for i=1:length(cHeader2)
cHeader2{i} = char(cHeader2{i});
end
textHeader = strjoin(cHeader2, ',');
%write header to file
fid = fopen([direct,'\',ident,'-Temporary_Average_Data.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([direct,'\',ident,'-Temporary_Average_Data.csv'],finMat,'-append');


end





