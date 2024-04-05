function extractData
% EXTRACTDATA extract spike//FR data from sim results

if ~isfolder('results')
    error(['results not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to results folder.'])
end

load([pwd '/vars/sim_vars.mat'], 'namesOfNeurons','tspan','var_combos','var_names');


if ~isfolder('data')
    mkdir data
end


numCells = length(namesOfNeurons);
n_trials = length(unique(var_combos(:,1)));
n_totalVars = length(unique(var_combos(:,2:end),'rows'));

spkData = struct('spktime', [],'FR', []);

for x=1:n_totalVars
simResults = load([pwd '/results/simResults' num2str(x) '.mat']).simResults;

for n=1:numCells

    total_spks = [];
    for i=1:n_trials
        t  = simResults(i).data.time;
        vm = simResults(i).data.(namesOfNeurons{n});

        [~, loc] = findpeaks(vm, t, 'MinPeakProminence', 50);

        spks{i} = loc;
        total_spks = [total_spks; spks{i}];
    end

    spkData(x).spktime.(namesOfNeurons{n}) = spks;

    [psth, centers] = return_histogram(total_spks, tspan(2), n_trials, 31);

    spkData(x).FR.time = centers;
    spkData(x).FR.(namesOfNeurons{n}) = psth.*1000;
end
end

save([pwd '/data/spkData.mat'],'spkData')

end %main
