using Models.TC_TRNnetwork
using OrdinaryDiffEq
using Plots: plot, plot!


# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:9]
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
    ### noise
    p.A[ii] = 0.5
    p.tA[ii] = poissonP(80,endTime)
    p.AI[ii] = 0.5
    p.tAI[ii] = poissonP(20,endTime)
end

prob = ODEProblem(dsim!, u0, tspan, p)

# Start sim
sol = solve(prob, BS3(), saveat=dt, save_idxs=1:p.per_neuron:length(u0))

sol
end #main

@time sol = main()

# Plot Vm
plot(sol, idxs = 1)

