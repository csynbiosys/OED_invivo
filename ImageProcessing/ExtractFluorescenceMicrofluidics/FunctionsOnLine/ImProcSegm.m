
%% Image processing by frame

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


function [] = ImProcSegm(obj, event, cutcor, pDIC, ident, INP)

%% Generate necessary directories if they do not exist
if ~exist([pDIC,'\Segmentation'],'dir')
    mkdir([pDIC,'\Segmentation']);
    addpath([pDIC,'\Segmentation']);
end
if ~exist([pDIC,'\CutDIC'],'dir')
    mkdir([pDIC,'\CutDIC']);
    addpath([pDIC,'\CutDIC']);
end
if ~exist([pDIC,'\CutCitrine'],'dir')
    mkdir([pDIC,'\CutCitrine']);
    addpath([pDIC,'\CutCitrine']);
end
if ~exist([pDIC,'\CutSulf'],'dir')
    mkdir([pDIC,'\CutSulf']);
    addpath([pDIC,'\CutSulf']);
end
if ~exist([pDIC,'\Segmentation\Components'],'dir')
    mkdir([pDIC,'\Segmentation\Components']);
    addpath([pDIC,'\Segmentation\Components']);
end

%% Cut Images
% Get names of current images 
filePattern1 = fullfile(pDIC, 'exp*DIC_001.png');
filePattern2 = fullfile(pDIC, 'exp*mCitrineTeal_001.png');
filePattern3 = fullfile(pDIC, 'exp*Sulforhodamine_001.png');
Files1 = dir(filePattern1);
Files2 = dir(filePattern2);
Files3 = dir(filePattern3);
% Get number of frames for channel
maxidD=length(Files1);
maxidC=length(Files2);
maxidS=length(Files3);

