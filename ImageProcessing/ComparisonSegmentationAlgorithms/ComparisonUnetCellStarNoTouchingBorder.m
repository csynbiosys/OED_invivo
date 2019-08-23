

%% Load Images
GT = imread('MaskCut1.tif');
CS = imread('CellStarCut.tif');
UN = imread('UNetCut.tif');
LGT = bwlabel(GT,4);

LGT = imclearborder(LGT,4);
UN = imclearborder(UN,4);
CS = imclearborder(CS,4);


%% Compare the total number of cells obtained by the two 

tncGT = length(unique(LGT))-1;
% 751
tncCS = length(unique(CS))-1;
% 712
tncUN = length(unique(UN))-1;
% 773

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
        if LGT(i,j)~=0
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


tcCS/tcGT;
% 0.6985
tcUN/tcGT;
% 0.8320


%% Compute the intersection over union (IoU)
% To interpret results --> https://uk.mathworks.com/help/vision/ref/evaluatesemanticsegmentation.html

testLabelsDir = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Cut\GTNB';
testImagesDirCS = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Cut\CSNB';
testImagesDirUN = 'D:\PhD\Year_1\2019_04_15_ImageProcessing\ComparisonUnetCellStar\Cut\UNNB';

classNames = ["cell","background"];
labelIDs = [255 0];

pxdsTruth = pixelLabelDatastore(testLabelsDir,classNames,labelIDs);

pxdsResultsCS = pixelLabelDatastore(testImagesDirCS,classNames,labelIDs);
pxdsResultsUN = pixelLabelDatastore(testImagesDirUN,classNames,labelIDs);
                



metricsCS = evaluateSemanticSegmentation(pxdsResultsCS,pxdsTruth)        
metricsUN = evaluateSemanticSegmentation(pxdsResultsUN,pxdsTruth)           
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        





















