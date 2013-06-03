function x = ct_remove_laser_pulses(x, options)
% Adam Packer Started 20080317
% Preprocessor that finds absurdly strong and fast pulses
% that are probably due to laser uncaging or ablation.
% Replaces those frames with zero

% IF YOU CHANGE THIS, PLEASE CHECK ct_find_laser_pulses signal detector!

[nrecordings len] = size(x);
TracesAsCellArray=mat2cell(x,ones(1,nrecordings),[len]);

tracelengths=zeros(1,nrecordings);
for idx = 1:nrecordings
    zscoredTrace=zscore(TracesAsCellArray{idx});
    LaseredFrames=find(zscoredTrace>options.zscoreThreshold.value);
    if ~isempty(LaseredFrames)
        ends=find(diff(LaseredFrames)~=1); %find ends of sets of lasered frames
        ends(end+1)=length(LaseredFrames); %add the next frame to the end of the last end
        for i=1:length(ends) %loop through the ends
            LaseredFramesFront=LaseredFrames(1:ends(i)); %split vector at current end
            LaseredFramesBack=LaseredFrames(ends(i)+1:end);
            %put vector back together with the next frame after the end inserted
            %(ends(k)+(i-1)) indexes LaseredFrames counting the frames
            %added during this for loop. So, LaseredFrames(ends(i)+(i-1))+1
            %is the frame after the current end of a set of lasered frames
            if i==length(ends)
                LaseredFrames=[LaseredFramesFront LaseredFramesBack LaseredFrames(ends(i)+(i-1))+1];
            else
                LaseredFrames=[LaseredFramesFront LaseredFrames(ends(i)+(i-1))+1 LaseredFramesBack];
            end
        end
        try % NO TRY/CATCH HERE AP 20110523
            ChangeInTrace=diff(TracesAsCellArray{idx}(LaseredFrames)); %calculate the change in the trace
            if ~any(abs(ChangeInTrace)>options.MinChange.value) %check if any change is big enough
                LaseredFrames=[]; %if not, then these LaseredFrames do not count
            end
        catch
        end
    end
    TracesAsCellArray{idx}(LaseredFrames)=0;
    tracelengths(idx)=length(TracesAsCellArray{idx});
end

minlength=min(tracelengths);
for k=1:nrecordings
    NumFramesToDelete=length(TracesAsCellArray{k})-minlength;
    try
        TracesAsCellArray{k}(1:NumFramesToDelete)=[]; % [] was 0 AP 20110523
    catch
    end
end
traces=cell2mat(TracesAsCellArray);
x=traces;