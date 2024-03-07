
using Models.TRNmodel
using OrdinaryDiffEq
using MAT

# main program
function main()
# Simulation//Run variables
namesOfNeurons = ["TRN$i" for i in 1:1]
numNeurons = length(namesOfNeurons)
startTime  = 0.0
endTime    = 1000.0
tspan = (startTime, endTime)
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


savepath = joinpath(pwd(),"results")
if ~isdir(savepath)
    mkdir(savepath)

    tmpBlk = 1
    matwrite(joinpath(savepath,"tmpBlk.mat"),Dict("tmpBlk"=>tmpBlk))

    D_vars = Dict("namesOfNeurons"=>namesOfNeurons,
        "tspan"=>collect(tspan), "dt"=>dt,
        "var_names"=>var_names, "perBlk"=>convert(Float64,perBlk),
        "var_combos"=>[tup[k] for tup in var_combos, k in 1:length(var_names)])
    matwrite(joinpath(savepath,"sim_vars.mat"),D_vars;compress = true)
else
    D = matread(joinpath(savepath,"tmpBlk.mat"))
    tmpBlk = D["tmpBlk"]
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
        for ii = 1:p.n
            ### DC
            p.bias[ii] = iDC
        end

        Params[i] = p
    end

    u = zeros(numNeurons,length(startTime:dt:endTime),numSims)

    @time Threads.@threads for i = 1:numSims

        p = Params[i]

        prob = ODEProblem(dsim!,u0,tspan,p)

        # Start sim
        sol = solve(prob,BS3(),saveat=dt,save_idxs=1:p.per_neuron:length(u0))

        u[:,:,i]=sol[1:p.n,:]
    end

    # Save Vm data
    simResults = constructResults(u,Params)

    matwrite(joinpath(savepath,"simResults$tmpBlk.mat"),
                simResults;compress=true)

    tmpBlk += 1
    matwrite(joinpath(savepath,"tmpBlk.mat"),Dict("tmpBlk"=>tmpBlk))
end

return nothing
end #main

main()

