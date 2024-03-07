
using Models.TRNnetwork
using OrdinaryDiffEq
using MAT


# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:9]
numNeurons = length(namesOfNeurons)
startTime  = 0.0
endTime    = 1000.0
dt = 0.1
tspan = (startTime, endTime)

## Initial conditions
u0, per_neuron = initialconditions(numNeurons)

## vars
var_

var_names = [" "]
var_combos = allcombinations(var_,)

## Save//Run vars
numBlocks = length(var_combos)
reps = 150

savepath = joinpath(pwd(),"results")
if ~isdir(savepath)
    mkdir(savepath)

    tmpBlock = 1
    matwrite(joinpath(savepath,"tmpBlock.mat"),Dict("tmpBlock"=>tmpBlock))

    D_vars = Dict("namesOfNeurons"=>namesOfNeurons,
        "tspan"=>collect(tspan), "dt"=>dt,
        "var_names"=>var_names, "reps"=>convert(Float64,reps),
        "var_combos"=>[tup[k] for tup in var_combos, k in 1:length(var_names)])
    matwrite(joinpath(savepath,"sim_vars.mat"),D_vars;compress = true)
else
    D = matread(joinpath(savepath,"tmpBlock.mat"))
    tmpBlock = D["tmpBlock"]
end


# Start running blocks
while tmpBlock <= numBlocks

    ## deconstruct vars
      = var_combos[tmpBlock]

    ## Initialize simParams
    Params = Vector{simParams}(undef,reps)

    for i = 1:reps
        p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

        # Vars
        ## Inputs
        for ii = 1:p.n
            ### DC
            p.bias[ii] = 0.3
            ### noise
            p.tA[ii]  = poissonP(80,endTime)
            p.A[ii]   = 0.0.*randn(length(p.tA[ii])).+0.5
            p.tAI[ii] = poissonP(20,endTime)
            p.AI[ii]  = 0.0.*randn(length(p.tAI[ii])).+0.5
        end

        Params[i] = p
    end

    u = zeros(numNeurons,length(startTime:dt:endTime),reps)

    @time Threads.@threads for i = 1:reps

        p = Params[i]

        prob = ODEProblem(dsim!,u0,tspan,p)

        # Start sim
        sol = solve(prob,BS3(),saveat=dt,save_idxs=1:p.per_neuron:length(u0))

        u[:,:,i]=sol[1:p.n,:]
    end

    # Save Vm data
    simResults = constructResults(u,Params)

    matwrite(joinpath(savepath,"simResults$tmpBlock.mat"),
             simResults;compress = true)

    tmpBlock += 1
    matwrite(joinpath(savepath,"tmpBlock.mat"),Dict("tmpBlock"=>tmpBlock))
end

return nothing
end #main

main()

