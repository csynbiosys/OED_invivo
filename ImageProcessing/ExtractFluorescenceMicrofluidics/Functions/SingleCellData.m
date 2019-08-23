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

function [sct,sct2,scts] = SingleCellData(direct, ident, pat)

% Get Directory of images 
Folder=[direct];
filePattern = fullfile(Folder, '\CutDIC\',pat);
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Load tracking results
trki = cell(1,maxid);
for i=1:maxid
    strind=num2str(i,'%.3u');
    x = imread([direct, '\Tracking\trk-img_',strind,'.tif']);
    trki{i}=x;
end

save([direct, '\Tracking\',ident,'_TrakedMasks2.mat'], 'trki')

% Number of cells
n=cellfun(@(seg) max(seg(:)),trki);

% Empty cells with the results
medianBGCitrine=nan(maxid,1);
whenFull=nan;

% Load Cut Citrine images and Background images
load([direct,'\',ident,'-CutImages.mat'], 'CCs');%CCs=CCs.CTs;
load([direct,'\Segmentation\',ident,'_BackGroundMask.mat']);

% Compute Background intensity
for ind=1:maxid
    tempim2=double(CCs{ind});
    
    if (isnan(whenFull))
        medianBGCitrine(ind)=median(tempim2(logical(BGMask{ind})));
        if (mean(double(logical(BGMask{ind}(:))))<0.25)
            meanBGCitrine=mean(medianBGCitrine,'omitnan');
            whenFull=ind;
            break;
        end
    end
end

meanBGCitrineNew=mean(medianBGCitrine,'omitnan');

% Singel Cell Data per frame
sct = {};

parfor ind=1:maxid
    strind=num2str(ind,'%.3u');
    fprintf(['Processing frame ',strind,'...\n']);
    tempim2=double(CCs{ind});
    
    temp1=unique(trki{ind});
    temp1 = nonzeros(temp1);
    sct{ind} = NaN(2,max(n));
    
    [a,b] = size(tempim2);
    z = zeros(a,b);
    np = 0;
    for i=1:a
        for j=1:b
            if BGMask{ind}(i,j)==1
                np=np+1;
            end
        end
    end
    id = 1;
    if (np/(a*b)) > 0.50
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{ind}==temp1(p)))-medianBGCitrine(ind)), std((tempim2(trki{ind}==temp1(p)))-medianBGCitrine(ind))];
        end
        id = id+1;
    else
        for p=1:length(temp1)
            sct{ind}(:,temp1(p)) = [mean((tempim2(trki{ind}==temp1(p)))-mean(medianBGCitrine(1:id))), std((tempim2(trki{ind}==temp1(p)))-mean(medianBGCitrine(1:id)))];
        end
    end
    
    
end

save([direct, '\Tracking\',ident,'_SingleCellTrackPerFrame.mat'], 'sct')

% Single cell data per cell

sct2 = {};

for i=1:maxid
    for j=1:max(n)
        sct2{j}(:,i) = sct{i}(:,j);
    end
end

save([direct, '\Tracking\',ident,'_SingleCellTrackPerCell.mat'], 'sct2')

% Singel Cell Size
scts = {};
parfor ind=1:maxid
    strind=num2str(ind,'%.3u');
    tempim2=double(CCs{ind});
    
    temp1=unique(trki{ind});
    temp1 = nonzeros(temp1);
    scts{ind} = NaN(1,max(n));
    
    
    for p=1:length(temp1)
        scts{ind}(:,temp1(p)) = length((tempim2(trki{ind}==temp1(p))));
    end
        
end

save([direct, '\Tracking\',ident,'_SingleCellTracSize.mat'], 'scts')


end



