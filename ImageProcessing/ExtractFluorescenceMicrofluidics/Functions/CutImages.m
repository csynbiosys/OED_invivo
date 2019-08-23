%% Cut Images Funtion

% This function reads all the images from a specific microfluidic
% experiment and cuts the ROI in the chamber for DIC and fluorescence
% images. 

% --------> direct: Directory path where the images are saved (string)
% --------> pos: positions where the images are going to be cut. This needs
% to be a (1,4) vector ordered as minx, maxx, miny, maxy
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> pat: patern of the images names to keep track on the number of
% frames that are in the folder


function [] = CutImages(direct, pos, ident ,pat)

% Get Directory of images 
Folder=[direct];
filePattern = fullfile(Folder, pat);
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Read Images
Ds=cell(maxid,1);
Cs=cell(maxid,1);

if isempty(gcp('nocreate'))
    for ind=1:maxid
        Ds{ind}=imread(num2str(ind,'exp_000%.3u_DIC_001.png'));
        Cs{ind}=imread(num2str(ind,'exp_000%.3u_mCitrineTeal_001.png'));
    end
else
    parfor ind=1:maxid
        Ds{ind}=imread(num2str(ind,'exp_000%.3u_DIC_001.png'));
        Cs{ind}=imread(num2str(ind,'exp_000%.3u_mCitrineTeal_001.png'));
    end
end

% Cut Images
minx=pos(1);
maxx=pos(2);
miny=pos(3);
maxy=pos(4);

CDs=cell(maxid,1);
CCs=cell(maxid,1);

if isempty(gcp('nocreate'))
    for ind=1:maxid
        CDs{ind}=Ds{ind}(miny:maxy,minx:maxx);
        CCs{ind}=Cs{ind}(miny:maxy,minx:maxx);
    end
else
    parfor ind=1:maxid
        CDs{ind}=Ds{ind}(miny:maxy,minx:maxx);
        CCs{ind}=Cs{ind}(miny:maxy,minx:maxx);
    end
end


if ~exist([direct,'\CutDIC'],'dir')
    mkdir([direct,'\CutDIC']);
    addpath([direct,'\CutDIC']);
end
if ~exist([direct,'\CutFluo'],'dir')
    mkdir([direct,'\CutFluo']);
    addpath([direct,'\CutDIC']);
end

parfor ind=1:maxid
    imwrite(CDs{ind},[direct,'\CutDIC\',num2str(ind,'DIC_Frame%.3u.png')]);
    imwrite(CCs{ind},[direct,'\CutFluo\',num2str(ind,'Fluo_Frame%.3u.png')]);
end

save([direct,'\',ident,'-CutImages.mat'],'Ds','Cs','CDs','CCs');

end






