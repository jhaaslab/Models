
function iapp_func(bias, i_amp, t, (istart, istop))
    for i in eachindex(istart)
        if t>=istart[i] && t<=istop[i]
            return -i_amp
        else
            return -bias
        end
    end
end

function iexp_func(i, tdecay, t, istart)
    if t>=istart
        return -i*exp(-((t-istart)/tdecay))
    else
        return 0.0
    end
end

function extsyn_func(t, tstart, a)
    amp  = 0.0
    vpre = -100.0
    for i in eachindex(tstart)
        if t>=tstart[i] && t<=tstart[i]+2.0
            amp  = a[i]
            vpre = 0.0
        end
    end

    return amp,  vpre
end

function gtacr_func(g, t, (on, off))
    for i in eachindex(on)
        if t>=on[i] && t<=off[i]
            return g
        else
            return 0.0
        end
    end
end

function gsyn_func(v, cell_vms, gj)
    gsyn = 0.0
    for i in eachindex(cell_vms)
        gsyn += gj[i] * (v-cell_vms[i])
    end

    return gsyn
end
