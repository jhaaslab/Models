function [sim] = adjustRin(sim)
%Calculate coupled TRN network Rin and adjust to uncoupled cell value 

load('g_L_func.mat','g_L_func')
load('iDCfunc.mat', 'iDCfunc')


Rin_tgt = 7.89;

startTime  = 0;
endTime    = 1100;
tspan = [startTime endTime];
tmax = abs(endTime - startTime);

options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));
skip_time = 1/10; % ms


iDC = -1:0.1:-0.1;
cell_num = 1:9;

all_vars    = { iDC, 'iDC_TRN';
                cell_num, 'cell_num'};
            
var_vectors = all_vars(:, 1)';
var_names   = all_vars(:, 2)';
var_combos  = all_combos(var_vectors{:});

%Estimate Rin adjust
for i=1:sim.n
    sim.g_L(i)=g_L_func(sum(sim.gj(:,i)));
end

%Calculate initial Rin
%Run sims
sim_result = struct('file', [], 'vars', [], 'data', []);
for i=1:length(var_combos)
tmpStruct = struct('file',i);
selected = num2cell(var_combos(i,:),1);
    
% Get out the 'location' of which values to pick from 'selected'
[iApp,cell_num] = selected{:};
sim_tmp = sim;    
% Inputs
%DC
sim_tmp.iDC(cell_num) = iApp;
sim_tmp.istart{cell_num} = 500;
sim_tmp.istop{cell_num}  = 1000;

varCellTmpStruct = cell(1, 2*length(var_names));
varCellTmpStruct(1 : 2 : end-1) = var_names;
varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
tmpStruct.vars = struct(varCellTmpStruct{:});
    
[t,s] = ode23(@(t,s) dsimIterative(t,s,sim_tmp),tspan,sim_tmp.s0,options);

% Saving Vm data (sampled)
tot_skip_points = ceil( skip_time * length(t) / tmax );
kept_idx = 1 : tot_skip_points : length(t);

tmpS_struct = struct('time', t(kept_idx));
idx = 1;
for ii = 1 : sim_tmp.n
    tmpS_struct.(sim_tmp.names{ii}) = s(kept_idx, idx);
    idx = idx+sim_tmp.per_neuron;
end
tmpStruct.data = tmpS_struct;

sim_result(i) = tmpStruct;
tmpStruct = []; %#ok<*NASGU>
end

%Rin calculation
for x=1:length(var_combos)
    v1(x)=mean(sim_result(x).data.TRN1(7275:9092));  %#ok<*AGROW>
    v2(x)=mean(sim_result(x).data.TRN2(7275:9092));
    v3(x)=mean(sim_result(x).data.TRN3(7275:9092));
    v4(x)=mean(sim_result(x).data.TRN4(7275:9092));
    v5(x)=mean(sim_result(x).data.TRN5(7275:9092));
    v6(x)=mean(sim_result(x).data.TRN6(7275:9092));
    v7(x)=mean(sim_result(x).data.TRN7(7275:9092));
    v8(x)=mean(sim_result(x).data.TRN8(7275:9092));
    v9(x)=mean(sim_result(x).data.TRN9(7275:9092));
