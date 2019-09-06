function [x] = MorePix (x)

    
    [i,j]=size(x);
    for w=1:15
        y = zeros(i,j);

        for a=1:i
            for b=1:j
                if a+1>1 && a-1>1 && b+1>1 && b-1>1 && a+1<i && b+1<j
                    if x(a,b)==1 && x(a-1,b)==0 
                        y(a-1,b) = 1;
                    elseif x(a,b)==1 && x(a+1,b)==0
                        y(a+1,b) = 1;
                    elseif x(a,b)==1 && x(a,b-1)==0
                        y(a,b-1) = 1;
                    elseif x(a,b)==1 && x(a,b+1)==0
                        y(a,b+1) = 1;
                    elseif x(a,b)==1 && x(a-1,b-1)==0
                        y(a-1,b-1) = 1;
                    elseif x(a,b)==1 && x(a-1,b+1)==0
                        y(a-1,b+1) = 1;
                    elseif x(a,b)==1 && x(a+1,b-1)==0
                        y(a+1,b-1) = 1;
                    elseif x(a,b)==1 && x(a+1,b+1)==0
                        y(a+1,b+1) = 1;    

                    end
                end
            end
        end

        for a=1:i
            for b=1:j
                if y(a,b)==1
                    x(a,b)=1;
                end
            end
        end
    
    end
    
    for a=1:i
        for b=1:j
            if a+1<1 || a-1<1 || b+1<1 || b-1<1 || a+1>i || b+1>j
                x(a,b)=1;
            end
        end
    end

return
end










