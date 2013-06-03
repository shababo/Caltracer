function [se] = get_SE2(summary);

%This function goes through any matrix whose data is organized in COLUMNS,
%which contains entries NaN, and finds the mean and std of the COLUMNS. The output,
%se a vector, in which each COLUMN entry corresponds to
%the column of input data. 


for i = 1:size(summary,2)
    NaN1(:,i) = isnan(summary(:,i));
    se(:,i) = sem(summary(find(NaN1(:,i)==0), i),1);      
end



