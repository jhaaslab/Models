function [psth, centers] = return_histogram(spk_times, t_span, n_trials, smooth_win)
edges = 0:1:t_span; 
centers = (edges(1:end-1)+edges(2:end))/2; 
counts = histcounts(spk_times, edges);
counts = counts/n_trials;
sm_wind = hanning(smooth_win); % gausswin(smooth_win,smooth_win/10);
psth = conv(counts, sm_wind, 'same')/sum(sm_wind);
end