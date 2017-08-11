function ret = bg_step(i,j,DB,RB,A,B)
    ret = 0;
    for r = 1:41
        for p = 1:41
            WS = 0;
            ZS = 0;
            for t = 1:7
                for q = 1:7
                    w = A(r,t) * B(p,q);
                    WS = WS + w;
                    ZS = ZS + (w * RB(t,q));
                end
            end
            ZS = ZS / WS;
            ret = ret + (DB(r,q) - ZS) * min(A(r,i),B(p,j)) / WS;
        end
    end
    
    ret = ret / 1681;
end