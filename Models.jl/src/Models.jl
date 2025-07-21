module Models

# dependencies
using OrdinaryDiffEq
using Statistics
using Random
using LinearAlgebra
using Peaks, NaNStatistics, DSP
using JLD2, MAT
using ProgressMeter

export poisson_process, construct_gj_net, construct_syn_net
export psth

include("runutils.jl")
include("channels.jl")
include("inputs.jl")
include("synapses.jl")

export Model,
    TRNmodel,
    TRNnetwork,
    TCnetwork

abstract type Model end
Base.copy(x::Model) where Model = Model([deepcopy(getfield(x, k)) for k ∈ fieldnames(Model)]...)

include("TRNmodel.jl")
include("TRNnetwork.jl")
include("TCnetwork.jl")

export runsim, RunVars

include("runsim.jl")

end #module Models
