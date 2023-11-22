function ds = dsim_TRN_basic(t,s,num_cell)
per_cell = 12;
Iapp = 1;
stim_onset = 100;

if t>stim_onset && t<800
    I = -Iapp;
else
    I=0;
end

ds = zeros(max(size(s)),1);

g_ca_lts = 0.75;     %gca of .75 with leak of .1 is good;
g_nat = 60.5; g_kd = 60; g_nap = 0; g_kt = 5; g_k2 = .5; g_ar = 0.025; g_L = 0.1;
E_na = 50; E_k = -100; E_ca = 125; E_ar = -40; E_L = -75; C = 1;

for i=1:num_cell
idx = per_cell*(i-1);
v = s(idx+1);


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


ds(idx+2)=dm_nat;
ds(idx+3)=dh_nat;
ds(idx+4)=dm_nap;
ds(idx+5)=dm_kd;
ds(idx+6)=dm_kt;
ds(idx+7)=dh_kt;
ds(idx+8)=dm_k2;
ds(idx+9)=dh_k2;
ds(idx+10)=dm_ca_lts;
ds(idx+11)=dh_ca_lts;
ds(idx+12)=dm_ar;


Ina = (g_nat*(s(idx+2)^3)*s(idx+3) + g_nap*s(idx+4)) * (v-E_na);
Ik  = (g_kd*(s(idx+5)^4) + g_kt*(s(idx+6)^4)*s(idx+7) ...
      + g_k2*s(idx+8)*s(idx+9)) * (v-E_k);
ICa = (g_ca_lts*(s(idx+10)^2)*s(idx+11)) * (v-E_ca);
IAR = (g_ar*s(idx+12)) * (v-E_ar);
IL  = (g_L) * (v-E_L);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% final equations

ds(idx+1) = (-1/C)*(Ina + Ik + ICa + IAR + IL + I);
end


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
    minf_ca_lts = 1./(1+exp((-v-47)./7.4));   %traub, right shifted 5 mv
    tau_m_ca_lts = 1 + .33./(exp((v+27)/10) + exp((-v-102)./15));
    hinf_ca_lts = 1./(1+exp((v+80)./5));
    tau_h_ca_lts = 28.3 + .33./(exp((v+48)/4) + exp((-v-407)/50));
    dm = -(1/tau_m_ca_lts) * (m - minf_ca_lts);
    dh = -(1/tau_h_ca_lts) * (h - hinf_ca_lts);
end

function dm=AR(v, m)
    minf_ar = 1/(1+exp((v+75)/5.5));
    tau_m_ar = 1/(exp(-14.6  - .086*v) + exp(-1.87 + .07*v));
    dm= -(1/tau_m_ar) * (m - minf_ar);
end


end  %main