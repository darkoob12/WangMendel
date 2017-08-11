function ret = sg_step(p,q,i,j,DB,RB,A,B)
    WS = 0;
    ZS = 0;
    for y = 1:7
        for u = 1:7
            w = A(p,y)*B(q,u);
            WS = WS + w;
            ZS = ZS + w * RB(y,u);
        end
    end
    ZS = ZS / WS;
    
    ret = DB(p,q) - ZS;
    ret = ret * (A(p,i)*B(q,j)) / WS;
end