
function K_syn(v)
    k = 1.0/(1.0+exp(-(v+50.0)/2.0))

    return k
end

function poissonP(r,T)
    # POISSONP Poisson process for generating stochastic spike trains
    # Computes spike times for given rate(r) in Hz over total time(T) in ms
    dt = 0.1 # ms
    spks = zeros(Int(T*(1.0/dt)))
    R = rand(length(spks))
    tspks = findall(x -> x<r*dt/1000.0, R)/(1.0/dt)

    return tspks
end

function constructGJ(num_TRN,mu_gc,sig_gc)
    #CONSTRUCTGJ generate random coupling within TRN network
    #   Each cell makes 1-3 connections with P 0.45 0.5 0.05 respectively
    #   P synapse will favor cells with no GJs (0.2 bias)
    #   Coupling strength values are gaussian following mu,sig
    if sig_gc > mu_gc
        error("sigma larger than mean Gc, use a smaller value to prevent negative values")
    end

    gjMat=zeros(num_TRN,num_TRN)
    for i in randperm(num_TRN)
        r=rand()
        if r>=0.95
            numGJ=3
        elseif r>0.45 && r<0.95
            numGJ=2
        elseif r<=0.45
            numGJ=1
        end

        numGJ=numGJ-Int(sum(gjMat[:,i]))
        if numGJ<0
            numGJ=0
        end

        r2=rand(num_TRN)
        for ii=1:num_TRN
            if gjMat[i,ii]==1 || sum(gjMat[:,ii])>=3
                r2[ii]=0
            end
            if sum(gjMat[:,ii])==0
                r2[ii]+=0.2
            end
        end
        r2[i]=0

        idx=partialsortperm(r2, 1:numGJ, rev=true)
        gjMat[i,idx].=1

        gjMat = gjMat+gjMat'
        gjMat[gjMat.>1].=1
    end

    gjMat = UpperTriangular(gjMat)

    gc = sig_gc.*randn(size(gjMat)).+mu_gc
    gjMat = gjMat.*gc

    gjMat = gjMat+gjMat'

    return gjMat
end #constructGJ

function constructConnections(num_pairs,recip_prob,div_prob,A_mean,A_sig)
    #CONSTRUCTCONNECTIONS generate random synapses between TRN-TC networks
    #   Each possible location has prob of occuring, with recip_prob and 
    #   div_prob for connections between same cell pair and surrounding cells
    #   respectively. Synapse strength values are gaussian following mu, sig,
    #   normalized to total number of synapses recieved by each cell.

    connMat = zeros(num_pairs,num_pairs)
    R = rand(num_pairs,num_pairs)

    recipMat = Diagonal(R)
    recipMat = recipMat.>1-recip_prob

    divMat = R-Diagonal(R)
    divMat = divMat.>1-div_prob

    connMat = recipMat.+divMat

    A_mat = A_sig.*randn(size(connMat)).+ A_mean
    connMat = connMat.*A_mat ./ sum(connMat,dims=1)
    connMat[isnan.(connMat)].=0

    return connMat
end #constructConnections

