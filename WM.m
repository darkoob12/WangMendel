prepare;

%STEP1: CREATING FUZZY PARTITION OF THE INPUT VAIABLE SPACE
%---------------------------------------------------------
%Let A and B be a matrix containing parameters for fuzzy sets on each of
%the inout space

partition;
clear X1 X2;
%STEP2: GENERATING CANDIDATE LINGUISTIC RULE SET
%and 
%STEP3: GIVE AN IMPORTANCE DEGREE TO EACH RULE IN THE SET
%----------------------------------------------------------
%i will store rules in a matrix which indicates Fuzzy Set for each variable

DRB = zeros(1681,4);    %three columns for 2 input and an output 
                        %another column for degree of the rule
%iterating through X1 and X2 values
for i = 1:1681
    [F1,Fm1] = fMem(DB(i,1),A);
    [F2,Fm2] = fMem(DB(i,2),B);
    [Fz, Fmz] = fMem(DB(i,3),C);
    %the rule for (i,j)th data is determined
    DRB(i,:) = [F1,F2,Fz,Fm1*Fm2*Fmz];
end

clear i j k l F1 F2 Fz Fmz Fm1 Fm2;
%STEP4: OBTAIN A FINAL RB FROM THE RULE SET
%----------------------------------------------------------
%categorizing rules and selecting best rule from each category
R = zeros(7,7);

for i = 1:7
    for j = 1:7
        %finding rules with i,j anticedent
        found = false;        
        for l = 1:1681
            if (DRB(l,1) == i) && (DRB(l,2) == j)
                if found
                    if DRB(l,4) > DRB(R(i,j),4)
                        R(i,j) = l;
                    end
                else
                    R(i,j) = l;
                    found = true;
                end
            end
        end
    end
end

%setting the final rule base system
RB = zeros(49,3);
l = 1;
for i = 1:7
    for j = 1:7
        RB(l,:) =  DRB(R(i,j),[1 2 3]);
        l = l + 1;
    end
end

clear i j found l R DRB;

%MSE FOR TRAINING DATA

Ez = zeros(1681,1); %estimated z values for the training sample from FRBS

for i = 1:1681
    Ez(i) = fsys(RB,[DB(i,1),DB(i,2)],A,B,C);
end

MSEtrain = sum((Ez - DB(:,3)).^2) / (2 * 1681);
fprintf('MSE for Train Data:\n');
disp(MSEtrain);

%EVALUATING MSE FOR TEST DATA
Ezt = zeros(168,1);
for i = 1:168
    Ezt(i) = fsys(RB,XT(i,:),A,B,C);
end

MSEtest = sum((Ezt - ZT).^2) / (2*168);
fprintf('MSE for Test Data:\n');
disp(MSEtest);

clear i j l;
