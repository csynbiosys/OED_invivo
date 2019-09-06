%% Single-cell data curation

% This scrip extracts sick/big cells as well as errors introduced by cell
% segmentation and/or cell tracking and only accounts for cells that have
% been present in the experiment for a certain ammount of time

% --------> pDIC: pDICory path where the images are saved (string)
% --------> ident: identifier that will be added to the matlab structure
% containing all the cut images (string)

%OUTPUTS
% --------> dat: Matrix with mean and standard deviation of the
% fluorescence for an experiment considering all cells
% --------> sct6: Matlab structure containing the single cell citrine levels
% by cell after the correcton of the traces

function [dat,sct6,sct62] = SingleCellDataCurationOnLine(pDIC, ident, CitFreq, DicFreq)

filePattern1 = fullfile(pDIC, 'exp*DIC_001.png');
filePattern2 = fullfile(pDIC, 'exp*mCitrineTeal_001.png');
Files1 = dir(filePattern1);
Files2 = dir(filePattern2);
maxidD=length(Files1);
maxidC=length(Files2);

load([pDIC, '\Tracking\',ident,'_SingleCellTrackPerFrame.mat'], 'sct');
load([pDIC, '\Tracking\',ident,'_SingleCellTrackPerCell.mat'], 'sct2');
load([pDIC, '\Tracking\',ident,'_SingleCellTrackSize.mat'], 'scts');
load([pDIC,'\',ident,'-CutImages.mat'], 'CCs');
load([pDIC, '\Tracking\',ident,'_TrakedMasks2.mat'], 'trki');
n=cellfun(@(seg) max(seg(:)),trki);
% Extract mean and standard deviation of the whole dataset
nf = maxidC;
dat = zeros(maxidC,2);

for i=1:maxidC
    dat(i,1)=mean(sct{i}(1,:), 'omitnan');
    dat(i,2)=std(sct{i}(1,:), 'omitnan');
end

save([pDIC, '\Tracking\',ident,'_SingleCellData.mat'], 'dat');

%%%%%%%%%%%%%% All cells - bright stars
% Get single vector with all sizes
allcs = [];
for i=1:maxidC
    allcs = [allcs, scts{i}(~isnan(scts{i}))];
end
% Threshold size
ths = mean(allcs)+3*(std(allcs));
% Get size per cell
scts2 = {};
for i=1:maxidC
    for j=1:max(n)
        scts2{j}(:,i) = scts{i}(:,j);
    end
end
% Get index of cells that at the end of the experiment are too large (3sd from the mean)
lar = [];
for i=1:length(scts{maxidC})
    if scts{maxidC}(i)>ths
        lar = [lar, i];
    end
end


%%%%% Distribution based on fluorescence
% Get single vector with all fluorescence
allfs = [];
for i=1:maxidC
    itm = sct{i}(1,:);
    allfs = [allfs, itm(~isnan(itm))];
end
% Threshold size
thf = mean(allfs)+3*(std(allfs));
% Get index of cells that at some point of the experiment are too bright (3sd from the mean)
larf = [];
for j=1:maxidC
    for i=1:length(sct{j})
        if sct{j}(1,i)>thf
%             sct{j}(1,i)
            larf = [larf, i];
        end
    end
end
larf = unique(larf);


%%%%%%%%%%%%%%%%% Extract cells that touch the edge
% Try GPU: https://uk.mathworks.com/matlabcentral/answers/36235-parfor-on-gpu
% if gpuDeviceCount~=0
%     edgeind = gpuArray();
% else
%     edgeind = [];
% end

edgeind = [];

sctEDGE = cell(1,maxidC);


r = 1:CitFreq/DicFreq:maxidD;
parfor ind=1:maxidC
    tempim2=double(CCs{ind});
    disp(num2str(ind))
    temp1=unique(trki{r(ind)});
    temp1 = nonzeros(temp1);
    sctEDGE{ind} = NaN(1,max(n));
    
    [a,b] = size(tempim2);
    np = 0;
    
    for h=1:length(temp1)
        ti = trki{r(ind)}==temp1(h);
        BW2 = imclearborder(ti);
        if length(unique(BW2))<=1
            edgeind = [edgeind, temp1(h)];
            sctEDGE{ind}(temp1(h)) = 1;
        else
            sctEDGE{ind}(temp1(h)) = 0;
        end
    end

end

edgeind = unique(edgeind);
sctEDGE2 = {};
for i=1:maxidC
    for j=1:max(n)
        sctEDGE2{j}(:,i) = sctEDGE{i}(:,j);
    end
end

% Extract fluorescence from the frame where a cells touches the edge of the
% image
sctNoEdge = cell(1,length(sct2));
for i=1:length(sct2)
    iv = sct2{i}(1,:);
    tv = sctEDGE2{i};
    for j=1:maxidC
        if j+1<maxidC && tv(j)~=tv(j+1) && ~isnan(tv(j))
            iv(j:end)=NaN;
        end
    end
    sctNoEdge{i}= iv;
end

% Extract fluorescence from initial frames for new borns
sctNoNew = cell(1,length(sct2));
for i=1:length(sct2)
    iv = sct2{i}(1,:);
    for j=1:nf
        if j-1>1 && j+1<maxidC && abs(iv(j)-iv(j+1))>10 && isnan(iv(j-1))
            iv(j)=NaN;
        elseif j-1>1 && j+3<maxidC && abs(iv(j)-iv(j+3))>10 && isnan(iv(j-1))
            iv(j)=NaN;iv(j+1)=NaN;iv(j+2)=NaN;
        end
    end
    sctNoNew{i}= iv;
end


% Implementation of both

sctNENB = cell(1,length(sct2));

for i=1:length(sct2)
    iv = sct2{i}(1,:);
    tv = sctEDGE2{i};
    for j=1:nf
        if j+1<nf && tv(j)==1 && ~isnan(tv(j))
            iv(j:end)=NaN;
        end
    end
    for j=20:nf
        if j-1>1 && j+1<maxidC && abs(iv(j)-iv(j+1))>5 && isnan(iv(j-1))
            iv(j)=NaN;
        elseif j-1>20 && j+4<maxidC && abs(iv(j)-iv(j+4))>5 && isnan(iv(j-1))
            iv(j)=NaN;iv(j+1)=NaN;iv(j+2)=NaN;
        end
    end
    sctNENB{i}= iv;
end

% Extract cells with weird bumps (issues in tracking) from the point where
% it starts happening
sctNENBNBu = cell(1,length(sctNENB));
ls = [];
for i=1:length(sctNENB)
    iv = sctNENB{i}(1,:);
    
    for j=20:nf
        if j-1>1 && j+1<maxidC && abs(iv(j)-iv(j+1))>15 && ~isnan(iv(j-1))
            iv(j+1:end)=NaN;
            ls = [ls, i];
        end
    end
    sctNENBNBu{i}= iv;
end

% Apply All Filters
f = 0;
sct6 = cell(1,max(n));
% Index for low expression cells
lec = [];
for i=1:max(n)
    A = sctNENBNBu{i}(1,:);
    if length(A(~isnan(A)))>round((maxidC)*0.2) && ~ismember(i,larf) && ~ismember(i,lar)
        f = f+1;
        sct6{f} = sctNENBNBu{i};
        % Check for cells with really low fluorescence
        B = sctNENBNBu{i}(~isnan(sctNENBNBu{i}));
        if histc(double(B<0),1)>2
            lec = [lec, i];
        end
    end
end

save([pDIC, '\Tracking\',ident,'_FinalCuratedTraces.mat'], 'sct6');

sct62 = sct6(~cellfun('isempty',sct6));

save([pDIC, '\Tracking\',ident,'_FinalCuratedTracesNoEmpty.mat'], 'sct62');

end















