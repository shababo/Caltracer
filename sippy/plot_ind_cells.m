workspace = who;

figure;
hold on;
colors = 'rgbmcykrgbmcykrgbmcyk';

for j = 1:length(workspace);
    expt = eval(workspace{j});
    for i = 1:size(expt,1)
        errorbar([expt(i,3), expt(i,1)], [expt(i,4), expt(i,2)], colors(j));
        hold on;
    end
end


