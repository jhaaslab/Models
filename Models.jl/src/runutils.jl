allcombinations(v...) = vec(collect(Iterators.product(v...)))

function findspks(vm::Vector{Float64}, t::Vector{Float64})
    spks = [NaN]

    pks,_ = findmaxima(vm)
    peakproms!(pks, vm; min=50)

    spks = t[pks]

    return spks
end

function psth(spks::Vector{Float64}; tspan::Integer, bin_window::Float64, n_trials::Integer,
    window_width::Integer)
    # Calculates psth over tspan (ms) with bin window (ms) over n_trials,
    # smoothed with hanning window of size win_width (ms)
    edges   = 0:bin_window:tspan
    centers = bin_window/2:bin_window:tspan

    win_width = Int(div(window_width,bin_window))

    counts, _ = histcountindices(spks,edges)
    counts = counts./n_trials

    sm_win = hanning(win_width)

    psth = conv(counts, sm_win)./sum(sm_win)

    #get center convolution
    offset = Int(div(win_width-1,2))
    psth = psth[offset+1:length(centers)+offset]

    #Alternative center conv, (slower method, dep: ImageFiltering)
    #psth = imfilter(counts, reflect(centered(sm_win)), Fill(0))

    return centers, psth
end

struct VmData
    rep::Int64
    data::Dict{String, Vector{Float64}}

    function VmData(names::Vector{String}, vm::Matrix{Float64}, rep::Int64)
        data = Dict(zip(names,[vm[i,:] for i in eachindex(names)]))
        new(rep,data)
    end
end

struct SpikeData
    spiketimes::Dict{String, Vector{Vector{Float64}}}

    function SpikeData(names::Vector{String}, spikes::Matrix{Vector{Float64}})
        spiketimes = Dict(zip(names,[spikes[i,:] for i in eachindex(names)]))
        new(spiketimes)
    end
end

struct FRData
    dt::Float64
    FR::Dict{String, Vector{Float64}}

    function FRData(names::Vector{String}, spikes::Matrix{Vector{Float64}},
        tspan::Integer, dt::Float64, n_trials::Integer, window_width::Integer)

        num_neurons = length(names)
        
        # Calculate FR
        FR = zeros(num_neurons,Int(round(tspan/dt)))
        for n=1:num_neurons
            _, FR[n,:] = psth(reduce(vcat,spikes[n,:]),
                tspan=tspan,bin_window=dt,
                n_trials=n_trials,window_width=window_width)
        end

        #convert to Hz
        FR .= FR.*1000
        
        new(dt,Dict(zip(names,[FR[i,:] for i in eachindex(names)])))
    end
end
