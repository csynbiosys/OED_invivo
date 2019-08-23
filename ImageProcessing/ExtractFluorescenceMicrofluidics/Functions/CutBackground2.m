%% Cut Images Funtion 2 (Manual selection of axis in image)

% This function reads all the images from a specific microfluidic
% experiment and cuts the ROI in the chamber for DIC and fluorescence
% images. 

% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> pat: patern of the images names to keep track on the number of
% frames that are in the folder


function [] = CutBackground2(direct, ident ,pat)

% Get Directory of images 
Folder=[direct];
filePattern = fullfile(Folder, pat);
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Read Images
bDs=cell(maxid,1);
bCs=cell(maxid/2,1);

% if isempty(gcp('nocreate'))
    for ind=1:maxid
        num = num2str(ind,'%.3u');
        bDs{ind}=imread([direct,'\exp_000',num,'_DIC_001.png']);
    end
% else
%     parfor ind=1:maxid
%         num = num2str(ind,'%.3u');
%         bDs{ind}=imread([direct,'\exp_000',num,'_DIC_001.png']);
%     end
% end

i=1;
for ind=2:2:maxid
    num = num2str(ind,'%.3u');
    bCs{i}=imread([direct,'\exp_000',num,'_mCitrineTeal_001.png']);
    i=i+1;
end

% Cut Images
figure;
s = imshow(mat2gray(bDs{1}));
hBox = drawrectangle();
message = sprintf('Finished??');
uiwait(msgbox(message));% roiPosition = wait(hBox);
roiPosition=round(hBox.Position);
close


bCDs=cell(maxid,1);
bCCs=cell(maxid/2,1);

if isempty(gcp('nocreate'))
    for ind=1:maxid
        bCDs{ind}=bDs{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
    end
else
    parfor ind=1:maxid
        bCDs{ind}=bDs{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
    end
end


parfor ind=1:maxid/2
    bCCs{ind}=bCs{ind}(roiPosition(2)+(0:roiPosition(4)-1),roiPosition(1)+(0:roiPosition(3)-1));
end



save([direct,'\',ident,'-CutBackground.mat'],'bCDs','bCCs');

end






