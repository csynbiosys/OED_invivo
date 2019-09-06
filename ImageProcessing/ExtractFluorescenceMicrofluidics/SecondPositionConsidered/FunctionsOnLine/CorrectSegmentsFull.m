
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
    
    % Remove small pixel connections
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


    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && a-2>1 && a-3>1 && a-4>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==0 && x(a-2,b)==0 && x(a-3,b)==0 && x(a-4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 && x(a-1,b+1)==1 && x(a-1,b-1)==1 && x(a-2,b+1)==1 && x(a-2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end


    for a=1:i
        for b=1:j
            if a-1>1 && a+1>1 && a+2>1 && a+3>1 && a+4>1 && b+1>1 && b-1>1 && a+1<i && a+2<i && a+3<i && a+4<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==1 && x(a+1,b)==0 && x(a+2,b)==0 && x(a+3,b)==0 && x(a+4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 && x(a+1,b+1)==1 && x(a+1,b-1)==1 && x(a+2,b+1)==1 && x(a+2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    for a=1:i
        for b=1:j
            if a+1>1 && a+2>1 && a-1>1 && b-1>1 && b-1>2 && a+1<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==1 && x(a+2,b)==0 && x(a,b+1)==1 && x(a,b+2) && x(a,b-1)==1 && x(a,b-2)==1 && x(a+1,b-1)==1 && x(a+1,b-2)==1 && x(a+1,b+1)==1 && x(a+1,b+2)==1 && (x(a-1,b-2)==1 || x(a+2,b-2)==1) && (x(a-1,b+2)==1 || x(a+2,b+2)==1)       
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
                if x(a,b)==1 && (x(a-1,b)==0 || x(a+1,b)==0 || x(a,b-1)==0 || x(a,b+1)==0 || x(a-1,b-1)==0 || x(a-1,b+1)==0 || x(a+1,b-1)==0 || x(a+1,b+1)==0)
                    y(a,b) = 1;
                end
            end
        end
    end
    
    for a=1:i
        for b=1:j
            if y(a,b)==1
                x(a,b)=0;
            end
        end
    end
    
    % Remove small pixel connections 2
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


    for a=1:i
        for b=1:j
            if a+1>1 && a-1>1 && a-2>1 && a-3>1 && a-4>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                if x(a,b)==1 && x(a+1,b)==1 && x(a-1,b)==0 && x(a-2,b)==0 && x(a-3,b)==0 && x(a-4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 && x(a-1,b+1)==1 && x(a-1,b-1)==1 && x(a-2,b+1)==1 && x(a-2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end


    for a=1:i
        for b=1:j
            if a-1>1 && a+1>1 && a+2>1 && a+3>1 && a+4>1 && b+1>1 && b-1>1 && a+1<i && a+2<i && a+3<i && a+4<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==1 && x(a+1,b)==0 && x(a+2,b)==0 && x(a+3,b)==0 && x(a+4,b)==0 && x(a,b+1)==1 && x(a,b-1)==1 && x(a+1,b+1)==1 && x(a+1,b-1)==1 && x(a+2,b+1)==1 && x(a+2,b-1)==1   
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    for a=1:i
        for b=1:j
            if a+1>1 && a+2>1 && a-1>1 && b-1>1 && b-1>2 && a+1<i && b+1<j
                if x(a,b)==1 && x(a-1,b)==0 && x(a+1,b)==1 && x(a+2,b)==0 && x(a,b+1)==1 && x(a,b+2) && x(a,b-1)==1 && x(a,b-2)==1 && x(a+1,b-1)==1 && x(a+1,b-2)==1 && x(a+1,b+1)==1 && x(a+1,b+2)==1 && (x(a-1,b-2)==1 || x(a+2,b-2)==1) && (x(a-1,b+2)==1 || x(a+2,b+2)==1)       
                    x(a,b) = 0;
                    y(a,b) = 1;
                end
            end
        end
    end
    
    return
end






