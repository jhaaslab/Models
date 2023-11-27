using OrdinaryDiffEq
using Plots: plot, plot!

# Potassium ion-channel rate functions
alpha_n(v) = (0.02 * (v - 25.0)) / (1.0 - exp((-1.0 * (v - 25.0)) / 9.0))
beta_n(v) = (-0.002 * (v - 25.0)) / (1.0 - exp((v - 25.0) / 9.0))

# Sodium ion-channel rate functions
alpha_m(v) = (0.182 * (v + 35.0)) / (1.0 - exp((-1.0 * (v + 35.0)) / 9.0))
beta_m(v) = (-0.124 * (v + 35.0)) / (1.0 - exp((v + 35.0) / 9.0))

alpha_h(v) = 0.25 * exp((-1.0 * (v + 90.0)) / 12.0)
beta_h(v) = (0.25 * exp((v + 62.0) / 6.0)) / exp((v + 90.0) / 12.0)

# n, m & h steady-states
n_inf(v) = alpha_n(v) / (alpha_n(v) + beta_n(v))
m_inf(v) = alpha_m(v) / (alpha_m(v) + beta_m(v))
h_inf(v) = alpha_h(v) / (alpha_h(v) + beta_h(v))


function Iapp_f(I,t,(Istart,Istop))
    if t >= Istart && t<= Istop
        return -I
    else
        return 0.0
    end
end


function HH!(du, u, p, t)
    gK, gNa, gL, EK, ENa, EL, C, I, Istart, Istop = p
    v, n, m, h = u

    Iapp = Iapp_f(I,t,(Istart,Istop))

    du[1] = (-(gK * (n^4.0) * (v - EK)) - (gNa * (m^3.0) * h * (v - ENa)) -
             (gL * (v - EL)) - Iapp) / C
    du[2] = (alpha_n(v) * (1.0 - n)) - (beta_n(v) * n)
    du[3] = (alpha_m(v) * (1.0 - m)) - (beta_m(v) * m)
    du[4] = (alpha_h(v) * (1.0 - h)) - (beta_h(v) * h)
    nothing
end

function main()
tspan = (0.0, 1000.0)
dt = 0.1

I = 1.0; Istart = 100.0; Istop = 800.0
p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1.0, I, Istart, Istop]
u0 = [-60, n_inf(-60), m_inf(-60), h_inf(-60)]

prob = ODEProblem(HH!, u0, tspan, p)

sol = solve(prob,BS3(),saveat=dt)
sol
end #main

@time sol = main()

plot(sol,idxs=1)
