%% Extract data as CSV

% This script exrtacts the experimental results as well as the experimental
% information (time, inputs) and generates a csv file.

% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> fic: Name of the CSV file containing the information of the
% inputs for an experiment

function [] = ExtractDataAsCSV(direct, ident, fic, direct2)

% Load data
load([direct, '\Tracking\',ident,'_FinalCuratedTraces.mat'], 'sct6');

%% Single-cell data

% Read Inputs file
csvDat = readtable([direct2,'\',fic,'.csv']);
% Get time vector
time = csvDat.SwitchTime(1):5:csvDat.FinalTime(1)-5;

% Generate IPTG vector
IPTG = nan(1,length(time));
for i=1:length(csvDat.IPTG)
    for j=1:length(time)
        if time(j) >= csvDat.SwitchTime(i)
            IPTG(j) = csvDat.IPTG(i);
        end
    end
end

IPTGpre = zeros(1,length(time));

% Generate matrix with all data to be converted into CSV

finMat = zeros(length(time),length(sct6)+3);

finMat(:,1) = IPTGpre;
finMat(:,2) = IPTG;
finMat(:,3) = time;

for i=4:length(finMat)
    finMat(:,i) =sct6{(i-3)};
end

indcell = strings(1,length(sct6));

for i=1:length(indcell)
    indcell(i) = ['Cell_',int2str(i)];
end

header = strings(1,length(sct6)+3);
header(1) = 'IPTGpre';
header(2) = 'IPTG';
header(3) = 'time(min)';
header(4:end) = indcell;

% Write CSV file
cHeader = num2cell(header); %dummy header
for i=1:length(cHeader)
cHeader{i} = char(cHeader{i});
end
commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas
%write header to file
fid = fopen([direct,'\',ident,'-SC_Data.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([direct,'\',ident,'-SC_Data.csv'],finMat,'-append');

%% Average data

% Compute mean and standard deviation of the trajectories
fina = [];
for i=1:length(sct6)
    fina = [fina;sct6{i}];
end

mv = mean(fina,'omitnan');
sv = std(fina,'omitnan');

% Put everything inside a matrix
finMat2 = zeros(length(time),5);

finMat2(:,1) = IPTGpre;
finMat2(:,2) = IPTG;
finMat2(:,3) = time;
finMat2(:,4) = mv;
finMat2(:,5) = sv;

% Write the heathers for the CSV file
header2 = strings(1,5);
header2(1) = 'IPTGpre';
header2(2) = 'IPTG';
header2(3) = 'time(min)';
header2(4) = 'Mean';
header2(5) = 'Standard Deviation';

% Write CSV file
cHeader2 = num2cell(header2); %dummy header
for i=1:length(cHeader2)
cHeader2{i} = char(cHeader2{i});
end
commaHeader = [cHeader2;repmat({','},1,numel(cHeader2))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas
%write header to file
fid = fopen([direct,'\',ident,'-Average_Data.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([direct,'\',ident,'-Average_Data.csv'],finMat2,'-append');


end
















































