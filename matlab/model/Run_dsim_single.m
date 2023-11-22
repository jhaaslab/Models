
%
%Simulation//Run variables
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9',...
                  'TC1','TC2','TC3','TC4','TC5','TC6','TC7','TC8','TC9'};
startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));

load('s_init_0_3.mat','s_init')
s_init = [s_init zeros(1,length(namesOfNeurons)/2)];
s0 = repmat(s_init,1,length(namesOfNeurons));

per_neuron = length(s_init);


sim = simParams(namesOfNeurons,per_neuron,s0);

for ii=1:sim.n
    sim.bias(ii) = 0.3;
    %
    sim.A(ii) = 0.2;
    sim.tA{ii} = poissonP(80,endTime);
    sim.AI(ii) = 0.2;
    sim.tAI{ii} = poissonP(20,endTime);
    %
end
%
tic
[t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options); 
toc
figure(2);plot(t,s(:,1));