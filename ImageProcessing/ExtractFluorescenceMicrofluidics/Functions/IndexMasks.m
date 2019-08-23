
%% Index cells in Masks

% This script takes all the masks and indexes each element (cell) with a
% different identifier

% INPUTS
% --------> Segs: Matlab structure containing all the segmented masks
% --------> dire: Directory path where the masks will be saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)

function [] = IndexMasks(Segs,dire,ident)

maxid = length(Segs);

c = cell(1,maxid);

if ~exist([dire,'\Components'],'dir')
    mkdir([dire,'\Components']);
    addpath([dire,'\Components']);
end

% Annotate images
for i=1:maxid

    x = Segs{i};
    [x,y] = CorrectSegmentsFull(x);
    x2 = mat2gray(x);
    L = bwlabel(x2,4);
    L = ResizeIm(L,y);
    c{i}=L;
    num = num2str(i,'%.3u');
%     imwrite(mat2gray(L),[dire,'\Components\img_',num ,'.png'],'bitdepth',16);
end

save([dire,'\Components\',ident,'_IndexedMask.mat'], 'c')

% Save each mask as a matrix so it can be converted to an image using
% Python (Matlab has issues with the procedure due to the larg number of
% elements at the ending images)
for i=1:maxid
    f = c{i};
    save([dire,'\Components\Segment',int2str(i),'.mat'], 'f')
end

% Generate Python script with all the specifications

fil = fopen([dire,'\Components\',ident,'-PythonAnotateImage.py'], 'w');

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

fprintf(fil, ['for i in range(1,',num2str(maxid+1),'):']);
fprintf(fil, '\n');

dir1 = strrep(pwd,'\2','\\2');
dir1 = strrep(dir1,'\','\\');
dire2 = strrep(dire,'\','\\');
fprintf(fil, ['    im = sio.loadmat(''',dir1,'\\',dire2,'\\Components\\Segment''+str(i)+''.mat'')']);

fprintf(fil, '\n');
fprintf(fil, '    k = im[''f'']');
fprintf(fil, '\n');
fprintf(fil, '    img = Image.fromarray(k)');
fprintf(fil, '\n');
fprintf(fil, ['    img.save(''',dir1,'\\',dire2,'\\Components\\img_''+"{0:0=3d}".format(i)+''.tif'')']);
fprintf(fil, '\n');
fprintf(fil, '\n');

fclose(fil);

% Run Python script
system(['python ',dire,'\Components\',ident,'-PythonAnotateImage.py']);


end



































