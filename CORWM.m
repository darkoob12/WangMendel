prepare;

%STEP1: CREATING FUZZY PARTITION OF THE INPUT VAIABLE SPACE
%---------------------------------------------------------
%Let A and B be A matrix containing parameters for fuzzy sets on each of
%the inout space

A = zeros(7,3);
C = zeros(7,3);
for i = 0:6
    t = 10/6;
    A(i+1,:) = [(i-1)*t - 5,i*t - 5,(i+1)*t  - 5];
    t = 50/6;
    C(i+1,:) = [(i-1)*t,i*t,(i+1)*t];
end
B = A;

clear t;
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
CRB = zeros(49,49);
RB0 = zeros(49,3);
h = 0;
for i = 1:7
    for j = 1:7
        h = h + 1;
        k = 1;
        M = 0;
        for l = 1:1681
            if (DRB(l,1) == i) && (DRB(l,2) == j)
                CRB(h,k) = l;
                if DRB(l,4) > M
                    RB0(h,:) = DRB(l,[1 2 3]);
                    M = DRB(l,4);
                end
                k = k + 1;
            end
        end
    end
end

%initial solution

Ez = zeros(1681,1);
r = 1;
for i = 1:41
    for j = 1:41
        Ez(r) = pfsys(RB0,[i j],As,Bs,C);
        r = r + 1;
    end
end
mset0 = MSE(Ez,DB(:,3));
%number of iterations for each tempereture
nrep = 10;
%initial temperature
t =  1;

cool = inline('0.83*t','t');

%SA main loop
done = false;
while ~(done)
    for l = 1:nrep
        c = round(random('unif',1,49));    %which category?
        found = false;
        while ~found
            x = round(random('unif',1,49));
            if CRB(c,x) ~= 0
                found = true;
            end
        end
        RB = RB0;
        
        RB(c,:) = DRB(CRB(c,x),[1 2 3]);   %new RB in the neighbor
 
        %estimating
        r = 1;
        for i = 1:41
            for j = 1:41
                Ez(r) = pfsys(RB,[i j],As,Bs,C);
                r = r +1;
            end
        end
        mset = MSE(Ez,DB(:,3));   %MSE for new sol
        
        del = mset - mset0;
        if del <= 0
            RB0 = RB;
            mset0 = mset;
        else
            x = rand(1);
            if x < exp(-1 * (del/t))
                RB0 = RB;
                mset0 = mset;
            end
        end
    end
    %next temperature
    t = cool(t);
    disp(mset0);
    
    %are we there yet?
    if (t <= .0000001)
        done = true;
    end
end
RB = RB0;    
MSEtrain = mset0;

clear r h i j k l t del RB0 x c found done mset mset0;
%------------------------------------------------------------
%CALCULATING MSE
%------------------------------------------------------------
%MSE FOR TRAINING DATA
fprintf('MSE for Train Data:\n');
disp(MSEtrain);

%EVALUATING MSE FOR TEST DATA
Ezt = zeros(168,1);
for i = 1:168
    Ezt(i) = fsys(RB,XT(i,:),A,B,C);
end
 
MSEtest = MSE(Ezt,ZT);
fprintf('MSE for Test Data:\n');
disp(MSEtest);

clear i j l;
