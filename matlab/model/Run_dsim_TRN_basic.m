

%Simulation//Run variables
startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
num_cell = 18;
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));


load('s_init.mat','s_init')
s_init = s_init(1:12);
s0 = repmat(s_init,1,num_cell);

tic
[t,s] = ode23(@(t,s) dsim_TRN_basic(t,s,num_cell),tspan,s0,options);
toc


figure(1);plot(t,s(:,1));