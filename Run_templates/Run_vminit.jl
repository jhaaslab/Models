using Models.TRNmodel
using OrdinaryDiffEq
using Plots: plot, plot!

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN1"]
numNeurons = length(namesOfNeurons)
startTime  = 0.0
endTime    = 5000.0
tspan = (startTime, endTime)
dt = 0.1

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## Initialize simParams
p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

# Vars
## inputs
for ii = 1:p.n
    ### DC
    p.bias[ii] = -2.0
end

prob = ODEProblem(dsim!, u0, tspan, p)

# Start sim
@time sol = solve(prob, VCAB3(), save_everystep = false)

u = sol[end]

end #main

u=main()

