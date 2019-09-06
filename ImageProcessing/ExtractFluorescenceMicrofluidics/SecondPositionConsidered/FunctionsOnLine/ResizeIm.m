%% Resize Image
% This script reintroduces the extracted problematic pixels from
% CorrectSegmentsFull.m with the correct identifier

% INPUTS
% --------> x: Segmented mask without problematic pixels
% --------> y: Mask containing all the problematic pixels to be
% reintroduced latter on

%OUTPUTS
% --------> x: Full Mask with indexed cells

function [x]=ResizeIm(x,y)

    [i,j]=size(x);
    
    for b=1:j
        for a=1:i
            if y(a,b)==1
                if a-1>1 && x(a-1,b)>0
                    x(a,b)=x(a-1,b);
                    y(a,b)=0;
                elseif a+1<i && x(a+1,b)>0
                    x(a,b)=x(a+1,b);
                    y(a,b)=0;
                elseif b-1>1 && x(a,b-1)>0
                    x(a,b)=x(a,b-1);
                    y(a,b)=0;
                elseif b+1>1 && x(a,b+1)>0
                    x(a,b)=x(a,b+1);
                    y(a,b)=0;
                end
            end
        end
    end
    
    for b=1:j
        for a=1:i
            if y(a,b)==1
                if a-1>1 && x(a-1,b)>0
                    x(a,b)=x(a-1,b);
                elseif a+1<i && x(a+1,b)>0
                    x(a,b)=x(a+1,b);
                elseif b-1>1 && x(a,b-1)>0
                    x(a,b)=x(a,b-1);
                elseif b+1>1 && x(a,b+1)>0
                    x(a,b)=x(a,b+1);
                elseif a-1>1 && b-1>1 && x(a-1,b-1)>0
                    x(a,b)=x(a-1,b-1);
                elseif a+1<i && b+1<j && x(a+1,b+1)>0
                    x(a,b)=x(a+1,b+1);
                elseif a+1<i && b-1>1 && x(a+1,b-1)>0
                    x(a,b)=x(a+1,b-1);
                elseif a-1>1 && b+1<j && x(a-1,b+1)>0
                    x(a,b)=x(a-1,b+1);
                end
            end
        end
    end
    
    
    return
end