end
v=[v1(1:10),v2(11:20),v3(21:30),v4(31:40),v5(41:50),v6(51:60),v7(61:70),v8(71:80),v9(81:90)];
v=reshape(v,10,9);
for i=1:sim.n
    [fit1] = fit(iDC',v(:,i),'poly1');
    Rin(i) = fit1.p1;
end

%Adjust Rins
counter=1;
while any(abs((Rin(counter,:)-Rin_tgt)./Rin_tgt) > 0.01)
%Adjust leak
gL_adj = 0.0025*(0.6^counter);
for i=1:sim.n
    if abs((Rin(counter,i)-Rin_tgt)/Rin_tgt) > 0.01
        if Rin(counter,i)>Rin_tgt
        sim.g_L(i)=sim.g_L(i)+gL_adj;
        else
        sim.g_L(i)=sim.g_L(i)-gL_adj;
        end
    end
end

%Run sims 
sim_result = struct('file', [], 'vars', [], 'data', []);
for i=1:length(var_combos)
tmpStruct = struct('file',i);
selected = num2cell(var_combos(i,:),1);
    
% Get out the 'location' of which values to pick from 'selected'
[iApp,cell_num] = selected{:};
sim_tmp = sim;    
% Inputs
%DC
sim_tmp.iDC(cell_num) = iApp;
sim_tmp.istart{cell_num} = 500;
sim_tmp.istop{cell_num}  = 1000;

varCellTmpStruct = cell(1, 2*length(var_names));
varCellTmpStruct(1 : 2 : end-1) = var_names;
varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
tmpStruct.vars = struct(varCellTmpStruct{:});
    
[t,s] = ode23(@(t,s) dsimIterative(t,s,sim_tmp),tspan,sim_tmp.s0,options);

% Saving Vm data (sampled)
tot_skip_points = ceil( skip_time * length(t) / tmax );
kept_idx = 1 : tot_skip_points : length(t);

tmpS_struct = struct('time', t(kept_idx));
idx = 1;
    for ii = 1 : sim_tmp.n
        tmpS_struct.(sim_tmp.names{ii}) = s(kept_idx, idx);
        idx = idx+sim_tmp.per_neuron;
    end
tmpStruct.data = tmpS_struct;

sim_result(i) = tmpStruct;
tmpStruct = [];
end

counter=counter+1;

%Rin calculation
for x=1:length(var_combos)
    v1(x)=mean(sim_result(x).data.TRN1(7275:9092));
    v2(x)=mean(sim_result(x).data.TRN2(7275:9092));
    v3(x)=mean(sim_result(x).data.TRN3(7275:9092));
    v4(x)=mean(sim_result(x).data.TRN4(7275:9092));
    v5(x)=mean(sim_result(x).data.TRN5(7275:9092));
    v6(x)=mean(sim_result(x).data.TRN6(7275:9092));
    v7(x)=mean(sim_result(x).data.TRN7(7275:9092));
    v8(x)=mean(sim_result(x).data.TRN8(7275:9092));
    v9(x)=mean(sim_result(x).data.TRN9(7275:9092));
end
v=[v1(1:10),v2(11:20),v3(21:30),v4(31:40),v5(41:50),v6(51:60),v7(61:70),v8(71:80),v9(81:90)];
v=reshape(v,10,9);
for i=1:sim.n
    [fit1] = fit(iDC',v(:,i),'poly1');
    Rin(counter,i) = fit1.p1;
end

if counter == 6
    break
end
end
sim.Rin=Rin;

%Calculate CC
iDC = -2;
cell_num = 1:9;

all_vars    = { iDC, 'iDC_TRN';
                cell_num, 'cell_num'};
            
var_vectors = all_vars(:, 1)';
var_names   = all_vars(:, 2)';
var_combos  = all_combos(var_vectors{:});

%Run sims
sim_result = struct('file', [], 'vars', [], 'data', []);
for i=1:length(var_combos)
tmpStruct = struct('file',i);
selected = num2cell(var_combos(i,:),1);
    
% Get out the 'location' of which values to pick from 'selected'
[iApp,cell_num] = selected{:};
sim_tmp = sim;    
% Inputs
%DC
sim_tmp.iDC(cell_num) = iApp;
sim_tmp.istart{cell_num} = 500;
sim_tmp.istop{cell_num}  = 1000;

varCellTmpStruct = cell(1, 2*length(var_names));
varCellTmpStruct(1 : 2 : end-1) = var_names;
varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
tmpStruct.vars = struct(varCellTmpStruct{:});
    
[t,s] = ode23(@(t,s) dsimIterative(t,s,sim_tmp),tspan,sim_tmp.s0,options);

% Saving Vm data (sampled)
tot_skip_points = ceil( skip_time * length(t) / tmax );
kept_idx = 1 : tot_skip_points : length(t);

tmpS_struct = struct('time', t(kept_idx));
idx = 1;
for ii = 1 : sim_tmp.n
    tmpS_struct.(sim_tmp.names{ii}) = s(kept_idx, idx);
    idx = idx+sim_tmp.per_neuron;
end
tmpStruct.data = tmpS_struct;

sim_result(i) = tmpStruct;
tmpStruct = [];
end

%CC calculation
for x=1:length(var_combos)
    dv1(x)=sim_result(x).data.TRN1(4547)-mean(sim_result(x).data.TRN1(7275:9092));
    dv2(x)=sim_result(x).data.TRN2(4547)-mean(sim_result(x).data.TRN2(7275:9092));
    dv3(x)=sim_result(x).data.TRN3(4547)-mean(sim_result(x).data.TRN3(7275:9092));
    dv4(x)=sim_result(x).data.TRN4(4547)-mean(sim_result(x).data.TRN4(7275:9092));
    dv5(x)=sim_result(x).data.TRN5(4547)-mean(sim_result(x).data.TRN5(7275:9092));
    dv6(x)=sim_result(x).data.TRN6(4547)-mean(sim_result(x).data.TRN6(7275:9092));
    dv7(x)=sim_result(x).data.TRN7(4547)-mean(sim_result(x).data.TRN7(7275:9092));
    dv8(x)=sim_result(x).data.TRN8(4547)-mean(sim_result(x).data.TRN8(7275:9092));
    dv9(x)=sim_result(x).data.TRN9(4547)-mean(sim_result(x).data.TRN9(7275:9092));
end
dv=[dv1;dv2;dv3;dv4;dv5;dv6;dv7;dv8;dv9];
for i=1:sim.n
    cc(i,:) = dv(i,:)./dv(i,i);
end

sim.cc = cc;

%Adjust Vm // S_init
vm_tgt = -70;

startTime  = 0;
endTime    = 5000;
tspan = [startTime endTime];
tmax = abs(endTime - startTime);

for i=1:sim.n
    sim.bias(i) = iDCfunc(sum(sim.gj(:,i)));
end

[t,s] = ode23(@(t,s) dsimIterative(t,s,sim),tspan,sim.s0,options);

sim.s0 = s(end,:);
vm=sim.s0(1:sim.per_neuron:end);

counter=1;
while any(abs(vm(counter,:)-vm_tgt) > 0.1)

%Adjust bias
iDC_adj = 0.01*(0.9^counter);
for i=1:sim.n
    if abs(vm(counter,i)-vm_tgt) > 0.1
        if vm(counter,i)>vm_tgt
        sim.bias(i)=sim.bias(i)-iDC_adj;
        else
        sim.bias(i)=sim.bias(i)+iDC_adj;
        end
    end
end

[t,s] = ode23(@(t,s) dsimIterative(t,s,sim),tspan,sim.s0,options);

counter=counter+1;

sim.s0 = s(end,:);
vm(counter,:)=sim.s0(1:sim.per_neuron:end);

if counter == 6
    break
end
end
sim.vm_rest=vm;

end %main