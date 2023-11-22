

%Simulation//Run variables
namesOfNeurons = {'TRN1'};%,'TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9',...
                 % 'TC1','TC2','TC3','TC4','TC5','TC6','TC7','TC8','TC9'};
startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));


s_init=[-70.47 -70.47 -70.47 0 0]; %g_kL 0.0152
%s_init = [-67.58 -67.58 -67.58 0 0]; %g_kL 0.0065
%s0=s_init;
%s_init = [s_init zeros(1,length(namesOfNeurons)/2)];
s0 = repmat(s_init,1,length(namesOfNeurons));

per_neuron = length(s_init);


sim = simParams_reduced(namesOfNeurons,per_neuron,s0);

for ii=1:sim.n
    sim.iDC(ii) = 0.3; %bursts -0.1 burst-tonic 0.3, tonic 0.5
    sim.istart{ii} = 200;
    sim.istop{ii} = 800;
    %{
    sim.A(ii) = 0.05;
    sim.tA{ii} = poissonP(80,endTime/1000);
    sim.AI(ii) = 0.05;
    sim.tAI{ii} = poissonP(20,endTime/1000);
    %}
end
tic
[t,s] = ode23(@(t,s) dsim_reduced(t,s,sim),tspan,sim.s0,options);
toc
figure(1);plot(t,s(:,1));