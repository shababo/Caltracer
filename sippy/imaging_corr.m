workspace = who;


%extract spike inference for all cells in each movie
%inference and F are cell arrays; each entry is one movie, and within each
%of these are all the cells in that movie
%e.g. inference{1,2}{1} is the spike inference for first cell in the second
%movie

for i = 1:length(workspace)
    rawF = eval(workspace{i});
        [inference{i} deltaF{i} F{i}] = stim_spike_inference(rawF);
end


for j = 1:length(inference) %for each movie
    [Ncorr{j} Fcorr{j} Fns_corr{j}] = corr_spike_inf(inference{1,j}, F{1,j});
end

