#Izhikevichch Model
using OrdinaryDiffEq
using Plots: plot, plot!

function izh!(du, u, p, t)
    a, b, c, d, I = p

    du[1] = 0.04 * u[1]^2 + 5 * u[1] + 140 - u[2] + I
    du[2] = a * (b * u[1] - u[2])
end

function thr(u, t, integrator)
    integrator.u[1] >= 30
end

function reset!(integrator)
    integrator.u[1] = integrator.p[3]
    integrator.u[2] += integrator.p[4]
end

threshold = DiscreteCallback(thr, reset!)
current_step = PresetTimeCallback(50, integrator -> integrator.p[5] += 1)
cb = CallbackSet(current_step, threshold)

p = [0.02, 0.25, -65, 0.5, 0]
u0 = [-65, p[2] * -65]
tspan = (0.0, 1000)

prob = ODEProblem(izh!, u0, tspan, p, callback = cb)

@time sol = solve(prob);
plot(sol, idxs = 1)