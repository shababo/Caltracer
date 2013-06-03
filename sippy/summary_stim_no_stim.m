function [tt1stspike] = summary_stim_nostim(structure)

%this function will take data from a data structure made in analyze_stim,
%separate it into stim and no stim trial, and make a figure.
% x-axis of figure will be tt1st spike, y axis of figure will be trial
% number, and stim/nostim trials will be differentiated by color. 

num_epochs = 3; % if diff number of epochs desired, change here
num_subepochs = 5; % if diff number of subepochs desired, change here

for a = 1:length(structure.experiment.cells); % columns are cells
    for b = 1:length(structure.experiment.cells(a).sweeps); % rows are sweeps
        if structure.experiment.cells(a).sweeps(b). analyze == 1
            Vm(b,a) = structure.experiment.cells(a).sweeps(b).baselineVm;
            Ih(b,a) = structure.experiment.cells(a).sweeps(b).baselineI;
            if structure.experiment.cells(a).sweeps(b).stim == 0; 
                stim(b,a) = 0;
                if structure.experiment.cells(a).sweeps(b).numupstates == 1;
                    UP_aps1(b,a) = structure.experiment.cells(a).sweeps(b).aps;
                    UP_ap_epochs(b,a) = {[structure.experiment.cells(a).sweeps(b).APepochs]};
                    UP_ap_subepochs(b,a) = {[structure.experiment.cells(a).sweeps(b).APsubepochs]};
                    tt1st_spike(b,a) = structure.experiment.cells(a).sweeps(b).tt1st;
                else UP_aps1(b,a) = NaN;
                    UP_ap_epochs(b,a) = {[NaN(1, num_epochs)]};
                    UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
                    tt1st_spike(b,a) = NaN;
                end
            else if structure.experiment.cells(a).sweeps(b).stim == 1; 
                    stim(b,a) = 1;
                    UP_aps1(b,a) = NaN;
                    UP_ap_epochs (b,a) = {[NaN(1, num_epochs)]};
                    UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
                    tt1st_spike(b,a) = NaN;
                    APs_stim(b,a) = structure.experiment.cells(a).sweeps(b).stimaps;
                end
            end
        else Vm(b,a) = NaN;
            tt1st(b,a) = NaN;
            stim(b,a) = NaN;
            UP_aps1(b,a) = NaN;
            UP_ap_epochs (b,a) = {[NaN(1, num_epochs)]};
            UP_ap_subepochs(b,a) = {[NaN(1, num_subepochs)]};
        end
    end
end

% % organize data into stim trials/nostim trials
% if size(tt1st, 2) == 2;
%     for e = 1:size(tt1st,2); % number of cells (columns)
%         for f = 1:size(tt1st,2);  % number of sweeps (rows)
%             if structure.experiment.cells(1).sweeps(f).stim == 1 || structure.experiment.cells(2).sweeps(f).stim == 1  % change this line if less than 3 cells
%                 tt1st_stim(f,e)= UP_amp_cell(f,e);
%             else tt1st_stim(f,e)= NaN;
%                 tt1st_nostim(f,e) = NaN;   % do same for UP_dur and # Aps
%             end
%         end
%     end
% end
% if size(tt1st,2) == 3
%     for e = 1:size(tt1st,2); % number of cells (columns)
%         for f = 1:size(tt1st,2);  % number of sweeps (rows)
%             if structure.experiment.cells(1).sweeps(f).stim == 1 || structure.experiment.cells(2).sweeps(f).stim == 1 || structure.experiment.cells(3).sweeps(f).stim == 1  % change this line if less than 3 cells
%                 tt1st_stim(f,e)= tt1st(f,e);
%             else tt1st_stim(f,e)= NaN;         
%                 tt1st_nostim(f,e) = tt1st(f,e);
%             end
%         end
%     end
% end



% [mean_tt1st_stim, std_tt1st_stim] =  getmeans2(tt1st_stim);
% [mean_tt1st_nostim, std_tt1st_nostim] = getmeans2(tt1st_nostim);




tt1stspike = cat(2,tt1st_spike, stim);


end





