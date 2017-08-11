function z = fsys(RB,X,A,B,C)
    %this function implement a fuzzy infrence system
    %RB is Rules Matrix
    %X is input for variables
    %A , B, C Fuzzy partitions for ...
    %7 fuzzy set on each of the input variables
    %and 49 rules
    z = 0;
    W = 0;
    for i = 1:49
        %calculating membership of input;
        t1 = trimf(X(1),A(RB(i,1),:));
        t2 = trimf(X(2),B(RB(i,2),:));
        
        %using MIN for T_Norm
        if t1 < t2
            w = t1;
        else
            w = t2;
        end
        
        W = W + w;  %summing fire strength of each rule
        z = z + (w*C(RB(i,3),2)); %adding centroid of z
                                  %since fuzzy sets are triangular centroid
                                  %is center of triangle
    end
    z = z / W;
end
