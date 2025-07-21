function [psth, centers] = return_histogram(spk_times, t_span, bw, n_trials, smooth_win)
edges = 0:bw:t_span; 
centers = (edges(1:end-1)+edges(2:end))/2; 
counts = histcounts(spk_times, edges);
counts = counts/n_trials;
sm_wind = hanning(round(smooth_win)); 
psth = conv(counts, sm_wind, 'same')/sum(sm_wind);
end