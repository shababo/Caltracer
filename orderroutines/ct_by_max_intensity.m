function [result, rastermap, options] = ...
    ct_by_max_intensity(handles, ridxs, rastermap, regions, options)


% Very simple: Order the contours based on their max intensity. 

% Unlike clustering, the ordering routines must work on all contours,
% including those that have been eliminated from clustering.  This is
% true because the concept of ordering extends to all kinds of viewing
% such as coloration of the clickmap and trace plot as well.

% Use a small filter to avoid noise.
lil_filt = ones(1,5)/5;
ncontours = size(rastermap, 1);
len = size(rastermap, 2);
conv_rastermap = ones(ncontours, len+5-1);
for i = 1:ncontours
    conv_rastermap(i,:) = conv(rastermap(i,:), lil_filt);
end   
result = max(conv_rastermap, [], 2);

