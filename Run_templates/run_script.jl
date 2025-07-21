
# Import packages
using Models
# using Random

# create neurons
params = TRNmodel(names = ["TRN1"])

# parameters could be modified here for all simulations
# params.g_cat = [0.0 for i in params.n]

# setup vars
var_names = ["A", "B"]
var_A = 1:10
var_B = 0.5:0.1:1.0

vars = RunVars(
    var_names,
    var_A,
    var_B,

    # optionally, change default run vars
    tspan = 1000, #ms
    dt = 0.1, #ms
    reps = 1
)

# define how the model handles vars
function param_function(params::Model, var_combo::Tuple)
    #destructure vars from var_combos !IMPORTANT: list vars in same order
    A, B = var_combo

    p = copy(params)

    p.A = A
    p.B = B
    
    return p
end

# begin running sims, data will be saved to /data
# by default only spike times saved.
# A progress bar will also be visible from the terminal,
# if the process crashes for any reason simply re-run this script
# and the program will detect and resume from the saved data. 
runsim(params, vars, param_function,
    # optionally, save all vm data
    save_vm = true,
)

