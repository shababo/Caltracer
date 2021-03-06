workspace = who;

Rmin = -.05;
Rmax = .4;
bins = 15;
edges = linspace(Rmin,Rmax,bins);

start = 1;
counts = zeros(1,length(edges));
for i = 1:length(workspace)
    corr_exp = eval(workspace{i});
    for ii = 1:size(corr_exp,2)
        counts = counts + histc(corr_exp{ii}, edges);
        if i ==1 && ii ==1;
            ALL_Ncorr(start:length(corr_exp{ii})) = corr_exp{ii};
        else
            ALL_Ncorr(start:start + length(corr_exp{ii})-1) = corr_exp{ii};
        end
        start = length(ALL_Ncorr) +1;
    end
    counts_all{i} = counts;
    counts = zeros(1,length(edges));
end

meanR = mean(ALL_Ncorr);
SE_R = get_SE(ALL_Ncorr);
sum_counts = sum(vertcat(counts_all{1,:}));
norm_sum_counts = sum_counts./max(sum_counts);
prob_R_bin = sum_counts./sum(sum_counts);

figure; bar(edges,prob_R_bin);
