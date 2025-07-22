This template script contains the necessary steps to run the model, but will need to be modified for your simulation runs. the work flow should be:

- make a sim run directory in your project/simulations folder. be concise and specific as possible, and organize folders by aim/experiments as needed.

- copy the run_script.jl template

- make changes to the script for your simulation:

# Neurons

```julia
# Import packages
using Models

# create neurons
params = TRNmodel( 
    names = ["TRN1"]
    # parameters could be modified here for all simulations
    # g_cat = [0.0]
)
```

The script first imports model code, then we can create the model neuron structure `params`. 
We have three [models](Julia%20Model.md) that can be used:
 - TRNmodel
 - TRNnetwork
 - TCnetwork

The only mandatory input is the names of the neurons, specified as a `Vector{String}`

multiple cells//types can be easily made by:

```julia
names = [
	["TRN$i" for i in 1:9];
	["TC$i" for i in 1:9]
]
```

# Defining variables 

Vars are stored in the `RunVars` structure.

We need to name the variables with `var_names`, specified as a `Vector{String}`.
Vars themselves should be lists of values.
These are all listed in our call to construct `RunVars`, order matters and should correspond to `var_names`.

We can also change:
 - `tspan` total length of the simulation in ms
 - `dt` the sampling rate in ms
 - `reps` how many replications per variable

```julia
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
```

# Variable handling 

Here we use this function template to change the specific variables of interest 
- list your variables in the same order they were added to `RunVars`
- for each variable edit the parameters of interest in `p`, the new set of params that is returned by this function

```julia
# define how the model handles vars
function param_function(params::Model, var_combo::Tuple)
    #destructure vars from var_combos !IMPORTANT: list vars in same order
    A, B = var_combo

    p = copy(params)

    p.A = A
    p.B = B
    
    return p
end
```

A real example where we change variables for multiple cells:

```julia 
# define how the model handles vars
function param_function(params::Model, var_combo::Tuple)
    #destructure vars from var_combos !IMPORTANT: list vars in same order
    I_DC, g_cat, g_l = var_combo

    p = copy(params)

	for n in 1:p.n
	    p.g_cat[n] = g_cat
	    p.g_l[n]   = g_l
	
	    p.i_dc[n]       = I_DC
	    p.i_dc_start[n] = [ 250.0]
	    p.i_dc_stop[n]  = [1250.0]    
    end
    return p
end

```

here we had variables for DC current, T currents and leak currents set for all neurons. We could have included conditional statements to provide even more control over cell types.

## Synapses

A more comprehensive guide for synapses can be found at [Synapse construction](Synapse%20construction.md).
# runsim

initializes the run, `save_vm` can be set to false to save only spiketime data, useful for saving space:

```julia
# begin running sims, model code may need to be precompiled on first execution.
# data folders will also be created, once the simulations start 
# a progress bar will be visible from the terminal.
# if the process crashes for any reason simply re-run this script
# and the program will detect and resume from the saved data. 
runsim(params, vars, param_function,
    # optionally, save all vm data
    save_vm = true,
)
```


- run using one of these methods:
	- from the run button in vs-code
	- from a terminal with julia in the PATH:
		`julia --project -t auto run_script.jl`
	- from the julia REPL opened at the simulation folder:
		`include("run_script.jl")`

- visualize results within matlab 
	- `plotVm` for Vm data
	- `plotFR` for rasters and FR data

- write and run analysis, make figures, etc. 

-  commit model folders when manuscript data//code needs to be published

>[!warning]
> Large files such as VmData.mat files should be ignored from the .gitignore file, if you have a lot of large result or analysis files add them to the .gitignore to prevent them from being committed.  

