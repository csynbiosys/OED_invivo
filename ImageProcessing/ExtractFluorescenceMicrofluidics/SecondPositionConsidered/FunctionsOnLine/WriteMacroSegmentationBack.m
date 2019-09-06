
%% Write Macro ImageJ script to perform image segmentation

% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS
% --------> pDIC: Directory were the microscope images are going to be
% saved.
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)
% --------> 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS
% --------> 


function [] = WriteMacroSegmentationBack(pDIC,ident,IP,Cmod,RSA,cutcorBACK1,cutcorBACK2)

if ~exist([pDIC,'\SegmentationOne'],'dir')
    mkdir([pDIC,'\SegmentationOne']);                    %
    addpath([pDIC,'\SegmentationOne']);
end                                                        %                      
if ~exist([pDIC,'\SegmentationTwo'],'dir') && ~isempty(cutcorBACK2)
    mkdir([pDIC,'\SegmentationTwo']);                    %
    addpath([pDIC,'\SegmentationTwo']);
end                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate Macros ImageJ script
fil = fopen([pDIC,'\SegmentationOne\',ident,'-MacroSegmentationBackOne.ijm'], 'w');
dir1 = [pDIC,'\CutDICBackOne'];
dir12 = [pDIC,'\SegmentationOne'];
dir1 = strrep(dir1,'\','/');
dir12 = strrep(dir12,'\','/');

fprintf(fil, ['dir1 = "',dir1,'/";']);
fprintf(fil, '\n');
fprintf(fil, ['dir2 = "',dir12,'/";']);
fprintf(fil, '\n');
fprintf(fil, 'list = getFileList(dir1);');
fprintf(fil, '\n');
fprintf(fil, 'setBatchMode(true);');
fprintf(fil, '\n\n');
fprintf(fil, 'for (i=0; i<list.length; i++) {');
fprintf(fil, '\n');
fprintf(fil, '    if(!File.exists(dir2+replace(list[i], "png", "tif"))){');
fprintf(fil, '\n');
fprintf(fil, ['        open("',dir1,'/"+list[i]);']);
fprintf(fil, '\n');

RSA = strrep(RSA,'\','/');
fprintf(fil, ['        call(''de.unifreiburg.unet.SegmentationJob.processHyperStack'', ''modelFilename=D:/David/OED_invivo-master/ImageProcessing/2d_cell_net_v0_model/2d_cell_net_v0.modeldef.h5, Memory (MB):=5000,weightsFilename=',Cmod,'.caffemodel.h5,gpuId=all available,useRemoteHost=true,hostname=',IP,',port=22,username=ubuntu,RSAKeyfile=//',RSA,',processFolder=,average=none,keepOriginal=false,outputScores=false,outputSoftmaxScores=false'');']);
fprintf(fil, '\n');

a=cutcorBACK1(2)-cutcorBACK1(1)+1;
b=cutcorBACK1(4)-cutcorBACK1(3)+1;

fprintf(fil, ['        run("Size...", "width=',num2str(b),' height=',num2str(a),' depth=1 constrain average interpolation=Bilinear");']);
fprintf(fil, '\n');

dir2 = [pDIC,'\SegmentationOne'];
dir2 = strrep(dir2,'\','/');

fprintf(fil, ['        saveAs("Tiff", "',dir2,'/"+list[i]);']);
fprintf(fil, '\n\n');
fprintf(fil, '         close();');
fprintf(fil, '\n');
fprintf(fil, '    }');
fprintf(fil, '\n');
fprintf(fil, '}');
fprintf(fil, '\n');

fclose(fil);

if ~isempty(cutcorBACK2)
    
    % Generate Macros ImageJ script
    fil = fopen([pDIC,'\SegmentationTwo\',ident,'-MacroSegmentationBackTwo.ijm'], 'w');
    dir1 = [pDIC,'\CutDICBackTwo'];
    dir12 = [pDIC,'\SegmentationTwo'];
    dir1 = strrep(dir1,'\','/');
    dir12 = strrep(dir12,'\','/');

    fprintf(fil, ['dir1 = "',dir1,'/";']);
    fprintf(fil, '\n');
    fprintf(fil, ['dir2 = "',dir12,'/";']);
    fprintf(fil, '\n');
    fprintf(fil, 'list = getFileList(dir1);');
    fprintf(fil, '\n');
    fprintf(fil, 'setBatchMode(true);');
    fprintf(fil, '\n\n');
    fprintf(fil, 'for (i=0; i<list.length; i++) {');
    fprintf(fil, '\n');
    fprintf(fil, '    if(!File.exists(dir2+replace(list[i], "png", "tif"))){');
    fprintf(fil, '\n');
    fprintf(fil, ['        open("',dir1,'/"+list[i]);']);
    fprintf(fil, '\n');

    RSA = strrep(RSA,'\','/');
    fprintf(fil, ['        call(''de.unifreiburg.unet.SegmentationJob.processHyperStack'', ''modelFilename=D:/David/OED_invivo-master/ImageProcessing/2d_cell_net_v0_model/2d_cell_net_v0.modeldef.h5, Memory (MB):=5000,weightsFilename=',Cmod,'.caffemodel.h5,gpuId=all available,useRemoteHost=true,hostname=',IP,',port=22,username=ubuntu,RSAKeyfile=//',RSA,',processFolder=,average=none,keepOriginal=false,outputScores=false,outputSoftmaxScores=false'');']);
    fprintf(fil, '\n');

    a=cutcorBACK2(2)-cutcorBACK2(1)+1;
    b=cutcorBACK2(4)-cutcorBACK2(3)+1;

    fprintf(fil, ['        run("Size...", "width=',num2str(b),' height=',num2str(a),' depth=1 constrain average interpolation=Bilinear");']);
    fprintf(fil, '\n');

    dir2 = [pDIC,'\SegmentationTwo'];
    dir2 = strrep(dir2,'\','/');

    fprintf(fil, ['        saveAs("Tiff", "',dir2,'/"+list[i]);']);
    fprintf(fil, '\n\n');
    fprintf(fil, '         close();');
    fprintf(fil, '\n');
    fprintf(fil, '    }');
    fprintf(fil, '\n');
    fprintf(fil, '}');
    fprintf(fil, '\n');

    fclose(fil);
    
end



end




















