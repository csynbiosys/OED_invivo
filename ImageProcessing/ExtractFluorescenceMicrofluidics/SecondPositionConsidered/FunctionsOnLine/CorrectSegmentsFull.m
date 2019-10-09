
%% Correct segments
% This script extracts problematic pixels from the mask (1 pixel
% connections fo example) in order to ease the cell labeling

% INPUTS
% --------> x: Segmented mask to be 'corrected'

%OUTPUTS
% --------> x: Segmented mask without problematic pixels
% --------> y: Mask containing all the problematic pixels to be
% reintroduced latter on

function [x,y]=CorrectSegmentsFull(x)

    [i,j]=size(x);
    y = zeros(i,j);
    s = zeros(i,j); % Matrix that will contain small cells (less than 175 pixels)
    
    % Do not consider small\normal size cells into the procedure (150-200 pixels)
    L = bwlabel(x,4); % Index original mask
    nuce = unique(L); % Get the number of elements
    nuce = nuce(2:end); % Discard the 0 (background)
    for k=1:length(nuce) % Iterate over the number of cells in the frame
        pc = find(L==nuce(k)); % Find matrix indexes for each cell
        if length(pc)<=175 % If the cell is small, put them on s and delete them from x. The cells will be added again at the end of the script. 
            s(pc)=1;
            x(pc)=0;
        end
    end
    
    % Add pixel if there is a cell with one missing pixel
    % 111 
    %11111
    %11011
    %11111
    % 111 
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j && a+2>1 && a-2>1 && b+2>1 && b-2>1 && a+2<i && b+2<j
                if x(a,b)==0 && x(a+1,b)==1 && x(a+2,b)==1 && x(a-1,b)==1 && x(a-2,b)==1 ...
                        && x(a,b+1)==1 && x(a,b+2)==1 && x(a,b-1)==1 && x(a,b-2)==1 ...
                        && x(a+1,b+1)==1 && x(a+1,b+2)==1 && x(a+1,b-1)==1 && x(a+1,b-2)==1 ...
                        && x(a-1,b+1)==1 && x(a-1,b+2)==1 && x(a-1,b-1)==1 && x(a-1,b-2)==1 ...
                        && x(a+2,b+1)==1 && x(a+2,b-1)==1 ... 
                        && x(a-2,b+1)==1 && x(a-2,b-1)==1
                    x(a,b) = 1;                    
                end
            end
        end
    end
    
    % Remove small pixel connections
    % 1   010
    %010  111
    % 1   010
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==1 && x(a,b+1)==0 && x(a,b-1)==0
                    x(a,b) = 0;
                elseif x(a,b)==1 && x(a+1,b)==0 && x(a-1,b)==0 && x(a,b+1)==1 && x(a,b-1)==1
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end

    % 1 
    %111
    %101
    %101
    % 0
    % 0
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && a-2>1 && a-3>1 && a-4>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==0 && x(a-2,b)==0 && x(a-3,b)==0 && x(a-4,b)==0 ...
                        && x(a,b+1)==1 && x(a,b-1)==1 && x(a-1,b+1)==1 && x(a-1,b-1)==1 && x(a-2,b+1)==1 && x(a-2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end

    % 0 
    % 0 
    % 0 
    %101
    %111
    % 1 
    for a=1:i
        for b=1:j
            if a-1>1 && a+1>1 && a+2>1 && a+3>1 && a+4>1 && b+1>1 && b-1>1 && a+1<i && a+2<i && a+3<i && a+4<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==1 && x(a+1,b)==0 && x(a+2,b)==0 && x(a+3,b)==0 && x(a+4,b)==0 && x(a,b+1)==1 ...
                        && x(a,b-1)==1 && x(a+1,b+1)==1 && x(a+1,b-1)==1 && x(a+2,b+1)==1 && x(a+2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    %-1 0 1-
    %|11111|
    %|11111|
    %-1 0 1-
    for a=1:i
        for b=1:j
            if a+1>1 && a+2>1 && a-1>1 && b-1>1 && b-1>2 && a+1<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==1 && x(a+2,b)==0 && x(a,b+1)==1 && x(a,b+2) && x(a,b-1)==1 && x(a,b-2)==1 ...
                        && x(a+1,b-1)==1 && x(a+1,b-2)==1 && x(a+1,b+1)==1 && x(a+1,b+2)==1 && (x(a-1,b-2)==1 || x(a+2,b-2)==1) ...
                        && (x(a-1,b+2)==1 || x(a+2,b+2)==1)       
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
   
    % Remove outline
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && (x(a-1,b)==0 || x(a+1,b)==0 || x(a,b-1)==0 || x(a,b+1)==0 || x(a-1,b-1)==0 || x(a-1,b+1)==0 ...
                        || x(a+1,b-1)==0 || x(a+1,b+1)==0)
                    y(a,b) = 1;
                end
            end
        end
    end
    
    % Remove outline
%     for a=1:i
%         for b=1:j
%             if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
%                 if x(a,b)==1 && (x(a-1,b)==0 || x(a+1,b)==0 || x(a,b-1)==0 || x(a,b+1)==0)
%                     y(a,b) = 1;
%                 end
%             end
%         end
%     end
%     
    % Correct if not done before
    for a=1:i
        for b=1:j
            if y(a,b)==1
                x(a,b)=0;
            end
        end
    end
    
    % Correct for extremely small diagonal elements
    % 000   000 
    %0010   0100
    %0100   0010
    %000     000
    
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j && a+2>1 && a-2>1 && b+2>1 && b-2>1 && a+2<i && b+2<j
                if x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==0 && x(a+2,b)==0 ...
                        && x(a-1,b+1)==0 && x(a,b+1)==0 && x(a+1,b+1)==0 ...
                        && x(a-1,b-1)==0 && x(a,b-1)==0 && x(a+1,b-1)==1 && x(a+2,b-1)==0 ...
                        && x(a,b-2)==0 && x(a+1,b-2)==0 && x(a+2,b-2)==0
                    if y(a,b-1)==1
                        x(a,b-1) = 1;
                        y(a,b-1) = 0;
                    end
                    if y(a+1,b)==1
                        x(a+1,b) = 1;
                        y(a+1,b) = 0;
                    end
                elseif x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==0 && x(a+2,b)==0 ...
                        && x(a,b-1)==0 && x(a+1,b-1)==0 && x(a-1,b-1)==0 ...
                        && x(a-1,b+1)==0 && x(a,b+1)==0 && x(a+1,b+1)==1 && x(a+2,b+1)==0 ...
                        && x(a,b+2)==0 && x(a+1,b+2)==0 && x(a+2,b+2)==0
                    if y(a,b+1)==1
                        x(a,b+1) = 1;
                        y(a,b+1) = 0;
                    end
                    if y(a+1,b)==1
                        x(a+1,b) = 1;
                        y(a+1,b) = 0;
                    end
                end
            end
        end
    end
    
    % Remove small pixel connections 2
    % 1 -
    % 1 |    010
    %010|   11111
    % 1 |   |010|
    % 1 -    ---
    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j + a+2>1 && a-2>1 && b+2>1 && b-2>1 && a+2<i && b+2<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==1 && x(a,b+1)==0 && x(a,b-1)==0 && (x(a+2,b)==1 || x(a-2,b)==1)
                    x(a,b) = 0;
                    y(a,b) = 1;
                elseif x(a,b)==1 && x(a+1,b)==0 && x(a-1,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 && (x(a,b+2)==1 || x(a,b-2)==1)
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end


    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && a-2>1 && a-3>1 && a-4>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==0 && x(a-2,b)==0 && x(a-3,b)==0 && x(a-4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 ...
                        && x(a-1,b+1)==1 && x(a-1,b-1)==1 && x(a-2,b+1)==1 && x(a-2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end


    for a=1:i
        for b=1:j
            if a-1>1 && a+1>1 && a+2>1 && a+3>1 && a+4>1 && b+1>1 && b-1>1 && a+1<i && a+2<i && a+3<i && a+4<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==1 && x(a+1,b)==0 && x(a+2,b)==0 && x(a+3,b)==0 && x(a+4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 ...
                        && x(a+1,b+1)==1 && x(a+1,b-1)==1 && x(a+2,b+1)==1 && x(a+2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    for a=1:i
        for b=1:j
            if a+1>1 && a+2>1 && a-1>1 && b-1>1 && b-1>2 && a+1<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==1 && x(a+2,b)==0 && x(a,b+1)==1 && x(a,b+2) && x(a,b-1)==1 && x(a,b-2)==1 ...
                        && x(a+1,b-1)==1 && x(a+1,b-2)==1 && x(a+1,b+1)==1 && x(a+1,b+2)==1 && (x(a-1,b-2)==1 || x(a+2,b-2)==1) ...
                        && (x(a-1,b+2)==1 || x(a+2,b+2)==1)       
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    % Bring back the small cells into the image
    smce = find(s==1); % Get the indexes of all the small sells
    x(smce) = 1; % Set the output frame pixels for small cells to 1
    
    return
end




