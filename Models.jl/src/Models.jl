module Models
# dependencies
## external
#using OrdinaryDiffEq
#using MAT
using Statistics

## self defined -- top level deps
#------------------------------------------------------------
# Run helper functions:
#------------------------------------------------------------

include("RunUtils.jl")
export allcombinations, constructResults, meanvm!

#------------------------------------------------------------
#Channel functions
#------------------------------------------------------------

include("Channels.jl")
export Na_t, Na_p, K_rect, K_A, K2, Ca_T, AR

#------------------------------------------------------------
#Input functions
#------------------------------------------------------------

include("Inputs.jl")
export Iapp_f, vpre_f, GtACR_f
#------------------------------------------------------------

#------------------------------------------------------------
#Synapse functions
#------------------------------------------------------------

include("Synapses.jl")
export K_syn, poissonP
#------------------------------------------------------------


#------------------------------------------------------------
# Model constructs
#------------------------------------------------------------
## TRNmodel, dep: Models
module TRNmodel

using Models

export dsim!, simParams, initialconditions
export allcombinations, constructResults, meanvm!

include("TRNmodel.jl")

end #module TRNmodel

## TRNnetwork, dep: Models
module TRNnetwork

using Models

export dsim!, simParams, initialconditions, poissonP
export allcombinations, constructResults, meanvm!

include("TRNnetwork.jl")

end #module TRNnetwork

## TC_TRNnetwork, dep: Models
module TC_TRNnetwork

using Models

export dsim!, simParams, initialconditions, poissonP
export allcombinations, constructResults, meanvm!

include("TC_TRNnetwork.jl")

end #module TC_TRNnetwork
#------------------------------------------------------------

end #module Models
