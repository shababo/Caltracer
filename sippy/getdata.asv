function [data] = getdata(structure)
num_epochs = 3; % if diff number of epochs desired, change here
num_subepochs = 5; % if diff number of subepochs desired, change here

% this function will go through a data structure created by analyze_stim,
% average the data, provide standard deviations of the means
% and sort all the variables and their averages in a cell array
% it will also plot averages with error bars of Amplitide, duration, and
% number of action potentials during UP states with and without interneuron
% stimulation.

num_sweeps = length(structure.experiment.cells(1).sweeps);

for a = 1:length(structure.experiment.cells); % columns are cells
    for b = 1:length(structure.experiment.cells(a).sweeps); % rows are sweeps
        if structure.experiment.cells(a).sweeps(b). analyze == 1
            Vm(b,a) = structure.experiment.cells(a).sweeps(b).baselineVm;
            Ih(b,a) = structure.experiment.cells(a).sweeps(b).baselineI;
            if structure.experiment.cells(a).sweeps(b).stim == 0;
                UP_amp_cell(b,a) = structure.experiment.cells(a).sweeps(b).UPamp;
                UP_dur_cell(b,a) = structure.experiment.cells(a).sweeps(b).UPdur;
                if structure.experiment.cells(a).sweeps(b).numupstates == 1;
                    UP_aps1(b,a) = structure.experiment.cells(a).sweeps(b).aps;
                    UP_ap_epochs(b,a) = {[structure.experiment.cells(a).sweeps(b).APepochs]};       
                    UP_ap_subepochs(b,a) = {[structure.experiment.cells(a).sweeps(b).APsubepochs]};
                    UP_tt1st(b,a) = structure.experiment.cells(a).sweeps(b).tt1st;
                    tt_all_spikes(b,a) = {[structure.experiment.cells(a).sweeps(b).tt_all_spikes]};
                else UP_aps1(b,a) = NaN;
                    UP_ap_epochs(b,a) = {[NaN(1, num_epochs)]};
                    UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
                    UP_tt1st(b,a) = NaN;
                    tt_all_spikes(b,a) = {[NaN(1, num_subepochs)]};
                end
            else if structure.experiment.cells(a).sweeps(b).stim == 1 || structure.experiment.cells(a).sweeps(b).stim == 2;
                    UP_amp_cell(b,a) = NaN;
                    UP_dur_cell(b,a) = NaN;
                    UP_aps1(b,a) = NaN;
                    UP_ap_epochs (b,a) = {[NaN(1, num_epochs)]};
                    UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
                    APs_stim(b,a) = structure.experiment.cells(a).sweeps(b).stimaps;
                    UP_tt1st(b,a) = NaN;
                    tt_all_spikes(b,a) = {[NaN(1, num_subepochs)]};
                end
            end
        else if structure.experiment.cells(a).sweeps(b).analyze == 0 || isempty(structure.experiment.cells(a).sweeps(b).analyze);
                Vm(b,a) = NaN;
                UP_amp_cell(b,a) = NaN;
                UP_dur_cell(b,a) = NaN;
                UP_aps1(b,a) = NaN;
                UP_ap_epochs (b,a) = {[NaN(1, num_epochs)]};
                UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
                UP_tt1st(b,a) = NaN;
                tt_all_spikes(b,a) = {[NaN(1, num_subepochs)]};
            end
        end
    end
end




avg_Vm = getmeans2(Vm);
avg_Ih = mean(Ih);
UP_aps = UP_aps1;
avg_tt1st = getmeans2(UP_tt1st);

% epochs_cells is a matrix, the rows are sweep number, the columns are the
% epochs. 
% sub_epochs cells is also a matrix, rows are the sweep number and the
% columns are the epochs. 

