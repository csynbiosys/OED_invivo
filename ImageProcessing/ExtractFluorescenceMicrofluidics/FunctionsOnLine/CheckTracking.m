

function [] = CheckTracking(CellIdent, pDIC, ident)


    id = CellIdent;
    load([pDIC, '\',ident,'-CutImages.mat'], 'CDs')
    load([pDIC, '\Tracking\',ident,'_TrakedMasksCorrected.mat'], 'trki');
    figure()
    for i=1:length(CDs)
        %# read image
        num = num2str(i,'%.3u');
        img = trki{i};
        im1 = img==id;
        im2 = CDs{i};
        %# show image
        C = imfuse(mat2gray(im2),edge(im1));
        imshow(C), hold on
    %     pause(0.5);
        hold off

        drawnow
    end




end














