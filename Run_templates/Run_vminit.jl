
using Models.TRNmodel
using OrdinaryDiffEq

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN1"]
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 5000
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## Initialize simParams
p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

# Vars
## inputs
for ii = 1:p.n
    ### DC
    #p.bias[ii] = -2.0
end

prob = ODEProblem(dsim!, u0, tspan, p)

# Start sim
@time sol = solve(prob, BS3(), save_everystep = false)

u = sol[end]
return u
end #main

u=main()
