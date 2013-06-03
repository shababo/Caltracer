function [m, s] = getmeans(summary);

%This function goes through any matrix whose data is organized in ROWS,
%which contains entries NaN, and finds the mean and std of the ROWS. The output,
%average and/or std is a vector, in which each ROW entry corresponds to
%the row of input data. 
%for data which is organized in columns, use getmeans2

for i = 1:size(summary,1)
    NaN1(i,:) = isnan(summary(i,:));
    average(i,:) = mean(summary(i, find(NaN1(i,:)==0)));    
    st_dev(i,:) = std(summary(i, find(NaN1(i,:)==0)));
end

m = average;
s = st_dev;




