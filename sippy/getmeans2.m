function [m, s] = getmeans2(summary);

%This function goes through any matrix whose data is organized in COLUMNS,
%which contains entries NaN, and finds the mean and std of the COLUMNS. The output,
%average and/or std is a vector, in which each COLUMN entry corresponds to
%the column of input data. 


for i = 1:size(summary,2)
    NaN1(:,i) = isnan(summary(:,i));
    average(:,i) = mean(summary(find(NaN1(:,i)==0), i));    
    st_dev(:,i) = std(summary(find(NaN1(:,i)==0), i));
end

m = average;
s = st_dev;


