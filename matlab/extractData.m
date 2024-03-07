function extractData()
% EXTRACTDATA finds spikes from simResults vM data and,
% performs extracted FR measure from all sim reps.
% stores these data in data/spk_data
if ~isfolder('results')
    error(['results not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to results folder.'])
end

load( [pwd '/results/sim_vars.mat'], 'namesOfNeurons','tspan','dt', ...
    'reps','var_names','var_combos' );


if ~isfolder('data')
    mkdir data
end


numCells = length(namesOfNeurons);
n_trials = reps;
n_totalVars = length(var_combos);

t = tspan(1):dt:tspan(2);

spk_data = struct('vars', [],'spktime', [],'FR', []);

for x=1:n_totalVars
    simResults = load([pwd '/results/simResults' num2str(x) '.mat']).simResults;

    %Restruct for consistency
    simResults = [simResults{:}];
    save([pwd '/results/simResults' num2str(x) '.mat'], 'simResults');

    for var = 1:length(var_names)
        spk_data(x).vars.(var_names{var}) = var_combos(x,var);
    end

    for n=1:numCells

        for i=1:n_trials

            vm = simResults(i).data.(namesOfNeurons{n});

            [~, loc] = findpeaks(vm, t, 'MinPeakProminence', 50);

            spks{i} = loc;
        end

        spk_data(x).spktime.(namesOfNeurons{n}) = spks;

        total_spks = cell2mat(spks);

        [psth, centers] = returnHistogram(total_spks, tspan(2), n_trials, 31);

        spk_data(x).FR.time = centers;
        spk_data(x).FR.(namesOfNeurons{n}) = psth.*1000;
    end
end

save([pwd '/data/spk_data.mat'],'spk_data')

function [psth, centers] = returnHistogram(spk_times,t_span,n_trials,smooth_win)
edges = 0:1:t_span;
centers = (edges(1:end-1)+edges(2:end))/2;

counts = histcounts(spk_times, edges);
counts = counts/n_trials;

sm_wind = hanning(smooth_win); % gausswin(smooth_win,smooth_win/10);

psth = conv(counts, sm_wind, 'same')/sum(sm_wind);
end %returnHistogram

end %main
