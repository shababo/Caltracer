workspace = who;

for i = 1:length(workspace)
    all_corr_exp(:,i) = eval(workspace{i});
end

MEANS_i =  getmeans(all_corr_exp);
SE_i = get_SE(all_corr_exp);

figure; h =  errorbar(MEANS_i(1900:2100), SE_i(1900:2100), 'bd-'); errorbar_tick(h, 200000);