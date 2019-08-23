%% Image Processing Core

% This script performs the necessary image processing tasks from 
% microfluidic experiment images to obtain the cell citrine levels of the 
% experiment

%% Include necessary paths for the tasks
subs = genpath('Data');
addpath(subs);
addpath('Functions');
addpath('Temp_Masks');
addpath('Temp_Track');

%% Cut ROI and save results

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
direct='Data\IntuitionDriven2\Random1\exp_00\Chamber001';
dire = 'Data\IntuitionDriven2\Random1-3\exp_00\Chamber001\chamber001';
% pos=[437,891,4,1021];
ident = 'Random1';
pat = strcat('exp_000','*_DIC_001.png');
% pat2 = 'exp_000*_mCitrineTeal_001.png';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Cuting Images ...')
% CutImages(direct,pos,ident,pat);
CutImagesManual2(direct, ident ,pat)
disp('Finished!')

%% Cut background images

disp('Cuting background ...')
CutBackground2(direct, ident ,pat)
disp('Finished!')

% %% Save results if images are already cut
% 
% %%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
% direct='Data\IntuitionDriven1\Steps-1';
% directC='Data\IntuitionDriven1\Steps-1\CutImages';
% ident = 'Steps1';
% pat2 = strcat('DIC_Frame','*.png');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% disp('Reading Images ...')
% ReadImages(directC,direct,ident,pat2);
% disp('Finished!')

%% Perform Image Segmentation

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
IP = '129.215.193.61';
Cmod = 'CChNewFin3';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Segmenting Images ...')
UNetSegment(direct, ident, IP, Cmod);
% 5425.046962 seconds --> 90.4 min --> 1.5h
disp('Finished!')

%% Genertion of background masks from segmentation results
disp('Generating Background Masks ...')
[Segs,BGMask] = generateBackgroundMask(direct, ident);
disp('Finished!')

%% Check Segmentation as a video compared to DIC images

load([direct,'\',ident,'-CutImages.mat'],'CDs')
figure()
for i=1:length(Segs)
        
        img = mat2gray(CDs{i});
        mas = mat2gray(Segs{i});
        
        subplot(1,2,1),
        imshow(img),subplot(1,2,2),
        imshow(mas), hold on

        hold off
%         pause(0.6);
        drawnow
end

%% Get indexed masks (different identifier per cell and per mask)

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Indexing Cells ...')
IndexMasks(Segs,dire,ident);
disp('Finished!')

%% Move Indexed masks to the temporeraly directory
masks = [dire,'\Components\img_*'];
copyfile(masks,'Temp_Masks')
disp('Images Moved!')

%% Perform cell trking with Lineage Mapper
% Increase Java memory in Matlab --> https://imagej.net/MATLAB_Scripting
LineageMapperTracking(direct,ident);

% Check when tracking is finished
Folder=['Temp_Track'];
filePattern = fullfile(Folder, strcat('trk-img*'));
Files2 = dir(filePattern);
% Get number of frames for channel
maxid=length(Files2);

while length(Segs)~=maxid
    Files2 = dir(filePattern);
    % Get number of frames for channel
    maxid=length(Files2);
end
disp('Tracking Finished!')

%% Move tracking masks and empty Temp_Masks directory
tempT = [pwd,'\Temp_Track\*'];
finalT = [direct, '\Tracking'];

rmpath([pwd,'\Temp_Track\trk-lineage-viewer'])
movefile(tempT, finalT)
delete([pwd,'\Temp_Masks\img_*'])
disp('Masks moved')

%% Check tracking by selecting a cell identifier

id = 31;
load([direct,'\',ident,'-CutImages.mat'],'CDs')
figure()
for i=1:length(CDs)
    %# read image
    num = num2str(i,'%.3u');
    img = imread(['.\',direct,'\Tracking\trk-img_',num,'.tif']);
    im1 = img==id;
    im2 = CDs{i};
    %# show image
    C = imfuse(mat2gray(im2),edge(im1));
    imshow(C), hold on
%     pause(0.5);
    hold off

    drawnow
end

%% Fluorescence data extraction
pat3= 'DIC_Frame*.png';

disp('Extracting Single-Cell fluorescence ...')
[sct,sct2,scts] = SingleCellData2(direct, ident, pat3);
disp('Finished!')

%% Plot single-cell citrine traces for check
maxid2 = length(sct2);
figure;
hold on
for i=1:maxid2
%     A = sct2{i}(1,:);
    plot(1:length(sct), sct2{i}(1,:))
end
hold off

%% Single-cell data curation
disp('Curating Traces ...')
[dat,sct6] = SingleCellDataCuration2(direct, ident, pat3);
disp('Finished!')

%% Plot comparison between full traces and curated traces

fina = [];
for i=1:length(sct6)
    fina = [fina;sct6{i}];
end

t = 1:5:(288*5);
hold on
shadedErrorBar(t, dat(:,1)', dat(:,2)','lineprops', '-r','transparent', 0)
shadedErrorBar(t, mean(fina,'omitnan'), std(fina, 'omitnan'),'lineprops', '-g','transparent', 1)

% % Switching times
% plot([180 180],[-20 120])
% plot([360 360],[-20 120])
% plot([540 540],[-20 120])
% plot([720 720],[-20 120])
% plot([900 900],[-20 120])
% plot([1080 1080],[-20 120])
% plot([1260 1260],[-20 120])

xlabel('time(min)')
ylabel('Fluorescence (AU)')
title(['All Cells (',num2str(length(sct2)),' traces) VS Final Filter (',num2str(length(sct6)),' traces)'])
legend('All Cells', 'Filtered')
hold off

%% Make a CSV file containing the experimental data

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
fic = 'RandomInputs';
direct2 = 'Data\IntuitionDriven2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Generating CSV files ...')
ExtractDataAsCSV(direct, ident,fic, direct2)
disp('Finished!')

%% Merge data replicates

%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%
globdir = 'Data\IntuitionDriven1';
idents = 'Steps';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Generating CSV files ...')
MergeDataAsCSV(globdir, idents, fic)
disp('Finished!')


                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %      **      THE END      **      %
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                
                
                
                
                
                


