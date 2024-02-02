#=
using Models.TRNmodel
using OrdinaryDiffEq
using MAT


function main()
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)
numNeurons = [collect(2:2:18); 100]

reps = 100

tlocal = zeros(length(numNeurons))

for n in eachindex(numNeurons)
    namesOfNeurons = ["TRN$i" for i in 1:numNeurons[n]]

    ## Initial conditions
    u0, per_neuron = initialconditions(numNeurons[n],false)

    ## Initialize simParams
    Params = Vector{simParams}(undef,reps)

    for i = 1:reps
        p = simParams(names=namesOfNeurons,n=numNeurons[n],per_neuron=per_neuron)

        # Vars
        ## Inputs
        for ii = 1:p.n
            p.iDC[ii] = 1.0
            p.iStart[ii] = [200.0]
            p.iStop[ii]  = [800.0]
        end

        Params[i] = p
    end

    tlocal[n] = @elapsed Threads.@threads for i = 1:reps
        p = Params[i]

        prob = ODEProblem(dsim!, u0, tspan, p)

        # Start sim
        solve(prob,BS3(),save_everystep=false,save_idxs=1:p.per_neuron:length(u0))
    end
end

matwrite(joinpath(pwd(),"texec_model_nonoise.mat"),Dict("tlocal"=>tlocal))

=#

using Models.TC_TRNnetwork
using OrdinaryDiffEq
using MAT

function main()
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)
numNeurons = [collect(2:2:18); 100]

reps = 100

tlocal = zeros(length(numNeurons))

for n in eachindex(numNeurons)
    namesOfNeurons = [["TRN$i" for i in 1:div(numNeurons[n],2)]; ["TC$i" for i in 1:div(numNeurons[n],2)]]
    ## Initial conditions
    u0, per_neuron = initialconditions(numNeurons[n])

    ## Initialize simParams
    Params = Vector{simParams}(undef,reps)

    for i = 1:reps
        p = simParams(names=namesOfNeurons,n=numNeurons[n],per_neuron=per_neuron)

        # Vars
        ## Inputs
        for ii = 1:p.n
            p.bias[ii] = 0.3
            # noise
            p.A[ii] = 0.5
            p.tA[ii] = poissonP(80,endTime)
            p.AI[ii] = 0.5
            p.tAI[ii] = poissonP(20,endTime)
        end

        Params[i] = p
    end

    tlocal[n] = @elapsed Threads.@threads for i = 1:reps
        p = Params[i]

        prob = ODEProblem(dsim!, u0, tspan, p)

        # Start sim
        solve(prob,BS3(),save_everystep=false,save_idxs=1:p.per_neuron:length(u0))
    end
end

matwrite(joinpath(pwd(),"texec_TC_TRNnet_noise.mat"),Dict("tlocal"=>tlocal))




tlocal = zeros(length(numNeurons))

for n in eachindex(numNeurons)
    namesOfNeurons = [["TRN$i" for i in 1:div(numNeurons[n],2)]; ["TC$i" for i in 1:div(numNeurons[n],2)]]

    ## Initial conditions
    u0, per_neuron = initialconditions(numNeurons[n],false)

    ## Initialize simParams
    Params = Vector{simParams}(undef,reps)

    for i = 1:reps
        p = simParams(names=namesOfNeurons,n=numNeurons[n],per_neuron=per_neuron)

        # Vars
        ## Inputs
        for ii = 1:p.n
            p.iDC[ii] = 1.0
            p.iStart[ii] = [200.0]
            p.iStop[ii]  = [800.0]
        end

        Params[i] = p
    end

    tlocal[n] = @elapsed Threads.@threads for i = 1:reps
        p = Params[i]

        prob = ODEProblem(dsim!, u0, tspan, p)

        # Start sim
        solve(prob,BS3(),save_everystep=false,save_idxs=1:p.per_neuron:length(u0))
    end
end

matwrite(joinpath(pwd(),"texec_TC_TRNnet_nonoise.mat"),Dict("tlocal"=>tlocal))


nothing
end #main

main()

