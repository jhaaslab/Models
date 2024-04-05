#class

This class controls the variables that will be set for every simulation run.

The first block we have cell labels, num cells, num ODEs per cell (perNeuron), initial conditions (s0). These start empty and will be set by the constructor.

```matlab
classdef simParams
    % Parameters passed to a dsim function
    % 'default' values:
    properties
        names
        n 
        n_TRN
        n_TC 
        per_neuron
        s0
```

# Vars

Next, we set default values for channel conductance and reversal potentials.

```matlab
    % mS/cm^2
    g_caT   = 0.75;     %gca of .75 with leak of .1 is good;
    g_nat   = 60.5;
    g_kd    = 60;
    g_nap   = 0;
    g_kt    = 5;
    g_k2    = .5;
    g_ar    = 0.025;
    g_L     = 0.1;
    g_GtACR = 10; 

    % mV
    E_na    = 50;
    E_k     = -100;
    E_ca    = 125;
    E_ar    = -40;
    E_L     = -75;
    E_GtACR = -70;
    E_AMPA  = 0;
    E_GABA  = -100;

    C = 1;       % membrance capacitance  uF/cm^2
```


# Inputs

DC pulse amplitude and start/end times or GtACR channel activation/inactivation times sepcified here:

```matlab
        % DC pulses, uA/cm2
        bias
        iDC          % DC  .25 is ~TR for burst
        istart = {};
        istop  = {};

        % Silencing 
        GtACR_on  = {};
        GtACR_off = {};

```


# Synapses

Time constants

Amplitudes and arrival times for external synapses

All possible synapses within the network are also initialized, these amplitude values will be modified if testing that synapse. These do not have arrival times as they will be activated by the source cell.

```matlab
        % Alpha/Beta Synapses, uA/cm2
        Ti1 = 5;     %Inh rise time constant
        Ti2 = 35;       %fall time constant
        Te1 = 5;     %Exc
        Te2 = 35;

        A            %amplitude of AMPAergic inputs
        tA = {};      %arrival time of AMPAergic inputs
        
        AI           %amplitude of GABAergic inputs
        tAI = {};     %arrival time of GABAergic inputs

        A_TC         %amplitude of AMPAergic TC synapses
        AI_TRN       %amplitude of GABAergic TRN synapses
        
        % Electrical Synapses, mS/cm^2
        gj
    end
    
```


# Initialization

Calling the inner construction method will produce an 'empty' network with default cell parameters and inputs//synapses set to zero

```matlab
methods
	function sp = simParams(namesOfNeurons,per_neuron,s0)
	    if nargin > 0
			sp.names = namesOfNeurons;
			sp.n = length(namesOfNeurons);
			sp.n_TRN = sum(startsWith(sp.names,'TRN'));
			sp.n_TC  = sum(startsWith(sp.names,'TC'));
			sp.per_neuron = per_neuron;
			sp.s0 = s0;
			
			sp.g_L(1:sp.n) = 0.1;
			
			sp.bias(1:sp.n) = 0;
			
			sp.iDC(1:sp.n) = 0;
			sp.istart(1:sp.n) = {0};
			sp.istop(1:sp.n)  = {0};
			
			sp.A(1:sp.n)  = 0;
			sp.tA(1:sp.n) = {0};
			
			sp.AI(1:sp.n)  = 0;
			sp.tAI(1:sp.n) = {0};
			
			sp.GtACR_on(1:sp.n)  = {0};
			sp.GtACR_off(1:sp.n) = {0};

			sp.A_TC   = zeros(sp.n_TC);
			sp.AI_TRN = zeros(sp.n_TRN);

			sp.gj = zeros(sp.n_TRN);
	    end
	end
end
```