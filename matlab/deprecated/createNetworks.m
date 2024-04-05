% Connecting parallel pool 
c = parcluster; 
parpool(c, 14); 

% Vars
nets = 1:50;
Gc_total = (0.005:0.005:0.03)*9;

save_dir = 'TRN_networks_het';
if not(isfolder(save_dir))
% Create a unique RNG stream if using poissonP or constructConnections/GJ
sc = parallel.pool.Constant(RandStream('Threefry','seed','shuffle'));
seed = sc.Value.Seed;

mkdir save_dir
save([pwd '/' save_dir '/Gc_totals.mat'], 'Gc_total');
save([pwd '/' save_dir '/RNG_seed.mat'], 'seed');

else 
load([pwd '/' save_dir '/RNG_seed.mat']);    
sc = parallel.pool.Constant(RandStream('Threefry','seed',seed));
end

load('s_init.mat','s_init')
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9'};
s0 = repmat(s_init,1,length(namesOfNeurons));
per_neuron = length(s_init);

for i=1:length(Gc_total)
    Gc_tot=Gc_total(i);
    tic
    parfor ii=1:length(nets)
    stream = sc.Value;        % Extract the stream from the Constant
    stream.Substream = (50*(i-1))+ii;
    RandStream.setGlobalStream(stream);
    
    sim_tmp = simParams(namesOfNeurons,per_neuron,s0); % initialize simParams object
    % change simParams vars to selected vars

    % Synapses
    % coupling
    sim_tmp.gj=constructGJ2(sim_tmp.n,Gc_tot,0.003);
    sim_tmp.Gc_total = Gc_tot;
    
    %Normalize
    num_gj=length(find(sim_tmp.gj>0));
    sim_tmp.gj=sim_tmp.gj./num_gj;
    
    sim_tmp.gj = fillmissing(sim_tmp.gj,'constant',0);
    
    % adjust Rin
    [sim_tmp]=adjustRin(sim_tmp);
    
    sim(ii)=sim_tmp;
    sim_tmp=[];
    end
    toc
    save([pwd '/' save_dir '/net' num2str(i) '.mat'], 'sim');
    
end

delete(gcp('nocreate')) %shutdown parallel pool