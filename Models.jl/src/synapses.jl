
k_syn(v) = 1.0/(1.0+exp(-(v+50.0)/2.0))

function poisson_process(rate::Number, tspan::Number;
    bin_width::Float64 = 0.1)
    # Poisson process for generating stochastic spike trains
    # Computes spike times for given rate (Hz) over total time (ms)
    # binned by size bin_width (ms)
    
    n_total_bins = Int(floor(tspan*1.0/bin_width))
    
    R = rand(n_total_bins)
    
    tspks = findall(x -> x<rate*bin_width/1000.0, R)/(1.0/bin_width)

    return tspks
end

function construct_gj_net(num_TRN::Int; mean_gc::Float64, sigma_gc::Float64=0.0,
    normalize::String="none")
    # generate random coupling within TRN network
    # Each cell makes 1-3 connections with P 0.45 0.5 0.05 respectively
    # P synapse will favor cells with no GJs (0.2 bias)
    # Coupling strength values are gaussian following mu,sig
    # optionally normalized to total number of synapses || by each cell.

    if sigma_gc*3 > mean_gc
        error("Smaller sigma value needed to prevent negative amplitude values")
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

    gcMat = sigma_gc.*randn(size(gjMat)).+mean_gc
    gcMat[gcMat.<0.0].=0.0

    gcMat = gjMat.*gcMat
    gcMat = gcMat+gcMat'

    if normalize == "none"
        gjMat=gcMat
        
    elseif normalize == "per-cell"
        gjMat = gjMat+gjMat'
        gjMat = gcMat ./ sum(gjMat,dims=1)
        gjMat[isnan.(gjMat)].=0
        
    elseif normalize == "all"
        gjMat = gcMat ./ sum(gjMat)
        gjMat[isnan.(gjMat)].=0
        
    else
        error("Not a valid normalization method: all | per-cell | none")
    end

    return gjMat
end

function construct_syn_net(num_pairs::Int; recip_prob::Float64, div_prob::Float64,
    mean::Float64, sigma::Float64=0.0, normalize::String="none")
    # generate random synapses between TRN-TC networks
    # Each possible location has prob of occuring, with recip_prob and
    # div_prob for connections between same cell pair and surrounding cells
    # respectively. Synapse strength values are gaussian following mu, sig,
    # optionally normalized to total number of synapses || by each cell.

    if sigma*3 > mean
        error("Smaller sigma value needed to prevent negative amplitude values")
    end

    connMat = zeros(num_pairs,num_pairs)
    R = rand(num_pairs,num_pairs)

    recipMat = Diagonal(R)
    recipMat = recipMat.>1-recip_prob

    divMat = R-Diagonal(R)
    divMat = divMat.>1-div_prob

    connMat = recipMat.+divMat

    ampMat = sigma.*randn(size(connMat)).+ mean
    ampMat[ampMat.<0.0].=0.0

    if normalize == "none"
        connMat = connMat.*ampMat

    elseif normalize == "per-cell"
        connMat = connMat.*ampMat ./ sum(connMat,dims=1)
        connMat[isnan.(connMat)].=0
        
    elseif normalize == "all"
        connMat = connMat.*ampMat ./ sum(connMat)
        connMat[isnan.(connMat)].=0

    else
        error("Not a valid normalization method: all | per-cell | none")
    end

    return connMat
end

