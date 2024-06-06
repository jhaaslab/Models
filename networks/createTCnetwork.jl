
using Models.TC_TRNnetwork
using OrdinaryDiffEq
using Statistics
using JLD2

# Run scripts
include("run_scripts/calcFR.jl")

# Functions
function Amp_func(Gc,A_TC)
    Gc_adj = -0.8523Gc .-76.41Gc.^2 .+ 1745Gc.^3
    TC_adj = -0.01525A_TC .-0.2125A_TC.^2 .+ 0.1952A_TC.^3
    return Gc_adj.+TC_adj
end

Amp_adj(dFR)  = 0.000001.*(0.2395 .+ 9009dFR .- 166.5dFR.^2)


# main program
function main()
# vars
all_sigGc = 0.001:0.001:0.005
for sigGc in all_sigGc

savepath = joinpath(pwd(),"rand_sig_0_00$(Int(sigGc*1000))")
vars = jldopen(joinpath(savepath,"net_vars.jld2"))
gj   = load_object(joinpath(savepath,"gj.jld2"))
g_L  = load_object(joinpath(savepath,"g_L.jld2"))
bias = load_object(joinpath(savepath,"bias.jld2"))

TRNnames = vars["namesOfNeurons"]
numTRN = length(TRNnames)

namesOfNeurons = [TRNnames; ["TC$i" for i in 1:numTRN]]
numNeurons = length(namesOfNeurons)
numTC = numTRN

numGc   = length(axes(gj,1))
numNets = length(axes(gj,2))

A_TC  = constructConnections(numTRN,1.0,0.0,0.5,0.0)
#AI_TRN = constructConnections(numTRN,1.0,0.0,1.0,0.0)


FR_tgt = 7.0 #Hz
A_noise_est = 0.1267 #change this to a func of FR_tgt

A_noise = fill(zeros(numNeurons),(numGc,numNets))
FR      = fill(zeros(numNeurons),(numGc,numNets))

if ~isfile(joinpath(savepath,"saveBlk.jld2"))
    saveBlk = 1
    save_object(joinpath(savepath,"saveBlk.jld2"),saveBlk)
else
    saveBlk = load_object(joinpath(savepath,"saveBlk.jld2"))
end

# Iterate networks
while saveBlk <= numGc
    m=saveBlk
    for n=1:numNets
        A_noise_tmp = [ A_noise_est.+Amp_func( vec(sum(gj[m,n],dims=1)') ,0.5)
                       [A_noise_est for i in 1:numTC] ]

        # FR calculation//adjustment
        counter = 1
        FR_tmp = calcFR(namesOfNeurons,gj[m,n],g_L[m,n],bias[m,n],A_TC,A_noise_tmp)

        FR_diff = FR_tmp.-FR_tgt
        while any(abs.(FR_diff)./FR_tgt .> 0.07) # +/- 0.5 Hz
            #Adjust noise
            A_noise_tmp = A_noise_tmp.-Amp_adj(FR_diff)

            #Recalculate FR
            FR_tmp = calcFR(namesOfNeurons,gj[m,n],g_L[m,n],bias[m,n],A_TC,A_noise_tmp)

            FR_diff = FR_tmp.-FR_tgt

            counter += 1
            if counter == 10
                break
            end
        end

        A_noise[m,n] = A_noise_tmp
        FR[m,n]      = FR_tmp
    end

    save_object(joinpath(savepath,"A_noise.jld2"),A_noise)
    save_object(joinpath(savepath,"FR.jld2"),FR)

    saveBlk += 1
    save_object(joinpath(savepath,"saveBlk.jld2"),saveBlk)
end

end

return nothing
end #main

main()

