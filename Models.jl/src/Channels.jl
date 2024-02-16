
function Na_t(v, m, h)
    minf_nat = 1.0/(1.0 + exp((-v - 38.0)/10.0))
    if v<= -30.0
        tau_m_nat = 0.0125 + 0.1525*exp((v+30.0)/10.0)
    else
        tau_m_nat = 0.02 + 0.145*exp((-v-30.0)/10.0)
    end
    hinf_nat = 1.0/(1.0 + exp((v + 58.3)/6.7))
    tau_h_nat = 0.225 + 1.125/(1.0+exp((v+37.0)/15.0))
    dm = -(1.0/tau_m_nat) * (m - minf_nat)
    dh = -(1.0/tau_h_nat) * (h - hinf_nat)

    return dm, dh
end

function Na_p(v, m)
    minf_nap = 1.0/(1.0+exp((-v-48.0)/10.0))
    if v<= -40.0
        tau_m_nap = 0.025 + 0.14*exp((v+40.0)/10.0)
    else
        tau_m_nap = 0.02 + 0.145*exp((-v-40.0)/10.0)
    end
    dm = -(1.0/tau_m_nap) * (m - minf_nap)

    return dm
end

function K_rect(v, m)
    minf_kd = 1.0/(1.0+exp((-v-27.0)/11.5))
    if v<= -10.0
        tau_m_kd = 0.25 + 4.35*exp((v+10.0)/10.0)
    else
        tau_m_kd = 0.25 + 4.35*exp((-v-10.0)/10.0)
    end
    dm = -(1.0/tau_m_kd) * (m - minf_kd)

    return dm
end

function K_A(v, m, h)
    minf_kt = 1.0/(1.0+exp((-v-60.0)/8.5))
    tau_m_kt = 0.185 + 0.5/(exp((v+35.8)/19.7) + exp((-v-79.0)/12.7))
    hinf_kt = 1.0/(1.0+exp((v+78.0)/6.0))
    if v<= -63.0
        tau_h_kt = 0.5/(exp((v+46.0)/5.0) + exp((-v-238.0)/37.5))
    else
        tau_h_kt = 9.5
    end
    dm = -(1.0/tau_m_kt) * (m - minf_kt)
    dh = -(1.0/tau_h_kt) * (h - hinf_kt)

    return dm, dh
end

function K2(v, m, h)
    minf_k2 = 1.0/(1.0+exp((-v-10.0)/17.0))
    tau_m_k2 = 4.95 + 0.5/(exp((v-81.0)/25.6) + exp((-v-132.0)/18.0))
    hinf_k2 = 1.0/(1.0+exp((v+58.0)/10.6))
    tau_h_k2 = 60.0 + 0.5/(exp((v - 1.33)/200.0) + exp((-v-130.0)/7.1))
    dm = -(1.0/tau_m_k2) * (m - minf_k2)
    dh = -(1.0/tau_h_k2) * (h - hinf_k2)

    return dm, dh
end

function Ca_T(v, m, h)
    minf_ca_lts = 1.0/(1.0+exp((-v-47.0)/7.4))   #traub, right shifted 5 mv
    tau_m_ca_lts = 1.0 + 0.33/(exp((v+27.0)/10.0) + exp((-v-102.0)/15.0))
    hinf_ca_lts = 1.0/(1.0+exp((v+80.0)/5.0))
    tau_h_ca_lts = 28.3 + 0.33/(exp((v+48.0)/4.0) + exp((-v-407.0)/50.0))
    dm = -(1.0/tau_m_ca_lts) * (m - minf_ca_lts)
    dh = -(1.0/tau_h_ca_lts) * (h - hinf_ca_lts)

    return dm, dh
end

function AR(v, m)
    minf_ar = 1.0/(1.0+exp((v+75.0)/5.5))
    tau_m_ar = 1.0/(exp(-14.6  - 0.086*v) + exp(-1.87 + 0.07*v))
    dm = -(1.0/tau_m_ar) * (m - minf_ar)

    return dm
end

