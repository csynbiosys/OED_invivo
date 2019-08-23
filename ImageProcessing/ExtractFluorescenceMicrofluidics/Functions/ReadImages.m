%% Cut Images Funtion

% This function reads all the images from a specific microfluidic
% experiment and cuts the ROI in the chamber for DIC and fluorescence
% images. 

% --------> direct: Directory path where the images are saved (string)
% --------> pos: positions where the images are going to be cut. This needs
% to be a (1,4) vector ordered as minx, maxx, miny, maxy
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)


function [] = ReadImages(directC, direct, ident, pat)

% Get Directory of images 
Folder=[directC];
filePattern = fullfile(Folder, pat);
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Read Images
CDs=cell(maxid,1);
CCs=cell(maxid,1);

if isempty(gcp('nocreate'))
    for ind=1:maxid
        CDs{ind}=imread(num2str(ind,'DIC_Frame%.3u.png'));
        CCs{ind}=imread(num2str(ind,'Citrine_Frame%.3u.png'));
    end
else
    parfor ind=1:maxid
        CDs{ind}=imread(num2str(ind,'DIC_Frame%.3u.png'));
        CCs{ind}=imread(num2str(ind,'Citrine_Frame%.3u.png'));
    end
end

if ~exist([direct,'\CutDIC'],'dir')
    mkdir([direct,'\CutDIC']);
    addpath([direct,'\CutDIC']);
end
if ~exist([direct,'\CutFluo'],'dir')
    mkdir([direct,'\CutFluo']);
    addpath([direct,'\CutFluo']);
end

parfor ind=1:maxid
    imwrite(CDs{ind},[direct,'\CutDIC\',num2str(ind,'DIC_Frame%.3u.png')]);
    imwrite(CCs{ind},[direct,'\CutFluo\',num2str(ind,'Fluo_Frame%.3u.png')]);
end

save([direct,'\',ident,'-CutImages.mat'],'CDs','CCs');

end









