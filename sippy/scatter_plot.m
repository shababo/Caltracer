function sctrplt = scatter_plot(diff_spikes)

%spike_diffs is a cell array

colors = 'rgbmcykrgbmcykrgbmcyk';


for j = 1:length(diff_spikes);
    sweep = diff_spikes{j};
    for i = 1:size(sweep,2)
        plot(j, sweep(i), 'dk');
        hold on;
    end
    sweep = [];
end



