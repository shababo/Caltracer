function partition = newpartition 
% This function serves to keep the structures 'the same' according to matlab,
% I beleive this means that the fields all have to be declared in the same
% order.
partition.id = 0;
partition.title = '0';
partition.numClusters = 0;
partition.options = [];
% not strictly necessary but faster.
partition.clusterIdxsByContour = {};	                        
partition.startIdxs = [];
partition.stopIdxs = [];
partition.colors = zeros(0,3);
partition.preprocessOptions = {};
partition.preprocessStrings = {};
partition.contourOrderId = 1;
partition.cleanContourTraces = [];
partition.cleanHaloTraces = [];

partition.clusters = struct;    % Must always go last! -DCS