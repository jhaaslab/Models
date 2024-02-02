
function calcBias(namesOfNeurons,gj,g_L,vm_tgt)

# Simulation//Run variables
numNeurons = length(namesOfNeurons)
startTime = 0.0
endTime   = 3000.0
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## vars
var_iDC = 0:0.02:0.2
var_Gc_idx  = axes(gj,1)
var_net_idx = axes(gj,2)

var_combos = allcombinations(var_iDC,var_Gc_idx,var_net_idx)

## Save//Run vars
numSims = length(var_combos)
numDC   = length(var_iDC)
numGc   = length(var_Gc_idx)
numNets = length(var_net_idx)

Params = Vector{simParams}(undef,numSims)

for i = 1:numSims

    iDC, Gc_idx, net_idx = var_combos[i]

    p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

    # Vars
    p.g_L = g_L[Gc_idx,net_idx]

    ## Inputs
    for ii = 1:p.n
        ### DC
        p.bias[ii] = iDC
    end

    ## Synapses
    p.gj = gj[Gc_idx,net_idx]

    Params[i] = p
end

u = zeros(numNeurons,numSims)

@time Threads.@threads for i = 1:numSims

    p = Params[i]

    prob = ODEProblem(dsim!,u0,tspan,p)

    # Start sim
    sol = solve(prob,BS3(),save_everystep=false,save_idxs=1:p.per_neuron:length(u0))

    u[:,i] = sol[end]
end

# Calculate bias current
vm = reshape(u,(numNeurons,numDC,numGc,numNets))

bias = fill(zeros(numNeurons),(numGc,numNets))

for m=1:numGc
for n=1:numNets

bias_tmp = zeros(numNeurons)
for i=1:numNeurons
    fit1 = curve_fit(Polynomial, vm[i,:,m,n], var_iDC, 3)
    bias_tmp[i] = fit1(vm_tgt)
end

bias[m,n] = bias_tmp

end
end

return bias
end #calcBias

