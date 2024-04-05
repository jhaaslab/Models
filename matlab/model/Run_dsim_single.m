
%Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2',...
                  'TC1', 'TC2' };
startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));

load('s_init_-70.mat','s_init')
s_init = [s_init zeros(1,length(namesOfNeurons)/2)];
s0 = repmat(s_init,1,length(namesOfNeurons));

per_neuron = length(s_init);

% Initalize parameters
sim = simParams(namesOfNeurons,per_neuron,s0);

% vars

% inputs
for ii=1:sim.n
    % bias current
    sim.bias(ii) = 0.3;
    % noise
    sim.A(ii)   = 0.1;
    sim.tA{ii}  = poissonProc(80,endTime);
    sim.AI(ii)  = 0.1;
    sim.tAI{ii} = poissonProc(20,endTime);
    %
end

% synapses


tic
[t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
toc

vm=s(:,1:per_neuron:end);

figure(1);
for i = 1 : length(namesOfNeurons)
    subplot(2, 2, i);
    plot(t,vm(:,i));
    title(namesOfNeurons{i});
end
