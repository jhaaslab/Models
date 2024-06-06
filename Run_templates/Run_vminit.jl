
using Models.TRNmodel
using OrdinaryDiffEq

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:1]
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 1000

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## Initialize simParams
p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

prob = ODEProblem(dsim!, u0, (startTime, endTime), p)

# Start sim
@time sol = solve(prob, BS3(), save_everystep = false)

u = sol[end]

return u
end #main

u=main()

