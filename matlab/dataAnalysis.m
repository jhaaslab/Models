function dataAnalysis()
% ISI, mean, plot etc.

if ~isfolder('data')
    error(['data not found in current working directory. '...
     'cd to sim directory and ensure sim data was extracted.'])
end

load([pwd '/vars/sim_vars.mat'], 'namesOfNeurons','tspan','reps','perBlk','var_combos');


t=0.5:1:tspan(2);

n_totalVars = length(var_combos);
numBlks     = ceil(n_totalVars/perBlk);
numCells    = length(namesOfNeurons);
n_trials    = reps;

spkData_all=[];
for b = 1:numBlks
load([pwd '/data/spkData' num2str(b) '.mat'],  'spkData');

spkData = [spkData{:}];
save([pwd '/data/spkData' num2str(b) '.mat'],  'spkData');

spkData_all = [spkData_all spkData];
end

spkData = spkData_all;
save([pwd '/data/spkData.mat'],  'spkData');


%ISI{numCells,n_totalVars} = [];
meanFR = zeros(numCells,n_totalVars); tmean=[515, 575];
for x=1:n_totalVars

for n=1:numCells
%{
for i=1:n_trials
    % ISI
    spksi = spk_data(x).spktime.(namesOfNeurons{n}){i};
    spksi = spksi(spksi>300);

    if length(spksi) > 1
        isi_i = spksi(2:end)-spksi(1:end-1);
        ISI{n,x} = [ISI{n,x} isi_i];
    end

end
%}
% meanFR
FR = spkData(x).FR.(namesOfNeurons{n});

meanFR(n,x) = mean(FR(t>tmean(1) & t<tmean(2)));

end
end

%meanFR = reshape(meanFR,numCells, )

%save([pwd '/data/ISI.mat'],   'ISI')
save([pwd '/data/meanFR_I1.mat'],'meanFR')

end
