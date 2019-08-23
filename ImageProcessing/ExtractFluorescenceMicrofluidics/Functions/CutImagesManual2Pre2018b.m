%% Cut Images Funtion 2 (Manual selection of axis in image)

% This function reads all the images from a specific microfluidic
% experiment and cuts the ROI in the chamber for DIC and fluorescence
% images. 

% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> pat: patern of the images names to keep track on the number of
% frames that are in the folder


function [] = CutImagesManual2Pre2018b(direct, ident ,pat)

% Get Directory of images 
Folder=[direct];
filePattern = fullfile(Folder, pat);
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Read Images
Ds=cell(maxid,1);
Cs=cell(maxid/2,1);
Ss=cell(maxid/2,1);

% if isempty(gcp('nocreate'))
    for ind=1:maxid
        num = num2str(ind,'%.3u');
        Ds{ind}=imread([direct,'\exp_000',num,'_DIC_001.png']);
    end
% else
%     parfor ind=1:maxid
%         num = num2str(ind,'%.3u');
%         Ds{ind}=imread([direct,'\exp_000',num,'_DIC_001.png']);
%     end
% end

i=1;
for ind=2:2:maxid
    num = num2str(ind,'%.3u');
    Cs{i}=imread([direct,'\exp_000',num,'_mCitrineTeal_001.png']);
    Ss{i}=imread([direct,'\exp_000',num,'_Sulforhodamine_001.png']);
    i=i+1;
end

% Cut Images
figure;
s = imshow(mat2gray(Ds{1}));
hBox = imrect();
message = sprintf('Finished??');
uiwait(msgbox(message));% roiPosition = wait(hBox);
roiPosition=round(hBox.getPosition);
close


CDs=cell(maxid,1);
CCs=cell(maxid/2,1);
CSs=cell(maxid/2,1);

cutcor = [roiPosition(2), roiPosition(2)+(roiPosition(4)-1), roiPosition(1), roiPosition(1)+(roiPosition(3)-1)];

% if isempty(gcp('nocreate'))
    for ind=1:maxid
        CDs{ind}=Ds{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
    end
% else
%     parfor ind=1:maxid
%         CDs{ind}=Ds{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
%     end
% end


parfor ind=1:maxid/2
    CCs{ind}=Cs{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
    CSs{ind}=Ss{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
end


if ~exist([direct,'\CutDIC'],'dir')
    mkdir([direct,'\CutDIC']);
    addpath([direct,'\CutDIC']);
end
if ~exist([direct,'\CutFluo'],'dir')
    mkdir([direct,'\CutFluo']);
    addpath([direct,'\CutFluo']);
end
if ~exist([direct,'\CutSulf'],'dir')
    mkdir([direct,'\CutSulf']);
    addpath([direct,'\CutSulf']);
end

parfor ind=1:maxid
    imwrite(CDs{ind},[direct,'\CutDIC\',num2str(ind,'DIC_Frame%.3u.png')]);
end
i=1;
for ind=2:2:maxid
    imwrite(CCs{i},[direct,'\CutFluo\',num2str(ind,'Fluo_Frame%.3u.png')]);
    imwrite(CSs{i},[direct,'\CutSulf\',num2str(ind,'Sulf_Frame%.3u.png')]);
    i=i+1;
end

save([direct,'\',ident,'-CutImages.mat'],'Ds','Cs','Ss','CDs','CCs','CSs','cutcor');

end






