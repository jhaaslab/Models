
function calcCC(namesOfNeurons,gj,g_L,uinit)

# Simulation//Run variables
numNeurons = length(namesOfNeurons)
startTime = 0.0
endTime   = 3000.0
tspan = (startTime, endTime)

## Initial conditions - exract from calcUinit results
uinit0 = uinit["uinit_0"]
per_neuron = uinit["per_neuron"]

## vars
var_cell_num = 1:numNeurons
var_Gc_idx  = axes(gj,1)
var_net_idx = axes(gj,2)

var_combos = allcombinations(var_cell_num,var_Gc_idx,var_net_idx)

## Save//Run vars
numSims = length(var_combos)
numGc   = length(var_Gc_idx)
numNets = length(var_net_idx)

## Initialize simParams
Params = Vector{simParams}(undef,numSims)
u0 = fill(zeros(numNeurons*per_neuron),numSims)

for i = 1:numSims
    cell_num, Gc_idx, net_idx = var_combos[i]

    p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

    # Vars
    p.g_L = g_L[Gc_idx,net_idx]

    ## Inputs
    ### DC
    p.bias[cell_num] = -2

    ## Synapses
    p.gj = gj[Gc_idx,net_idx]

    Params[i] = p
    u0[i] = uinit0[Gc_idx,net_idx]
end

u = zeros(numNeurons,numSims)

@time Threads.@threads for i = 1:numSims

    p = Params[i]

    prob = ODEProblem(dsim!,u0[i],tspan,p)

    # Start sim
    sol = solve(prob,BS3(),save_everystep=false,save_idxs=1:p.per_neuron:length(u0[i]))

    u[:,i] = sol[end].-u0[i][1:per_neuron:end] #save dVm from rest
end

# Calculate CC
u = reshape(u,(numNeurons,numNeurons,:))

cc = [u[:,:,i]./[u[n,n,i] for n in var_cell_num]' for i = 1:numGc*numNets]
cc = reshape(cc, (numGc,numNets))

return cc
end #calcCC

