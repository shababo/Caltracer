workspace=who;

%opsin data in which there are multiple files for each condition. In each
%file only ONE TRIAL is run.
%data will be in workspace from packephys (export visible data)

%indices of workspace which correspond to each condition should be set
%here:

no_shutter = [];
shutter = [];
shutter_only = [];


sample_rate = 10000;
ISI = 40; %interstimulus interval in Hz
flip = 0;

base_time = 1; %time before trials in which there is a baseline

number_trials = 1;


ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;



soi = 1;
nsi = 1;
si = 1;

for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data = eval([workspace{d} '.' channels{1}]);
    if flip ==1
        data = data*-1;
    end
    data_stim = eval([workspace{d} '.' channels{3}]);
    data_shutter = eval([workspace{d} '.' channels{4}]);
    stim_art_index = continuousabove(data_stim, 0, 2, 1, 100);
    shutter_index = continuousabove(data_shutter,0,2,10,21000);
    if isempty(stim_art_index)
        shutter_only(soi) = d;
        soi = soi + 1;
    else
        if isempty(shutter_index)
            no_shutter(nsi) = d;
            nsi = nsi + 1;
        else if ~isempty(shutter_index)
                shutter(si) = d;
                si = si + 1;
            end
        end
        ISI_all = roundn(diff(stim_art_index),1);
        ISIs_data = ISI_all(1);
        number_stims = length(stim_art_index)/number_trials;
        if ISIs_data ~= ISIs
            error('user input ISIs does not match calculated ISIs');
        end
        s = 1;
        for i = 1:number_trials
            indices{i} = zeros(number_stims,2);
            indices{i}(1:number_stims,1) = stim_art_index(s:s + number_stims -1,2) + 20;
            indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -40);
            event_index = indices{i};
            bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
            data= data -bl;
            bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
            data_trial{i,d} = data(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);
            for ii = 1:length(event_index)
                ap_index1 = findaps2(data(event_index(ii,1):event_index(ii,2)));
                if ~isempty(ap_index1)
                    integral(ii) = NaN;
                    integral_total(ii) = NaN;
                    amps(ii) = NaN;
                    ten_90(ii) = NaN;
                else
                    [max_amp index_max] = max(data(event_index(ii,1):event_index(ii,2)));
                    index_max = event_index(ii,1) + index_max -1;
                    [min_amp index_min] = min(data(event_index(ii,1):index_max));
                    index_min = event_index(ii,1) + index_min - 1;
                    if index_min >= index_max
                        integral(ii) = NaN;
                        integral_total(ii) = NaN;
                        amps(ii) = NaN;
                        ten_90(ii) = NaN;
                    else
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
                end
            end
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
end



% calculate and plot averages in both conditions
for ns = 1:length(no_shutter)
    for n = 1:number_trials
        amp_ns(ns,:) = all_amps{n, no_shutter(ns)};
        amp_ratios_ns(ns,:) = amp_ratios{n, no_shutter(ns)};
        ten_90_ns(ns,:) = ten_90_all{n, no_shutter(ns)};
        integral_ns(ns,:) = integral_all{n, no_shutter(ns)};
    end
    integral_total_event_ns(ns) = integral_total_event_all{no_shutter(ns)};
end

for sh = 1:length(shutter);
    for n = 1:number_trials
        amp_s(sh,:) = all_amps{n, shutter(sh)};
        amp_ratios_s(sh,:) = amp_ratios{n, shutter(sh)};
        ten_90_s(sh,:) = ten_90_all{n, shutter(sh)};
        integral_s(sh,:) = integral_all{n, shutter(sh)};
    end
    integral_total_event_s(sh) = integral_total_event_all{shutter(sh)};
end





total_integral(1,1) = getmeans(integral_total_event_ns);
total_integral(1,2) = getmeans(integral_total_event_s);
errors_integral(1,1) = get_SE(integral_total_event_ns);
errors_integral(1,2) = get_SE(integral_total_event_s);


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


data_no_shutter = cat(3,data_trial{:,no_shutter});
data_shutter = cat(3,data_trial{:,shutter});

avg_data_ns = mean(data_no_shutter,3);
avg_data_s = mean(data_shutter,3);
if flip ==1
    avg_data_ns = avg_data_ns*-1;
    avg_data_s = avg_data_s*-1;
end
figure; plot(avg_data_ns); hold on; plot(avg_data_s, 'r'); hold off;

figure; barweb(total_integral, errors_integral);
