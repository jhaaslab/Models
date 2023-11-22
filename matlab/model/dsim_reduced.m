function ds = dsim_reduced(t,s,sim)
    
    
    ds = zeros(max(size(s)),1);

    for i=1:sim.n
    idx = sim.per_neuron*(i-1);
    
    v=s(idx+1); y=s(idx+2); z=s(idx+3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Applied Current
    if any((sim.istart{i}<t) .* (t<sim.istop{i}))
        Iapp = sim.iDC(i);
    else
        Iapp = sim.bias(i);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Synaptic Inputs 
    % AMPAergic
    if any((t>sim.tA{i}) .* (t<sim.tA{i}+2))
        vpre = 0;
    else
        vpre = -100;
    end

    % GABAergic
    if any((t>sim.tAI{i}) .* (t<sim.tAI{i}+2))
        vpreI = 0;
    else
        vpreI = -100;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Channels
    % m channel
    t1 = 13 - v + sim.NaK_th;
    t1_exp = exp(t1 / 4);
    m_alpha_by_V = 0.32 * t1 / (t1_exp - 1);  % \alpha_m(V)
    m_alpha_by_V_diff = (-0.32 * (t1_exp - 1) + 0.08 * t1 * t1_exp) / (t1_exp - 1)^2; % \alpha_m'(V)
    t2 = v - 40 - sim.NaK_th;
    t2_exp = exp(t2 / 5);
    m_beta_by_V = 0.28 * t2 / (t2_exp - 1);  % \beta_m(V)
    m_beta_by_V_diff = (0.28 * (t2_exp - 1) - 0.056 * t2 * t2_exp) / (t2_exp - 1)^2;  % \beta_m'(V)
    m_tau_by_V = 1 / sim.phi_m / (m_alpha_by_V + m_beta_by_V);  % \tau_m(V)
    m_inf_by_V = m_alpha_by_V / (m_alpha_by_V + m_beta_by_V);  % \m_{\infty}(V)
    m_inf_by_V_diff = (m_alpha_by_V_diff * m_beta_by_V - m_alpha_by_V * m_beta_by_V_diff) / ...
                      (m_alpha_by_V + m_beta_by_V)^2;  % \m_{\infty}'(V)

    % h channel
    h_alpha_by_V = 0.128 * exp((17 - v + sim.NaK_th) / 18);  % \alpha_h(V)
    h_beta_by_V = 4 / (exp((40 - v + sim.NaK_th) / 5) + 1);  % \beta_h(V)
    h_inf_by_V = h_alpha_by_V / (h_alpha_by_V + h_beta_by_V);  % h_{\infty}(V)
    h_tau_by_V = 1 / sim.phi_h / (h_alpha_by_V + h_beta_by_V);  % \tau_h(V)
    h_alpha_by_y = 0.128 * exp((17 - y + sim.NaK_th) / 18);  % \alpha_h(y)
    t3 = exp((40 - y + sim.NaK_th) / 5);
    h_beta_by_y = 4 / (t3 + 1);  % \beta_h(y)
    h_beta_by_y_diff = 0.8 * t3 / (1 + t3) ^ 2;  % \beta_h'(y)
    h_inf_by_y = h_alpha_by_y / (h_alpha_by_y + h_beta_by_y);  % h_{\infty}(y)
    h_alpha_by_y_diff = -h_alpha_by_y / 18;  % \alpha_h'(y)
    h_inf_by_y_diff = (h_alpha_by_y_diff * h_beta_by_y - h_alpha_by_y * h_beta_by_y_diff) / ...
                      (h_beta_by_y + h_alpha_by_y) ^ 2;  % h_{\infty}'(y)

    % n channel
    t4 = (15 - v + sim.NaK_th);
    n_alpha_by_V = 0.032 * t4 / (exp(t4 / 5) - 1);  % \alpha_n(V)
    n_beta_by_V = sim.b * exp((10 - v + sim.NaK_th) / 40);  % \beta_n(V)
    n_tau_by_V = 1 / (n_alpha_by_V + n_beta_by_V) / sim.phi_n;  % \tau_n(V)
    n_inf_by_V = n_alpha_by_V / (n_alpha_by_V + n_beta_by_V);  % n_{\infty}(V)
    t5 = (15 - y + sim.NaK_th);
    t5_exp = exp(t5 / 5);
    n_alpha_by_y = 0.032 * t5 / (t5_exp - 1);  % \alpha_n(y)
    t6 = exp((10 - y + sim.NaK_th) / 40);
    n_beta_y = sim.b * t6;  % \beta_n(y)
    n_inf_by_y = n_alpha_by_y / (n_alpha_by_y + n_beta_y);  % n_{\infty}(y)
    n_alpha_by_y_diff = (0.0064 * t5 * t5_exp - 0.032 * (t5_exp - 1)) / (t5_exp - 1)^2;  % \alpha_n'(y)
    n_beta_by_y_diff = -n_beta_y / 40;  % \beta_n'(y)
    n_inf_by_y_diff = (n_alpha_by_y_diff * n_beta_y - n_alpha_by_y * n_beta_by_y_diff) / ...
                      (n_alpha_by_y + n_beta_y)^2;  % n_{\infty}'(y)

    % p channel
    p_inf_by_V = 1 / (1 + exp((sim.p_half - v + sim.IT_th) / sim.p_k));  % p_{\infty}(V)
    p_tau_by_V = (3 + 1 / (exp((v + 27 - sim.IT_th) / 10) + ...
                    exp(-(v + 102 - sim.IT_th) / 15))) / sim.phi_p;  % \tau_p(V)
    t7 = exp((sim.p_half - y + sim.IT_th) / sim.p_k);
    p_inf_by_y = 1 / (1 + t7);  % p_{\infty}(y)
    p_inf_by_y_diff = t7 / sim.p_k / (1 + t7)^2;  % p_{\infty}'(y)

    % q channel
    q_inf_by_V = 1 / (1 + exp((sim.q_half - v + sim.IT_th) / sim.q_k));  % q_{\infty}(V)
    t8 = exp((sim.q_half - z + sim.IT_th) / sim.q_k);
    q_inf_by_z = 1 / (1 + t8); % q_{\infty}(z)
    q_inf_diff_z = t8 / sim.q_k / (1 + t8)^2;  % q_{\infty}'(z)
    q_tau_by_V = (85 + 1 / (exp((v + 48 - sim.IT_th) / 4) + ...
                    exp(-(v + 407 - sim.IT_th) / 50))) / sim.phi_q;  % \tau_q(V)


    gNa = sim.g_na * m_inf_by_V^3 * h_inf_by_y;  % gNa
    gK = sim.g_k * n_inf_by_y^4;  % gK
    gT = sim.g_caT * p_inf_by_y * p_inf_by_y * q_inf_by_z;  % gT
    FV = gNa + gK + gT + sim.g_L + sim.g_kL;  % dF/dV
    Fm = 3 * sim.g_na * h_inf_by_y * (v - sim.E_na) * m_inf_by_V * m_inf_by_V * m_inf_by_V_diff;  % dF/dvm
    t9 = sim.C / m_tau_by_V;
    t10 = FV + Fm;
    t11 = t9 + FV;
    rho_V = (t11 - sqrt(max(t11 ^ 2 - 4 * t9 * t10, 0))) / 2 / t10;  % rho_V

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Synapses

    %excitatory input 
    ds(idx+4) = sim.Te1*K_syn(vpre)*(1-s(idx+4)) - sim.Te2*s(idx+4);    
    Esyn1 = sim.A(i) *s(idx+4)*(v-sim.E_AMPA);

    %inhibitory input 
    ds(idx+5) = sim.Ti1*K_syn(vpreI)*(1-s(idx+5)) - sim.Ti2*s(idx+5);    
    Isyn1 = sim.AI(i) *s(idx+5)*(v-sim.E_GABA);


    if startsWith(sim.names{i},'TRN')
    %excitatory input TC
    Esyn2=0;
    for ii=1:sum(startsWith(sim.names,'TC'))
    ds(idx+5+ii) = sim.Te1*K_syn(s(sim.per_neuron*(ii+((sim.n/2)-1))+1))*(1-s(idx+5+ii))...
                    - sim.Te2*s(idx+5+ii); 
    Esyn2 = Esyn2 + sim.A_TC(ii,i) *s(idx+5+ii)*(v-sim.E_AMPA);
    end

    %Electrical synapses TRN
    v_TRNs = zeros(1,sum(startsWith(sim.names,'TRN')));
    for ii=1:sum(startsWith(sim.names,'TRN'))
        v_TRNs(ii) = s(sim.per_neuron*(ii-1)+1);
    end

    Gsyn = sum(sim.gj(:,i)' .* (v-v_TRNs));

    Summed_Isyn = Esyn1 + Isyn1 + Esyn2 + Gsyn;

    else %%% TC
    %inhibitory input TRN
    Isyn2=0;
    for ii=1:sum(startsWith(sim.names,'TRN'))
    ds(idx+5+ii) = sim.Ti1*K_syn(s(sim.per_neuron*(ii-1)+1))*(1-s(idx+5+ii))...
                    - sim.Ti2*s(idx+5+ii); 
    Isyn2 = Isyn2 + sim.AI_TRN(ii,i-(sim.n/2)) *s(idx+5+ii)*(v-sim.E_GABA);
    end

    Summed_Isyn = Esyn1 + Isyn1 + Isyn2;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% final equations

    INa  = gNa * (v - sim.E_na);
    IK   = gK * (v - sim.E_k);
    IT   = gT * (v - sim.E_ca);
    IL   = sim.g_L * (v - sim.E_L);
    IKL  = sim.g_kL * (v - sim.E_kL);
    Iext = sim.V_factor * (Iapp + Summed_Isyn);

    ds(idx+1) = rho_V * (-INa - IK - IT - IL - IKL + Iext) / sim.C;

    % Y 
    Fvh = sim.g_na * m_inf_by_V^3 * (v - sim.E_na) * h_inf_by_y_diff;  % dF/dvh
    Fvn = 4 * sim.g_k * (v - sim.E_k) * n_inf_by_y^3 * n_inf_by_y_diff;  % dF/dvn
    f4 = Fvh + Fvn;
    rho_h = (1 - sim.rho_p) * Fvh / f4;
    rho_n = (1 - sim.rho_p) * Fvn / f4;
    fh = (h_inf_by_V - h_inf_by_y) / h_tau_by_V / h_inf_by_y_diff;
    fn = (n_inf_by_V - n_inf_by_y) / n_tau_by_V / n_inf_by_y_diff;
    fp = (p_inf_by_V - p_inf_by_y) / p_tau_by_V / p_inf_by_y_diff;

    ds(idx+2) = rho_h * fh + rho_n * fn + sim.rho_p * fp;

    % Z 
    ds(idx+3) = (q_inf_by_V - q_inf_by_z) / q_tau_by_V / q_inf_diff_z;
    end

    function k = K_syn(v)
        k = 1/(1+exp(-(v+50)/2));
    end
    
end %main