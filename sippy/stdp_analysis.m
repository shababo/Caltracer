workspace=who;

%data will be in workspace from packephys (export visible data)

sample_rate = 10000;
ISI = 100; %interstimulus interval in Hz
ITI = 10; % intertrial interval--> seconds in between stimulation trials change according to experimental conditions
base_time = .5; %time before trials in which there is a baseline


ITIs = ITI*sample_rate;

ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;

before = [1];
after = [2];


flip = 1;

soi = 1;
nsi = 1;
si = 1;

for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data = eval([workspace{d} '.' channels{1}]);
    if flip ==1;
        data = data*-1;
    end
    data_stim = eval([workspace{d} '.' channels{3}]);
    stim_art_index = continuousabove(data_stim, 0, 2, 1, 100);
    
    ISI_all = roundn(diff(stim_art_index),1);
    ISIs_data = ISI_all(1);
    ISIs_range = ISIs_data-20:ISIs_data + 20;
    end_trial = find(ISI_all(:,1) > ITIs);
    number_trials = length(end_trial) + 1;
    number_stims = length(stim_art_index)/number_trials;
    if isempty(find(ismember(ISIs_data,ISIs_range)))
        error('user input ISIs does not match calculated ISIs');
    end
    s = 1;
    for i = 1:number_trials
        indices{i} = zeros(number_stims,2);
        indices{i}(1:number_stims,1) = stim_art_index(s:s + number_stims -1,2) + 20;
        indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -25);
        event_index = indices{i};
        bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
        data= data -bl;
        bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
        data_trial{i,d} = data(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);
        for ii = 1:length(event_index)
            [max_amp index_max] = max(data(event_index(ii,1):event_index(ii,2)));
            index_max = event_index(ii,1) + index_max -1;
            [min_amp index_min] = min(data(event_index(ii,1):index_max));
            index_min = event_index(ii,1) + index_min - 1;
            amp_event = data(index_min:index_max) - min_amp;
            amp_10 = find(amp_event > .1*max(amp_event),1, 'first');
            amp_90 = find(amp_event > .9*max(amp_event),1, 'first');
            amp_event = data(index_min:event_index(ii,2)) - min_amp;
            integral(ii)  = sum(amp_event);
            integral_event = data((index_min:event_index(ii,2))) - bl;
            integral_total(ii) = sum(integral_event);
            amps(ii) = max_amp - min_amp;
            ten_90(ii) = (amp_90 - amp_10)/sample_rate;
        end
        integral_total_event(i) = sum(integral_total);
        for iii = 1:length(event_index);
            amp_ratio(iii) = amps(iii)/amps(1);
        end
        all_amps{i,d} = amps;
        amp_ratios{i,d} = amp_ratio;
        ten_90_all{i,d} = ten_90;
        integral_all{i,d} = integral;
        integral_total_event_all{:,d} = integral_total_event;
        s = s + number_stims;
        amps = [];
        amp_ratio = [];
        ten_90 = [];
        integral = [];
        integral_total = [];
        amp_event = [];
        integral_event = [];
    end
    data = [];
    stim_art_index = [];
end


% calculate and plot averages in both conditions

for n = 1:number_trials
    amp_ns(n,:) = all_amps{n, before};
    amp_s(n,:) = all_amps{n, after};
    amp_ratios_ns(n,:) = amp_ratios{n, before};
    amp_ratios_s(n,:) = amp_ratios{n, after};
    ten_90_s(n,:) = ten_90_all{n, before};
    ten_90_ns(n,:) = ten_90_all{n, after};
    integral_ns(n,:) = integral_all{n, before};
    integral_s(n,:) = integral_all{n, after};
end

integral_total_event_ns = integral_total_event_all{before};
integral_total_event_s = integral_total_event_all{after};



total_integral(before,1) = getmeans(integral_total_event_ns);
total_integral(after,1) = getmeans(integral_total_event_s);
errors_integral(before,1) = get_SE(integral_total_event_ns);
errors_integral(after,1) = get_SE(integral_total_event_s);




figure;
a(1) = subplot(3,1,1); hold on; title('amp');
[avg_amp_ns std_amp_ns] = getmeans2(amp_ns);
[avg_amp_s std_amp_s] = getmeans2(amp_s);
errorbar(avg_amp_ns, std_amp_ns); errorbar(avg_amp_s, std_amp_s,  'r');

a(2) = subplot(3,1,2); hold on; title('integral');
[avg_integral_ns std_integral_ns] = getmeans2(integral_ns);
[avg_integral_s std_integral_s] = getmeans2(integral_s);
errorbar(avg_integral_ns, std_integral_ns); errorbar(avg_integral_s, std_integral_s,  'r');

a(3) = subplot(3,1,3); hold on; title('Pulse Ratios');
[avg_ratios_ns std_ratios_ns] = getmeans2(amp_ratios_ns);
[avg_ratios_s std_ratios_s] = getmeans2(amp_ratios_s);
errorbar(avg_ratios_ns, std_ratios_ns); errorbar(avg_ratios_s, std_ratios_s, 'r');
linkaxes(a,'x');
hold off;


data_before = cat(3,data_trial{:,before});
data_after = cat(3,data_trial{:,after});

avg_data_ns = mean(data_before,3);
avg_data_s = mean(data_after,3);

if flip == 0
        figure; plot(avg_data_ns); hold on; plot(avg_data_s, 'r'); hold off;
else if flip ==1
        figure; plot(avg_data_ns*-1); hold on; plot(avg_data_s*-1, 'r'); hold off;
    end
end




figure; barweb(total_integral, errors_integral);
