% Connecting parallel pool 
c = parcluster; 
parpool(c, 14); 

% Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9',...
                  'TC1', 'TC2', 'TC3', 'TC4', 'TC5', 'TC6', 'TC7', 'TC8', 'TC9' };   
startTime = 0;
endTime   = 1000;
tspan = [startTime endTime];

load('s_init_0_3.mat','s_init')
s_init = [s_init zeros(1,length(namesOfNeurons)/2)];
s0 = repmat(s_init,1,length(namesOfNeurons));
per_neuron = length(s_init);

% parameters
var_rep = 1:50;


var_vectors = {var_rep, };
var_names   = {'rep', ''};
var_combos  = all_combos(var_vectors{:});

% Run//save vars
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));
skip_time = 0.1; % ms

maxNumIter     = 1000; 
[lpp, ~]       = size(var_combos); 
maxNumBlocks   = ceil(lpp/maxNumIter);
allblocks = vec2mat(1 : lpp, maxNumIter);


if ~isfolder('results')
tmpBlock = 1;
% Create a unique RNG stream if using poissonP or constructConnections/GJ
sc = parallel.pool.Constant(RandStream('Threefry','seed','shuffle'));
seed = sc.Value.Seed;

mkdir results
save( [pwd '/results/sim_vars.mat'], 'namesOfNeurons', 'tspan',...
      'var_combos','var_vectors','var_names','maxNumBlocks' );
save([pwd '/results/tmpBlock.mat'], 'tmpBlock');
save([pwd '/results/RNG_seed.mat'], 'seed');


else 
load([pwd '/results/tmpBlock.mat']);
load([pwd '/results/RNG_seed.mat']);    
sc = parallel.pool.Constant(RandStream('Threefry','seed',seed));
end


% Start running
while tmpBlock <= maxNumBlocks
block2run = allblocks(tmpBlock, :);

if tmpBlock == maxNumBlocks
    block2run = block2run(block2run ~= 0);
end

var_combos_2run = var_combos(block2run, :);  

Sim_results = struct('file', [], 'vars', [], 'data', []);

tic
parfor i = 1:numel(block2run)
    stream = sc.Value;        % Extract the stream from the Constant
    stream.Substream = block2run(i);
    RandStream.setGlobalStream(stream);
    
    tmpStruct = struct('file', block2run(i));
    selected = num2cell(var_combos_2run(i,:),1);
    
    % Deconstruct vars from selected var_combos
    [rep, ] = selected{:};

    varCellTmpStruct = cell(1, 2*length(var_names));
    varCellTmpStruct(1 : 2 : end-1) = var_names;
    varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
    tmpStruct.vars = struct(varCellTmpStruct{:});
    
    % initialize simParams object
    sim = simParams(namesOfNeurons,per_neuron,s0); 


    
    
    % Start stimualtion
    [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
    
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

    Sim_results(i) = tmpStruct;
    tmpStruct = [];
end
toc

save([pwd '/results/Sim_results' num2str(tmpBlock) '.mat'], 'Sim_results');

tmpBlock = tmpBlock+1;
save([pwd '/results/tmpBlock.mat'], 'tmpBlock');
end

delete(gcp('nocreate')) %shutdown parallel pool