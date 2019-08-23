
%% Generate Background Masks
% Script to generate the background masks from the segmentation results
% (inverse of the binary mask)

% INPUTS
% --------> direct: Directory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)

%OUTPUTS
% --------> Segs: Matlab structure containing all the segmented masks
% --------> BGMask: Matlab structure containing all the background masks

function [Segs,BGMask] = generateBackgroundMask(direct, ident)

% Get Directory of images 
dir1 = [direct,'\Segmentation'];
Folder=dir1;
filePattern = fullfile(Folder, strcat('DIC_Frame*'));
Files = dir(filePattern);
% Get number of frames for channel
maxid=length(Files);

% Get segmentations masks
Segs=cell(maxid,1);
BGMask=cell(maxid,1);

parfor ind=1:maxid
    Segs{ind}=imread([dir1,'\',num2str(ind,'DIC_Frame%.3u.tif')]);
end

% Generate Background masks

for i=1:maxid
    x = Segs{i};
    [d,f] = size(x);
    z = zeros(d,f);
    
    for k=1:d
        for j=1:f
            if x(k,j)==0
                z(k,j) = true;
            else
                z(k,j) = false;
            end
        end
    end
    BGMask{i} = z;
end

save([dir1,'\',ident,'_BackGroundMask.mat'], 'BGMask')
save([dir1,'\',ident,'_SegmentationMask.mat'], 'Segs')


end



