% Check if frame has been already cut and if not, cut image and save it
for i=1:maxidD % Cut DIC images
    if ~isfile([pDIC,'\CutDIC\',Files1(i).name])
        temp1 = imread([pDIC,'\',Files1(i).name]);
        temp2 = temp1(cutcor(1):cutcor(2),cutcor(3):cutcor(4));
        imwrite(temp2, [pDIC,'\CutDIC\',Files1(i).name])
    end
end

for i=1:maxidC % Cut Citrine images
    if ~isfile([pDIC,'\CutCitrine\',Files2(i).name])
        temp1 = imread([pDIC,'\',Files2(i).name]);
        temp2 = temp1(cutcor(1):cutcor(2),cutcor(3):cutcor(4));
        imwrite(temp2, [pDIC,'\CutCitrine\',Files2(i).name])
    end
end

for i=1:maxidS % Cut Sulforodamine images
    if ~isfile([pDIC,'\CutSulf\',Files3(i).name])
        temp1 = imread([pDIC,'\',Files3(i).name]);
        temp2 = temp1(cutcor(1):cutcor(2),cutcor(3):cutcor(4));
        imwrite(temp2, [pDIC,'\CutSulf\',Files3(i).name])
    end
end

%% Segmentation

% Run UNet segmentation Macro code
IJ=ij.IJ();
macro_path = [pDIC,'\Segmentation'];
IJ.runMacroFile(java.lang.String(fullfile(macro_path,[ident,'-MacroSegmentation.ijm'])));

%% Generate Background masks
% Get names of current images 
filePattern4 = fullfile([pDIC,'\Segmentation'], 'exp*DIC_001.tif');
Files4 = dir(filePattern4);

% Get number of frames for channel
maxidM=length(Files4);

% Check if masks have been reverted (inverse binary) and if no, do it and
% save it with the identifier BKG
for i=1:maxidM % Cut DIC images
    if ~isfile([pDIC,'\Segmentation\BKG-',Files4(i).name])
        temp1 = imread([pDIC,'\Segmentation\',Files4(i).name]);
        [d,f] = size(temp1);
        z = zeros(d,f);
        for k=1:d
            for j=1:f
                if temp1(k,j)==0
                    z(k,j) = true;
                else
                    z(k,j) = false;
                end
            end
        end
        imwrite(z, [pDIC,'\Segmentation\BKG-',Files4(i).name])
    end
end

%% Indexing masks
% Get names of current images 
filePattern4 = fullfile([pDIC,'\Segmentation'], 'exp*DIC_001.tif');
Files4 = dir(filePattern4);

% Get number of frames for channel
maxidM=length(Files4);

for i=1:maxidM 
    if ~isfile([pDIC,'\Segmentation\Components\IndexMask-',Files4(i).name])
        
        x = imread([pDIC,'\Segmentation\',Files4(i).name]);
        [x,y] = CorrectSegmentsFull(x);
        x2 = mat2gray(x);
        L = bwlabel(x2,4);
        L = ResizeIm(L,y);
        f = L;
        save([pDIC,'\Segmentation\Components\Segment',int2str(i),'.mat'], 'f')
        
        % Generate Python script with all the specifications
        num = num2str(i,'%.3u');
        fil = fopen([pDIC,'\Segmentation\Components\',ident,'-PythonAnotateImage.py'], 'w');

        fprintf(fil, '# -*- coding: utf-8 -*-');
        fprintf(fil, '\n');
        fprintf(fil, 'import scipy');
        fprintf(fil, '\n');
        fprintf(fil, 'from os.path import dirname, join as pjoin');
        fprintf(fil, '\n');
        fprintf(fil, 'import scipy.io as sio');
        fprintf(fil, '\n');
        fprintf(fil, 'from PIL import Image');
        fprintf(fil, '\n');
        fprintf(fil, 'import numpy as np');
        fprintf(fil, '\n \n');

        dir1 = strrep([pDIC,'\Segmentation'],'\2','\\2');
        dir1 = strrep(dir1,'\','\\');
        fprintf(fil, ['im = sio.loadmat(''',dir1,'\\Components\\Segment',num2str(i), '.mat'')']);

        fprintf(fil, '\n');
        fprintf(fil, 'k = im[''f'']');
        fprintf(fil, '\n');
        fprintf(fil, 'img = Image.fromarray(k)');
        fprintf(fil, '\n');
        fprintf(fil, ['img.save(''',dir1,'\\Components\\img_',num,'.tif'')']);
        fprintf(fil, '\n');
        fprintf(fil, '\n');

        fclose(fil);
        
        % Run Python script
        system(['python ',pDIC,'\Segmentation\Components\',ident,'-PythonAnotateImage.py']);
    end
end


%% Temporary Fluorescence data extraction

load([pDIC,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');
load([pDIC,'\Segmentation\TemporaryBackground.mat'],'tBKGround');
load([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');

r = 2:2:maxidD;
for i=1:maxidC % Cut DIC images
    if isnan(tfluo(1,i))
        num = num2str(r(i),'%.3u');
        tBKG=imread([pDIC,'\Segmentation\BKG-',Files4(r(i)).name]); % Background image
        tSegs=imread([pDIC,'\Segmentation\Components\img_',num,'.tif']); % Mask
        tCitr=double(imread([pDIC,'\CutCitrine\exp_000',num,'_mCitrineTeal_001.png'])); % Cut citrine image
        
        % Compute Background intensity
        tBKGround(i)=median(tCitr(logical(tBKG))); % Compute Background
        
        [a,b] = size(tSegs); % Compute percentage of pixels from background
        np = 0;
        for q=1:a
            for w=1:b
                if logical(tBKG(q,w))==1
                    np=np+1;
                end
            end
        end
        
        if (np/(a*b)) > 0.50
            tBKGroundS(i)=tBKGround(i);   % Save background value if condition is meet for the exception 
            
            me1 = nan(1,length(unique(tSegs))-1); % Store mean fluorescence values per cell
            for j=1:(length(unique(tSegs))-1)
                me1(j)=mean(tCitr(tSegs==j)-tBKGround(i),'omitnan');
            end
            
            
            tfluo(1,i)=mean(me1,'omitnan'); % Mean and standard deviation fluorescence value of the image
            tfluo(2,i)=std(me1,'omitnan');
            
        else
            me1 = nan(1,length(unique(tSegs))-1);
            for j=1:(length(unique(tSegs))-1)
                me1(j)=mean(tCitr(tSegs==j)-mean(tBKGroundS,'omitnan'),'omitnan');
            end
            tfluo(1,i)=mean(me1,'omitnan');
            tfluo(2,i)=std(me1,'omitnan');
            
        end
        
    end
end


save([pDIC,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');
save([pDIC,'\Segmentation\TemporaryBackground.mat'],'tBKGround');
save([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');


%% Plot results

time = 0:5:(length(tfluo)-1)*5;
% figure;
hold on
yyaxis left
errorbar(time, tfluo(1,:), tfluo(2,:), 'g'); % Fluorescence Levels
title('Temporary Fluorescence')
xlabel('time(min)')
ylabel('Citrine(A.U.)')

yyaxis right
stairs(INP(2,:), INP(1,:), 'b') % Input design
ylabel('IPTG(uM)')

hold off


end






