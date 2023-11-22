function dY=dHHapp(t,Y)

global stim Iapp t_stim amp freq gbar_Na gbar_K gbar_L    % applied current

if strcmp(stim,'DC input') == 1
    if t>50 && t<t_stim+50        
        I = Iapp;
    else
        I=0;
    end
else
    I = amp*sin(2*pi*freq*(t/1000));
end

C=1.0;       %micro F/cm^2
%gbar_Na=120; %(micro A/mV)/cm^2
%gbar_K=36;   %(micro A/mV)/cm^2
%gbar_L=0.3;   %(micro A/mV)/cm^2
E_Na= 45;     %mV
E_K= -82;     %mV
E_L= -59;     %mv

V=Y(1);
m=Y(2);
h=Y(3);
n=Y(4);

[m_inf, tau_m]=m_and_tau_m(V);
[h_inf, tau_h]=h_and_tau_h(V);
[n_inf, tau_n]=n_and_tau_n(V);

dY(1)=(-1/C)*( gbar_Na*m^3*h*(V-E_Na) + gbar_K*n^4*(V-E_K)...
              + gbar_L*(V-E_L) - I );
dY(2)=(1/tau_m)*( m_inf-m );
dY(3)=(1/tau_h)*( h_inf-h );
dY(4)=(1/(tau_n*10))*( n_inf-n );

dY=dY';

end

function [m_inf, tau_m]= m_and_tau_m(V)
alpha_m=( (V+45)/10 )./( 1-exp( -(V+45)/10 ) );
beta_m=4*exp( -(V+70)/18 );
m_inf=alpha_m./(alpha_m + beta_m);
tau_m=1./(alpha_m + beta_m);

end
function [h_inf, tau_h]= h_and_tau_h(V)
alpha_h=0.07*exp( -(V+70)/20 );
beta_h=1./( 1 + exp( -(V+40)/10 ) );
h_inf=alpha_h./(alpha_h + beta_h);
tau_h=1./(alpha_h + beta_h);

end
function [n_inf, tau_n]= n_and_tau_n(V)
alpha_n=0.1*( (V+60)/10 )./( 1-exp( -(V+60)/10 ) );
beta_n=0.125*exp( -(V+70)/80 );
n_inf=alpha_n./(alpha_n + beta_n);
tau_n=1./(alpha_n + beta_n);
end
