function [onsets, offsets, params] = ...
    ct_find_laser_pulses(rastermap, handles, ridxs, clustered_contour_ids, options)
% AP 2008/04/22
% ct_remove_laser_pulses style code for easy display of zeroed frames

for idx = 1:size(rastermap,1);%for each trace
    zscoredTrace=zscore(rastermap(idx,:));
    LaseredFrames=find(zscoredTrace>options.zscoreThreshold.value);
    if ~isempty(LaseredFrames)
        ends=find(diff(LaseredFrames)~=1); %find ends of sets of lasered frames
        ends(end+1)=length(LaseredFrames); %the end of the vector is also an end
        for i=1:length(ends) %loop through the ends
            LaseredFramesFront=LaseredFrames(1:ends(i)); %split vector at current end
            LaseredFramesBack=LaseredFrames(ends(i)+1:end);
            %put vector back together with the next frame after the end inserted
            %(ends(i)+(i-1)) indexes LaseredFrames counting the frames
            %added during this for loop. So, LaseredFrames(ends(i)+(i-1))+1
            %is the frame after the current end of a set of lasered frames
            if i==length(ends)
                LaseredFrames=[LaseredFramesFront LaseredFramesBack LaseredFrames(ends(i)+(i-1))+1];
            else
                LaseredFrames=[LaseredFramesFront LaseredFrames(ends(i)+(i-1))+1 LaseredFramesBack];
            end
        end
        ChangeInTrace=diff(rastermap(idx,LaseredFrames)); %calculate the change in the trace
        if ~any(abs(ChangeInTrace)>options.MinChange.value) %check if any change is big enough
            LaseredFrames=[]; %if not, then these LaseredFrames do not count
        end
    end
    if length(LaseredFrames)>0
        ends=find(diff(LaseredFrames)~=1);
        ends(end+1)=0;
        ends(end+1)=length(LaseredFrames); %the last Lasered Frame is an end too!
        ends=sort(ends);
        lengths=diff(ends);
        ends(1)=[];
        if ~isempty(ends)
            onsets{idx}=LaseredFrames(ends-(lengths-1));
            offsets{idx}=LaseredFrames(ends);
        else
            onsets{idx} = [];
            offsets{idx} = [];
        end
    else
        onsets{idx} = [];
        offsets{idx} = [];
    end
end
params.zscoreThreshold=options.zscoreThreshold.value;