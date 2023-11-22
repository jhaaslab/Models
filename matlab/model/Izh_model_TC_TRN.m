% Created by Eugene M. Izhikevich, February 25, 2003
% Excitatory neurons    Inhibitory neurons
Ne=9;                   Ni=9;
%re=rand(Ne,1);          ri=rand(Ni,1);
a=[0.02*ones(1,Ne),     0.02*ones(1,Ni)];
b=[0.25*ones(1,Ne),     0.25*ones(1,Ni)];
c=[-65 *ones(1,Ne),     -65 *ones(1,Ni)];
d=[0.05*ones(1,Ne),     0.05*ones(1,Ni)];
%S=[0.5*rand(Ne+Ni,Ne),  -rand(Ne+Ni,Ni)];
I=[1*ones(1,Ne),      1*ones(1,Ni)];
v=-65*ones(1,Ne+Ni);    % Initial values of v
u=b.*v;                 % Initial values of u
firings=[];             % spike timings

endTime=1000;
step=0.1;
t=step:step:endTime;
for t_step=2:(endTime/step)            % simulation of 1000 ms
  %  
  % DC input
  if t(t_step) >= 200
      Iapp = I;
  else
      Iapp = I.*0;
  end
  %}
  %Isyn=[5*randn(1,Ne),5*randn(1,Ni)]; % external synapses
  Isyn = 0;

  fired=find(v(t_step-1,:)>=30);    % indices of spikes
  firings=[firings; t(t_step-1)+0*fired',fired'];
  
  %Isyn=Isyn+sum(S(:,fired),2)'; % connected synapses

  v(t_step,:)=v(t_step-1,:)+step.*(0.04.*v(t_step-1,:).^2+5.*v(t_step-1,:)+140-u(t_step-1,:)+Iapp+Isyn); 
  u(t_step,:)=u(t_step-1,:)+step.*a.*(b.*v(t_step-1,:)-u(t_step-1,:));   

  v(t_step,fired)=c(fired);
  u(t_step,fired)=u(t_step-1,fired)+d(fired);
end
v(v>30)=30;
%plot trace
figure(1);plot(t,v(:,1));

% rasterize
%figure(2);plot(firings(:,1),firings(:,2),'.');