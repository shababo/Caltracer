function CONTShr=shrink_contours(CONTSold)
shrink=input('\nWhat percentage are we shrinking the contours by [0-100]?: ');
shrink=shrink/100;
figure;
for i=1:length(CONTSold)
    hold on
    centr=create_centroid(CONTSold{i});
    centr=repmat(centr,size(CONTSold{i},1),1);
    disp=centr-CONTSold{i};
    CONTS{i}=CONTSold{i}+shrink*disp;
    scatter(CONTS{i}(:,1),CONTS{i}(:,2));
    scatter(CONTSold{i}(:,1),CONTSold{i}(:,2));
end

save('CONTShr.mat','CONTS');