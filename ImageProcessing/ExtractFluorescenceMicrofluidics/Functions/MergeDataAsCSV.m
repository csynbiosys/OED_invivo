%% Merge data as CSV

% This script exrtacts the experimental results as well as the experimental
% information (time, inputs) of the 3 replicates for one same tipe of
% experiment and merges the results saving them as a CSV with all the data
% and a CSV with the mean results.

% --------> globdir: Directory path where results of one type of
% experiments are saved.
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string). Do no add the number at the end
% of the directory since all of themm will be considered.
% --------> fic: Name of the CSV file containing the information of the
% inputs for an experiment

function [] = MergeDataAsCSV(globdir, idents, fic)

% Load Data
sc1 = load([globdir, '\',idents,'-1\Tracking\',idents,'-1_FinalCuratedTraces.mat'], 'sct6');
sc2 = load([globdir, '\',idents,'-2\Tracking\',idents,'-2_FinalCuratedTraces.mat'], 'sct6');
sc3 = load([globdir, '\',idents,'-3\Tracking\',idents,'-3_FinalCuratedTraces.mat'], 'sct6');


%% Single-cell data

% Read Inputs file
csvDat = readtable([globdir,'\',idents,'-1\',fic,'.csv']);
% Get time vector
time = csvDat.SwitchTime(1):2.5:csvDat.FinalTime(1)-2.5;

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

finMat = zeros(length(time),length(sc1)+length(sc2)+length(sc3)+3);

finMat(:,1) = IPTGpre;
finMat(:,2) = IPTG;
finMat(:,3) = time;

for i=4:length(sc1)
    finMat(:,i) =sc1{(i-3)};
end
for i=(length(sc1)+3):(length(sc2)+length(sc1)+3)
    finMat(:,i) =sc2{i};
end

for i=(length(sc1)+length(sc2)+3):(length(sc3)+length(sc2)+length(sc1)+3)
    finMat(:,i) =sc3{i};
end


indcell = strings(1,length(sc1)+length(sc2)+length(sc3));

for i=1:length(indcell)
    indcell(i) = ['Cell_',int2str(i)];
end

header = strings(1,length(sc1)+length(sc2)+length(sc3)+3);
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
fid = fopen([globdir,'\',idents,'-SC_Data.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([globdir,'\',idents,'-SC_Data.csv'],finMat,'-append');

%% Average data

% Compute mean and standard deviation of the trajectories
mv = mean(finMat,'omitnan');
sv = std(finMat,'omitnan');

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
fid = fopen([globdir,'\',idents,'-Average_Data.csv'],'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite([globdir,'\',idents,'-Average_Data.csv'],finMat2,'-append');





end



























