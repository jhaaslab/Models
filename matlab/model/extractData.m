close all


load( [pwd '/init_data/sim_vars.mat'], 'namesOfNeurons','tspan',...
      'var_combos','var_vectors','var_names','maxNumBlocks' );

if ~exist('Sim_results','var')
Sim_results = [];
for i = 1:maxNumBlocks
    resultsi = load([pwd '/result/Sim_results' num2str(i) '.mat']).Sim_results;
    Sim_results = [Sim_results, resultsi];
end
end

if ~isfolder('data')
    mkdir data
end

% meanFR from control runs
FR_0=0.0149;

numCells = length(namesOfNeurons);
n_trials = length(var_vectors{1});
n_totalVars = length(var_combos)/length(var_vectors{1});

spk_data = struct('spktime', [],'FR', []);

for x=1:n_totalVars

for n=1:numCells

    for i=1:n_trials
        t = Sim_results(i+(n_trials*(x-1))).data.time;
        vm = Sim_results(i+(n_trials*(x-1))).data.(namesOfNeurons{n});

        [~, loc] = findpeaks(vm, t, 'MinPeakProminence', 50);

        spks{i} = loc;
    end 

    spk_data(x).spktime.(namesOfNeurons{n}) = spks;

    total_spks = cell2mat(spks');

    [psth, centers] = return_histogram(total_spks, tspan(2), n_trials, 31);

    spk_data(x).FR.time = centers;
    spk_data(x).FR.(namesOfNeurons{n}) = psth;

end

end

save([pwd '/data/spk_data.mat'],'spk_data')

% sort, norm, plot etc. 
%{
TCsurround_FR(x,:) = mean(TC_FR);
TCsurround_meanFR(x)= mean(TCsurround_FR(x,516:975));
TCsurroundFR_SEM(x)=std(TCsurround_FR(x,516:975))/sqrt(length(TCsurround_FR(x,516:975)));

TRNsurround_FR(x,:) = mean(TRN_FR);
TRNsurround_meanFR(x)= mean(TRNsurround_FR(x,516:975));
TRNsurroundFR_SEM(x)=std(TRNsurround_FR(x,516:975))/sqrt(length(TRNsurround_FR(x,516:975)));

TCsurround_gain=TCsurround_meanFR./TCsurround0;
TRNsurround_gain=TRNsurround_meanFR./TRNsurround0;


figure(1);plot(centers,TCsurround_FR./TCsurround0);savefig([pwd '/data/TCsurround_plots.fig'])
figure(2);plot(centers,TRNsurround_FR./TRNsurround0);savefig([pwd '/data/TRNsurround_plots.fig'])


save([pwd '/data/TCsurround.mat'],'TC_FR','TCsurround_FR','TCsurround_meanFR','TCsurroundFR_SEM')
save([pwd '/data/TRNsurround.mat'],'TRN_FR','TRNsurround_FR','TRNsurround_meanFR','TRNsurroundFR_SEM')
%}

