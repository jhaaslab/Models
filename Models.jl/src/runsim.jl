
struct RunVars
    tspan::Number
    dt::Float64
    # vars::Dict{String,Any}
    var_names::Vector{String}
    var_combos::Vector{Tuple}
    per_block::Int
    reps::Int

    function RunVars(var_names, all_vars...;
        tspan = 1000,
        dt    = 0.1,
        reps  = 1)

        # vars = Dict(zip(var_names,all_vars[i] for i in eachindex(var_names)))

        if length(all_vars) >1 
            var_combos = allcombinations(all_vars...)
        else
            var_combos = all_vars
        end

        per_block = 100
        if reps >1
            per_block = 1
        end
        
        new(tspan,dt,var_names,var_combos,per_block,reps)
    end
end

function runsim(params::Model, vars::RunVars, param_func::Function; save_vm=false)
    # Setup directories
    dirs = Dict(
        "varpath"   => joinpath(pwd(),"vars"),
        "datapath"  => joinpath(pwd(),"data"),
        "resultpath"=> joinpath(pwd(),"results")
    )
    
    if ~isdir(dirs["varpath"])
        mkdir(dirs["varpath"])
    end

    if ~isdir(dirs["datapath"])
        mkdir(dirs["datapath"])
    end

    if save_vm && ~isdir(dirs["resultpath"])
        mkdir(dirs["resultpath"])
    end
        
    ## Initial conditions
    u0 = initialconditions(params)
   
    # Run
    if vars.reps > 1
        iterate_var_reps(params, vars, param_func, u0, dirs, save_vm)
    else
        iterate_vars(params, vars, param_func, u0, dirs, save_vm)
    end

    return nothing
end

function iterate_vars(params::Model, vars::RunVars, param_func::Function,
    u0::Vector{Float64}, dirs::Dict{String,String}, save_vm::Bool)

    n_total_vars = length(vars.var_combos)

    prog = Progress(n_total_vars,barglyphs=BarGlyphs("[=> ]"),barlen=35,showspeed=true)

    all_blocks = 1:n_total_vars
    all_blocks = [all_blocks[i:min(i + vars.per_block-1, end)] for i in 1:vars.per_block:n_total_vars]

    num_blocks = length(all_blocks)
    
    # resume if previous sim ran
    if isfile(joinpath(dirs["varpath"],"save_block.jld2"))
        save_block = load_object(joinpath(dirs["varpath"],"save_block.jld2"))

        update!(prog,(save_block-1)*vars.per_block)
    else
        save_block = 1
        
        D_vars = Dict("namesOfNeurons"=>params.names,
            "tspan"=>[0.0, convert(Float64,vars.tspan)],
            "dt"=>vars.dt,
            "perBlk"=>convert(Float64,vars.per_block),
            "reps"=>convert(Float64,vars.reps),
            "var_names"=>vars.var_names,
            "var_combos"=>[convert(Float64,tup[k]) for tup in vars.var_combos,
                k in 1:length(vars.var_names)]
        )
        matwrite(joinpath(dirs["varpath"],"sim_vars.mat"),D_vars)
    end
    
    # Start running blocks
    while save_block <= num_blocks
        this_block = all_blocks[save_block]
        num_vars = length(this_block)

        rng = Vector{Xoshiro}(undef,num_vars)

        if save_vm
            vmdata = Vector{VmData}(undef,num_vars)
        end

        all_spikes = Vector{SpikeData}(undef,num_vars)
        all_FR     = Vector{FRData}(undef,num_vars)
        
        # Run sims in parallel
        Threads.@threads for i in eachindex(this_block)
            # store rng state
            rng[i] = copy(Random.default_rng())

            p = param_func(params, vars.var_combos[this_block[i]])

            prob = ODEProblem(dsim!, u0, (0,vars.tspan), p)

            sol = solve(prob, VCAB3(), saveat=vars.dt, save_idxs=1:p.per_neuron:length(u0))

            vm = sol[1:p.n,:]
            t  = sol.t

            # Extract spks
            spikes = fill([NaN],params.n,vars.reps)
            for n=1:p.n
                spikes[n,vars.reps] = findspks(vm[n,:],t)
            end          

            all_spikes[i] = SpikeData(p.names,spikes)

            all_FR[i] = FRData(p.names,spikes,vars.tspan,1.0,vars.reps,31)

            # Store Vm data
            if save_vm
                vmdata[i] = VmData(p.names,vm,vars.reps)
            end
            
            next!(prog)
        end

        # Save rngs
        save_object(joinpath(dirs["varpath"],"rng$save_block.jld2"),rng)

        # save Vm data
        if save_vm
            matwrite(joinpath(dirs["resultpath"],"VmData$save_block.mat"),Dict("VmData"=>vmdata))
        end
        
        # save Spike data
        matwrite(joinpath(dirs["datapath"],"SpikeData$save_block.mat"),Dict("SpikeData"=>all_spikes))

        # save FR data
        matwrite(joinpath(dirs["datapath"],"FRData$save_block.mat"),Dict("FRData"=>all_FR))

        save_block += 1
        save_object(joinpath(dirs["varpath"],"save_block.jld2"),save_block)
    end
    
    finish!(prog)

    return nothing