for h = 1:length(UP_ap_epochs) % number of sweeps
    if length(structure.experiment.cells) == 1;
        epochs_cells(h,:) = UP_ap_epochs{h,1};
        sub_epochs_cells(h,:) = UP_ap_subepochs{h,1};
        index_ep = [1:num_epochs];
        index_subep = [1:num_subepochs];
    end
    if length(structure.experiment.cells) == 2;
        epoch_cell1(h,:) = UP_ap_epochs{h,1};
        epoch_cell2(h,:) = UP_ap_epochs{h,2};
        epochs_cells(h,:) = cat(2, epoch_cell1(h,:), epoch_cell2(h,:));
        sub_epochs_cell1(h,:) = UP_ap_subepochs{h,1};
        sub_epochs_cell2(h,:) = UP_ap_subepochs{h,2};
        sub_epochs_cells(h,:) = cat(2, sub_epochs_cell1(h,:), sub_epochs_cell2(h,:));
        index_ep = [1:num_epochs; num_epochs + 1: 2*num_epochs];
        index_subep = [1:num_subepochs; num_subepochs + 1: 2*num_subepochs];
    end
    if length(structure.experiment.cells) == 3;
        epoch_cell1(h,:) = UP_ap_epochs{h,1};
        epoch_cell2(h,:) = UP_ap_epochs{h,2};
        epoch_cell3(h,:) = UP_ap_epochs{h,3};
        epochs_cells(h,:) = cat(2, epoch_cell1(h,:), epoch_cell2(h,:),epoch_cell3(h,:));
        sub_epochs_cell1(h,:) = UP_ap_subepochs{h,1};
        sub_epochs_cell2(h,:) = UP_ap_subepochs{h,2};
        sub_epochs_cell3(h,:) = UP_ap_subepochs{h,3};
        sub_epochs_cells(h,:) = cat(2, sub_epochs_cell1(h,:), sub_epochs_cell2(h,:), sub_epochs_cell3(h,:));
        index_ep = [1:num_epochs; num_epochs + 1: 2*num_epochs; 2*num_epochs + 1: 3*num_epochs];
        index_subep = [1:num_subepochs; num_subepochs + 1: 2*num_subepochs; 2*num_subepochs + 1: 3*num_subepochs];
    end
end

for n = 1:size(UP_aps,1);
    for nn = 1:size(UP_aps,2);
        if UP_aps(n,nn) > 0
            norm_epochs(n, (index_ep(nn,:))) = epochs_cells(n, (index_ep(nn,:)))/UP_aps(n,nn);
        end
        if UP_aps(n,nn) == 0 || isnan(UP_aps(n,nn))
            norm_epochs(n, (index_ep(nn,:))) = NaN;
        end
        if epochs_cells(n, (nn-1)*num_epochs + 1) > 0
            norm_subepochs(n, (index_subep(nn,:))) = sub_epochs_cells(n, (index_subep(nn,:)))/epochs_cells(n, (nn-1)*num_epochs + 1);
        end
        if epochs_cells(n, (nn-1)*num_epochs + 1) == 0 || isnan(epochs_cells(n, (nn-1)*num_epochs + 1))
            norm_subepochs(n, (index_subep(nn,:))) = NaN;
        end
    end
end


                

avg_APs_epoch = getmeans2(epochs_cells); % average number of APs in each epoch for each cell

avg_APs_subepochs = getmeans2(sub_epochs_cells); % average number of APs in each subepoch for each cell 

avg_norm_epochs = getmeans2(norm_epochs);

avg_norm_subepochs = getmeans2(norm_subepochs);


 % to replace NaN in trials in which there is a stim with number of APs:
 if exist('Aps_stim') == 1
     for d = 1:size(APs_stim,2);
         APi = find(APs_stim(:,d));
         UP_aps1(APi,d) = APs_stim(APi,d);
         for di = 1: num_sweeps;
             if isnan(UP_aps1(di,d)) == 1; % if still NaN for some reason, replace with zero.
                 UP_aps1(di,d) = 0;
             end
         end
     end
 end


