#
include("TRN_network.jl")

using .TRN_network
using OrdinaryDiffEq
using MAT

namesOfNeurons = ["TRN1","TRN2","TRN3","TRN4","TRN5","TRN6","TRN7","TRN8","TRN9",
                  "TC1", "TC2", "TC3", "TC4", "TC5", "TC6", "TC7", "TC8", "TC9" ]
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)

reps = 100;

tlocal = zeros(9)

for n = 1:9
    n_names = [namesOfNeurons[1:n]; namesOfNeurons[10:9+n]]
    numNeurons = length(n_names)

    ## Initial conditions
    u0, per_neuron = initialconditions(numNeurons,false)


    tlocal[n] = @elapsed Threads.@threads for i = 1:reps
        # Initialize simParams
        p = simParams(names=n_names,n=numNeurons,per_neuron=per_neuron)

        # Vars 
        ## Inputs
        for ii = 1:p.n
            #= DC
            p.bias[ii] = 0.3
            =#
            p.iDC[ii] = 1.0
            p.iStart[ii] = 200.0
            p.iStop[ii] = 800.0
            #= noise
            p.A[ii] = 0.2
            p.tA[ii] = poissonP(80,endTime)
            p.AI[ii] = 0.2
            p.tAI[ii] = poissonP(20,endTime)
            =#
        end

        prob = ODEProblem(dsim!, u0, tspan, p)

        # Start sim
        sol = solve(prob, VCAB3(), saveat=0.1, save_idxs=1:p.per_neuron:length(u0))

    end
end

matwrite(string(pwd(),"\\exec_time_net_nonoise.mat"),Dict("tlocal"=>tlocal))

#=
include("TRN_simple.jl")

using .TRN_simple
using OrdinaryDiffEq
using MAT

namesOfNeurons = ["TRN1","TRN2","TRN3","TRN4","TRN5","TRN6","TRN7","TRN8","TRN9",
         "TRN10","TRN11","TRN12","TRN13","TRN14","TRN15","TRN16","TRN17","TRN18"]
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)

reps = 100;

tlocal = zeros(9)

for n = 1:9
    n_names = namesOfNeurons[1:n*2]
    numNeurons = length(n_names)

    ## Initial conditions
    u0, per_neuron = initialconditions(numNeurons,false)


    tlocal[n] = @elapsed Threads.@threads for i = 1:reps
        # Initialize simParams
        p = simParams(names=n_names,n=numNeurons,per_neuron=per_neuron)

        # Vars 
        ## Inputs
        for ii = 1:p.n
            #= DC
            p.bias[ii] = 0.3
            =#
            p.iDC[ii] = 1.0
            p.iStart[ii] = 200.0
            p.iStop[ii] = 800.0
            #= noise
            p.A[ii] = 0.2
            p.tA[ii] = poissonP(80,endTime)
            p.AI[ii] = 0.2
            p.tAI[ii] = poissonP(20,endTime)
            =#
        end

        prob = ODEProblem(dsim!, u0, tspan, p)

        # Start sim
        sol = solve(prob, VCAB3(), saveat=0.1, save_idxs=1:p.per_neuron:length(u0))

    end
end

matwrite(string(pwd(),"\\exec_time_simple_nonoise.mat"),Dict("tlocal"=>tlocal))
=#