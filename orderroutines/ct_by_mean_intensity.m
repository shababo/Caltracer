function [result, rastermap, options] = ...
    ct_by_mean_intensity(handles, ridxs, rastermap, regions, options)


% Very simple: Order the contours based on their mean intensity. 

% Unlike clustering, the ordering routines must work on all contours,
% including those that have been eliminated from clustering.  This is
% true because the concept of ordering extends to all kinds of viewing
% such as coloration of the clickmap and trace plot as well.

result = mean(rastermap, 2);

