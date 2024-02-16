
using Models.TRNnetwork
using OrdinaryDiffEq
using CurveFit
using JLD2

# Run scripts
include("run_scripts/calcRin.jl")
include("run_scripts/calcBias.jl")
include("run_scripts/calcUinit.jl")
include("run_scripts/calcCC.jl")

# Functions
gL_func(x) = 0.1 .- 0.9773x .+ 6.33x.^2
gL_adj(x)  = 0.0001.*(-0.2243 .- 254.5x .+ 35.73x.^2 .- 2.59x.^3)


# main program
function main()
# vars
namesOfNeurons = ["TRN$i" for i in 1:9]
numNeurons = length(namesOfNeurons)
allGc = 0.005:0.005:0.03
numGc = length(allGc)
Gc_sig = 0
numNets = 50

Rin_tgt = 6.239
vm_tgt  = -70


savepath = joinpath(pwd(),"ring")
if ~isdir(savepath)
    mkdir(savepath)

    jldsave(joinpath(savepath,"net_vars.jld2");namesOfNeurons,allGc,numNets)
end

gj   = fill(zeros(numNeurons,numNeurons),(numGc,numNets))
g_L  = fill(zeros(numNeurons),(numGc,numNets))
Rin  = fill(zeros(numNeurons),(numGc,numNets))

# Iterate networks
for m=1:numGc
    Gc = allGc[m]
    for n=1:numNets
        gj_tmp = constructGJ(numNeurons,Gc,Gc_sig);

        #Estimate Rin adjust
        g_L_tmp = gL_func(vec(sum(gj_tmp,dims=1)'))

        # Rin calculation//adjustment
        Rin_tmp = calcRin(namesOfNeurons,gj_tmp,g_L_tmp)

        Rin_diff = Rin_tmp.-Rin_tgt
        while any(abs.(Rin_diff)./Rin_tgt .> 0.001)
            #Adjust leak
            g_L_tmp = g_L_tmp.-gL_adj(Rin_diff)

            #Recalculate Rin
            Rin_tmp = calcRin(namesOfNeurons,gj_tmp,g_L_tmp)

            Rin_diff = Rin_tmp.-Rin_tgt
        end

        gj[m,n]  = gj_tmp
        g_L[m,n] = g_L_tmp
        Rin[m,n] = Rin_tmp
    end
end

save_object(joinpath(savepath,"gj.jld2"), gj)
save_object(joinpath(savepath,"g_L.jld2"),g_L)
save_object(joinpath(savepath,"Rin.jld2"),Rin)


# Calculate bias current
bias = calcBias(namesOfNeurons,gj,g_L,vm_tgt)

save_object(joinpath(savepath,"bias.jld2"),bias)

# Recalculate initial conditions
uinit = calcUinit(namesOfNeurons,gj,g_L,bias)

save_object(joinpath(savepath,"uinit.jld2"),uinit)

# Calculate CC
cc = calcCC(namesOfNeurons,gj,g_L,uinit)

save_object(joinpath(savepath,"cc.jld2"),cc)

return nothing
end #main

main()

