using Models.TRNmodel
using OrdinaryDiffEq
using Plots: plot, plot!

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN1","TRN2"]
numNeurons = length(namesOfNeurons)
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)
dt = 0.1

## Initial conditions
u0, per_neuron = initialconditions(numNeurons)

## Initialize simParams
p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

# Vars
## inputs
for ii = 1:p.n
    ### DC
    p.bias[ii] = 0.3

    p.iDC[ii]    = 1.0
    p.iStart[ii] = 100.0
    p.iStop[ii]  = 800.0;
end

prob = ODEProblem(dsim!, u0, tspan, p)

# Start sim
@time sol = solve(prob, VCAB3(), saveat=dt, save_idxs=1:p.per_neuron:length(u0))
end #main

sol = main()

# Plot Vm
plot(sol, idxs = 1)
plot(sol, idxs = 2)

