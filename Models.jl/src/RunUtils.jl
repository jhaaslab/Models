allcombinations(v...) = vec(collect(Iterators.product(v...)))

function constructResults(u, Params)
    numNeurons = axes(u,1)
    numSims = axes(u,3)
    vmdata = @views u

    D_results = Vector{Dict}(undef,length(numSims))

    for i in numSims
        #vmdata = @views u[:,:,i]
        vm = [vmdata[n,:,i] for n in numNeurons]

        D_results[i] = Dict("rep" => i,
            "simParams" => Params[i],
            "data" => Dict(zip(Params[i].names,vm)))
    end

    simResults = Dict("simResults"=>D_results)
    simResults
end

function meanvm!(vm,u,t,(t1,t2))
    numNeurons = axes(u,1)
    numSims    = axes(u,3)
    vmdata = @views u[:,(t.>=t1) .* (t.<=t2),:]

    #vm = zeros(numNeurons,numSims)

    for i in numSims
        vm_i = vmdata[:,:,i]

        #vm[:,i] = mean(vm_i,dims=2)
        vm[:,i] = mean!(vm[:,i],vm_i)
    end

    #vm
    nothing
end

