workspace=who;

%data will be in workspace from packephys (export visible data)

sample_rate = 10000;
ISI = 20; %interstimulus interval in Hz
ITI = 4; % intertrial interval--> seconds in between stimulation trials change according to experimental conditions
base_time = .5; %time before trials in which there is a baseline


ITIs = ITI*sample_rate;

ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;

shutter_only = [];
no_shutter = [];
shutter = [];



soi = 1;
nsi = 1;
si = 1;

for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data_EPSP = eval([workspace{d} '.' channels{1}]) ;
    data_IPSC = eval([workspace{d} '.' channels{2}]);
    data_stim = eval([workspace{d} '.' channels{3}]);
    data_shutter = eval([workspace{d} '.' channels{4}]);
    stim_art_index = continuousabove(data_stim, 0, 2, 1, 100);
    shutter_index = continuousabove(data_shutter,0,2,10,10000);
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
            indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -40);
            event_index = indices{i};
            bl_EPSP = mean(data_EPSP(event_index(1,1)- bt:event_index(1,1) - 100));
            data_EPSP= data_EPSP -bl_EPSP;
            bl_IPSC = mean(data_IPSC(event_index(1,1)- bt:event_index(1,1) - 100));
            bl_IPSC = mean(data_IPSC(event_index(1,1)- bt:event_index(1,1) - 100));
            data_IPSC= data_IPSC -bl_IPSC;
            bl_IPSC = mean(data_IPSC(event_index(1,1)- bt:event_index(1,1) - 100));
            data_trial_EPSP{i,d} = data_EPSP(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);
            data_trial_IPSC{i,d} = data_IPSC(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);           
            for ii = 1:length(event_index)
                ap_index1 = findaps2(data_EPSP(event_index(ii,1):event_index(ii,2)));
                if ~isempty(ap_index1)
                    integral_EPSP(ii) = NaN;
                    integral_total_EPSP(ii) = NaN;
                    amps_EPSP(ii) = NaN;
                    ten_90_EPSP(ii) = NaN;
                    num_aps_EPSP(ii) = length(ap_index1);
                    integral_IPSC(ii) = NaN;
                    integral_total_IPSC(ii) = NaN;
                    amps_IPSC(ii) = NaN;
                    ten_90_IPSC(ii) = NaN;
                    num_aps_IPSC(ii) = length(ap_index1);
                else
                    [max_amp index_max] = max(data_EPSP(event_index(ii,1):event_index(ii,2)));
                    index_max = event_index(ii,1) + index_max -1;
                    [min_amp index_min] = min(data_EPSP(event_index(ii,1):index_max));
                    index_min = event_index(ii,1) + index_min - 1;
                    amp_event = data_EPSP(index_min:index_max) - min_amp;
                    amp_10 = find(amp_event > .1*max(amp_event),1, 'first');
                    amp_90 = find(amp_event > .9*max(amp_event),1, 'first');
                    amp_event = data_EPSP(index_min:event_index(ii,2)) - min_amp;
                    integral_EPSP(ii)  = sum(amp_event);
                    integral_event_EPSP = data_EPSP((index_min:event_index(ii,2))) - bl_EPSP;
                    integral_total_EPSP(ii) = sum(integral_event_EPSP);
                    amps_EPSP(ii) = max_amp - min_amp;
                    if ~isempty(amp_10)
                        ten_90_EPSP(ii) = (amp_90 - amp_10)/sample_rate;
                    else
                        ten_90_EPSP(ii) = NaN;
                    end
                    %% repeat measurements for IPSCs
                    [max_amp index_max] = max(data_IPSC(event_index(ii,1):event_index(ii,2)));
                    index_max = event_index(ii,1) + index_max -1;
                    [min_amp index_min] = min(data_IPSC(event_index(ii,1):index_max));
                    index_min = event_index(ii,1) + index_min - 1;
                    amp_event = data_IPSC(index_min:index_max) - min_amp;
                    amp_10 = find(amp_event > .1*max(amp_event),1, 'first');
                    amp_90 = find(amp_event > .9*max(amp_event),1, 'first');
                    amp_event = data_IPSC(index_min:event_index(ii,2)) - min_amp;
                    integral_IPSC(ii)  = sum(amp_event);
                    integral_event_IPSC = data_IPSC((index_min:event_index(ii,2))) - bl_IPSC;
                    integral_total_IPSC(ii) = sum(integral_event_IPSC);
                    amps_IPSC(ii) = max_amp - min_amp;
                    ten_90_IPSC(ii) = (amp_90 - amp_10)/sample_rate;
                end
            end
            %% data within trial for EPSPs and IPSCs
            integral_total_event_EPSP(i) = sum(integral_total_EPSP);
            integral_total_event_IPSC(i) = sum(integral_total_IPSC);
            for iii = 1:length(event_index);
                pp_ratio_EPSP(iii) = amps_EPSP(iii)/amps_EPSP(1);
                pp_ratio_IPSC(iii) = amps_IPSC(iii)/amps_IPSC(1);
            end
            all_amps_EPSP{i,d} = amps_EPSP;
            pp_ratios_EPSP{i,d} = pp_ratio_EPSP;
            ten_90_all_EPSP{i,d} = ten_90_EPSP;
            integral_all_EPSP{i,d} = integral_EPSP;
            integral_total_event_all_EPSP{:,d} = integral_total_event_EPSP;
            all_amps_IPSC{i,d} = amps_IPSC;
            pp_ratios_IPSC{i,d} = pp_ratio_IPSC;
            ten_90_all_IPSC{i,d} = ten_90_IPSC;
            integral_all_IPSC{i,d} = integral_IPSC;
            integral_total_event_all_IPSC{:,d} = integral_total_event_IPSC;
            s = s + number_stims;
            amps_EPSP = [];
            pp_ratio_EPSP = [];
            ten_90_EPSP = [];
            integral_EPSP = [];
            integral_total_EPSP = [];
            integral_event_EPSP = [];
            amps_IPSC = [];
            pp_ratio_IPSC = [];
            ten_90_IPSC = [];
            integral_IPSC = [];
            integral_total_IPSC = [];
            amp_event_IPSC = [];
            integral_event_IPSC = [];
        end
        data = [];
        stim_art_index = [];
    end
