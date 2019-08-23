%% Load Images
GT = imread('Mask180.tif');
CS = load('CellStarSeg_180.mat');
CS = CS.segments;
UN = imread('Unet_180.tif');


LGT = bwlabel(GT,4);

%% Compare the total number of cells obtained by the two 

tncGT = length(unique(LGT))-1;
% 2099
tncCS = length(unique(CS))-1;
% 1917
tncUN = length(unique(UN))-1;
% 2119

%% Compare the total amount of pixels that have been selected as a cell
tcCS = 0;
tcUN = 0;
tcGT = 0;

[a,b]=size(LGT);
binCS = zeros(a,b);
binUN = zeros(a,b);
binGT = zeros(a,b);

for i=1:a
    for j=1:b
        if CS(i,j)~=0
            binCS(i,j)=1;
        end
        if UN(i,j)~=0
            binUN(i,j)=1;
        end
        if GT(i,j)~=0
            binGT(i,j)=1;
        end
    end
end


for i=1:a
    for j=1:b
        if binCS(i,j)~=0 && GT(i,j)~=0
            tcCS = tcCS+1;
        end
        if binUN(i,j)~=0 && GT(i,j)~=0
            tcUN = tcUN+1;
        end
        if GT(i,j)~=0
            tcGT = tcGT+1;
        end
    end
end


tcC = tcCS/tcGT;
% 0.7440
tcU = tcUN/tcGT;
% 0.8863


%% Compute the intersection over union (IoU)
% To interpret results --> https://uk.mathworks.com/help/vision/ref/evaluatesemanticsegmentation.html

testLabelsDir = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Comparison\GroundTruth';
testImagesDirCS = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Comparison\CellStar';
testImagesDirUN = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Comparison\UNet';

classNames = ["cell","background"];
labelIDs = [255 0];

pxdsTruth = pixelLabelDatastore(testLabelsDir,classNames,labelIDs);

pxdsResultsCS = pixelLabelDatastore(testImagesDirCS,classNames,labelIDs);
pxdsResultsUN = pixelLabelDatastore(testImagesDirUN,classNames,labelIDs);
                



metricsCS = evaluateSemanticSegmentation(pxdsResultsCS,pxdsTruth)        
metricsUN = evaluateSemanticSegmentation(pxdsResultsUN,pxdsTruth)           
        
        
        
        
%% Preccision and recall and False positives/negatives

cCSGT = 0;
for h=1:(length(unique(LGT))-1)
    temp = LGT==h;
    for i=1:a
        for j=1:b
            if temp(i,j)==1 && binCS(i,j)~=0
                cCSGT=cCSGT+1;
                break
            end
        end
        if temp(i,j)==1 && binCS(i,j)~=0
                
                break
        end
    end
end   

% Precission
p1 = cCSGT/length(unique(CS));
% Recall
r1 = cCSGT/length(unique(LGT));
% F
f1 = 2*(p1*r1/(p1+r1));
        
cUNGT = 0;
for h=1:(length(unique(LGT))-1)
    temp = LGT==h;
    for i=1:a
        for j=1:b
            if temp(i,j)==1 && binUN(i,j)~=0
                cUNGT=cUNGT+1;
                break
            end
        end
        if temp(i,j)==1 && binUN(i,j)~=0
                
                break
        end
    end
end           

% Precission
p2 = cUNGT/length(unique(UN));
% Recall
r2 = cUNGT/length(unique(LGT));        
% F
f2 = 2*(p2*r2/(p2+r2));        
        
        
        
        
        
        
        
        
        
        
        
        