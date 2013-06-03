function handles = mergeclusters(handles, pidx, combineclusters)
% Combine the clusters in each row of combineclusters.  So {[1 3 5] [2
% 4 6]} will create two clusters of {1,3,5} and {2,4,6}.
%
% BECAUSE THE COMBINATION SIZES MIGHT VARY THE COMBINECLUSTERS
% PARAMETER IS A CELL ARRAY.  SO YOU MUST USE THE '{' '}' SYNTAX!

%
% (C) 2004 David C. Sussillo.  All rights reserved.

ncombines = size(combineclusters, 2);

p = handles.app.experiment.partitions(pidx);
% Since we affectively delete the combined clusters (minus one) we
% have to update the app.data structure too.
app_p = handles.app.data.partitions(pidx);

% BP.
for i = 1:ncombines
    for j = combineclusters{i}
        if (isempty(find([p.clusters.id] == j)))
            error(['Cluster ' num2str(j) ' does not exist.']);
        end
    end
end

% Combine the clusters.
numdeleted = 0;
for i = 1:ncombines
    combines = combineclusters{i};
    into_id = combines(1);		% save for later.
    into_idx = find([p.clusters.id] == into_id);
    all_into_idxs{i} = into_idx; % save for later.
    combines = combines(2:end);
    numdeleted = numdeleted + length(combines);
    all_combines_idx{i} = [];
    for cid = combines			% cluster id=
        cidx = find([p.clusters.id] == cid);
        all_combines_idx{i} = [all_combines_idx{i} cidx];
        p.clusters(into_idx).contours = ...
            [p.clusters(into_idx).contours ...
            p.clusters(cidx).contours];
    end
    p.clusters(into_idx).numContours = ...
	length(p.clusters(into_idx).contours);

    % Delete the old clusters.  Leave the clusterColor array alone
    % because the color is keyed to id, and not the idx.
    for j_id = combines
        j_idx = find([p.clusters.id] == j_id);
        p.clusters(j_idx) = [];
        app_p.clusters(j_idx) = [];
    end
end
p.numClusters = p.numClusters - numdeleted;

% Update the clusterIdxsByContour field.  Replace the current cid for a
% given contour with the cid that it should now go into.
for j = 1:length(all_combines_idx)
    for i = 1:handles.app.experiment.numContours
        if(~isempty(find(all_combines_idx{j} == p.clusterIdxsByContour{i})))
            p.clusterIdxsByContour{i} = all_into_idxs{j};
        end
    end
end
% Now account for lost cluster indices.
for j = 1:length(all_combines_idx)
    p.clusterIdxsByContour = updatecontourids(p.clusterIdxsByContour, all_combines_idx{j});
end


% Finally, we've updated the neuron ids so we now generate the data
% for each cluster.
p = genclusterstats(handles, p, 'computecolors', 0);

handles.app.experiment.partitions(pidx) = p;
% Since we affectively delete the combined clusters (minus one) we
% have to update the app.data structure too.
handles.app.data.partitions(pidx) = app_p;