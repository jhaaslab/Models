
%Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4',...
                  'TC1', 'TC2' };
numNeurons = length(namesOfNeurons);
numTRN = sum(startsWith(namesOfNeurons,'TRN'));
numTC  = sum(startsWith(namesOfNeurons,'TC'));

startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));

load('common_files/s_init.mat','s_init')
s_init = [s_init zeros(1,max([numTRN numTC]))];
s0 = repmat(s_init,1,length(namesOfNeurons));

per_neuron = length(s_init);

% Initalize parameters
sim = simParams(namesOfNeurons,per_neuron,s0);

% vars

% inputs
sim.iDC(5) = 0.5;
sim.istart{5} = 500;
sim.istop{5}  = 600;

sim.iDC(6) = 0.5;
sim.istart{6} = 500;
sim.istop{6}  = 600;


% synapses
sim.A_TC = constructConnections(numTC,numTRN,1,0,0.5,0);

tic
[t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
toc

vm=s(:,1:per_neuron:end);

figure(1);
for i = 1 : length(namesOfNeurons)
    subplot(numNeurons/2, 2, i);
    plot(t,vm(:,i));
    ylim([-100 50])
    title(namesOfNeurons{i});
end
