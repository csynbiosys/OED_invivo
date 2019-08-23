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

function [sct,sct2,scts] = SingleCellDataOnLine(pDIC, ident)

% Get Directory of images 
Folder=[pDIC,'\CutDIC\'];
filePattern = fullfile(Folder, 'exp*DIC_001.png');
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Load tracking results
trki = cell(1,maxid);
for i=1:maxid
    strind=num2str(i,'%.3u');
    x = imread([pDIC, '\Tracking\trk-img_',strind,'.tif']);
    trki{i}=x;
end

save([pDIC, '\Tracking\',ident,'_TrakedMasks2.mat'], 'trki')

% Number of cells
n=cellfun(@(seg) max(seg(:)),trki);

% Empty cells with the results
medianBGCitrine=nan(maxid/2,1);
whenFull=nan;

% Load Cut Citrine images and Background images
load([pDIC,'\',ident,'-CutImages.mat'], 'CCs');
load([pDIC,'\',ident,'_BackGroundMask.mat']);
load([pDIC,'\Segmentation\TemporaryBackground.mat']);
medianBGCitrine=tBKGround;

% Compute Background intensity
r = 2;
for ind=1:maxid/2
    tempim2=double(CCs{ind});
    
    if (isnan(whenFull))
        medianBGCitrine(ind)=median(tempim2(logical(BGMask{r})));
        if (mean(double(logical(BGMask{r}(:))))<0.25)
            meanBGCitrine=mean(medianBGCitrine,'omitnan');
            whenFull=ind;
            break;
        end
    end
    r=r+2;
end


% Singel Cell Data per frame
sct = cell(1,maxid/2);
r=2:2:maxid;
parfor ind=1:maxid/2
    strind=num2str(ind,'%.3u');
    fprintf(['Processing frame ',strind,'...\n']);
    tempim2=double(CCs{ind});
    
    temp1=unique(trki{r(ind)});
    temp1 = nonzeros(temp1);
    sct{ind} = NaN(2,max(n));
    
    [a,b] = size(tempim2);
    z = zeros(a,b);
    np = 0;
    for i=1:a
        for j=1:b
            if BGMask{r(ind)}(i,j)==1
                np=np+1;
            end
        end
    end
    id = 1;
    if (np/(a*b)) > 0.50
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{r(ind)}==temp1(p)))-medianBGCitrine(ind)), std((tempim2(trki{r(ind)}==temp1(p)))-medianBGCitrine(ind))];
        end
        id = id+1;
    else
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{r(ind)}==temp1(p)))-mean(medianBGCitrine(1:id))), std((tempim2(trki{r(ind)}==temp1(p)))-mean(medianBGCitrine(1:id)))];
        end
    end
    
end

save([pDIC, '\Tracking\',ident,'_SingleCellTrackPerFrame.mat'], 'sct')

% Single cell data per cell

sct2 = cell(1,max(n));

for i=1:maxid/2
    for j=1:max(n)
        sct2{j}(:,i) = sct{i}(:,j);
    end
end

save([pDIC, '\Tracking\',ident,'_SingleCellTrackPerCell.mat'], 'sct2')

% Singel Cell Size
scts = {};
parfor ind=1:maxid/2
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



