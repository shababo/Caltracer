function [epoch_aps, subepoch_aps] = subdiv_epoch(dataVm, upstates);

%this function will subdivide a period of data (an UP state- the indices of
%which must be found before calling this function) into "epochs" and
%find the # of APs in each epoch. It will then divide the 1st epoch into subepochs and find the 
% # of APs in the subepochs. 
% input should be a data vector, and the indices of the UP states
%output will be two matrices of size m x n, where m is the number of cells,
%and n is the # of epochs. 

num_epochs = 3; % if diff number of epochs desired, change here
num_subepochs = 5; % if diff number of subepochs desired, change here
epochstart = [];
epochend = [];
subepochstart = [];
subepochend = [];

remain=rem(length(dataVm(upstates(2):upstates(3))), num_epochs);
if remain > 0; % if the number of data points during the plateau is not divisible by num_epochs
    epochlength = (length(dataVm(upstates(2):upstates(3)))+ num_epochs - remain)/num_epochs; % add on the remainder to make it divisible by num_epochs
else epochlength = length(dataVm(upstates(2):upstates(3)))/num_epochs;
end

% if (floor(epochlength)-epochlength ~= 0);
%     display('epochlength is not an integer')
% end

epochstart(1) = upstates(2);
epochend(1) = upstates(2)+ epochlength;
for i = 2:num_epochs;
    epochstart(i) = epochend(i-1) + 1;
    epochend(i) = epochstart(i) + epochlength;
end

for j = 1:num_epochs
    aps = findaps2(dataVm(epochstart(j):epochend(j)));
    numaps(j) = length(aps);
end

epoch_aps = numaps;


remain1 = rem(length(dataVm(epochstart(1):epochend(1))), num_subepochs);
if remain1 > 0;
    subepoch_length = (length(dataVm(epochstart(1):epochend(1))) + num_subepochs - remain1)/num_subepochs;
else subepoch_length = length(dataVm(epochstart(1):epochend(1)))/num_subepochs;

% if (floor(subepoch_length)- subepoch_length ~= 0);
%     display('subepoch_length is not an integer')
% end
 
end
subepochstart(1) = epochstart(1);
subepochend(1) = subepochstart(1) + subepoch_length - 1;

for k = 2:num_subepochs;
    subepochstart(k) = subepochend(k-1) + 1;
    subepochend(k) = subepochstart(k) + subepoch_length;
end

for m = 1:num_subepochs;
    aps_sub = findaps2(dataVm(subepochstart(m):subepochend(m)));
    numaps_sub(m) = length(aps_sub);
end

subepoch_aps = numaps_sub; 