end

%% calculate and plot averages in both conditions

% calculate and plot averages in both conditions
for ns = 1:length(no_shutter)
    for n = 1:number_trials
        amp_ns_EPSP(ns,:) = all_amps_EPSP{n, no_shutter(ns)};     
        pp_ratios_ns_EPSP(ns,:) = pp_ratios_EPSP{n, no_shutter(ns)};      
        ten_90_ns_EPSP(ns,:) = ten_90_all_EPSP{n, no_shutter(ns)};      
        integral_ns_EPSP(ns,:) = integral_all_EPSP{n, no_shutter(ns)};
         amp_ns_IPSC(ns,:) = all_amps_IPSC{n, no_shutter(ns)}; 
        pp_ratios_ns_IPSC(ns,:) = pp_ratios_IPSC{n, no_shutter(ns)};     
        ten_90_ns_IPSC(ns,:) = ten_90_all_IPSC{n, no_shutter(ns)};    
         integral_ns_IPSC(ns,:) = integral_all_IPSC{n, no_shutter(ns)};
    end
%     integral_total_event_ns_EPSP(ns) = integral_total_event_all_EPSP{no_shutter(ns)};
%     integral_total_event_ns_IPSC(ns) = integral_total_event_all_IPSC{no_shutter(ns)};
end

for sh = 1:length(shutter);
    for n = 1:number_trials
        amp_s_EPSP(sh,:) = all_amps_EPSP{n, shutter(sh)};     
        pp_ratios_s_EPSP(sh,:) = pp_ratios_EPSP{n, shutter(sh)};      
        ten_90_s_EPSP(sh,:) = ten_90_all_EPSP{n, shutter(sh)};      
        integral_s_EPSP(sh,:) = integral_all_EPSP{n, shutter(sh)};
         amp_s_IPSC(sh,:) = all_amps_IPSC{n, shutter(sh)}; 
        pp_ratios_s_IPSC(sh,:) = pp_ratios_IPSC{n, shutter(sh)};     
        ten_90_s_IPSC(sh,:) = ten_90_all_IPSC{n, shutter(sh)};    
         integral_s_IPSC(sh,:) = integral_all_IPSC{n, shutter(sh)};
    end
%     integral_total_event_s_EPSP(sh) = integral_total_event_all_EPSP{shutter(sh)};
%     integral_total_event_s_IPSC(sh) = integral_total_event_all_IPSC{shutter(sh)};
end



avg_amp_ns_EPSP = getmeans2(amp_ns_EPSP);
avg_amp_s_EPSP = getmeans2(amp_s_EPSP);
avg_amp_ns_IPSC = getmeans2(amp_ns_IPSC);
avg_amp_s_IPSC = getmeans2(amp_s_IPSC);

avg_pp_ratios_ns_EPSP = getmeans2(pp_ratios_ns_EPSP);
avg_pp_ratios_s_EPSP = getmeans2(pp_ratios_s_EPSP);
avg_pp_ratios_ns_EPSP = getmeans2(pp_ratios_ns_EPSP);
avg_pp_ratios_s_EPSP = getmeans2(pp_ratios_s_EPSP);

avg_ten_90_ns_EPSP = getmeans2(ten_90_ns_EPSP);
avg_ten_90_s_EPSP = getmeans2(ten_90_s_EPSP);
avg_ten_90_ns_IPSC = getmeans2(ten_90_ns_IPSC);
avg_ten_90_s_IPSC = getmeans2(ten_90_s_IPSC);

