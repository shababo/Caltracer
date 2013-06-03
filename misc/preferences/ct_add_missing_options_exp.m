function [exp, appdata] = ct_add_missing_options_exp(exp, appdata)
% function exp = ct_add_missing_options_exp(exp)
% 
% Set the defaults for the experiment so that if we add new options
% the saved 'experiment' files are not invalidated.

% Set the default options to use the halos, and align the signals
% correctly after a zscore.
if (~isfield(exp, 'preprocessOptions'))
     exp.preprocessOptions{1} = feval('ct_dfof_options');
     exp.preprocessOptions{2} = struct;
end

if (~isfield(exp, 'preprocessStrings'))
    exp.preprocessStrings{1} = 'dfof' ;
    exp.preprocessStrings{2} = 'halo_subtract';
end

% Old contour which is now contour lines.
if (isfield(exp, 'neurons') & isfield(exp, 'contours'))
    exp.numContours = exp.numNeurons;
    exp.contourLines = exp.contours;
    exp = rmfield(exp, 'contours');
    exp.contours = exp.neurons;
    exp = rmfield(exp, 'neurons');
    exp.contourOrder = exp.neuronOrder;
end


if (~isfield(exp, 'numMasks') & isfield(exp, 'nMaps'))
    exp.numMasks = exp.nMaps;
    exp = rmfield(exp, 'nMaps');	% update.
else
    exp.numMasks = 1;
end

if (~isfield(exp, 'numRegions') & isfield(exp, 'nRegions'))
    exp.numRegions = exp.nRegions;
    exp = rmfield(exp, 'nRegions');	% update.
end

if (~isfield(exp, 'numContours'))
    exp.numContours = 0;
end
if (~isfield(exp, 'numContourOrders'))
    exp.numContourOrders = 1;
end
if (~isfield(exp, 'contourColors'))
    exp.contourColors = jet(exp.numContours);
end

if (~isfield(exp, 'numPartitions'))
    % For some dumb reason I put the number of partitions in
    % appdata and not handles.exp.  Fixing this now. -DCS:2005/08/09
    if (isfield(appdata, 'numPartitions'))
	exp.numPartitions = appdata.numPartitions;
    else
	exp.numPartitions = 0;
    end
end


if (~isfield(exp, 'numContourOrders'))
    exp.numContourOrders = length(exp.contourOrder);
end
if (~isfield(exp, 'contourOrder'))
    corder = neworder;
    corder.id = 1;
    corder.title = '1';
    corder.orderName = 'default';
    corder.params = [];
    corder.order = 1:exp.numContours;
    corder.index = 1:exp.numContours;
    exp.contourOrder(1) = corder;

end
% Make up for some options that weren't there before.
if (isfield(exp, 'contourOrder'))
    add_new = 0;
    for coidx = 1:exp.numContourOrders
        if (~isfield(exp.contourOrder(coidx), 'title'))
            corder = neworder;
            corder.title = num2str(coidx);
            corder.id = num2str(coidx);
            corder.index = exp.contourOrder(coidx).index;
            corder.order = exp.contourOrder(coidx).order;
            contourOrder(coidx) = corder;
            add_new = 1;
        end
    end
    if (add_new)
        exp.contourOrder = contourOrder;
    end
   
end

% We always start with a default detection now.
% -DCS:2005/08/24 
if (~isfield(exp, 'numDetections'))
    exp.numDetections = 1;
end
if (isfield(exp, 'numDetections'))
    if (exp.numDetections <= 0)
	exp.numDetections = 1;
    end
end

if (~isfield(exp, 'detections'))
    exp.detections(1) = newdetection;
    exp.detections(1).id = 1;
    exp.detections(1).title = '1';
    exp.detections(1).detectorName = 'default';
    exp.detections(1).params = [];
    exp.detections(1).onsets = cell(1, exp.numContours);
    exp.detections(1).offsets = cell(1, exp.numContours);    
end




% Backwards compatibility for clusterIdxsByContour
if (isfield(exp, 'partitions'))
    if (~isfield(exp.partitions(1), 'clusterIdxsByContour'))
        for pidx = 1:exp.numPartitions
            cidxs = zeros(1,exp.numContours);
            p = exp.partitions(pidx);
            partitions(pidx) = newpartition;
            partitions(pidx).id = p.id;
            partitions(pidx).title = p.title;
            partitions(pidx).numClusters = p.numClusters;
            partitions(pidx).startIdxs = p.startIdxs;
            partitions(pidx).stopIdxs = p.stopIdxs;
            partitions(pidx).colors = p.colors;
            partitions(pidx).preprocessOptions = p.preprocessOptions;
            partitions(pidx).preprocessStrings = p.preprocessStrings;
            partitions(pidx).contourOrderId = p.contourOrderId;
            partitions(pidx).cleanContourTraces = p.cleanContourTraces;
            partitions(pidx).cleanHaloTraces = p.cleanHaloTraces;
            partitions(pidx).clusters = p.clusters;    % Must always go last! -DCS
            for i = 1:exp.numContours
                for j = 1:p.numClusters
                    pot_cidx = find([p.clusters(j).contours]==i);
                    if ~isempty(pot_cidx)
                        cidxs(i) = j;
                        break;
                    end
                end
            end
            partitions(pidx).clusterIdxsByContour = num2cell(cidxs);
        end
        exp.partitions = partitions;
    end
end