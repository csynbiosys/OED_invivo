%% Lineage Mapper Tracking

% This script generates and runs the necessary Macros ImageJ code to
% perform cell tracking

% --------> direct: Directory path where the original images are saved (string)

function [] = LineageMapperTracking(direct,ident)

if ~exist([direct,'\Tracking'],'dir')
    mkdir([direct,'\Tracking']);
    addpath([direct,'\Tracking']);
end

% Add ImageJ to the path


fil = fopen([direct,'\Tracking\',ident,'-MacroTracking.ijm'], 'w');
fprintf(fil, '\n');
% fprintf(fil, strcat('run("Lineage Mapper", ',strcat('"inputdirectory=',strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Segmentation\\\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\\\'),'\\\\',strrep(direct,'\','\\\\'),"\\\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"),'")'));

fprintf(fil, strcat('run("Lineage Mapper", ',strcat('"inputdirectory=',strrep(pwd,'\','\\\\'),'\\\\','Temp_Masks'," filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\\\'),'\\\\','Temp_Track'," outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"),'")'));

fprintf(fil, '\n');
fclose(fil);

addpath 'D:\Installers\fiji-win64\Fiji.app\scripts'
javaaddpath 'C:\Program Files\MATLAB\R2009b\java\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2009b\java\ij.jar'
ImageJ;
% https://uk.mathworks.com/matlabcentral/answers/20354-report-generation-toolbox-gives-warnings-and-no-figures-in-r2011b

IJ=ij.IJ();
macro_path = [pwd,'\',direct,'\Tracking'];
IJ.runMacroFile(java.lang.String(fullfile(macro_path,[ident,'-MacroTracking.ijm'])));

ij.IJ.run("Quit","");

% Run Lineage Mapper Macros
% ij.IJ.run("Lineage Mapper", strcat("inputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Segmentation\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"));
% disp(direct)
% disp(strcat("inputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Segmentation\\Components filenameprefix=img_{iii}.tif outputdirectory=",strrep(pwd,'\','\\'),'\\',strrep(direct,'\','\\'),"\\Tracking outputprefix=trk- weightcelloverlap=0.7 weightcentroidsdistance=0.8 weightcellsize=0.6 maxcentroidsdistance=150.0 mincelllife=6 celldeathdeltacentroid=0.0 celldensityaffectsci=true bordercellaffectsci=true daughtersizesimilarity=0.0 mindivisionoverlap=0.0 daughteraspectratiosimilarity=0.4 mothercircularityindex=0.2 numframestocheckcircularity=6 enablecelldivision=false mincellarea=4 minfusionoverlap=0.01 enablecellfusion=false"))
% % Quit ImageJ
% ij.IJ.run("Quit","");



end





























