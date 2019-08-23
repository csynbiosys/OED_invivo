
%% UNet Segmentation

% This script calls the Macros ImageJ code to run in batch the Image
% segmentation procedure for the DIC images of one experiment

% --------> direct: Directory path where the original images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> IP: IP address of the Linux remote machine where UNet will run
% the segmentation (string)
% --------> Cmod: Name of the caffe model to be used, without the
% .caffemodel.h5 part (string)

function [] = UNetSegment(direct, ident, IP, Cmod)

if ~exist([direct,'\Segmentation'],'dir')
    mkdir([direct,'\Segmentation']);
    addpath([direct,'\Segmentation']);
end

% Generate Macros ImageJ script
fil = fopen([direct,'\Segmentation\',ident,'-MacroSegmentation.ijm'], 'w');
dir1 = [pwd,'\',direct,'\CutDIC'];
dir1 = strrep(dir1,'\','/');

fprintf(fil, ['dir1 = getDirectory("',dir1,'");']);
fprintf(fil, '\n');
fprintf(fil, 'list = getFileList(dir1);');
fprintf(fil, '\n');
fprintf(fil, 'setBatchMode(true);');
fprintf(fil, '\n\n');
fprintf(fil, 'for (i=0; i<list.length; i++) {');
fprintf(fil, '\n');
fprintf(fil, ['    open("',dir1,'/"+list[i]);']);
fprintf(fil, '\n');
fprintf(fil, ['    call(''de.unifreiburg.unet.SegmentationJob.processHyperStack'', ''modelFilename=D:/PhD/Year_1/2019_04_15_ImageProcessing/2d_cell_net_v0_model/2d_cell_net_v0.modeldef.h5, Memory (MB):=5000,weightsFilename=',Cmod,'.caffemodel.h5,gpuId=all available,useRemoteHost=true,hostname=',IP,',port=22,username=ubuntu,RSAKeyfile=//eigg.sms.ed.ac.uk/home/s1778490/lin002Test.pem,processFolder=,average=none,keepOriginal=false,outputScores=false,outputSoftmaxScores=false'');']);
fprintf(fil, '\n');

imt = imread([dir1,'/DIC_Frame001.png']);
[a,b]=size(imt);

fprintf(fil, ['    run("Size...", "width=',num2str(b),' height=',num2str(a),' depth=1 constrain average interpolation=Bilinear");']);
fprintf(fil, '\n');

dir2 = [pwd,'\',direct,'\Segmentation'];
dir2 = strrep(dir2,'\','/');

fprintf(fil, ['    saveAs("Tiff", "',dir2,'/"+list[i]);']);
fprintf(fil, '\n\n');
fprintf(fil, '     close();');
fprintf(fil, '\n');
fprintf(fil, '}');
fprintf(fil, '\n');

fclose(fil);


% Add ImageJ to the path
addpath 'D:\Installers\fiji-win64\Fiji.app\scripts'
ImageJ;

% Run UNet segmentation Macro code
IJ=ij.IJ();
macro_path = [pwd,'\',direct,'\Segmentation'];
IJ.runMacroFile(java.lang.String(fullfile(macro_path,[ident,'-MacroSegmentation.ijm'])));

% Quit ImageJ
ij.IJ.run("Quit","");


end
















