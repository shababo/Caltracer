function [onsets, offsets, param] = ct_None_(rastermap, handles, ridxs, clustered_contour_ids, options)
%Updated 7/29/09 -MD
onsets = cell(1,length(clustered_contour_ids));
offsets = cell(1,length(clustered_contour_ids));
param = [];