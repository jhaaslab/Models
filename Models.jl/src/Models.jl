module Models
# dependencies
## external
using Statistics
using Random
using LinearAlgebra
using Peaks, NaNStatistics, DSP

## self defined -- top level deps
#------------------------------------------------------------
# Run helper functions:
#------------------------------------------------------------
include("RunUtils.jl")
export allcombinations, psthFR, findspks
export constructResults, simVars, simResults, spkData
#------------------------------------------------------------

#------------------------------------------------------------
#Channel functions
#------------------------------------------------------------
include("Channels.jl")
export Na_t, Na_p, K_rect, K_A, K2, Ca_T, AR
#------------------------------------------------------------

#------------------------------------------------------------
#Input functions
#------------------------------------------------------------
include("Inputs.jl")
export Iapp_f, ExtSyn_f, GtACR_f, Gsyn_f
#------------------------------------------------------------

#------------------------------------------------------------
#Synapse functions
#------------------------------------------------------------
include("Synapses.jl")
export K_syn, poissonP, constructGJ, constructConnections
#------------------------------------------------------------


#------------------------------------------------------------
# Model constructs
#------------------------------------------------------------
## TRNmodel, dep: Models
module TRNmodel

using Models

export dsim!, simParams, initialconditions
export allcombinations, constructResults,simVars, simResults, spkData 
export findspks, psthFR

include("TRNmodel.jl")

end #module TRNmodel
#------------------------------------------------------------

## TRNnetwork, dep: Models
module TRNnetwork

using Models

export dsim!, simParams, initialconditions
export poissonP, constructGJ
export allcombinations, constructResults,simVars, simResults, spkData 
export findspks, psthFR

include("TRNnetwork.jl")

end #module TRNnetwork
#------------------------------------------------------------

## TC_TRNnetwork, dep: Models
module TC_TRNnetwork

using Models

export dsim!, simParams, initialconditions
export poissonP, constructGJ, constructConnections
export allcombinations, constructResults,simVars, simResults, spkData 
export findspks, psthFR

include("TC_TRNnetwork.jl")

end #module TC_TRNnetwork
#------------------------------------------------------------


end #module Models
