
function calcFR(namesOfNeurons,gj,g_L,bias,A_TC,A_noise)

# Simulation//Run variables
numNeurons = length(namesOfNeurons)
startTime  = 0
endTime    = 1000
dt = 0.1

## Initial conditions
u0, per_neuron = initialconditions(numNeurons)

## Save//Run vars
reps = 150

## Initialize simParams
Params = Vector{simParams}(undef,reps)

for i = 1:reps
    p = simParams(names=namesOfNeurons,n=numNeurons,per_neuron=per_neuron)

    # Vars
    p.g_L = [g_L; [0.1 for n in 1:p.nTC]]

    ## Inputs
    ### DC
    p.bias = [bias; [0.3 for n in 1:p.nTC]]
    for ii = 1:p.n
        ### noise
        p.tA[ii]  = poissonP(80,endTime)
        p.A[ii]   = 0.01.*randn(length(p.tA[ii])).+A_noise[ii]
        p.tAI[ii] = poissonP(20,endTime)
        p.AI[ii]  = 0.01.*randn(length(p.tAI[ii])).+0.1
    end

    ## Synapses
    p.A_TC   = A_TC
    #p.AI_TRN = AI_TRN
    p.gj     = gj

    Params[i] = p
end

spks = fill([NaN],numNeurons,reps)

@time Threads.@threads for i = 1:reps

    p = Params[i]

    prob = ODEProblem(dsim!,u0,(startTime,endTime),p)

    # Start sim
    sol = solve(prob,VCAB3(),saveat=dt,save_idxs=1:p.per_neuron:length(u0))

    # Extract spks
    vm = sol[1:p.n,:]
    t  = sol.t

    for n=1:p.n
        spks[n,i] = findspks(vm[n,:],t)
    end
end

# Calculate FR
meanFR = zeros(numNeurons)
for n=1:numNeurons
    _, FR = psthFR(reduce(vcat,spks[n,:]),endTime,reps,31)
    meanFR[n] = mean(FR[400:900])
end

return meanFR
end #calcFR

