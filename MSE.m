function z = MSE(X,Y)
    n = length(X);
    z = sum((X - Y) .^ 2) / (2*n);
end