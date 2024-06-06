
function calcUinit(namesOfNeurons,gj,g_L)

# Simulation//Run variables
numNeurons = length(namesOfNeurons)
startTime = 0.0
endTime   = 5000.0
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## vars
var_Gc_idx  = axes(gj,1)
var_net_idx = axes(gj,2)

var_combos = allcombinations(var_Gc_idx,var_net_idx)

## Save//Run vars
numSims = length(var_combos)
numGc   = length(var_Gc_idx)
numNets = length(var_net_idx)

## Initialize simParams
Params = Vector{simParams}(undef,numSims)

for i = 1:numSims

    Gc_idx, net_idx = var_combos[i]

    p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

    # Vars
    p.g_L = g_L[Gc_idx,net_idx]

    ## Inputs

    ## Synapses
    p.gj = gj[Gc_idx,net_idx]

    Params[i] = p
end

u = zeros(numNeurons*per_neuron,numSims)

@time Threads.@threads for i = 1:numSims

    p = Params[i]

    prob = ODEProblem(dsim!,u0,tspan,p)

    # Start sim
    sol = solve(prob,BS3(),save_everystep=false)

    u[:,i] = sol[end]
end

# Save initial conditions
uinit_0 = [u[:,i] for i = 1:numSims]
uinit_0 = reshape(uinit_0, (numGc,numNets))

uinit = Dict("uinit_0"=>uinit_0,
             "per_neuron"=>per_neuron)

return uinit
end #calcUinit

