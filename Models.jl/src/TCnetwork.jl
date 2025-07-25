
@kwdef mutable struct TCnetwork <: Model
    names::Vector{String}
    n::Int          = length(names)
    nTRN::Int       = sum(startswith.(names,"TRN"))
    nTC::Int        = sum(startswith.(names,"TC"))
	nCTX::Int       = sum(startswith.(names,"CTX"))
    per_neuron::Int = 14+div(n,2)

    # channel conductance (mS/cm^2)
    g_cat::Vector{Float64} = fill( 0.75 ,n)
    g_nat::Vector{Float64} = fill(60.5  ,n)
    g_kd::Vector{Float64}  = fill(60.0  ,n)
    g_nap::Vector{Float64} = fill( 0.0  ,n)
    g_kt::Vector{Float64}  = fill( 5.0  ,n)
    g_k2::Vector{Float64}  = fill( 0.5  ,n)
    g_ar::Vector{Float64}  = fill( 0.025,n)
    g_l::Vector{Float64}   = fill( 0.1  ,n)

    # reversal potentials (mV)
    E_NA::Float64 =   50.0
    E_K::Float64  = -100.0
    E_CA::Float64 =  125.0
    E_AR::Float64 =  -40.0
    E_L::Float64  =  -75.0

    # capacitance (uF)
    C::Float64 = 1.0

    # DC pulses (uA/cm^2)
    bias::Vector{Float64} = zeros(n)
    i_dc::Vector{Float64} = zeros(n)
    i_dc_start::Vector{Vector{Float64}} = fill([0.0],n)
    i_dc_stop::Vector{Vector{Float64}}  = fill([0.0],n)

    # Falling exponential
    i_exp::Vector{Float64}       = zeros(n)
    i_exp_start::Vector{Float64} = zeros(n)
    i_exp_decay::Vector{Float64} = fill(30.0,n)
     
    # Silencing
    g_gtacr::Float64 =  10.0
    E_GTACR::Float64 = -70.0
    gtacr_on::Vector{Vector{Float64}}  = fill([0.0],n)
    gtacr_off::Vector{Vector{Float64}} = fill([0.0],n)

    # Alpha/Beta Synapses # uA/cm^2
    t_rise::Float64     =  5.0
    t_fall::Float64     = 35.0
    t_inh_rise::Float64 =  5.0
    t_inh_fall::Float64 = 35.0

    E_AMPA::Float64 =    0.0
    E_GABA::Float64 = -100.0

    A::Vector{Vector{Float64}}   = fill([0.0],n)
    tA::Vector{Vector{Float64}}  = fill([0.0],n)
    AI::Vector{Vector{Float64}}  = fill([0.0],n)
    tAI::Vector{Vector{Float64}} = fill([0.0],n)

    A_TC_TRN::Matrix{Float64}   = zeros(nTC,nTRN)
    A_TC_CTX::Matrix{Float64}   = zeros(nTC,nCTX)
    AI_TRN_TC::Matrix{Float64}  = zeros(nTRN,nTC)

    # Electrical Synapses (mS/cm^2)
    GJ::Matrix{Float64} = zeros(n,n)
end


