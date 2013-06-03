

colors = 'rgbcmyk'; 
figure; 
hold on; 
nBlockLength = 5;
nBlocks = 3;
for ii=1:nBlocks
    start=(ii-1)*nBlockLength+1; 
    endInd = start+nBlockLength-1; 
    errorbar(means_normsubepochs(start:endInd),std_normsubepochs(start:endInd),colors(ii));
end