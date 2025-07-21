
if ~isfolder('data')
    error(['data not found in current working directory. '...
     'cd to sim directory and ensure sim data was extracted.'])
end

load([pwd '/vars/sim_vars.mat'],'namesOfNeurons','tspan','var_names','var_combos','perBlk','reps');

n_totalVars = length(var_combos);
numBlks     = ceil(n_totalVars/perBlk);
numCells    = length(namesOfNeurons);
n_trials    = reps;

% load and concat all data structs
SpikeData_all=[];
for b = 1:numBlks
    SpikeData = load([pwd '/data/SpikeData' num2str(b) '.mat']);
    SpikeData = SpikeData.SpikeData;
    
    % julia data needs to be restructured to be consistent with matlab
    if iscell(SpikeData)
        SpikeData=[SpikeData{:}];
        save([pwd '/data/SpikeData' num2str(b) '.mat'],'SpikeData');
    end
    
    SpikeData_all = [SpikeData_all SpikeData]; %#ok<*AGROW>
end
clear SpikeData

FRData_all = [];
for b = 1:numBlks
    FRData = load([pwd '/data/FRData' num2str(b) '.mat']);
    FRData = FRData.FRData;
    
    if iscell(FRData)
        FRData=[FRData{:}];
        save([pwd '/data/FRData' num2str(b) '.mat'],'FRData');
    end

    FRData_all = [FRData_all FRData];
end
clear FRData


latency=zeros(n_trials,numCells,n_totalVars);
meanLat=zeros(numCells,n_totalVars);

ISI=cell(n_trials,numCells,n_totalVars);

for x=1:n_totalVars
for n=1:numCells

for i=1:n_trials

    spksi = SpikeData_all(x).spiketimes.(namesOfNeurons{n}){i};

    % latency
    if isempty(spksi)
        latency(i,n,x) = NaN;
    else
        latency(i,n,x) = spksi(1);
    end

    % ISI
    if length(spksi) < 2
        ISI{i,n,x} = NaN;
    else
        ISI{i,n,x} = spksi(2:end)-spksi(1:end-1);
    end

end

meanLat(n,x) = mean(latency(:,n,x),"omitnan");

end
end

if ~isfolder('analysis')
    mkdir('analysis')
end

save([pwd '/analysis/latency.mat'], 'latency','meanLat')
save([pwd '/analysis/ISI.mat'],     'ISI')