end

function iterate_var_reps(params::Model, vars::RunVars, param_func::Function,
    u0::Vector{Float64}, dirs::Dict{String,String}, save_vm::Bool)

    n_total_vars = length(vars.var_combos) 
    n_total_sims = n_total_vars * vars.reps

    prog = Progress(n_total_sims,barglyphs=BarGlyphs("[=> ]"),barlen=35,showspeed=true)
   
    # resume if previous sim ran
    if isfile(joinpath(dirs["varpath"],"save_block.jld2"))
        save_block = load_object(joinpath(dirs["varpath"],"save_block.jld2"))
        
        update!(prog,(save_block-1)*vars.reps)
    else
        save_block = 1
        
        D_vars = Dict("namesOfNeurons"=>params.names,
            "tspan"=>[0.0, convert(Float64,vars.tspan)],
            "dt"=>vars.dt,
            "perBlk"=>convert(Float64,vars.per_block),
            "reps"=>convert(Float64,vars.reps),
            "var_names"=>vars.var_names,
            "var_combos"=>[convert(Float64,tup[k]) for tup in vars.var_combos,
                k in 1:length(vars.var_names)]
        )
        matwrite(joinpath(dirs["varpath"],"sim_vars.mat"),D_vars)
    end
    
    # Iterate vars
    while save_block <= n_total_vars
        rng = Vector{Xoshiro}(undef,vars.reps)

        if save_vm
            vmdata = Vector{VmData}(undef,vars.reps)
        end

        spikes = fill([NaN],params.n,vars.reps)

        # Run reps in parallel
        Threads.@threads for i in 1:vars.reps
            # save rng state
            rng[i] = copy(Random.default_rng())

            p = param_func(params, vars.var_combos[save_block])

            prob = ODEProblem(dsim!, u0, (0,vars.tspan), p)

            sol = solve(prob, VCAB3(), saveat=vars.dt, save_idxs=1:p.per_neuron:length(u0))

            vm = sol[1:p.n,:]
            t  = sol.t

            # Extract spks
            for n=1:p.n
                spikes[n,i] = findspks(vm[n,:],t)
            end
            
            # Store Vm data
            if save_vm
                vmdata[i] = VmData(p.names,vm,i)
            end

            next!(prog)
        end

        # Save rngs
        save_object(joinpath(dirs["varpath"],"rng$save_block.jld2"),rng)

        # save Vm data
        if save_vm
            matwrite(joinpath(dirs["resultpath"],"VmData$save_block.mat"),Dict("VmData"=>vmdata))
        end

        # save Spike data
        all_spikes = SpikeData(params.names,spikes)
        matwrite(joinpath(dirs["datapath"],"SpikeData$save_block.mat"),Dict("SpikeData"=>all_spikes))

        # save FR data
        all_FR = FRData(params.names,spikes,vars.tspan,1.0,vars.reps,31)
        matwrite(joinpath(dirs["datapath"],"FRData$save_block.mat"),Dict("FRData"=>all_FR))

        save_block += 1
        save_object(joinpath(dirs["varpath"],"save_block.jld2"),save_block)
    end
    
    finish!(prog)

    return nothing
end

