function baseline = det_baseline(reading);


if length(reading)<1200000;%if total length is less than 2 minutes
    [baseline,trash]=findbase(reading);%make a baseline for the whole reading... line of best fit to most common range in reading
else%if 2 minutes or longer
    remain=rem(size(reading,1),100);
    if remain>0;%if number of points is not divisible by 100
        remvals=reading(end-(remain-1):end);
        remmean=mean(remvals);
        newreading=reading;
        addon=remmean(ones(100-remain,1));
        newreading=cat(1,newreading,addon);
        baseline=reshape(newreading,[100 size(newreading,1)/100]);%set up for 100 fold decimation of data
        baseline=mean(baseline);%decimation to 1 point per 10ms is complete
        baselinemean=mean(baseline);%for next step
        baseline=baseline-baselinemean;%subtract mean to minimize covolving probs at edges
        baseline=conv(hamming(6000)/sum(hamming(6000)),baseline);%convolve with a 4500 point = 45 sec filter
        %         baseline=conv(ones(3000,1)/3000,baseline);%convolve with a 3000 point = 30 sec filter
        baseline=baseline(3001:end-(3000-1));%get rid of convolvement artifacts
        baseline=baseline+baselinemean;%bring back to actual values
        baseline=repmat(baseline,[100 1]);
        baseline=baseline(1:end)';
        baseline(end-(size(addon,1)-1):end)=[];
    else%if divisible by 100
        baseline=reshape(reading,[100 size(reading,1)/100]);%set up for 100 fold decimation of data
        baseline=mean(baseline);%decimation to 1 point per 10ms is complete
        baselinemean=mean(baseline);%for next step
        baseline=baseline-baselinemean;%subtract mean to minimize covolving probs at edges
        baseline=conv(hamming(3000)/sum(hamming(3000)),baseline);%convolve with a 3000 point = 30 sec filter
        %         baseline=conv(ones(3000,1)/3000,baseline);%convolve with a 3000 point = 30 sec filter
        baseline=baseline(1501:end-(1500-1));%get rid of convolvement artifacts
        baseline=baseline+baselinemean;%bring back to actual values
        baseline=repmat(baseline,[100 1]);
        baseline=baseline(1:end)';
    end
end
end


