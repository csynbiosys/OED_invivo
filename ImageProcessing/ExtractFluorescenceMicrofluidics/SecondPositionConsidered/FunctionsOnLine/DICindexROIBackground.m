
%% Get indexes for the chamber ROI

% This function reads an initial DIC image from the chamber, displays it
% with an initial sugested ROI size. The user can modify the ROI as desired
% and the function will output the selected ROI indexes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS
% --------> dii: Full path directory specified by the user where the
% initial test image to define the ROI is saved

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS
% --------> cutcor: matrix indexes of the ROI

function [cutcor1, cutcor2] = DICindexROIBackground(dii)
    
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
        indx = [0,0,600,400];

        % User selection and modification of the ROI
        figure;
        s = imshow(mat2gray(Ds));
        hBox = drawrectangle('Position',indx);
        message = sprintf('Finished??');
        uiwait(msgbox(message));% roiPosition = wait(hBox);
        roiPosition=round(hBox.Position);
        close
        
        cutcor1 = [roiPosition(2)+1, roiPosition(2)+(roiPosition(4)-1), roiPosition(1)+1, roiPosition(1)+(roiPosition(3)-1)];
        cutcor2 = [];
        answer = questdlg('Do you want a second region?', ...
            'ROI Check', ...
            'Yes','No','none');

        switch answer
            case 'Yes'
                [a,b]=size(Ds);
                Dst = Ds;
                for i=1:a
                    for j=1:b
                        if i>=cutcor1(1) && i<=cutcor1(2) && j>=cutcor1(3) && j<=cutcor1(4)
                            Dst(i,j)=nan;
                        end
                    end
                end
                
                figure;
                s = imshow(mat2gray(Dst));
                hBox = drawrectangle('Position',indx);
                message = sprintf('Finished??');
                uiwait(msgbox(message));% roiPosition = wait(hBox);
                roiPosition=round(hBox.Position);
                close
                cutcor2 = [roiPosition(2)+1, roiPosition(2)+(roiPosition(4)-1), roiPosition(1)+1, roiPosition(1)+(roiPosition(3)-1)];
            
        end


        % ROI coordenates/indexes
        
        save([dii, '\ROIindexBackground.mat'],'cutcor1', 'cutcor2')
    end

end







































