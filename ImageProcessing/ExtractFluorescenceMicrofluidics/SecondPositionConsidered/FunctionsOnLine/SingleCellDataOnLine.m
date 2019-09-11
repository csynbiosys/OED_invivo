%% Single Cell Data
% This scrip extracts the single-cell fluorescence trajectories and
% corrects them by the background fluorescence

% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> CCs: Matlab structure containing the cut Citrine images

%OUTPUTS
% --------> sct: Matlab structure containing the single cell citrine levels
% by frame
% --------> sct2: Matlab structure containing the single cell citrine levels
% by cell
% --------> scts: Matlab structure containing the single cell sizes by
% frame

function [sct,sct2,scts] = SingleCellDataOnLine(pDIC,ident,CitFreq,DicFreq)

% Get Directory of images 
Folder=[pDIC,'\CutDIC\'];
filePattern = fullfile(Folder, 'exp*DIC_001.png');
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Get names of current images 
filePattern1 = fullfile(pDIC, 'exp*DIC_001.png');
filePattern2 = fullfile(pDIC, 'exp*mCitrineTeal_001.png');
Files1 = dir(filePattern1);
Files2 = dir(filePattern2);
maxidD=length(Files1);
maxidC=length(Files2);

% Load tracking results
trki = cell(1,maxidD);
for i=1:maxidD
    strind=num2str(i,'%.3u');
    x = imread([pDIC, '\Tracking\trk-img_',strind,'.tif']);
    trki{i}=x;
end

save([pDIC, '\Tracking\',ident,'_TrakedMasks2.mat'], 'trki')

% Number of cells
n=cellfun(@(seg) max(seg(:)),trki);

% Load Cut Citrine images and Background images
load([pDIC,'\',ident,'-CutImages.mat'], 'CCs');
load([pDIC,'\',ident,'_BackGroundMask.mat']);
load([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');
medianBGCitrine=tBKGroundS;

% Singel Cell Data per frame
sct = cell(1,maxidC);

r = 1:CitFreq/DicFreq:maxidD;
for ind=1:maxidC
    strind=num2str(ind,'%.3u');
    fprintf(['Processing frame ',strind,'...\n']);
    tempim2=double(CCs{ind});
    
    temp1=unique(trki{r(ind)});
    temp1 = nonzeros(temp1);
    sct{ind} = NaN(2,max(n));
    
    if ~isnan(tBKGroundS(ind))
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{r(ind)}==temp1(p)))-medianBGCitrine(ind)), std((tempim2(trki{r(ind)}==temp1(p)))-medianBGCitrine(ind))];
        end
    else
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{r(ind)}==temp1(p)))-mean(medianBGCitrine(37:end),'omitnan')), std((tempim2(trki{r(ind)}==temp1(p)))-mean(medianBGCitrine(37:end),'omitnan'))];
        end
    end
    
end

save([pDIC, '\Tracking\',ident,'_SingleCellTrackPerFrame.mat'], 'sct')

% Single cell data per cell

sct2 = cell(1,max(n));

for i=1:maxidC
    for j=1:max(n)
        sct2{j}(:,i) = sct{i}(:,j);
    end
end

save([pDIC, '\Tracking\',ident,'_SingleCellTrackPerCell.mat'], 'sct2')

% Singel Cell Size
scts = {};
parfor ind=1:maxidC
    strind=num2str(ind,'%.3u');
    tempim2=double(CCs{ind});
    
    temp1=unique(trki{r(ind)});
    temp1 = nonzeros(temp1);
    scts{ind} = NaN(1,max(n));
    
    
    for p=1:length(temp1)
        scts{ind}(:,temp1(p)) = length((tempim2(trki{r(ind)}==temp1(p))));
    end
        
end

save([pDIC, '\Tracking\',ident,'_SingleCellTrackSize.mat'], 'scts')


end




