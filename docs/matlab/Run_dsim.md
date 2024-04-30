#script

This is the main script controlling execution of the model, most of the work will be done within this script. Here I will show how to build this file for a simulation run.


> [!todo]
> Sections that require editing will be labeled with a TODO block, while code that should mostly be the same for each sim run will not have this label.

>[!info]
>Variables that will depend on your sim will be indicated by `<*VAR*>`, this is a placeholder and will need to be replaced

# Sim run setup

First we will initialize a parallel pool to speedup execution

```matlab
% Connecting parallel pool
parpool('Threads');
```

> [!todo]

We also need to initialize some general run variables, most important here is to specify the length of the sim runs with 'startTime' and 'endTime', and specify cells that will be simulated. neuron naming should start with the cell type TRN or TC, a pair number, followed by an optional subtype identifier if used (ie. TRN1_PV, TRN2_SOM, TC1_MGB, TC2_HO ).

Initial conditions are now constructed based on network size, make sure to load the correct s_init file for either rest (s_init.m) or brought to -70 mv for noisy inputs (s_init_-70.m) 

```matlab
% Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2',...
                  'TC1', 'TC2' };   
startTime = 0;
endTime   = 1000;
tspan = [startTime endTime];

load('s_init_-70.mat','s_init')
s_init = [s_init zeros(1,length(namesOfNeurons)/2)];
s0 = repmat(s_init,1,length(namesOfNeurons));
per_neuron = length(s_init);
```

> [!todo]

Next, variables need to be listed and set:
- var_vectors: the lists of separated variable values defined for the runs
- var_names: list of string vectors for names of variables
- var_combos: all combinations of all variable values listed down the matrix rows, with each variable defined in 'var_names' listed across the columns 

```matlab
% parameters
var_rep = 1:150;
var_<*VAR*>

var_vectors = {var_rep, var_<*VAR*>};
var_names   = {'rep', '<*VAR*>'};
var_combos  = all_combos(var_vectors{:});
```

ODE solver options here control just control step size, ensuring a minimum resolution of 0.1 ms 
skip time determines how much the raw data is subsampled to save space storing results 

We break the simulation runs into block of size 'maxNumIter' to protect from crashes as only the currently running block would be lost

```matlab
% Run//save vars
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));
skip_time = 0.1; % ms

perBlock     = 150; 
[lpp, ~]     = size(var_combos); 
maxNumBlocks = ceil(lpp/perBlock);
allblocks    = vec2mat(1 : lpp, perBlock);
```

Lastly, we setup folders and check if the sim had started previously (useful for resuming after a crash or splitting a sim run)
We will also set run specific variables and save to 'init_data' directory:
- RNG stream with random 'shuffled' seed, is needed when calling rand(). Threefry algorithm used since it supports parallel processing and substreams. 

