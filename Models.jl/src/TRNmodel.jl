@kwdef mutable struct simParams
    names::Vector{String}
    n::Int
    per_neuron::Int

    # mS/cm^2
    g_caT::Float64   = 0.75
    g_nat::Float64   = 60.5
    g_kd::Float64    = 60.0
    g_nap::Float64   = 0.0
    g_kt::Float64    = 5.0
    g_k2::Float64    = 0.5
    g_ar::Float64    = 0.025
    g_L::Float64     = 0.1

    # mV
    E_na::Float64    = 50.0
    E_k::Float64     = -100.0
    E_ca::Float64    = 125.0
    E_ar::Float64    = -40.0
    E_L::Float64     = -75.0

    C::Float64 = 1.0 # membrance capacitance uF/cm^2

    # DC pulses # uA/cm^2
    bias::Vector{Float64} = zeros(n)
    iDC::Vector{Float64}  = zeros(n)
    iStart::Vector{Any}   = zeros(n)
    iStop::Vector{Any}    = zeros(n)
end


function dsim!(du, u, p, t)
    for i = 1:p.n
    idx = p.per_neuron*(i-1)
    v, m_nat, h_nat, m_nap, m_kd, m_kt, h_kt, m_k2, h_k2, m_caT, h_caT, m_ar = u[idx+1:idx+12]

    # Inputs
    ## Applied current
    Iapp = Iapp_f(p.bias[i],p.iDC[i],t,(p.iStart[i],p.iStop[i]))

    # Channels
    ## Regular sodium
    dm_nat, dh_nat = Na_t(v, m_nat, h_nat)
    ## Persistent sodium
    dm_nap = Na_p(v, m_nap)
    ##  Delayed rectifier
    dm_kd = K_rect(v, m_kd)
    ## Transient K = A current, McCormick/Huguenard 1992
    dm_kt, dh_kt = K_A(v, m_kt, h_kt)
    ## GK2
    dm_k2, dh_k2 = K2(v, m_k2, h_k2)
    ## T current, as implemented by Traub 2005, which cites Destexhe 1996
    dm_caT, dh_caT = Ca_T(v, m_caT, h_caT)
    ## Anonymous rectifier, AR; Traub 2005 calls this 'h'.  ?!
    dm_ar = AR(v, m_ar)

    Ina = (p.g_nat*(m_nat^3.0)*h_nat + p.g_nap*m_nap) * (v-p.E_na)
    Ik  = (p.g_kd*(m_kd^4.0) + p.g_kt*(m_kt^4.0)*h_kt + p.g_k2*m_k2*h_k2) * (v-p.E_k)
    ICa = (p.g_caT*(m_caT^2.0)*h_caT) * (v-p.E_ca)
    IAR = (p.g_ar*m_ar) * (v-p.E_ar)
    IL  = (p.g_L) * (v-p.E_L)

    # Final equations
    du[idx+1]  = (-1.0/p.C)*(Ina + Ik +ICa + IAR + IL + Iapp)
    du[idx+2]  = dm_nat
    du[idx+3]  = dh_nat
    du[idx+4]  = dm_nap
    du[idx+5]  = dm_kd
    du[idx+6]  = dm_kt
    du[idx+7]  = dh_kt
    du[idx+8]  = dm_k2
    du[idx+9]  = dh_k2
    du[idx+10] = dm_caT
    du[idx+11] = dh_caT
    du[idx+12] = dm_ar
    end

    nothing
end

function initialconditions(numNeurons, bias = true)
    u_init = [-70.0, 0.039, 0.85, 0.1, 0.023, 0.24, 0.21, 0.029, 0.76, 0.043, 0.12, 0.29]

    if bias == false
        u_init = [-72.8, 0.03, 0.9, 0.076, 0.018, 0.18, 0.3, 0.024, 0.8, 0.03, 0.19, 0.4]
    end

    per_neuron = length(u_init)

    u0 = repeat(u_init, numNeurons)

    u0, per_neuron
end


