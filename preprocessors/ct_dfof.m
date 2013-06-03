function x = ct_dfof(x, options)
[nrecordings len] = size(x);

time_res = options.timeRes.value;

%F0 = mean of the lowest 50% of n previous frames

% We'd like to get

% (Fi - F0)/F0
%

nFrames=ceil(options.nSecs.value/time_res);
if mod(nFrames,2)==0
    nFrames=nFrames+1;  %make sure we take an odd window size for the median filter.
end

mid=ceil(nFrames/2);

switch options.function.value
    case {'mean','MEAN'}
        for i = 1:nrecordings
            y=x(i,:); %pull out current trace for ease of indexing later on.
            %             for j=nFrames+1:len
            %                 fo=y(j-nFrames:j-1); %look at previous nFrames
            %                 fo=mean(fo); %take their mean
            %                 x(i,j) = (y(j) - fo)/ fo; %subtract and divide raw data by mean
            %             end
            %         end
            fo=tsmovavg(y,'s',nFrames); %sliding window moving average, faster than a for loop
            x(i,:)=(y-fo)./fo;
            foo=mean(y(1:nFrames));
            for j=1:nFrames %set fo = mean of first nFrames for the first nFrames of X.
                x(i,j)=(y(j) - foo)/ foo;
            end
        end
    case{'lower','LOWER'}
        for i = 1:nrecordings
            y=x(i,:); %pull out current trace for ease of indexing later on.
            foo=mean(y(1:nFrames));
            for j=1:nFrames %set fo = mean of first nFrames for the first nFrames of X.
                x(i,j)=(y(j) - foo)/ foo;
            end
            for j=nFrames+1:len
                fo=y(j-nFrames:j-1); %look at previous nFrames
                fo=sort(fo);
                fo=fo(1:mid); % remove upper 50% of previous nFrames
                fo=mean(fo); %take their mean
                x(i,j) = (y(j) - fo)./ fo; %subtract and divide raw data by mean
            end
        end
    case{'median','MEDIAN'}
        
                for i=1:nrecordings
                    y=x(i,:);
                    fo=medfilt1(y,nFrames);
                    x(i,:)=(y-fo)./mean(fo);
                end
%         for i = 1:nrecordings
%             y = x(i,:);
%             foo = median(y(1:nFrames));
%             for j = 1:nFrames
%                 x(i,j)=(y(j)-foo)./foo;
%             end
%             for j = nFrames+1:len
%                 fo = y(j-nFrames:j-1);
%                 fo = median(fo);
%                 x(i,j)=(y(j) - fo)/ fo;
%             end
%         end
end
end
