function [N_corr F_corr Fns_corr] = corr_spike_inf(inference, F)

%This function will take a cell array of nNeurons in length, each
%representing one neuron with some signal and correlate them with eachother. 
%Only one input is required, use two if want to separate data, for example, by cell type

%make a matrix from cell array

for m = 1:length(inference)
    N_cell(m,:) = inference{m};
end

for n = 1:length(F)
    F_cell(n,:) = F{n};
end
    

%% if want to threshold, use the following code
thresh = .05;
hh = 1;
for h = 1:size(N_cell,1)
    if isempty(find(N_cell(h,100:600) > thresh))
        delete_cell_i(hh) = h;
        hh = hh + 1;
    end
end


% jj = 1;
% for j = 1:size(N_cell,1)
%     if isempty(find(N_cell(j,:) > thresh))
%         cell_no_signal(jj) = j;
%         jj = jj + 1;
%     end
% end

% F_cell_nosig = F_cell(cell_no_signal,:);

if exist('delete_cell_i', 'var')
    F_cell_nosig = F_cell(delete_cell_i,:);
    N_cell(delete_cell_i,:) = [];
    F_cell(delete_cell_i,:) = [];   
end


%% Correlation of spike inference

corr_range = 350;
t = 1;

for p = 1:size(N_cell,1) -1

    for q = p:size(N_cell,1) -1
        sc = circshift(N_cell(p,1:2*corr_range), [0 -corr_range]); %shift trace back
        rsc_temp = zeros(2*corr_range,1);
        for ss = 1:2*corr_range
            sc = circshift(sc, [0 1]); %shift n forward by 1 frame
            tempcorr_sc = corrcoef(N_cell(q+1,1:2*corr_range), sc); %correlate
            rsc_temp(ss) = tempcorr_sc(1,2);
        end
        N_rsc(:,t) = rsc_temp; %add correlations to matrix rsc; each column is a correlation between a cell pair
        t = t+1; %t is nCk of Ncells, correlated pairwise
    end
end

for cc = 1: size(N_rsc,2)
    N_r_rsc(cc) = N_rsc(corr_range, cc);
end
  
N_corr = N_r_rsc; 

%correlation of fluorescence

corr_range_F = 350;
tt = 1;

for pp = 1:size(F_cell,1) -1

    for qq = pp:size(F_cell,1) -1
        shift_F = circshift(F_cell(pp,:), [0 -corr_range_F]); %shift trace back
        r_temp = zeros(2*corr_range_F,1);
        for sss = 1:2*corr_range_F
            shift_F = circshift(shift_F, [0 1]); %shift n forward by 1 frame
            tempcorr_F = corrcoef(F_cell(qq+1,:), shift_F); %correlate
            r_temp(sss) = tempcorr_F(1,2);
        end
        F_rsc(:,tt) = r_temp; %add correlations to matrix rsc; each column is a correlation between a cell pair
        tt = tt+1; %t is nCk of Ncells
    end
end

for ccc = 1: size(F_rsc,2)
    F_r_rsc(ccc) = F_rsc(corr_range_F, ccc);
end

F_corr = F_r_rsc;

corr_range_F_nosig = 350;
ttt = 1;

if exist('F_cell_nosig', 'var')
    if size(F_cell_nosig,1) > 1
        for ppp = 1:size(F_cell_nosig,1) -1
            
            for qqq = ppp:size(F_cell_nosig,1) -1
                shift_Fns = circshift(F_cell_nosig(ppp,:), [0 -corr_range_F_nosig]); %shift trace back
                r_temp = zeros(2*corr_range_F_nosig,1);
                for ssns = 1:2*corr_range_F_nosig
                    shift_Fns = circshift(shift_Fns, [0 1]); %shift n forward by 1 frame
                    tempcorr_Fns = corrcoef(F_cell_nosig(qqq+1,:), shift_Fns); %correlate
                    r_tempns(ssns) = tempcorr_Fns(1,2);
                end
                Fns_rsc(:,tt) = r_tempns; %add correlations to matrix rsc; each column is a correlation between a cell pair
                ttt = ttt+1; %t is nCk of Ncells
            end
        end
        for cccc = 1: size(Fns_rsc,2)
            Fns_r_rsc(cccc) = Fns_rsc(corr_range_F_nosig, cccc);
        end
        Fns_corr =  Fns_r_rsc;
    else Fns_corr = NaN;
    end
else Fns_corr = NaN;
end




