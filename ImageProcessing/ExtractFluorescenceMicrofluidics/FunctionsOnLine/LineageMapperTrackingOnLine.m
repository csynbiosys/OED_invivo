%% Lineage Mapper Tracking

% This script generates and runs the necessary Macros ImageJ code to
% perform cell tracking

% --------> direct: Directory path where the original images are saved (string)

function [] = LineageMapperTrackingOnLine(direct,ident)

if ~exist([direct,'\Tracking'],'dir')
    mkdir([direct,'\Tracking']);
    addpath([direct,'\Tracking']);
end

% Add ImageJ to the path

% File for tracking
fil = fopen([direct,'\Tracking\',ident,'-MacroTracking.ijm'], 'w');
fprintf(fil, '\n');
% fprintf(fil, strcat('run("Lineage Mapper", ',strcat('"inputdirectory=',strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Segmentation\\\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"),'")'));

fprintf(fil, strcat('run("Lineage Mapper", ',strcat('"inputdirectory=',strrep(pwd,'\','\\\\'),'\\\\','Temp_Masks'," filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\\\'),'\\\\','Temp_Track'," outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.9 weightcellsize=0.5 maxcentroidsdistance=40.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=6 minfusionoverlap=0.01 enablecellfusion=false"),'")'));

dir1 = strrep(pwd,'\','/');
fprintf(fil, '\n');
fprintf(fil, ['dir1 = "',dir1,'/Temp_Masks/";']);
fprintf(fil, '\n');
fprintf(fil, ['dir2 = "',dir1,'/Temp_Track/";']);
fprintf(fil, '\n');
fprintf(fil, 'list1 = getFileList(dir1);');
fprintf(fil, '\n');
fprintf(fil, 'list2 = getFileList(dir2);');
fprintf(fil, '\n');
fprintf(fil, 'while(list2.length <= list1.length){');
fprintf(fil, '\n');
fprintf(fil, ['    dir1 = "',dir1,'/Temp_Masks/";']);
fprintf(fil, '\n');
fprintf(fil, ['    dir2 = "',dir1,'/Temp_Track/";']);
fprintf(fil, '\n');
fprintf(fil, '    list1 = getFileList(dir1);');
fprintf(fil, '\n');
fprintf(fil, '    list2 = getFileList(dir2);');
fprintf(fil, '\n');
fprintf(fil, '}');
fprintf(fil, '\n');
fprintf(fil, 'run("Quit");');
fprintf(fil, '\n');

fclose(fil);


% File to run ImageJ
fil = fopen([direct,'\Tracking\',ident,'-MacroTracking.py'], 'w');
fprintf(fil, '\n');
fprintf(fil, '# -*- coding: utf-8 -*-');
fprintf(fil, '\n');
fprintf(fil, 'import subprocess');
fprintf(fil, '\n');
fprintf(fil, 'import os');
fprintf(fil, '\n');
% fprintf(fil, strcat('run("Lineage Mapper", ',strcat('"inputdirectory=',strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Segmentation\\\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"),'")'));

% dir2 = strrep([direct,'\Segmentation'],'\2','\\2');
dir2 = strrep(direct,'\','\\');

fprintf(fil, strcat('cmd = [r"D:\\David\\fiji-win64\\Fiji.app\\ImageJ-win64.exe", "-macro", r"',dir2,'\\Tracking\\',ident,'-MacroTracking.ijm"]'));
fprintf(fil, '\n');
fprintf(fil, strcat('p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)'));

fprintf(fil, '\n');
fclose(fil);

system(['python "',direct,'\Tracking\',ident,'-MacroTracking.py"']);


% addpath 'D:\Installers\fiji-win64\Fiji.app\scripts'
% ImageJ;
% % https://uk.mathworks.com/matlabcentral/answers/20354-report-generation-toolbox-gives-warnings-and-no-figures-in-r2011b
% 
% IJ=ij.IJ();
% macro_path = [direct,'\Tracking'];
% IJ.runMacroFile(java.lang.String(fullfile(macro_path,[ident,'-MacroTracking.ijm'])));
% 
% ij.IJ.run("Quit","");

% Run Lineage Mapper Macros
% ij.IJ.run("Lineage Mapper", strcat("inputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Segmentation\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"));
% disp(direct)
% disp(strcat("inputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Segmentation\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"))
% % Quit ImageJ
% ij.IJ.run("Quit","");



end





