function dsim!(du, u, p::TCnetwork, t)
    for i = 1:p.n
        idx = p.per_neuron*(i-1)
        v, m_nat, h_nat, m_nap, m_kd, m_kt, h_kt, m_k2, h_k2, m_cat, h_cat, m_ar = @view u[idx+1:idx+12]
        I = 0.0

        # Inputs
        ## Applied current
        I += iapp_func(p.bias[i],p.i_dc[i],t,(p.i_dc_start[i],p.i_dc_stop[i]))
        I += iexp_func(p.i_exp[i],p.i_exp_decay[i],t,p.i_exp_start[i])
    
        ## External Synapses
        ### AMPAergic
        A, vpre = extsyn_func(t,p.tA[i],p.A[i])

        ### GABAergic
        AI, vpreI = extsyn_func(t,p.tAI[i],p.AI[i])
    
        # Channels
        ## Regular sodium
        dm_nat, dh_nat = na_t(v, m_nat, h_nat)
        ## Persistent sodium
        dm_nap = na_p(v, m_nap)
        ##  Delayed rectifier
        dm_kd = k_rect(v, m_kd)
        ## Transient K = A current, McCormick/Huguenard 1992
        dm_kt, dh_kt = k_a(v, m_kt, h_kt)
        ## GK2
        dm_k2, dh_k2 = k2(v, m_k2, h_k2)
        ## T current, as implemented by Traub 2005, which cites Destexhe 1996
        dm_cat, dh_cat = ca_t(v, m_cat, h_cat)
        ## Anonymous rectifier, AR; Traub 2005 calls this 'h'.  ?!
        dm_ar = ar(v, m_ar)

        # channel currents
        I += (p.g_nat[i]*(m_nat^3.0)*h_nat + p.g_nap[i]*m_nap) * (v-p.E_NA)
        I += (p.g_kd[i]*(m_kd^4.0) + p.g_kt[i]*(m_kt^4.0)*h_kt + p.g_k2[i]*m_k2*h_k2) * (v-p.E_K)
        I += (p.g_cat[i]*(m_cat^2.0)*h_cat) * (v-p.E_CA)
        I += (p.g_ar[i]*m_ar) * (v-p.E_AR)
        I += (p.g_l[i]) * (v-p.E_L)

        I += gtacr_func(p.g_gtacr,t,(p.gtacr_on[i],p.gtacr_off[i])) * (v-p.E_GTACR)

        # Synapses
        ## Excitatory input
        du[idx+13] = p.t_rise * k_syn(vpre)*(1.0-u[idx+13]) -
            p.t_fall*u[idx+13]
        I += A*u[idx+13] * (v-p.E_AMPA)

        ## Inhibitory input
        du[idx+14] = p.t_inh_rise * k_syn(vpreI)*(1.0-u[idx+14]) -
            p.t_inh_fall*u[idx+14]
        I += AI*u[idx+14] * (v-p.E_GABA)

        if startswith(p.names[i],"TRN")
            ## Excitatory input TC
            for ii=1:p.nTC
                du[idx+14+ii] = p.t_rise * k_syn(u[p.per_neuron*(ii+p.nTC-1)+1]) *
                    (1.0-u[idx+14+ii]) - p.t_fall*u[idx+14+ii]
                I += p.A_TC_TRN[ii,i]*u[idx+14+ii] * (v-p.E_AMPA)
            end

            ## Electrical synapses TRN
            I += gsyn_func(v,u[1:p.per_neuron:p.nTRN*p.per_neuron],p.GJ[:,i])

        elseif startswith(p.names[i],"CTX")
            ## Excitatory input TC
            for ii=1:p.nTC
                du[idx+14+ii] = p.t_rise * k_syn(u[p.per_neuron*(ii+p.nTC-1)+1]) *
                    (1.0-u[idx+14+ii]) - p.t_fall*u[idx+14+ii]
                I += p.A_TC_CTX[ii,i-(p.nTRN+p.nTC)]*u[idx+14+ii] * (v-p.E_AMPA)
            end

        else #TC
            ## Inhibitory input TRN
            for ii=1:p.nTRN
                du[idx+14+ii] = p.t_inh_rise * k_syn(u[p.per_neuron*(ii-1)+1]) *
                    (1.0-u[idx+14+ii]) - p.t_inh_fall*u[idx+14+ii]
                I += p.AI_TRN_TC[ii,i-p.nTRN]*u[idx+14+ii] * (v-p.E_GABA)
            end
        end
    
        # Final equations
        du[idx+1]  = (-1.0/p.C)*I
        du[idx+2]  = dm_nat
        du[idx+3]  = dh_nat
        du[idx+4]  = dm_nap
        du[idx+5]  = dm_kd
        du[idx+6]  = dm_kt
        du[idx+7]  = dh_kt
        du[idx+8]  = dm_k2
        du[idx+9]  = dh_k2
        du[idx+10] = dm_cat
        du[idx+11] = dh_cat
        du[idx+12] = dm_ar
    end

    return nothing
end

function initialconditions(p::TCnetwork; vm::Number = -72.8)
    u_init = [
        vm,
        minf_nat(vm),
        hinf_nat(vm),
        minf_nap(vm),
        minf_kd(vm),
        minf_kt(vm),
        hinf_kt(vm),
        minf_k2(vm),
        hinf_k2(vm),
        minf_ca_t(vm),
        hinf_ca_t(vm),
        minf_ar(vm),
        0.0,
        0.0
    ]

    u_init = [u_init; zeros(div(p.n,2))]

    u0 = repeat(u_init, p.n)

    return u0
end