>[!warning]
>matlab reverts to a default random stream at startup for more info on RNG in matlab refer to [documentation here](https://www.mathworks.com/help/matlab/math/creating-and-controlling-a-random-number-stream.html)

```matlab
if ~isfolder('vars')
mkdir vars

tmpBlock = 1;

% Create a unique RNG stream if using poissonP or constructConnections/GJ
sc = parallel.pool.Constant(RandStream('Threefry','seed','shuffle'));
seed = sc.Value.Seed;

save([pwd '/vars/sim_vars.mat'], 'namesOfNeurons', 'tspan',...
      'var_names','var_combos','perBlock' );
save([pwd '/vars/tmpBlock.mat'], 'tmpBlock');
save([pwd '/vars/RNG_seed.mat'], 'seed');

else
load([pwd '/vars/tmpBlock.mat']);
load([pwd '/vars/RNG_seed.mat']);
sc = parallel.pool.Constant(RandStream('Threefry','seed',seed));
end

if ~isfolder('results')
mkdir results
end
```

# Begin iterating sim blocks

Now we will start running the simulations in blocks:

```matlab
% Start running
while tmpBlock <= maxNumBlocks
block2run = allblocks(tmpBlock, :);

if tmpBlock == maxNumBlocks
    block2run = block2run(block2run ~= 0);
end

var_combos_2run = var_combos(block2run, :);  
```

# Begin sim runs in parallel

```matlab
Sim_results = struct('file', [], 'vars', [], 'data', [], 'analysis', []);

tic
parfor i = 1:numel(block2run)
    stream = sc.Value;        % Extract the stream from the Constant
    stream.Substream = block2run(i);
    RandStream.setGlobalStream(stream);
    
    tmpStruct = struct('file', block2run(i));
    selected = num2cell(var_combos_2run(i,:),1);
```

> [!todo]

Here is where the specific sim run will start, this is where most editing of the code will need to be done. list your variables in an array, in the same order they were added to 'all_vars'

```matlab
    % Deconstruct vars from selected var_combos
    [rep, <*VAR*> ] = selected{:};
```

```matlab
    varCellTmpStruct = cell(1, 2*length(var_names));
    varCellTmpStruct(1 : 2 : end-1) = var_names;
    varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
    tmpStruct.vars = struct(varCellTmpStruct{:});
```

# setup parameters for individual sim

We initialize an 'empty' simParam structure 

```matlab
	% initialize simParams object
    sim = simParams(namesOfNeurons,per_neuron,s0); 
```

The following section will be the most varied.
All synapses, inputs, and changing any values of constants in [[simParams]] need to be set

## Vars

> [!todo]

any changes to channel conductance/reversal potentials can be set here:

```matlab
sim.g_caT = g_caT;
```

Leak conductance is the only one set for each cell by default, so changing individual cell leak can be done by:

```matlab
sim.g_L(n) = g_L;
```
## Inputs

> [!todo]

DC inputs defined here:
- bias current
- tone inputs to TCs 

To add noise for spontaneous activity give external spike times from poisson process function

```matlab
% Inputs
for ii=1:sim.n
	%bias current
	sim.bias(ii) = 0.3;

	%DC pulse
	sim.iDC(ii)    = 1.0;
	sim.istart{ii} = 500;
	sim.istop{ii}  = 600;

	%noise
	sim.A(ii)   = 0.2;
	sim.tA{ii}  = poissonProc(80,endTime);
	sim.AI(ii)  = 0.2;
	sim.tAI{ii} = poissonProc(20,endTime);
end

```

Opto silencing can be simulated with the "GtACR" channel activated by on and off times

```matlab
%silencing -| TRN1_PV

    sim.GtACR_on{1}  = 500;
    sim.GtACR_off{1} = 600;
```


>[!tip]
>when changing properties of specific cell type you can do this within the for loop such as 
>```matlab 
>for ii=1:sim.n 
>	if startsWith(sim.names{ii},'TRN') 
>		sim.<*PROPERTY*> = <*VAR*>
>	else %TC
>	end
>end
>```

## Synapses

> [!todo]

Connectivity is represented by a matrix of amplitudes, or Gcs' for gap junctions (see [Synapse construction](../Synapse%20construction.md)). You can either self define the topology or use the construct functions for random connections.

```matlab
Gc = 0.01;
sim.gj = [0 Gc
		  Gc 0];
```

```matlab
sim.A_TC   = constructConnections(sim.n_TC,recip_prob,div_prob,meanAmp,sigAmp);

sim.AI_TRN = constructConnections(sim.n_TRN,recip_prob,div_prob,meanAmp,sigAmp);

sim.gj = constructGJ(sim.n_TRN,meanGc,sigGc);
```

# Solve ODEs

we call our ode solver with an '@' function handle broadcast over variables (t,s) passed to our [[dsim]] function, dsim also takes [[simParams]] input to extract all parameters for the run. t =timepoints of the solution, s = solutions to all differential equations at each value of t
ode function also needs 
- timespan 
- initial conditions, we stored these in sim.s0
- and any optional solver variables, here we changed the max and intial timesteps the solver will take

```matlab
    % Start stimualtion
    [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
```

# Saving sim results 

In most cases we only save voltage data, we will also skip some data points to save space, but not too many as to lose the structure of the data. Sampling ~0.1 ms is ideal but the ode solver steps are adaptive to get optimal solutions. This results in slight clipping of spikes as these are fast events, this will not affect spike detecting as they are still highly prominent in the traces. 

```matlab
    % Saving Vm data (sampled)
    tot_skip_points = ceil(skip_time * length(t) / endTime);
    kept_idx = 1 : tot_skip_points : length(t);
    
    tmpS_struct = struct('time', t(kept_idx)); 
    idx = 1;
    for ii = 1 : sim.n
       tmpS_struct.(sim.names{ii}) = s(kept_idx, idx);
       idx = idx+sim.per_neuron;
    end
    tmpStruct.data = tmpS_struct;
```

Lastly, store the temp struct in Sim_results. After each block we measure performance, save the results and increment the running block. When all blocks finish we delete the parallel pool to free up system resources. 

``` matlab
    Sim_results(i) = tmpStruct;
    tmpStruct = [];
end
toc

save([pwd '/result/Sim_results' num2str(tmpBlock) '.mat'], 'Sim_results');

tmpBlock = tmpBlock+1;
save([pwd '/init_data/tmpBlock.mat'], 'tmpBlock');
end

delete(gcp('nocreate')) %shutdown parallel pool
```