APs_all_sweeps = UP_aps1; %matrix of number of action potentials in all cells/all sweeps (columns are cells,
% row entries are number of APs per sweep.



% % organize data into stim trials/nostim trials
% for e = 1:size(UP_amp_cell,2); % number of cells (columns)
%     for f = 1:size(UP_amp_cell,1);  % number of sweeps (rows)
%         if structure.experiment.cells(1).sweeps(f).stim == 1 || structure.experiment.cells(2).sweeps(f).stim == 1  % change this line if less than 3 cells
%             UP_amp_stim(f,e)= UP_amp_cell(f,e);
%             UP_dur_stim(f,e) = UP_dur_cell(f,e);
%             UP_aps_stim(f,e) = UP_aps(f,e);
%         else UP_amp_stim(f,e)= NaN;
%             UP_dur_stim(f,e) = NaN;
%             UP_aps_stim(f,e) = NaN;
%         end
%         if structure.experiment.cells(1).sweeps(f).stim == 0 & structure.experiment.cells(2).sweeps(f).stim == 0  % change this line if less than 3 cells
%             UP_amp_nostim(f,e) = UP_amp_cell(f,e);
%             UP_dur_nostim(f,e) = UP_dur_cell(f,e);
%             UP_aps_nostim(f,e) = UP_aps(b,a);
%         else
%             UP_amp_nostim(f,e) = NaN;   % do same for UP_dur and # Aps
%             UP_dur_nostim(f,e) = NaN;
%             UP_aps_nostim(f,e) = NaN;
%         end
% 
% 
%         [mean_amp_stim, std_amp_stim] =  getmeans2(UP_amp_stim);
% 
%         [mean_amp_nostim, std_amp_nostim] = getmeans2(UP_amp_nostim);
% 
%         [mean_dur_stim, std_dur_stim] =  getmeans2(UP_dur_stim);
% 
%         [mean_dur_nostim, std_dur_nostim] = getmeans2(UP_dur_nostim);
% 
%         [mean_aps_stim, std_aps_stim] = getmeans2(UP_aps_stim);
% 
%         [mean_aps_nostim, std_aps_nostim] = getmeans2(UP_aps_nostim);
% 
% 
%         % make summary matrices of amp, dur, and AP data.
%         % each row corresponds to one cell in no stim(column 1)/stim  trials
%         % this is necessary later b/c format is appropriate for barweb
%         % function (see below)
%          amp_means(e,:) = [mean_amp_nostim(e), mean_amp_stim(e)];
%          amp_std(e,:) = [std_amp_nostim(e), std_amp_nostim(e)];
%          dur_means(e,:) = [mean_dur_nostim(e), mean_dur_stim(e)];
%          dur_std(e,:) = [std_dur_nostim(e), std_dur_stim(e)];
%          APs_means(e,:) = [mean_aps_nostim(e), mean_aps_stim(e)];
%          APs_std(e,:) = [std_aps_nostim(e), std_aps_stim(e)];
% 
% 
%         [mean_amp std_amp] = getmeans2(UP_amp_cell);
% 
%         [mean_dur std_dur] = getmeans2(UP_dur_cell);
% 
%         [mean_UP_aps std_UP_aps] = getmeans2(UP_aps);
% 
%     end
% end
% 
[mean_amp std_amp] = getmeans2(UP_amp_cell);

[mean_dur std_dur] = getmeans2(UP_dur_cell);

[mean_UP_aps std_UP_aps] = getmeans2(UP_aps);

% c(1,1) = {'Vm and Ih'};
% c(1,2) = {avg_Vm};
% c(1,3) = {avg_Ih};
% c(2,1) = {'Amplitudes'};
% c(2,2) = {mean_amp};
% c(3,1) = {'Durations'};
% c(3,2) = {mean_dur};
% c(4,1) = {'UP_APs_epochs'};
% c(4,2) = {mean_UP_aps};
% c(4,3) = {avg_APs_epoch};
% c(4,4) = {avg_APs_subepochs};
% c(5,1) = {'tt_spike'};
% c(5,2) = {UP_tt1st};
% c(5,3) = {avg_tt1st};
% c(5,4) = {tt_all_spikes};

c(1,1) = {avg_norm_epochs};
c(1,2) = {avg_norm_subepochs};

% 
% %stats. Vh, Wh, Xh = 0 is failure of rejection of null hypothesis that the
% %means are equal. (tested at the .05 significance level)
% % Vp, Wp, and Xp are the p values. 
% [Vh,Vp] = ttest2(UP_amp_nostim, UP_amp_stim);
% [Wh,Wp] = ttest2(UP_dur_nostim, UP_dur_stim);
% [Xh,Xp] = ttest2(UP_aps_nostim, UP_aps_stim);
% 
% c(1,1) = {'UP_amps'};
% c(1,2) = {UP_amp_cell};
% c(1,3) = {mean_amp};
% c(1,4) = {mean_amp_nostim};
% c(1,5) = {mean_amp_stim};
% c(1,6) = {[Vh;Vp]}; % stats (see above)
% c(2,1) = {'UP_dur'};
% c(2,2) = {UP_dur_cell};
% c(2,3) = {mean_dur};
% c(2,4) = {mean_dur_nostim};
% c(2,5) = {mean_dur_stim};
% c(2,6) = {[Wh;Wp]}; % stats
% c(3,1) = {'UP_aps'};
% c(3,2) = {UP_aps};
% c(3,3) = {mean_UP_aps};
% c(3,4) = {mean_aps_nostim};
% c(3,5) = {mean_aps_stim};
% c(3,6) = {[Xh;Xp]}; % stats
% c(4,1) = {'UP_ap_epochs'};
% c(4,2) = {UP_ap_epochs};
% c(4,3) = {avg_APs_epoch};
% c(5,1) = {'UP_ap_subepochs'};
% c(5,2) = {avg_APs_subepochs};
% 
% % figure;
% % subplot(3,1,1), barweb(amp_means, amp_std, [], [], 'Amplitude of UP state', 'cell number', 'mV');
% % hold on;
% % subplot(3,1,2), barweb(dur_means, dur_std, [], [], 'Duration of UP state', 'cell number', 'seconds');
% % hold on;
% % subplot(3,1,3), barweb(APs_means, APs_std, [], [], 'Number of Action Potentials', 'cell number', 'number of APs');

data = c;

% f = figure;





