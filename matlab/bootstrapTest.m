function [h, p] = bootstrapTest(spks_x,spks_y,nElements,M,plots)
% Estimate p-value that average maximum response between spks_x,spks_y not 
% equal using a bootstrap method. Total replications (nElements)
% partitioned into M clusters with length nTrials. 
% Defaults: nElements=200; M=4; nTrials=50;
nTrials = nElements/M;


FR_x=[];
psth_x=[];
FR_y=[];
psth_y=[];
for i=1:M
   spks_x = {spks_x{1,1+nTrials*(i-1):nTrials*i}}; %#ok<*CCAT1>
   [centers, psth, FR] = returnFR(spks_x',nTrials);
   psth_x = [psth_x; psth];
   FR_x = [FR_x FR]; %#ok<*AGROW>
   
   spks_y = {spks_y{1,1+nTrials*(i-1):nTrials*i}};
   [centers, psth, FR] = returnFR(spks_y',nTrials);
   psth_y = [psth_y; psth];
   FR_y = [FR_y FR];
end

meanPsth_x = mean(psth_x);
stdPsth_x = std(psth_x);

meanPsth_y = mean(psth_y);
stdPsth_y = std(psth_y);

meanFR_x = mean(FR_x);
varFR_x = var(FR_x);

meanFR_y = mean(FR_y);
varFR_y = var(FR_y);

tStat = abs(meanFR_x-meanFR_y)/sqrt((varFR_x/M) + (varFR_y/M));

meanFR_all = mean([FR_x FR_y]);

xPrime = FR_x-meanFR_x+meanFR_all;
yPrime = FR_y-meanFR_y+meanFR_all;


B=1000;
bootFR_x = bootstrp(B,@(x)[mean(x) var(x)],xPrime);
bootFR_y = bootstrp(B,@(x)[mean(x) var(x)],yPrime);

tStar = abs(bootFR_x(:,1)-bootFR_y(:,1)) ./ sqrt((bootFR_x(:,2)./M) + (bootFR_y(:,2)./M));
tStarTF = tStar(tStar>=tStat);
p = numel(tStarTF)/B;
if p<0.05
    h = 1;
else
    h = 0;
end



function [centers, psth, FR] = returnFR(spks,Ntrials)
spk_times=[];
for n=1:Ntrials
spk_times=[spk_times spks{n,1}'];
end

edges = 0:1:1500; 
centers = (edges(1:end-1)+edges(2:end))/2; 
counts = histcounts(spk_times, edges);
counts = counts/Ntrials;
sm_wind = hanning(31); % gausswin(smooth_win,smooth_win/10);
psth = conv(counts, sm_wind, 'same')/sum(sm_wind);

FR = max(psth);
end
end