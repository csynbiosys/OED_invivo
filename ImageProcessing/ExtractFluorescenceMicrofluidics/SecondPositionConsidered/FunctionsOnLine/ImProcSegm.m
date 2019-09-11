
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


function [] = ImProcSegm(obj, event, cutcor, pDIC, ident, INP, CitFreq, DicFreq, datenow, bacpat, cutcorBACK1, cutcorBACK2)

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

if ~isempty(cutcorBACK1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist([bacpat,'\CutDICBackOne'],'dir')
        mkdir([bacpat,'\CutDICBackOne']);                         %
        addpath([bacpat,'\CutDICBackOne']);
    end                                                        %
    if ~exist([bacpat,'\CutDICBackTwo'],'dir') && ~isempty(cutcorBACK2)
        mkdir([bacpat,'\CutDICBackTwo']);                         %
        addpath([bacpat,'\CutDICBackTwo']);
    end                                                        % SECOND POSITION
    if ~exist([bacpat,'\CutCitrineBackOne'],'dir')
        mkdir([bacpat,'\CutCitrineBackOne']);                         %
        addpath([bacpat,'\CutCitrineBackOne']);
    end                                                        %
    if ~exist([bacpat,'\CutCitrineBackTwo'],'dir') && ~isempty(cutcorBACK2)
        mkdir([bacpat,'\CutCitrineBackTwo']);                         %
        addpath([bacpat,'\CutCitrineBackTwo']);
    end                              
    if ~exist([bacpat,'\CutSulfBackOne'],'dir')
        mkdir([bacpat,'\CutSulfBackOne']);                         %
        addpath([bacpat,'\CutSulfBackOne']);
    end                                                        %
    if ~exist([bacpat,'\CutSulfBackTwo'],'dir') && ~isempty(cutcorBACK2)
        mkdir([bacpat,'\CutSulfBackTwo']);                         %
        addpath([bacpat,'\CutSulfBackTwo']);
    end                              
    if ~exist([bacpat,'\SegmentationOne'],'dir')
        mkdir([bacpat,'\SegmentationOne']);                    %
        addpath([bacpat,'\SegmentationOne']);
    end                                                        %                      
    if ~exist([bacpat,'\SegmentationTwo'],'dir') && ~isempty(cutcorBACK2)
        mkdir([bacpat,'\SegmentationTwo']);                    %
        addpath([bacpat,'\SegmentationTwo']);
    end                                                        %
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

try
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


%% Cut Images Background %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SECOND POSITION
% Get names of current images 

if ~isempty(cutcorBACK1)
    filePattern1b = fullfile(bacpat, 'exp*DIC_001.png');
    filePattern2b = fullfile(bacpat, 'exp*mCitrineTeal_001.png');
    filePattern3b = fullfile(bacpat, 'exp*Sulforhodamine_001.png');
    Files1b = dir(filePattern1b);
    Files2b = dir(filePattern2b);
    Files3b = dir(filePattern3b);
    % Get number of frames for channel
    maxidDb=length(Files1b);
    maxidCb=length(Files2b);
    maxidSb=length(Files3b);

    % Check if frame has been already cut and if not, cut image and save it
    for i=1:maxidDb % Cut DIC images
        if ~isfile([bacpat,'\CutDICBackOne\',Files1b(i).name])
            temp1 = imread([bacpat,'\',Files1b(i).name]);
            temp2 = temp1(cutcorBACK1(1):cutcorBACK1(2),cutcorBACK1(3):cutcorBACK1(4));
            imwrite(temp2, [bacpat,'\CutDICBackOne\',Files1b(i).name])
        end
        if ~isfile([bacpat,'\CutDICBackTwo\',Files1b(i).name]) && ~isempty(cutcorBACK2)
            temp1 = imread([bacpat,'\',Files1b(i).name]);
            temp2 = temp1(cutcorBACK2(1):cutcorBACK2(2),cutcorBACK2(3):cutcorBACK2(4));
            imwrite(temp2, [bacpat,'\CutDICBackTwo\',Files1b(i).name])
        end
    end

    for i=1:maxidCb % Cut Citrine images
        if ~isfile([bacpat,'\CutCitrineBackOne\',Files2b(i).name])
            temp1 = imread([bacpat,'\',Files2b(i).name]);
            temp2 = temp1(cutcorBACK1(1):cutcorBACK1(2),cutcorBACK1(3):cutcorBACK1(4));
            imwrite(temp2, [bacpat,'\CutCitrineBackOne\',Files2b(i).name])
        end
        if ~isfile([bacpat,'\CutCitrineBackTwo\',Files2b(i).name]) && ~isempty(cutcorBACK2)
            temp1 = imread([bacpat,'\',Files2b(i).name]);
            temp2 = temp1(cutcorBACK2(1):cutcorBACK2(2),cutcorBACK2(3):cutcorBACK2(4));
            imwrite(temp2, [bacpat,'\CutCitrineBackTwo\',Files2b(i).name])
        end
    end

    for i=1:maxidSb % Cut Sulforodamine images
        if ~isfile([bacpat,'\CutSulfBackOne\',Files3b(i).name])
            temp1 = imread([bacpat,'\',Files3b(i).name]);
            temp2 = temp1(cutcorBACK1(1):cutcorBACK1(2),cutcorBACK1(3):cutcorBACK1(4));
            imwrite(temp2, [bacpat,'\CutSulfBackOne\',Files3b(i).name])
        end
        if ~isfile([bacpat,'\CutSulfBackTwo\',Files3b(i).name]) && ~isempty(cutcorBACK2)
            temp1 = imread([bacpat,'\',Files3b(i).name]);
            temp2 = temp1(cutcorBACK2(1):cutcorBACK2(2),cutcorBACK2(3):cutcorBACK2(4));
            imwrite(temp2, [bacpat,'\CutSulfBackTwo\',Files3b(i).name])
        end
    end
end

%% Segmentation

% Run UNet segmentation Macro code


IJ=ij.IJ();
macro_path = [pDIC,'\Segmentation'];
IJ.runMacroFile(java.lang.String(fullfile(macro_path,[ident,'-MacroSegmentation.ijm'])));

if ~isempty(cutcorBACK1)
    macro_pathb1 = [bacpat,'\SegmentationOne'];
    IJ.runMacroFile(java.lang.String(fullfile(macro_pathb1,[ident,'-MacroSegmentationBackOne.ijm'])));
    if ~isempty(cutcorBACK2)
        macro_pathb2 = [bacpat,'\SegmentationTwo'];
        IJ.runMacroFile(java.lang.String(fullfile(macro_pathb2,[ident,'-MacroSegmentationBackTwo.ijm'])));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%% Exceptions to check if UNet has worked 
%%%%%%%%%%%%%%%%%%%%%%%%%% 

masknam = strrep(Files1(end).name,'png','tif');
tempmask = imread([pDIC,'\Segmentation\', masknam]);

if length(unique(tempmask))>3
    delete([pDIC,'\Segmentation\', masknam])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SECOND POSITION
if ~isempty(cutcorBACK1)
    masknama = strrep(Files1b(end).name,'png','tif');
    tempmaska = imread([bacpat,'\SegmentationOne\', masknama]);

    if length(unique(tempmaska))>3
        delete([bacpat,'\SegmentationOne\', masknama])
    end
    if ~isempty(cutcorBACK2)
        masknamb = strrep(Files1b(end).name,'png','tif');
        tempmaskb = imread([bacpat,'\SegmentationTwo\', masknamb]);

        if length(unique(tempmaskb))>3
            delete([bacpat,'\SegmentationTwo\', masknamb])
        end
    end
end

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

%% Compute background sulforhodamine levels
load([pDIC,'\Segmentation\TemporarySulforodamine.mat'],'tSulf');
r = 1:CitFreq/DicFreq:maxidD;

if ~isempty(cutcorBACK1)
    load([bacpat,'\SegmentationOne\TemporaryCellCount.mat'],'cBacka');    
    for i=1:maxidS % Cut DIC images
        if isnan(tSulf(1,i))
            num = num2str(r(i),'%.3u');
            sul = imread([bacpat,'\CutSulfBackOne\exp_000',num,'_Sulforhodamine_001.png']);
            sul21 = imread([bacpat,'\SegmentationOne\exp_000',num,'_DIC_001.tif']);    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Patch for segmentation issues when there is no cells
            L = bwlabel(sul21,4);
            cBacka(i)=length(unique(L));
            if i<360/CitFreq && cBacka(i)>100
                sul21=sul21*0;
            elseif i>=360/CitFreq && isempty(find((cBacka<100)==1))
                sul21=sul21*0;
            end
            save([bacpat,'\SegmentationOne\TemporaryCellCount.mat'],'cBacka');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            sulvec = double(sul(sul21==0));
            if ~isempty(cutcorBACK2)
                load([bacpat,'\SegmentationTwo\TemporaryCellCount.mat'],'cBackb');
                
                sulb = imread([bacpat,'\CutSulfBackTwo\exp_000',num,'_Sulforhodamine_001.png']);
                sul21b = imread([bacpat,'\SegmentationTwo\exp_000',num,'_DIC_001.tif']);    
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Patch for segmentation issues when there is no cells
                L = bwlabel(sul21b,4);
                cBackb(i)=length(unique(L));
                if i<360/CitFreq && cBackb(i)>100
                    sul21b=sul21b*0;
                elseif i>=360/CitFreq && isempty(find((cBackb<100)==1))
                    sul21b=sul21b*0;
                end
                save([bacpat,'\SegmentationTwo\TemporaryCellCount.mat'],'cBackb');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                sulvecb = double(sulb(sul21b==0));
                sulvec=[sulvec;sulvecb];
            end
            tSulf(i)=median(sulvec);
        end
    end
else
    for i=1:maxidS % Cut DIC images
        if isnan(tSulf(1,i))
            num = num2str(r(i),'%.3u');
            sul = imread([pDIC,'\CutSulf\exp_000',num,'_Sulforhodamine_001.png']);
            sul21 = imread([pDIC,'\Segmentation\exp_000',num,'_DIC_001.tif']);
            tSulf(i)=median(sul(logical(sul21)));
        end
    end
end
save([pDIC,'\Segmentation\TemporarySulforodamine.mat'],'tSulf');

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

        dir1 = strrep([pDIC,'\Segmentation'],'\1','\\1');
        dir1 = strrep([dir1],'\2','\\2');
        dir1 = strrep([dir1],'\3','\\3');
        dir1 = strrep([dir1],'\4','\\4');
        dir1 = strrep([dir1],'\5','\\5');
        dir1 = strrep([dir1],'\6','\\6');
        dir1 = strrep([dir1],'\7','\\7');
        dir1 = strrep([dir1],'\8','\\8');
        dir1 = strrep([dir1],'\9','\\9');
        dir1 = strrep([dir1],'\0','\\0');
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
        addpath 'D:\David\python'
        addpath 'C:\Program Files\MATLAB\R2018b\bin\win64'
        system(['python "',pDIC,'\Segmentation\Components\',ident,'-PythonAnotateImage.py"']);
    end
end


%% Temporary Fluorescence data extraction

load([pDIC,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');
load([pDIC,'\Segmentation\TemporaryBackground.mat'],'tBKGround');
load([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');

r = 1:CitFreq/DicFreq:maxidD;
if isempty(cutcorBACK1)
    for i=1:maxidC % Cut DIC images
        if isnan(tfluo(1,i))
            num = num2str(r(i),'%.3u');
            tBKG=imread([pDIC,'\Segmentation\BKG-',Files4(r(i)).name]); % Background image
            tSegs=imread([pDIC,'\Segmentation\Components\img_',num,'.tif']); % Mask
            tCitr=double(imread([pDIC,'\CutCitrine\exp_000',num,'_mCitrineTeal_001.png'])); % Cut citrine image

            % Compute Background intensity
            tBKGround(i)=mean(tCitr(logical(tBKG))); % Compute Background

            [a,b] = size(tSegs); % Compute percentage of pixels from background
            np = length(tCitr(logical(tBKG)==1));
            
            if (np/(a*b)) > 0.60
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
                    me1(j)=mean(tCitr(tSegs==j)-mean(tBKGroundS(1:end),'omitnan'),'omitnan');
                end
                tfluo(1,i)=mean(me1,'omitnan');
                tfluo(2,i)=std(me1,'omitnan');

            end

        end
    end
else
    for i=1:maxidC
        if isnan(tfluo(1,i))
            num = num2str(r(i),'%.3u');
%             Background
            tSegsBACK=imread([bacpat,'\SegmentationOne\',Files4(r(i)).name]); % Background image
            tCitrBACK=double(imread([bacpat,'\CutCitrineBackOne\exp_000',num,'_mCitrineTeal_001.png'])); % Cut citrine image
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Patch for segmentation issues when there is no cells
            firdrop = find((cBacka<100)==1);
            if i<360/CitFreq && cBacka(i)>100
                tSegsBACK=tSegsBACK*0;
            elseif i>=360/CitFreq && firdrop(1)>=i
                tSegsBACK=tSegsBACK*0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Compute Background intensity
            ALLround=(tCitrBACK(tSegsBACK==0)); % Compute Background
            if ~isempty(cutcorBACK2)
                tSegsBACK2=imread([bacpat,'\SegmentationTwo\',Files4(r(i)).name]); % Background image
                tCitrBACK2=double(imread([bacpat,'\CutCitrineBackTwo\exp_000',num,'_mCitrineTeal_001.png'])); % Cut citrine image
                % Compute Background intensity
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Patch for segmentation issues when there is no cells
                firdropb = find((cBackb<100)==1);
                if i<360/CitFreq && cBackb(i)>100
                    tSegsBACK2=tSegsBACK2*0;
                elseif i>=360/CitFreq && firdropb(1)>=i
                    tSegsBACK2=tSegsBACK2*0;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                ALLround2=(tCitrBACK2(tSegsBACK2==0)); % Compute Background
            end
            
            % ROI
            tSegs=imread([pDIC,'\Segmentation\Components\img_',num,'.tif']); % Mask
            tCitr=double(imread([pDIC,'\CutCitrine\exp_000',num,'_mCitrineTeal_001.png'])); % Cut citrine image

            [a,b] = size(tSegsBACK); % Compute percentage of pixels from background
            np = length(tCitrBACK(tSegsBACK==0));
            if ~isempty(cutcorBACK2)
                [a2,b2] = size(tSegsBACK2); % Compute percentage of pixels from background
                np2 = length(tCitrBACK2(tSegsBACK2==0));
            end
            
            % Only first square of second position
            if ~isempty(cutcorBACK1) && isempty(cutcorBACK2) && (np/(a*b))>=0.65
                tBKGround(i)=mean(ALLround); % Get mean of background pixels
                tBKGroundS(i)=tBKGround(i); % Stored in temporary vector that would be used for average if needed
            elseif ~isempty(cutcorBACK1) && isempty(cutcorBACK2) && (np/(a*b))>=0.45 && (np/(a*b))<0.65
                tSegsBACK = MorePix(tSegsBACK); % Add more pixels around the cells
                ALLround=(tCitrBACK(tSegsBACK==0)); % Get the background pixels again
                tBKGround(i)=mean(ALLround); 
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK1) && isempty(cutcorBACK2) && (np/(a*b))<0.45
                tBKGround(i)=mean(ALLround);
            
            % If there is a second square in the second position   
            % If second square is higher than 65%
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.65 && (np/(a*b))>=0.65
                tBKGround(i)=mean([ALLround; ALLround2]);
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.65 && (np/(a*b))>=0.40 && (np/(a*b))<0.65
                tSegsBACK = MorePix(tSegsBACK);
                ALLround=(tCitrBACK(tSegsBACK==0));
                tBKGround(i)=mean([ALLround; ALLround2]);
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.65 && (np/(a*b))<0.40
                tBKGround(i)=mean(ALLround2);
                tBKGroundS(i)=tBKGround(i);
                
            % If second square is between 65% and 35%    
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.40 && (np2/(a2*b2))<0.65 && (np/(a*b))>=0.65    
                tSegsBACK2 = MorePix(tSegsBACK2);
                ALLround2=(tCitrBACK2(tSegsBACK2==0));
                tBKGround(i)=mean([ALLround; ALLround2]);
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.40 && (np2/(a2*b2))<0.65 && (np/(a*b))>=0.40 && (np/(a*b))<0.65
                tSegsBACK2 = MorePix(tSegsBACK2);
                ALLround2=(tCitrBACK2(tSegsBACK2==0));
                tSegsBACK = MorePix(tSegsBACK);
                ALLround=(tCitrBACK(tSegsBACK==0));
                tBKGround(i)=mean([ALLround; ALLround2]);
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))>=0.40 && (np2/(a2*b2))<0.65 && (np/(a*b))<0.40
                tSegsBACK2 = MorePix(tSegsBACK2);
                ALLround2=(tCitrBACK2(tSegsBACK2==0));
                tBKGround(i)=mean(ALLround2);
                tBKGroundS(i)=tBKGround(i);
                
            % If second square is below 35%    
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))<0.40 && (np/(a*b))>=0.65
                tBKGround(i)=mean(ALLround); 
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))<0.40 && (np/(a*b))>=0.40 && (np/(a*b))<0.65
                tSegsBACK = MorePix(tSegsBACK); % Add more pixels around the cells
                ALLround=(tCitrBACK(tSegsBACK==0)); % Get the background pixels again
                tBKGround(i)=mean(ALLround); 
                tBKGroundS(i)=tBKGround(i);
            elseif ~isempty(cutcorBACK2) && (np2/(a2*b2))<0.40 && (np/(a*b))<0.40
                tBKGround(i)=mean([ALLround; ALLround2]);
            end
            
            
            % Extract cell fluorescence
            if ~isnan(tBKGroundS(i))
                me1 = nan(1,length(unique(tSegs))-1); % Store mean fluorescence values per cell
                for j=1:(length(unique(tSegs))-1)
                    me1(j)=mean(tCitr(tSegs==j)-tBKGround(i),'omitnan');
                end
                tfluo(1,i)=mean(me1,'omitnan'); % Mean and standard deviation fluorescence value of the image
                tfluo(2,i)=std(me1,'omitnan');
            elseif isnan(tBKGroundS(i))
                me1 = nan(1,length(unique(tSegs))-1);
                for j=1:(length(unique(tSegs))-1)
                    me1(j)=mean(tCitr(tSegs==j)-mean(tBKGroundS(1:end),'omitnan'),'omitnan');
                end
                tfluo(1,i)=mean(me1,'omitnan');
                tfluo(2,i)=std(me1,'omitnan');
            end

        end
    end
end

save([pDIC,'\Segmentation\TemporaryFluorescence.mat'],'tfluo');
save([pDIC,'\Segmentation\TemporaryBackground.mat'],'tBKGround');
save([pDIC,'\Segmentation\TemporaryBackgroundShort.mat'],'tBKGroundS');


%% Plot results

for han=1:4
    if ishandle(han)
        close(han);
    end
end

time = 0:CitFreq:(length(tfluo)-1)*CitFreq;
figure;
hold on
yyaxis left
errorbar(time, tfluo(1,:), tfluo(2,:), 'g'); % Fluorescence Levels
set(gca,'ycolor','g')
title('Temporary Citrine Fluorescence')
xlabel('time(min)')
ylabel('Citrine(A.U.)')

yyaxis right
stairs(INP(2,:), INP(1,:), 'b') % Input design
set(gca,'ycolor','b')
ylabel('IPTG(\muM)')
hold off

try
    saveas(gcf,['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-Citrine.png']);
catch
    warning('Problem Saving Citrine Image');
end


figure;
hold on
yyaxis left
plot(time,tSulf, 'r')
set(gca,'ycolor','r')
saveas(gcf,'Test.png')
title('Temporary Sulforhodamine Fluorescence')
xlabel('time(min)')
ylabel('Sulforhodamine(A.U.)')
xlim([0,(length(tfluo)-1)*5])

yyaxis right
stairs(INP(2,:), INP(1,:), 'b') % Input design
set(gca,'ycolor','b')
ylabel('IPTG(\muM)')
hold off

try
    saveas(gcf, ['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-Sulforodamine.png']);
catch
    warning('Problem Saving Sulforodamine Image');
end

try
    d = imread([Files1(end).folder, '\', Files1(end).name]);
    c = imread([Files2(end).folder, '\', Files2(end).name]);
    m = imread([Files1(end).folder, '\Segmentation\', strrep(Files1(end).name,'png','tif')]);
    s = imread([Files3(end).folder, '\', Files3(end).name]);
    
    if cutcor(4)-cutcor(3)>cutcor(2)-cutcor(1)
        figure
        hold on
        subplot(2,1,1)
        imshow(mat2gray(d(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('DIC')
        subplot(2,1,2)
        imshow(mat2gray(m))
        title('Mask')
        hold off
        saveas(gcf, ['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-LastTP1.png']);
        
        figure
        hold on
        subplot(2,1,1)
        imshow(mat2gray(c(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('Citrine')
        subplot(2,1,2)
        imshow(mat2gray(s(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('Sulforhodamine')
        hold off
        saveas(gcf, ['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-LastTP2.png']);
        
    else
        figure
        hold on
        subplot(1,2,1)
        imshow(mat2gray(d(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('DIC')
        subplot(1,2,2)
        imshow(mat2gray(m))
        title('Mask')
        hold off
        saveas(gcf, ['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-LastTP1.png']);
        
        figure
        hold on
        subplot(1,2,1)
        imshow(mat2gray(c(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('Citrine')
        subplot(1,2,2)
        imshow(mat2gray(s(cutcor(1):cutcor(2),cutcor(3):cutcor(4))))
        title('Sulforhodamine')
        hold off
        saveas(gcf, ['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-LastTP2.png']);
    end
    
catch
    warning('Problem Ploting current time-frame');
end


 
catch err
    %open file
    errorFile = ['Error-',erase(Files1(end).name,'.png'),'.errorLog'];
    fid = fopen(errorFile,'a+');
    fprintf(fid, '%s', err.getReport('extended', 'hyperlinks','off'));
    % close file
    fclose(fid);
end
end






