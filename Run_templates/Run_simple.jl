
using Models.TC_TRNnetwork
using OrdinaryDiffEq
using Plots


# main program
function main()
# Simulation//Run variables
namesOfNeurons = [["TRN$i" for i in 1:9]; ["TC$i" for i in 1:9]]
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 1000
dt = 0.1
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons)

## Initialize simParams
p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

# Vars
## inputs

for ii = 1:p.n
    #
    ### DC
    p.bias[ii] = 0.3
    ### noise
    p.tA[ii]  = poissonP(80,endTime)
    p.A[ii]   = 0.01.*randn(length(p.tA[ii])).+0.1
    p.tAI[ii] = poissonP(20,endTime)
    p.AI[ii]  = 0.01.*randn(length(p.tAI[ii])).+0.1
    #
end


prob = ODEProblem(dsim!, u0, tspan, p)

# Start sim
@time sol = solve(prob, VCAB3(), saveat=dt, save_idxs=1:p.per_neuron:length(u0))

return sol
end #main

sol = main()

# Plot Vm
plot(sol, idxs = 1)

