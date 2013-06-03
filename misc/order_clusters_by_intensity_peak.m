function handles = order_clusters_by_intensity_peak (handles, pidx);

c=handles.app.experiment.partitions(pidx).clusters;
for cidx = 1:length(c);
    [trash, maxes(cidx)] = max(c(cidx).meanIntensityClean);
end
[trash, sort_idxs] = sort(maxes);
for cidx = 1:length(sort_idxs);
    temp_clusters(cidx) = c(sort_idxs(cidx));
    temp_clusters(cidx).id = cidx;
    temp_clusters(cidx).color = handles.app.experiment.partitions(pidx).colors(cidx,:);
end
c = temp_clusters;

handles.app.experiment.partitions(end).clusters = c;