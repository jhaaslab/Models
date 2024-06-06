
using Models.TRNnetwork
using OrdinaryDiffEq
using JLD2, MAT


# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:9]
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 1000
dt = 0.1

## Initial conditions
u0, per_neuron = initialconditions(numNeurons)

## vars
var_

var_names  = [" "]
var_combos = allcombinations(var_,)

## Save//Run vars
perBlk = 100
reps   = 150

numBlks = Int(ceil(length(var_combos)/perBlk))

allBlks = [var_combos[(1:perBlk).+(perBlk*(i-1))] for i in 1:numBlks-1]
allBlks = vcat(allBlks, [var_combos[1+(perBlk*(numBlks-1)):end]])


varpath = joinpath(pwd(),"vars")
if ~isdir(varpath)
    mkdir(varpath)

    tmpBlk = 1
    save_object(joinpath(varpath,"tmpBlk.jld2"),tmpBlk)

    D_vars = Dict("namesOfNeurons"=>namesOfNeurons,
        "tspan"=>[convert(Float64,startTime), convert(Float64,endTime)],
        "dt"=>dt,
        "perBlk"=>convert(Float64,perBlk),
        "reps"=>convert(Float64,reps),
        "var_names"=>var_names,
        "var_combos"=>[convert(Float64,tup[k]) for tup in var_combos, k in 1:length(var_names)])
    matwrite(joinpath(varpath,"sim_vars.mat"),D_vars)
else
    tmpBlk = load_object(joinpath(varpath,"tmpBlk.jld2"))
end

resultspath = joinpath(pwd(),"results")
if ~isdir(resultspath)
    mkdir(resultspath)
end

datapath = joinpath(pwd(),"data")
if ~isdir(datapath)
    mkdir(datapath)
end

while tmpBlk <= numBlks
    Blk2run = allBlks[tmpBlk]
    numVars = length(Blk2run)

    Data = Vector{spkData}(undef,numVars)
    for ii = 1:numVars

    ## deconstruct vars
      = Blk2run[ii]

    ## Initialize simParams
    Params = Vector{simParams}(undef,reps)
    for i = 1:reps
        p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

        # Vars
        ## Inputs
        for n = 1:p.n
            ### DC
            p.bias[n] = 0.3
            ### noise
            p.tA[n]  = poissonP(80,endTime)
            p.A[n]   = 0.01.*randn(length(p.tA[n])).+0.1
            p.tAI[n] = poissonP(20,endTime)
            p.AI[n]  = 0.01.*randn(length(p.tAI[n])).+0.1
        end

        ## Synapses
        p.gj = constructGJ(p.n, 0.03, 0.0)

        Params[i] = p
    end

    save_object(joinpath(varpath,"simParams$tmpBlk"*"_"*"$ii.jld2"),Params)

    Results = Vector{simResults}(undef,reps)
    spks = fill([NaN],numNeurons,reps)
    @time Threads.@threads for i = 1:reps

        p = Params[i]

        prob = ODEProblem(dsim!,u0,(startTime,endTime),p)

        # Start sim
        sol = solve(prob,BS3(),saveat=dt,save_idxs=1:p.per_neuron:length(u0))

        vm = sol[1:p.n,:]
        t  = sol.t

        # Store Vm data
        Results[i] = simResults(namesOfNeurons,vm,i)

        # Extract spks
        for n=1:p.n
            spks[n,i] = findspks(vm[n,:],t)
        end
    end

    # save Vm data
    matwrite(joinpath(resultspath,"simResults$tmpBlk"*"_"*"$ii.mat"),Dict("simResults"=>Results))

    # Calculate FR
    FR = zeros(numNeurons,endTime)
    for n=1:numNeurons
        _, FR[n,:] = psthFR(reduce(vcat,spks[n,:]),endTime,reps,31)
    end

    # Store spkData
    Data[ii] = spkData(namesOfNeurons,spks,FR)
    end

    # Save spkData
    matwrite(joinpath(datapath,"spkData$tmpBlk.mat"),Dict("spkData"=>Data))

    tmpBlk += 1
    save_object(joinpath(varpath,"tmpBlk.jld2"),tmpBlk)
end

return nothing
end #main

main()

