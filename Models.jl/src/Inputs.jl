function Iapp_f(I,t,(Istart,Istop))
    if any((t.>=Istart) .* (t.<=Istop))
        return -I
    else
        return 0.0
    end
end

function vpre_f(t,tA)
    if any((t.>=tA) .* (t.<=tA.+2.0))
        return 0.0
    else
        return -100.0
    end
end

function GtACR_f(G,t,(on,off))
    if any((t.>=on) .* (t.<=off))
        return G
    else
        return 0.0
    end
end

