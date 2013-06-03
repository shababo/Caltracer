function [onsets, offsets, param] = ...
    ct_single_max(rastermap, handles, ridxs, clustered_contour_ids, options)
%-BW:2005/10/14
%Finds the absolute max of each signal.  
waithandle = waitbar(0,'Detecting signals');
for idx = 1:size(rastermap,1);%for each trace
    [trash, maxindex] = max(rastermap(idx,:));
    onsets{idx} = maxindex;
    offsets{idx} = maxindex;
    waitbar(idx/size(rastermap,1), waithandle);
end
param=[];
delete(waithandle);