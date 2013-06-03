function [ F deltaF ] = plot_deltaF( rawF )
% INPUT
% matrix of fluorescence signals nFrames x nNeurons
% OUTPUT
% fluorescnce values will be expressed in terms of deltaF and plotted
%delete every other column which are just contour number

delete(1) = 1;
for dd = 2:size(rawF,2)-1
    delete(dd) = delete(dd-1) + 2;
end
delete = delete(find(delete<(size(rawF,2))));
rawF(:,delete) = [];
F = rawF;

for n = 1:size(F,2)
    baseline = mean(F(1:200,n));
    deltaF(:,n) = (F(:,n)-baseline)/baseline;
    baseline = [];
end


