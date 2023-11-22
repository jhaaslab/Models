classdef simParams_reduced
    % Parameters passed to a dsim function
    % 'default' values:
    properties
        g_caT = 2.25;
        g_na = 100;
        g_k = 10;
        g_L = 0.1;
        g_kL = 0.0152; %0.0152, 0.0065 in later figs
        g_GtACR = 10;
        E_na = 50;
        E_k = -100;
        E_ca = 125; % 120? in code
        E_L = -70;
        E_kL = -100;
        E_GtACR = -70;
        E_AMPA = 0;
        E_GABA = -100;
        IT_th = -3;
        NaK_th = -55;
        b = 0.5; %??no mention in paper, 0.14 / 0.5 in code
        rho_p = 0.5; %0.01 in paper?? 0.35 / 0.5 / 0.6 in code
        phi_m = 1; phi_h = 1; phi_n = 1;
        phi_p = 5^((36 - 24) / 10); %T = 36;
        phi_q = 3^((36 - 24) / 10);
        p_half = -52; p_k = 7.4;
        q_half = -80; q_k = -5;
        C = 1;       % membrance capacitance  uF/cm^2
        V_factor = 1e-3/1.43e-4;
        Ti1 = 5;     %Inh rise time constant  %1e-4/5e-4 is good for b-let.
        Ti2 = 35;       %fall time constant  %5e-3 / 20e-3 ?? ~50 ms rise.
        Te1 = 5;     %Exc
        Te2 = 35;
        GtACR_on = {};
        GtACR_off = {};

        n 
        names
        per_neuron
        s0
        Rin
        vm_rest
        
        %DC pulses
        bias
        iDC          % uA/cm2;  DC  .25 is ~TR for burst
        istart={};
        istop={};
        
        %Alpha/Beta Synapses
        A            %amplitude of AMPAergic input to cell 1. (0.2)
        tA={};           %arrival time of AMPAergic input to cell 1.
        
        AI           %amplitude of GABAergic input to cell 1.
        tAI={};          %arrival time of GABAergic input to cell 1.

        A_TC        %amplitude of AMPAergic TC synapses
        AI_TRN      %amplitude of GABAergic TRN synapses
        
        %Electrical Synapses
        Gc_total
        gj
        cc
    end
    
    methods
        function sp = simParams_reduced(namesOfNeurons,per_neuron,s0)
            if nargin > 0
                sp.names = namesOfNeurons;
                sp.n = length(namesOfNeurons);
                sp.per_neuron = per_neuron;
                sp.s0 = s0;
                
                %sp.g_L(1:sp.n) = 0.1;
                
                sp.bias(1:sp.n) = 0;
                
                sp.iDC(1:sp.n) = 0;
                sp.istart(1:sp.n) = {0};
                sp.istop(1:sp.n)  = {0};
                
                sp.A(1:sp.n) = 0;
                sp.tA(1:sp.n) = {0};
                
                sp.AI(1:sp.n) = 0;
                sp.tAI(1:sp.n) = {0};
                
                sp.GtACR_on(1:sp.n) = {0};
                sp.GtACR_off(1:sp.n) = {0};

                sp.A_TC=zeros(sum(startsWith(sp.names,'TC')));
                sp.AI_TRN=zeros(sum(startsWith(sp.names,'TRN')));
                sp.gj=zeros(sum(startsWith(sp.names,'TRN')));
            end
        end
    end
    
end