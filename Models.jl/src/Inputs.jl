function Iapp_f(bias,I,t,(Istart,Istop))
    for i in eachindex(Istart)
        if t>=Istart[i] && t<=Istop[i]
            return -I
        else
            return -bias
        end
    end
end

function ExtSyn_f(t,tA,A)
    Amp =0.0; vpre=-100.0;
    for i in eachindex(tA)

        if t>=tA[i] && t<=tA[i]+2.0
            Amp  = A[i]
            vpre = 0.0
        end
    end

    return Amp, vpre
end

function GtACR_f(G,t,(on,off))
    for i in eachindex(on)
        if t>=on[i] && t<=off[i]
            return G
        else
            return 0.0
        end
    end
end

function Gsyn_f(v,vTRNs,gj)
    Gsyn = 0.0
    for i in eachindex(vTRNs)
        Gsyn += gj[i] * (v-vTRNs[i])
    end

    return Gsyn
end
