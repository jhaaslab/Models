
function calcRin(namesOfNeurons,gj,g_L)

# Simulation//Run variables
numNeurons = length(namesOfNeurons)
startTime = 0.0
endTime   = 3000.0
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## Vars
var_iDC = -1.05:0.01:-0.95
var_cell_num = 1:numNeurons

var_combos = allcombinations(var_iDC,var_cell_num)

## Save//Run vars
numSims = length(var_combos)
numDC = length(var_iDC)

## Initialize simParams
Params = Vector{simParams}(undef,numSims)

for i = 1:numSims
    iDC, cell_num = var_combos[i]

    p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

    # Vars
    p.g_L = g_L

    ## Inputs
    ### DC
    p.bias[cell_num] = iDC

    ## Synapses
    p.gj = gj

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

# Calculate Rin
Rin = zeros(numNeurons)
for i = 1:numNeurons
    vm = u[i,(1:numDC).+((i-1)*numDC)]
    fit1 = linear_fit(var_iDC,vm)
    Rin[i] = fit1[2]
end

return Rin
end #calcRin

