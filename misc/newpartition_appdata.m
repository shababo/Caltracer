function partition = newpartition_appdata(numclusters)
% function partition = newpartition_appdata(numclusters)

% Called by createclusters and open as caltracer 1.x.

% Create the fields for a new appdata partition, which just manages
% the GUI preferences.
for cidx = 1:numclusters
    partition.clusters(cidx).doPlotMean = 1;
    partition.clusters(cidx).doPlotStandardDeviation = 0;
    partition.clusters(cidx).doShowPosition = 0;
    partition.clusters(cidx).doShowBorder = 0;
    partition.clusters(cidx).doShowClusterBorder  = 0;
end
partition.displayedContours = [];
