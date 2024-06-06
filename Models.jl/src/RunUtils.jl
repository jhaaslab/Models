allcombinations(v...) = vec(collect(Iterators.product(v...)))

function findspks(vm::Vector{Float64},t::Vector{Float64})
    spks = [NaN]

    pks,_ = findmaxima(vm)
    peakproms!(pks, vm; min=50)

    spks = t[pks]

    return spks
end # findspks

function psthFR(spks::Vector{Float64},tspan::Integer,n_trials::Integer,win_width::Integer)
    # Calculates FR from psth over n_trials, smoothed with hanning window of size win_width
    edges   = 0:1:tspan
    centers = 0.5:1:tspan

    counts, _ = histcountindices(spks,edges)
    counts = counts./n_trials

    sm_win = hanning(win_width)

    psth = conv(counts, sm_win)./sum(sm_win)

    #get center convolution
    offset = floor(div(win_width-1,2))
    psth = psth[offset+1:tspan+offset]

    #Alternative center conv, (slower method, dep: ImageFiltering)
    #psth = imfilter(counts, reflect(centered(sm_win)), Fill(0))

    psth = psth.*1000 #convert to Hz
    return centers, psth
end # return_psth

struct simResults
    rep::Int64
    data::Dict{String, Vector{Float64}}

    function simResults(names::Vector{String},vm::Matrix{Float64},rep::Int64)
        data = Dict(zip(names,[vm[i,:] for i in eachindex(names)]))
        new(rep,data)
    end
end

struct spkData
    spktime::Dict{String, Vector{Vector{Float64}}}
    FR::Dict{String, Vector{Float64}}

    function spkData(names::Vector{String},spks::Matrix{Vector{Float64}},FR::Matrix{Float64})
        spktime = Dict(zip(names,[spks[i,:] for i in eachindex(names)]))

        FR = Dict(zip(names,[FR[i,:] for i in eachindex(names)]))
        new(spktime,FR)
    end
end
