function base_sub = basesub_norm(data);


baseline = findbase(data); %find the baseline
base_sub = data - baseline;

figure; plot(base_sub)

end


