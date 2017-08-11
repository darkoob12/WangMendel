function [Lv,M, mem] = fMem(X,A)
    %this function determine membership of a value i fuzzy sets
    %with triagle mem-function
    %X = the value
    %A = a matrix with 3 columns and a number of rows equal to number of
    %fuzzy sets
    %mem = A vector with length of  A dim one
    %Lv = Assigned Linguistic value
    f = size(A,1);  %number of fuzzy sets
    mem = zeros(f,1);
    M = 0;
    Lv = 1;
    for i = 1:f
       mem(i) = trimf(X,A(i,:));
       if mem(i) > M
          M = mem(i);
          Lv = i;
       end
    end
end