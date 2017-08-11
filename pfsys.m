function z = pfsys(RB,X,A,B,C)
    %this function implement a fuzzy infrence system
    %using PRE_CALCULATED memberships
    %RB is Rules Matrix
    %X is index of input for variables
    %A , B Membership in Fuzzy partitions for ...
    %C fuzzy sets for output
    %7 fuzzy set on each of the input variables
    %and 49 rules
    z = 0;
    W = 0;
    for i = 1:49
        t1 = A(X(1),RB(i,1));
        t2 = B(X(2),RB(i,2));
        
        if t1 < t2
            w = t1;
        else
            w = t2;
        end
        W = W + w;  %summing fire strength of each rule
        z = z + (w*C(RB(i,3),2)); %adding centroid of z
    end
    z = z / W;
end
