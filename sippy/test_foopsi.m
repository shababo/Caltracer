clear all;

load('C:\Tanya_Data\Imaging\workspace\030311_s2r2_cell1.mat');
% epath =  'C:\Tanya_Data\Physiology\March_2011\030311\s2r2.paq';

[V_trace frametime spike_frame_index spframe time start_UP_index exptime] = spike_frame_time(rawF, epath);

%%INPUTS
%%rawF      --   fluorescence vector 1 X Nframes 
%%epath     --   path to associated ephys file 
%%both inputs should be supplied in the loaded workspace


% V_trace --> ephys recording
% frametime --> time of frames in ephys samples
% spike_frame_index --> frametime in which spikes occur
% spframe --> binary vector same length of movie frames; in frames in which there is a spike will be 1, otherwise, 0
    % same as vector spikes from workspace
% time--> x axis for ephys plot converted to ms (starts when camera frames
    % start)
%% make plot

ephysrate = 10000;
figure;
a(1) = subplot(3,1,1); hold on;

F = -detrend(rawF);
F=F-min(F); 
F=F/max(F); 
F=F+eps;

%create deltaF

baseline = mean(rawF(1:200)); %change this according to fluorescence trace
deltaF = (rawF-baseline)./baseline;
deltaF = -detrend(deltaF);


plot(frametime/ephysrate, deltaF,'k'); hold on;
% plot(find(spframe == 1),1,'rv'); % can use spframe here instead
plot(spike_frame_index/ephysrate, max(deltaF) + .05,'r.');
%% run oopsi



V.dt = exptime(1)/ephysrate;
P.a = 1.5;
P.b = median(F);
P.lam= 2.5;
tau=1;
P.gam = (1-V.dt/tau)';
n = fast_oopsi(F,V,P);


%% add to plot- foopsi output
a(2) = subplot(3,1,2); hold on;
bar(frametime/ephysrate, n./max(n));
% plot(find(spframe == 1),1,'rv');
plot(spike_frame_index/ephysrate,1,'r.');
%% add to plot- ephys

a(3) = subplot(3,1,3); plot(time, V_trace); hold on;
% hold on; plot(spike_frame_index/ephysrate,1,'r.');
linkaxes(a,'x');



%% use this code only if want to expand window range
% min_window = 1;
% max_window = 3;
% window_range = min_window:max_window;
%
% for j = 1:length(window)
%     window = window_range(j)

end_UP_index = start_UP_index + 200;

UP_index = [start_UP_index:end_UP_index];

nonzero_thresh = .00000001;

norm_n = n./max(n);
window = 0;

%true positives and false negatives

for nzt = 1:length(nonzero_thresh)
    thresh = nonzero_thresh(nzt);
    spike_index = find(spframe);
    tp = 0;
    fn = 0;
    tp_UP = 0;
    fn_UP = 0;
    %     spike_index(length(spike_index)) = [];
    for i = 1:length(spike_index)
        si = spike_index(i);
        if window > 0
            if si > window && si < length(spframe -1)
                n_spike(i) = sum(norm_n(si:si+window)) + sum(norm_n(si-window:si-1));
            end
        else n_spike(i) = norm_n(si);
        end
        if n_spike(i) > thresh
            tp = tp + 1;
            if ismember(spike_index(i), UP_index) == 1
                tp_UP = tp_UP + 1;
            end
        else fn = fn + 1;
            if ismember(spike_index(i), UP_index) == 1
            fn_UP = fn_UP + 1;
            end
        end
    end

    true_positive(nzt) = tp;
    true_positive_UP(nzt) = tp_UP;
    false_negative(nzt) = fn;
    false_negative_UP(nzt) = fn_UP;

 
    %false positives

    fp = 0;
    fp_UP = 0;
    foopsi_positive_index = find(norm_n > thresh); %index of positive foopsi output
    if foopsi_positive_index(end) == length(spframe)
        foopsi_positive_index(end) = [];
    end

    for ii = 1:length(foopsi_positive_index)
        fpi = foopsi_positive_index(ii);
        spi_pos = spframe(fpi-window:fpi+window);
        fps = find(spi_pos);
        if ~isempty(fps)
            fp = fp + 1;
            if ismember(foopsi_positive_index(ii), UP_index) == 1
                fp_UP = fp_UP + 1;
            end
        end
    end

    false_positive(nzt) = fp;
    false_positive_UP(nzt) = fp_UP;
    
    %true negative
    tn = 0;
    tn_UP = 0;
%     foopsi_negative_index = find(norm_n < thresh);
    
    foopsi_negative_index = find(norm_n < thresh);
    
    for iii = 1:length(foopsi_negative_index)  %go through all negatives
        fni = foopsi_negative_index(iii);      % for each negative
        if fni > window && fni < length(spframe -1)
            spi_neg = spframe(fni-window:fni+window); %find corresponding spike index
        else spi_neg = spframe(fni); 
        end
        fns = find(spi_neg); %did foopsi find a spike in this frame?
        if isempty(fns) % if not, count as true negative
            tn = tn + 1; 
            if ismember(foopsi_negative_index(iii), UP_index) == 1
                tn_UP = tn_UP + 1;
            end
        end
    end
    
    true_negative(nzt) = tn;
    true_negative_UP(nzt) = tn_UP;

    specificity(nzt) = true_negative(nzt)/(true_negative(nzt) + false_positive(nzt));
    sensitivity(nzt) = true_positive(nzt)/(true_positive(nzt) + false_negative(nzt));
    
    % during UP state
    specificity_UP(nzt) = true_negative_UP(nzt)/(true_negative_UP(nzt) + false_positive_UP(nzt));
    sensitivity_UP(nzt) = true_positive_UP(nzt)/(true_positive_UP(nzt) + false_negative_UP(nzt));
    

    TPR(nzt) = sensitivity(nzt);
    FPR(nzt) = 1 - specificity(nzt);
    
    TPR_UP(nzt) = sensitivity_UP(nzt);
    FPR_UP(nzt) = 1 - specificity_UP(nzt);

end


