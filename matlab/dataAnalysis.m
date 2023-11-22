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

for x=1:120
    TRN_meanFR(x) = mean(spk_data(x).FR.TRN1(516:975));
end
TRN1_meanFR = reshape(TRN_meanFR,6,[])';
%}
