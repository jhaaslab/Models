
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
gL_func(Gc) = 0.1 .- 0.9773Gc .+ 6.33Gc.^2
gL_adj(dRin)= 0.0001.*(-0.2243 .- 254.5dRin .+ 35.73dRin.^2 .- 2.59dRin.^3)


# main program
function main()
# vars
namesOfNeurons = ["TRN$i" for i in 1:9]
numNeurons = length(namesOfNeurons)
meanGc  = 0.005:0.005:0.03
numGc   = length(meanGc)
all_sigGc = 0.0:0.001:0.005
numNets = 50

Rin_tgt = 6.239
vm_tgt  = -70

for sigGc in all_sigGc

savepath = joinpath(pwd(),"rand_sig_0_00$(Int(sigGc*1000))")
if ~isdir(savepath)
    mkdir(savepath)

    jldsave(joinpath(savepath,"net_vars.jld2");namesOfNeurons,meanGc,sigGc,numNets)

    gj   = fill(zeros(numNeurons,numNeurons),(numGc,numNets))
    g_L  = fill(zeros(numNeurons),(numGc,numNets))
    Rin  = fill(zeros(numNeurons),(numGc,numNets))

    save_object(joinpath(savepath,"gj.jld2"), gj)
    save_object(joinpath(savepath,"g_L.jld2"),g_L)
    save_object(joinpath(savepath,"Rin.jld2"),Rin)

    saveBlk = 1
    save_object(joinpath(savepath,"saveBlk.jld2"),saveBlk)
else
    gj  = load_object(joinpath(savepath,"gj.jld2"))
    g_L = load_object(joinpath(savepath,"g_L.jld2"))
    Rin = load_object(joinpath(savepath,"Rin.jld2"))

    saveBlk = load_object(joinpath(savepath,"saveBlk.jld2"))
end

# Iterate networks
while saveBlk <= numGc
    Gc = meanGc[saveBlk]
    for n=1:numNets
        gj_tmp = constructGJ(numNeurons,Gc,sigGc)

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

        gj[saveBlk,n]  = gj_tmp
        g_L[saveBlk,n] = g_L_tmp
        Rin[saveBlk,n] = Rin_tmp
    end

    save_object(joinpath(savepath,"gj.jld2"), gj)
    save_object(joinpath(savepath,"g_L.jld2"),g_L)
    save_object(joinpath(savepath,"Rin.jld2"),Rin)

    saveBlk += 1
    save_object(joinpath(savepath,"saveBlk.jld2"),saveBlk)
end

# Calculate bias current
bias = calcBias(namesOfNeurons,gj,g_L,vm_tgt)

save_object(joinpath(savepath,"bias.jld2"),bias)

# Recalculate Rest
uinit = calcUinit(namesOfNeurons,gj,g_L)

save_object(joinpath(savepath,"uinit.jld2"),uinit)

# Calculate CC
cc = calcCC(namesOfNeurons,gj,g_L,uinit)

save_object(joinpath(savepath,"cc.jld2"),cc)
end

return nothing
end #main

main()

