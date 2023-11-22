allcombinations(v...) = vec(collect(Iterators.product(v...)))

function constructResults(u, Params)
    numSims = axes(u,3)

    D_results = Vector{Dict}(undef,numSims)

    for i in numSims

        vmdata = u[:,:,i]
        vmdata = [vmdata[i, :] for i in axes(vmdata,1)]

        D_results[i] = Dict("rep" => i,
            "simParams" => Params[i],
            "data" => Dict(zip(Params[i].names,vmdata)))
    end

    simResults = Dict("simResults"=>D_results)
    simResults
end

function meanvm(u,t,(t1,t2))
    numNeurons = axes(u,1)
    numSims    = axes(u,3)
    vmdata = u[:,(t.>=t1) .* (t.<=t2),:]

    vm = zeros(numNeurons,numSims)

    for i in numSims
        vm_i = vmdata[:,:,i]

        vm[:,i] = mean(vm_i,dims=2)
    end

    vm
end

