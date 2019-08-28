
%% Save Images in Matlab Structures

% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS
% --------> obj,event: Arguments that need to be defined in the function
% for the timer scheduler function to work but do not need to do anything
% inside the function
% --------> pDIC: Directory were the microscope images are going to be
% saved.
% --------> cutcor: matrix indexes of the ROI.
% --------> ident: Identifier to be added to some temporary files
% -------->INP: 2xN matrix containing the time vector and input values
% applied during the experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS
% --------> 

function [CDs, CCs, Segs, BGMask] = SaveImgMat(pDIC,ident)

%% Cut Images

filePattern1 = fullfile([pDIC,'\CutDIC'], 'exp*DIC_001.png');
filePattern2 = fullfile([pDIC,'\CutCitrine'], 'exp*mCitrineTeal_001.png');
Files1 = dir(filePattern1);
Files2 = dir(filePattern2);
% Get number of frames for channel
maxidD=length(Files1);
maxidC=length(Files2);

CDs=cell(1,maxidD);
CCs=cell(1,maxidC);

parfor i=1:maxidD % DIC images
    num = num2str(i,'%.3u');
    CDs{i} = imread([pDIC,'\CutDIC\exp_000',num,'_DIC_001.png']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO CHECK FOR WORK
if str2double(Files1(1).name(5:10)) == str2double(Files2(1).name(5:10))
    r=str2double(Files1(1).name(5:10)):str2double(Files1(1).name(5:10)):maxidD;
else
    r=str2double(Files2(1).name(5:10)):str2double(Files2(1).name(5:10)):maxidD;
end

% r = 2:2:maxidD;
parfor i=1:maxidC % Citrine Images
    num = num2str(r(i),'%.3u');
    CCs{i} = imread([pDIC,'\CutCitrine\exp_000',num,'_mCitrineTeal_001.png']);
end

save([pDIC, '\',ident,'-CutImages.mat'], 'CDs', 'CCs')

%% Masks
filePattern3 = fullfile([pDIC,'\Segmentation'], 'exp*DIC_001.tif');
Files3 = dir(filePattern3);
% Get number of frames for channel
maxidM=length(Files3);

Segs=cell(1,maxidM);
parfor i=1:maxidM
    num = num2str(i,'%.3u');
    Segs{i}=imread([pDIC,'\Segmentation\exp_000',num,'_DIC_001.tif']);
end
save([pDIC,'\',ident,'_SegmentationMask.mat'], 'Segs')


%% Background
filePattern4 = fullfile([pDIC,'\Segmentation'], 'BKG-exp_000*_DIC_001.tif');
Files4 = dir(filePattern4);
% Get number of frames for channel
maxidB=length(Files4);

BGMask=cell(1,maxidB);
parfor i=1:maxidB
    num = num2str(i,'%.3u');
    BGMask{i}=imread([pDIC,'\Segmentation\BKG-exp_000',num,'_DIC_001.tif']);
end

save([pDIC,'\',ident,'_BackGroundMask.mat'], 'BGMask')


end









