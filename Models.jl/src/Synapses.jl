
function K_syn(v)
    k = 1.0/(1.0+exp(-(v+50.0)/2.0));
    k
end

function poissonP(r,T)
    # POISSONP Poisson process for generating stochastic spike trains
    # Computes spike times for given rate(r) in Hz over total time(T) in ms
    dt = 0.1 # ms
    spks = zeros(Int(T*(1.0/dt)))
    R = rand(length(spks))
    tspks = findall(x -> x<r*dt/1000.0, R)/(1.0/dt)
    tspks
end


