
%% Get indexes for the chamber ROI

% This function reads an initial DIC image from the chamber, displays it
% with an initial sugested ROI size. The user can modify the ROI as desired
% and the function will output the selected ROI indexes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS
% --------> dii: Full path directory specified by the user where the
% initial test image to define the ROI is saved

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS
% --------> cutcor: matrix indexes of the ROI

function [cutcor] = DICindexROIpre2018b(dii)
    
    pat = '*_DIC_001.png'; % Patern for the DIC image files
    Folder=[dii];
    filePattern = fullfile(Folder, pat);
    Files = dir(filePattern);
    % Get number of frames for channel
    maxid=length(Files);

    if maxid==0
        disp('Please, take a DIC image from the chamber and try again or check if the directory path is correct.')
        return
    else
        % Read the image
        Ds=imread([dii,'\',Files(1).name]);

        % Default average ROI size
        indx = [0,0,1023,400];

        % User selection and modification of the ROI
        figure;
        s = imshow(mat2gray(Ds));
        hBox = imrect(gca,indx);

        answer = questdlg('Is the ROI oriented correctly?', ...
            'ROI Check', ...
            'Yes','No','none');

        switch answer
            case 'Yes'
                message = sprintf('Finished??');
                uiwait(msgbox(message));% roiPosition = wait(hBox);
                roiPosition=round(hBox.getPosition);
                close
            case 'No'
                close
                indx = [0,0,400,1023];
                figure;
                s = imshow(mat2gray(Ds));
                hBox = imrect(gca,indx);
                message = sprintf('Finished??');
                uiwait(msgbox(message));% roiPosition = wait(hBox);
                roiPosition=round(hBox.getPosition);
                close
        end


        % ROI coordenates/indexes
        cutcor = [roiPosition(2), roiPosition(2)+(roiPosition(4)-1), roiPosition(1), roiPosition(1)+(roiPosition(3)-1)];
        
        for i=1:length(cutcor)
            if cutcor(i)>1024
                cutcor(i)=1024;
            end
            if cutcor(i)<1
                cutcor(i)=1;
            end
        end
        save([dii, '\ROIindex.mat'],'cutcor')
    end

end







































