function Run_HH
%Hodgkin-Huxley model

%------------------------------------------------------------
% Vars (edit stuff here)
% simulation length
t_end = 1000; % ms

% cell parameters:
% capacitance
C=1.0;         % uF/cm^2
% gmax
G_Na = 120;    % (uA/mV)/cm^2
G_K  = 36;
G_L  = 0.3;
% reversal potentials
E_Na = 45;     % mV
E_L  = -59;
E_K  = -90;
Esyn = 0;

% Inputs:
% Applied current
Iapp = 15;      % uA/cm^2
stim_start = 200; % ms
stim_stop  = 800;

% Synapse
Gsyn  = 0.0;     % (uA/mV)/cm^2
t_syn = 100;   % ms

%------------------------------------------------------------
% The H-H equations have four ODEs (for voltage, n, m, and h)
% and thus four initial conditions:
ICs = [-71.88, 0.04229, 0.6601, 0.2893, 0];

% Solver options:
options=odeset('RelTol',1e-8);

% Here is where we solve the equations.

[t,S]=ode23(@(t,S) dHH(t,S),[0 t_end],ICs,options);

% The variable S, which comes out of the solver, has four variables in it,
% and the first one is the solved voltage.
v=S(:,1);
m=S(:,2);
n=S(:,3);
h=S(:,4);

plot(t,v)
xlabel('Time (ms)');
ylabel('Membrane Voltage (mV)');
ylim([-100 50])

%------------------------------------------------------------
% dHH function
function dY=dHH(t,Y)

    % prealocate output array
    dY = zeros(max(size(Y)),1);

    % Inputs
    % Iapp:
    if t>=stim_start && t<=stim_stop
        I = Iapp;
    else
        I = 0;
    end

    % Syn:
    if t>t_syn && t < t_syn+2
        vpre = 0;
    else
        vpre = -100;
    end
    K = 1/(1+exp(-(vpre+50)/2));


    % extract HH variables from Y array:
    V=Y(1);m=Y(2);h=Y(3);n=Y(4);S=Y(5);

    % calculate activation variables:
    [m_inf, tau_m]=m_and_tau_m(V);
    [h_inf, tau_h]=h_and_tau_h(V);
    [n_inf, tau_n]=n_and_tau_n(V);

    %differential equations:
    dY(1)=(-1/C)*( G_Na*m^3*h*(V-E_Na) + G_K*n^4*(V-E_K) + G_L*(V-E_L)...
                - I + Gsyn*S*(V-Esyn) );
    dY(2)=(1/tau_m)*( m_inf-m );
    dY(3)=(1/tau_h)*( h_inf-h );
    dY(4)=(1/(tau_n*10))*( n_inf-n );
    dY(5)= 5*K*(1-S) - 25*S;

end %dHH

%------------------------------------------------------------
% channel functions
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

end %main
