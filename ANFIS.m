%% WANG MENDEL ALGORITHM
%This file uses anfis for adjusting sugeno parameters
prepare;

%generating fuzzy sets
partition;

%first we obtain a rule set using wang mendel method
%so i copy code from WM.m file
%STEP 1.5: in this step i calculate memnbership of each value in every
%fuzzy set for PERFORMANCE considerations
As = zeros(41,7);
Bs = zeros(41,7);
for i = 1:41
    for j = 1:7
        As(i,j) = trimf(X1(i),A(j,:));
        Bs(i,j) = trimf(X2(i),B(j,:));
    end
end
Cs = zeros(1681,7);
for i = 1:1681
    for j = 1:7
        Cs(i,j) = trimf(DB(i,3),C(j,:));
    end
end

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


%% setting initial sugeno parameter
% in a 7*7 matrix
SRB = zeros(7,7);
k = 1;
for i = 1:7
    for j = 1:7
        SRB(i,j) = C(RB(k,3),2); %centroid of consequent fuzzy set
        k = k + 1;
    end
end
clear C;
%changing Training data to a 41*41 matrix
SDB = zeros(41,41);
k = 1;
for i = 1:41
    for j = 1:41
        SDB(i,j) = DB(k,3);
        k = k + 1;
    end
end
RB = SRB;   %backup
clear i j k DB;
%% GRADIENT DESCENT FOR ANFIS PARAMETER TUNING 
%Now we use gradient descent for tuning these parameters
alpha = .015;    %learning rate
done = false;
q = 0;
while ~done
    for p = 1:41
        for r = 1:41
            %updating params
            for i = 1:7
                for j = 1:7
                    SRB(i,j) = SRB(i,j) + (alpha * sg_step(p,r,i,j,SDB,SRB,As,Bs));
                end
            end
        end
    end
    q = q + 1;
    if (q > 20)
        done  = true;
    end
end

clear q done alpha i j NRB;

%%  SHOWING RESULTS
%------------------------------------------------------------
%CALCULATING MSE
%------------------------------------------------------------

mse_train = 0;
for i = 1:41
    for j = 1:41
        WS = 0;
        ZS = 0;
        for p = 1:7
            for q = 1:7
                w = As(i,p) * Bs(j,q);
                ZS = ZS + (w * SRB(p,q));
                WS = WS + w;
            end
        end
        ZS = ZS / WS;
        
        mse_train = mse_train + (SDB(i,j) - ZS)^2;
        
    end
end

mse_train = mse_train / (2*1681);
fprintf('MSE for Train Data:\n');
disp(mse_train);

mse_test = 0;
for i = 1:168
    WS = 0;
    ZS = 0;
    for p = 1:7
        for q = 1:7
           w =  trimf(XT(i,1),A(p,:)) * trimf(XT(i,2),B(q,:));
           WS = WS + w;
           ZS = ZS + (w * SRB(p,q));
        end
    end
    ZS = ZS / WS;
    
    mse_test = mse_test  + (ZT(i) - ZS)^2;
end
mse_test = mse_test / (2 * 168);
fprintf('MSE for Test Data:\n');
disp(mse_test);
clear i j p q ZS WS w;
%% PLOTTING NEW MODEL
[X Y] = meshgrid(-5:.25:5,-5:.25:5);
Z = zeros(41,41);
for i = 1:41
    for j = 1:41
        WS = 0;
        ZS = 0;
        for p = 1:7
            for q = 1:7
            w =  trimf(X(i,j),A(p,:)) * trimf(Y(i,j),B(q,:));
            WS = WS + w;
         	ZS = ZS + (w * SRB(p,q));
            end
        end
        ZS = ZS / WS;
        Z(i,j) = ZS;
    end
end
surf(X,Y,Z);