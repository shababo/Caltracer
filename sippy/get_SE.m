function [se] = get_SE(summary)

%This function goes through any matrix whose data is organized in ROWS,
%which contains entries NaN, and finds the mean and std of the ROWS. The output,
%se is a vector, in which each ROW entry corresponds to
%the row of input data. 
%for data which is organized in columns, use get_SE2

for i = 1:size(summary,1)
    NaN1(i,:) = isnan(summary(i,:));
    se(i,:) = sem(summary(i, find(NaN1(i,:)==0)),2);    
end





