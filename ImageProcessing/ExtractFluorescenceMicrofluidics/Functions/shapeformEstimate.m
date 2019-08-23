function info=shapeformEstimate(timage)

        load('D:\PhD\Year_1\2019_07_31_OEDinVivo\Scripts\ImageProcessing\ExtractFluorescenceMicrofluidics\maskDataChamber.mat','mask','shape');
        formEstimate1 = imregcorr(shape,timage); % Estimate geometric transformation that aligns two 2-D images using phase correlation
        mshape = imwarp(shape,formEstimate1,'SmoothEdges',true); % Apply geometric transformation to image
        mmask = imwarp(mask,formEstimate1,'SmoothEdges',true);
        formEstimate2 = imregcorr(timage,mshape,'translation');
        T12=round(formEstimate2.T(3,[1,2]));
        if (min(T12)<0)
            mshape=[false(size(mshape,1),-min(T12(1),0)),mshape];
            mmask=[false(size(mmask,1),-min(T12(1),0)),mmask];
            mshape=[false(-min(T12(2),0),size(mshape,2));mshape];
            mmask=[false(-min(T12(2),0),size(mmask,2));mmask];
        end
        mshape=imcrop(mshape,[max(T12,0),size(timage)-1]);
        mmask=imcrop(mmask,[max(T12,0),size(timage)-1]);
        info.shape=false(size(timage));
        info.shape(1:size(mshape,1),1:size(mshape,2))=mshape;
        info.mask=false(size(timage));
        info.mask(1:size(mmask,1),1:size(mmask,2))=mmask;
        info.mask=imopen(info.mask,strel('disk',1));
        info.score=corr2(timage(:),info.shape(:));
        
end