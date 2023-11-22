#function
link: [[dsim.m]]
This function contains the equations for calculating the Hodgkin-Huxley system and will be passed to the ODE solver to run our simulations 

# Setup

```matlab
function ds = dsim(t,s,sim)


ds = zeros(max(size(s)),1);

for i=1:sim.n
idx = sim.per_neuron*(i-1);
v = s(idx+1);
```

# Inputs

To handle multiple input times we look for any time within the array of inputs by computing the dot product 
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Applied Current
if any((sim.istart{i}<t) .* (t<sim.istop{i}))
    Iapp = -sim.iDC(i);
else
    Iapp = -sim.bias(i);
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
```

# Ion Channels


```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Channels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Regular sodium
[dm_nat, dh_nat] = Na_t(v, s(idx+2),  s(idx+3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Persistent sodium
dm_nap = Na_p(v, s(idx+4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Delayed rectifier
dm_kd = K_rect(v, s(idx+5));

%%%%%%%%%%%%%%%%%%%%%%%%% Transient K = A current, McCormick/Huguenard 1992
[dm_kt, dh_kt]=K_A(v, s(idx+6), s(idx+7));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GK2
[dm_k2, dh_k2]= K2(v, s(idx+8), s(idx+9));

%%%%%%%% T current, as implemented by Traub 2005, which cites Destexhe 1996
[dm_ca_lts, dh_ca_lts]= Ca_T(v, s(idx+10), s(idx+11));

%%%%%%%%%%%%%%%%%%%%Anonymous rectifier, AR; Traub 2005 calls this 'h'.  ?!
dm_ar = AR(v, s(idx+12));


Ina = (sim.g_nat*(s(idx+2)^3)*s(idx+3) + sim.g_nap*s(idx+4)) * (v-sim.E_na);
Ik  = (sim.g_kd*(s(idx+5)^4) + sim.g_kt*(s(idx+6)^4)*s(idx+7)...
      + sim.g_k2*s(idx+8)*s(idx+9)) * (v-sim.E_k);

ICa = (sim.g_ca_lts*(s(idx+10)^2)*s(idx+11)) * (v-sim.E_ca);
if endsWith(sim.names{i},'SOM')||endsWith(sim.names{i},'HO')
    ICa = ICa*0.5;
end

IAR = (sim.g_ar*s(idx+12)) * (v-sim.E_ar);
IL  = (sim.g_L(i)) * (v-sim.E_L);

if any((sim.GtACR_on{i}<t) .* (t<sim.GtACR_off{i}))
    IGtACR = (sim.g_GtACR) * (v-sim.E_GtACR);
else
    IGtACR = 0;
end
```

# Synapses

Changes in synaptic conductance are calculated here while we iterate as the number of possible synapses increases with network size 
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Synapses

%excitatory input 
ds(idx+13) = sim.Te1*K_syn(vpre)*(1-s(idx+13)) - sim.Te2*s(idx+13);    
Esyn1 = sim.A(i) * s(idx+13) * (v-sim.E_AMPA);

%inhibitory input 
ds(idx+14) = sim.Ti1*K_syn(vpreI)*(1-s(idx+14)) - sim.Ti2*s(idx+14);    
Isyn1 = sim.AI(i) * s(idx+14) * (v-sim.E_GABA);


if startsWith(sim.names{i},'TRN')
    %excitatory input TC
    Esyn2=0;
    for ii=1:sum(startsWith(sim.names,'TC'))
    ds(idx+14+ii) = sim.Te1*K_syn(s(sim.per_neuron*(ii+((sim.n/2)-1))+1))...
                    *(1-s(idx+14+ii)) - sim.Te2*s(idx+14+ii); 
    Esyn2 = Esyn2 + sim.A_TC(ii,i) * s(idx+14+ii) * (v-sim.E_AMPA);
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
    ds(idx+14+ii) = sim.Ti1*K_syn(s(sim.per_neuron*(ii-1)+1))...
                    *(1-s(idx+14+ii)) - sim.Ti2*s(idx+14+ii); 
    Isyn2 = Isyn2 + sim.AI_TRN(ii,i-(sim.n/2)) * s(idx+14+ii) * (v-sim.E_GABA);
    end

    Summed_Isyn = Esyn1 + Isyn1 + Isyn2;
end
```

# Derivatives

Changes in synaptic conductance are omitted here as we assigned them while iterating over the synapses in the network [(above)](#Synapses)
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% final equations

ds(idx+1)  = (-1/sim.C)*(Ina + Ik + ICa + IAR + IL + IGtACR + Iapp + Summed_Isyn);
ds(idx+2)  = dm_nat;
ds(idx+3)  = dh_nat;
ds(idx+4)  = dm_nap;
ds(idx+5)  = dm_kd;
ds(idx+6)  = dm_kt;
ds(idx+7)  = dh_kt;
ds(idx+8)  = dm_k2;
ds(idx+9)  = dh_k2;
ds(idx+10) = dm_caT;
ds(idx+11) = dh_caT;
ds(idx+12) = dm_ar;
end
```


The following nested functions are the differential equations for channel activation (m) /inactivation (h) for all voltage dependent channels
```matlab
function [dm, dh]= Na_t(v, m, h)
    minf_nat = 1/(1 + exp((-v - 38)/10));
    if v<= -30
        tau_m_nat = 0.0125 + .1525*exp((v+30)/10);
    else
        tau_m_nat = 0.02 + .145*exp((-v-30)/10);
    end
    hinf_nat = 1/(1 + exp((v + 58.3)/6.7));
    tau_h_nat = 0.225 + 1.125/(1+exp((v+37)/15));
    dm = -(1/tau_m_nat) * (m - minf_nat);
    dh= -(1/tau_h_nat) * (h - hinf_nat);
end

function dm=Na_p(v, m)
    minf_nap = 1/(1+exp((-v-48)/10));
    if v<= -40
        tau_m_nap = 0.025 + .14*exp((v+40)/10);
    else
        tau_m_nap = 0.02 + .145*exp((-v-40)/10);
    end
    dm = -(1/tau_m_nap) * (m - minf_nap);
end

function dm = K_rect(v, m)
    minf_kd = 1/(1+exp((-v-27)/11.5));
    if v<= -10
        tau_m_kd = 0.25 + 4.35*exp((v+10)/10);
    else
        tau_m_kd = 0.25 + 4.35*exp((-v-10)/10);
    end
    dm = -(1/tau_m_kd) * (m - minf_kd);
end
->
function [dm, dh]= K_A(v, m, h)
    minf_kt = 1/(1+exp((-v-60)/8.5));
    tau_m_kt = .185 + .5/(exp((v+35.8)/19.7) + exp((-v-79)/12.7));
    hinf_kt = 1/(1+exp((v+78)/6));
    if v<= -63
        tau_h_kt = .5/(exp((v+46)/5) + exp((-v-238)/37.5));
    else
        tau_h_kt = 9.5;
    end
    dm = -(1/tau_m_kt) * (m - minf_kt);
    dh = -(1/tau_h_kt) * (h - hinf_kt);
end

function [dm, dh] = K2(v, m, h)
    minf_k2 = 1/(1+exp((-v-10)/17));
    tau_m_k2 = 4.95 + .5/(exp((v-81)/25.6) + exp((-v-132)/18));
    hinf_k2 = 1/(1+exp((v+58)/10.6));
    tau_h_k2 = 60 + .5/(exp((v - 1.33)/200) + exp((-v-130)/7.1));
    dm = -(1/tau_m_k2) * (m - minf_k2);
    dh = -(1/tau_h_k2) * (h - hinf_k2);
end

function [dm, dh]= Ca_T(v, m, h)
    minf_ca_lts = 1/(1+exp((-v-47)/7.4));   %traub, right shifted 5 mv
    tau_m_ca_lts = 1 + .33/(exp((v+27)/10) + exp((-v-102)/15));
    hinf_ca_lts = 1/(1+exp((v+80)/5));
    tau_h_ca_lts = 28.3 + .33/(exp((v+48)/4) + exp((-v-407)/50));
    dm = -(1/tau_m_ca_lts) * (m - minf_ca_lts);
    dh = -(1/tau_h_ca_lts) * (h - hinf_ca_lts);
end

function dm=AR(v, m)
    minf_ar = 1/(1+exp((v+75)/5.5));
    tau_m_ar = 1/(exp(-14.6  - .086*v) + exp(-1.87 + .07*v));
    dm= -(1/tau_m_ar) * (m - minf_ar);
end

function k = K_syn(v)
    k = 1/(1+exp(-(v+50)/2));
end


end  %main
```
