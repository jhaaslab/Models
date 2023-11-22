%Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9',...
                  'TC1', 'TC2', 'TC3', 'TC4', 'TC5', 'TC6', 'TC7', 'TC8', 'TC9' };
num_pairs = 9;

startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));
reps = 100;
numWorkers = [16 8];
tLocal = zeros(3,9);

for w = 1:numel(numWorkers)
% Connecting parallel pool
c = parcluster;
parpool(c, numWorkers(w));


% TRN network
for n = 1:num_pairs
n_names = {namesOfNeurons{[1:n,10:9+n]}};
load('s_init.mat','s_init')
s_init = [s_init zeros(1,length(n_names)/2)];
s0 = repmat(s_init,1,length(n_names));
per_neuron = length(s_init);

    tic;
    parfor i = 1:reps
        sim = simParams(n_names,per_neuron,s0);
        for ii=1:sim.n
        sim.iDC(ii) = 0.3;
        sim.istart{ii} = 0;
        sim.istop{ii} = 1000;
        %
        sim.A(ii) = 0.2;
        sim.tA{ii} = poissonP(80,endTime);
        sim.AI(ii) = 0.2;
        sim.tAI{ii} = poissonP(20,endTime);
        end
        
        [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
    end
    tLocal(w,n) = toc;
end
delete(gcp('nocreate')) %shutdown parallel pool
end


% Connecting parallel pool
parpool('Threads')

% TRN network w/ noise
for n = 1:num_pairs
n_names = {namesOfNeurons{[1:n,10:9+n]}};
load('s_init.mat','s_init')
s_init = [s_init zeros(1,length(n_names)/2)];
s0 = repmat(s_init,1,length(n_names));
per_neuron = length(s_init);

    tic;
    parfor i = 1:reps
        sim = simParams(n_names,per_neuron,s0);
        for ii=1:sim.n
        sim.iDC(ii) = 0.3;
        sim.istart{ii} = 0;
        sim.istop{ii} = 1000;
        %
        sim.A(ii) = 0.2;
        sim.tA{ii} = poissonP(80,endTime);
        sim.AI(ii) = 0.2;
        sim.tAI{ii} = poissonP(20,endTime);
        end
        
        [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
    end
    tLocal(3,n) = toc;
end
delete(gcp('nocreate')) %shutdown parallel pool

save("exec_time_matlab.mat","tLocal")
