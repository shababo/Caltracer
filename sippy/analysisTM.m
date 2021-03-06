close all; clear all;
load('C:\Tanya_Data\Imaging\workspace\092410_s2m1_8.mat')

%% make plot
figure; 
a(1) = subplot(2,1,1); hold on;
F = -detrend(signals);
F=F-min(F); F=F/max(F); F=F+eps;
% n = spikes;
plot(F./max(F),'k');
plot(find(spikes == 1),1,'rv');

%% run oopsi
V.dt = .015;
P.b = median(F);
n = fast_oopsi(F,V,P);

%% sensitivity and selectivity of oopsi
nonzero_thresh = .01;

norm_n = n./max(n);
%% use this code only if want to expand window range
% min_window = 0;
% max_window = 3;
% window_range = min_window:max_window;
% 
% for j = 1:length(window)
%     window = window_range(j)

window = 0;
%true positives and false negatives
spike_index = find(spikes);
true_positive = 0;
false_negative = 0;
spike_index(length(spike_index)) = []; 
for i = 1:length(spike_index)
    si = spike_index(i);
    if window > 0
    n_spike(i) = sum(norm_n(si):norm_n(si+window)) + sum(norm_n(si-window):norm_n(si-1));
    else n_spike(i) = norm_n(si);
    end
    if n_spike(i) > nonzero_thresh
    true_positive = true_positive + 1;
    else false_negative = false_negative + 1;
    end
end

%false positives
false_positive = 0;
foopsi_positive_index = find(norm_n > nonzero_thresh); %index of positive foopsi output

for ii = 1:length(foopsi_positive_index)
    fpi = foopsi_positive_index(ii);
    spi_pos = spikes(fpi-window:fpi+window);
    fps = find(spi_pos);
    if ~isempty(fps)
        false_positive = false_positive + 1;
    end
end

true_negative = 0;
foopsi_negative_index = find(norm_n < nonzero_thresh);
for iii = 1:length(foopsi_negative_index)
    fni = foopsi_negative_index(iii);
    if fni > window && fni < length(spikes -1)
        spi_neg = spikes(fni-window:fni+window);
    else spi_neg = spikes(fni);
    end
    fns = find(spi_neg);
    if isempty(fns)
        true_negative = true_negative + 1;
    end
end


    
specificity = true_negative/(true_negative + false_positive);
sensitivity = true_positive/(true_positive + false_negative);
%%     
%% add to plot
a(2) = subplot(2,1,2); hold on;
bar(n./max(n));
plot(find(spikes == 1),1,'rv');
linkaxes(a,'xy');