avg_integral_ns_EPSP = getmeans2(integral_ns_EPSP);
avg_integral_s_EPSP = getmeans2(integral_s_EPSP);
avg_integral_ns_IPSC = getmeans2(integral_ns_IPSC);
avg_integral_s_IPSC = getmeans2(integral_s_IPSC);

integral_total_event_ns_EPSP = integral_total_event_all_EPSP{no_shutter};
integral_total_event_s_EPSP = integral_total_event_all_EPSP{shutter};
integral_total_event_ns_IPSC = integral_total_event_all_IPSC{no_shutter};
integral_total_event_s_IPSC = integral_total_event_all_IPSC{shutter};
% 
% avg_total_integral_EPSP(no_shutter,1) = getmeans(integral_total_event_ns_EPSP);
% avg_total_integral_EPSP(shutter,1) = getmeans(integral_total_event_s_EPSP);
% avg_integral_errors_EPSP(no_shutter,1) = get_SE(integral_total_event_ns_EPSP);
% avg_integral_errors_EPSP(shutter,1) = get_SE(integral_total_event_s_EPSP);
% 
% avg_total_integral_IPSC(no_shutter,1) = getmeans(integral_total_event_ns_IPSC);
% avg_total_integral_IPSC(shutter,1) = getmeans(integral_total_event_s_IPSC);
% avg_integral_errors_IPSC(no_shutter,1) = get_SE(integral_total_event_ns_IPSC);
% avg_integral_errors_IPSC(shutter,1) = get_SE(integral_total_event_s_IPSC);

%% calculate ratios in no shutter/shutter for EPSP and IPSC

ratio_amp_EPSP = getmeans2(amp_s_EPSP)./getmeans2(amp_ns_EPSP);
ratio_integral_EPSP = getmeans2(integral_s_EPSP)./getmeans2(integral_ns_EPSP);

ratio_amp_IPSC = getmeans2(amp_s_IPSC)./getmeans2(amp_ns_IPSC);
ratio_integral_IPSC = getmeans2(integral_s_IPSC)./getmeans2(integral_ns_IPSC);

% ratio_total_integral_EPSP = avg_total_integral_EPSP(shutter,1)/avg_total_integral_EPSP(no_shutter,1);
% ratio_total_integral_IPSC = avg_total_integral_IPSC(shutter,1)/avg_total_integral_IPSC(no_shutter,1);

figure;

a(1) = subplot(2,1,1); hold on; title('Amp ratios');
plot(ratio_amp_EPSP, 'bd-'); plot(ratio_amp_IPSC, 'gd-');
hold off;
a(2) = subplot(2,1,2); hold on; title('Integral ratios');
plot(ratio_integral_EPSP, 'bd-'); plot(ratio_integral_IPSC, 'gd-');
hold off;




% figure;
% a(1) = subplot(3,1,1); hold on; title('amp');
% [avg_amp_ns std_amp_ns] = getmeans2(amp_ns);
% [avg_amp_s std_amp_s] = getmeans2(amp_s);
% errorbar(avg_amp_ns, std_amp_ns); errorbar(avg_amp_s, std_amp_s,  'r');
% 
% a(2) = subplot(3,1,2); hold on; title('integral');
% [avg_integral_ns std_integral_ns] = getmeans2(integral_ns);
% [avg_integral_s std_integral_s] = getmeans2(integral_s);
% errorbar(avg_integral_ns, std_integral_ns); errorbar(avg_integral_s, std_integral_s,  'r');
% 
% a(3) = subplot(3,1,3); hold on; title('Pulse Ratios');
% [avg_ratios_ns std_ratios_ns] = getmeans2(amp_ratios_ns);
% [avg_ratios_s std_ratios_s] = getmeans2(amp_ratios_s);
% errorbar(avg_ratios_ns, std_ratios_ns); errorbar(avg_ratios_s, std_ratios_s, 'r');
% linkaxes(a,'x');
% hold off;
% 




data_no_shutter_EPSP = cat(3,data_trial_EPSP{:,no_shutter});
data_shutter_EPSP = cat(3,data_trial_EPSP{:,shutter});

data_no_shutter_IPSC = cat(3,data_trial_IPSC{:,no_shutter});
data_shutter_IPSC = cat(3,data_trial_IPSC{:,shutter});

avg_data_ns_EPSP = mean(data_no_shutter_EPSP,3);
avg_data_s_EPSP = mean(data_shutter_EPSP,3);

avg_data_ns_IPSC = mean(data_no_shutter_IPSC,3);
avg_data_s_IPSC = mean(data_shutter_IPSC,3);

figure; plot(avg_data_ns_EPSP); hold on; plot(avg_data_s_EPSP, 'r'); hold off;
figure; plot(avg_data_ns_IPSC); hold on; plot(avg_data_s_IPSC, 'r'); hold off;


% figure; barweb(total_integral, errors_integral);

clearvars I* 
clearvars a* -except avg* 
clearvars b* c* d* e* i* m* n* p* 
clearvars s* -except  -regexp ^s\d{1}$*
clearvars t* w*





