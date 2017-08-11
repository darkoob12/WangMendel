%this file generates train and test data

clear;
clc;
%function to be modeled using FRBS
F = inline('x^2 + y^2','x','y');

%First we generate training data
X1 = -5:.25:5;
X2 = -5:.25:5;

%training data
DB = zeros(1681,3);
l = 1;
for i = 1:41
    for j = 1:41
        DB(l,:) = [X1(i),X2(j),F(X1(i),X2(j))];
        l = l+1;
    end
end

%Generating 168  samples for testing the system

XT = random('unif',-5,5,168,2);
ZT = XT(:,1).^2 + XT(:,2).^2;
