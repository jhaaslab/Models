```julia
@kwdef mutable struct TRNnetwork <: Model
    names::Vector{String}
    n::Int          = length(names)
    per_neuron::Int = 14

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

    # Electrical Synapses (mS/cm^2)
    GJ::Matrix{Float64} = zeros(n,n)
end
```