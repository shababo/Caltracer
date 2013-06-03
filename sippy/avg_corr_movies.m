workspace = who;

Rmin = 0;
Rmax = 1;
bins = linspace(Rmin,Rmax,20);

counts = zeros(1,length(bins));
for i = 1:length(workspace)
    corr_exp = eval(workspace{i});
    for ii = 1:size(corr_exp,2)
        counts = counts + histc(corr_exp{ii}, bins);    
    end
end


