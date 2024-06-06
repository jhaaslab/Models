
using Models.TRNmodel
using OrdinaryDiffEq
using JLD2, MAT

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:1]
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 1000
dt = 0.1

## Initial conditions
u0, per_neuron = initialconditions(numNeurons,false)

## vars
var_ = 

var_names = [""]
var_combos = allcombinations(var_, )

## Save//Run vars
perBlk = 150

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
        "var_names"=>var_names,
        "perBlk"=>convert(Float64,perBlk),
        "var_combos"=>[convert(Float64,tup[k]) for tup in var_combos, k in 1:length(var_names)])
    matwrite(joinpath(varpath,"sim_vars.mat"),D_vars)
else
    tmpBlk = load_object(joinpath(varpath,"tmpBlk.jld2"))
end

resultspath = joinpath(pwd(),"results")
if ~isdir(resultspath)
    mkdir(resultspath)
end


# Start running blocks
while tmpBlk <= numBlks

    Blk2run = allBlks[tmpBlk]
    numSims = length(Blk2run)

    ## Initialize simParams
    Params = Vector{simParams}(undef,numSims)
    for i = 1:numSims
        p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

        ## deconstruct vars
        iDC = Blk2run[i]

        # Vars
        ## Inputs
        for n=1:p.n
            ### DC
            p.bias[n] = iDC
        end

        Params[i] = p
    end

    save_object(joinpath(varpath,"simParams$tmpBlk.jld2"),Params)

    # Run sims in parallel
    Results = Vector{simResults}(undef,numSims)
    @time Threads.@threads for i = 1:numSims

        p = Params[i]

        prob = ODEProblem(dsim!,u0,(startTime,endTime),p)

        # Start sim
        sol = solve(prob,BS3(),saveat=dt,save_idxs=1:p.per_neuron:length(u0))

        vm = sol[1:p.n,:]

        # Store Vm data
        Results[i] = simResults(namesOfNeurons,vm,i)
    end

    # save Vm data
    matwrite(joinpath(resultspath,"simResults$tmpBlk.mat"),Dict("simResults"=>Results))

    tmpBlk += 1
    save_object(joinpath(varpath,"tmpBlk.jld2"),tmpBlk)
end

return nothing
end #main

main()

