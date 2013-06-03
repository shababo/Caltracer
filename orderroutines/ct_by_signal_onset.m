function [result, rastermap, options] = ...
    ct_by_signal_onset(handles, ridxs, rastermap, regions, options)

didx = handles.app.data.currentDetectionIdx;
d = handles.app.experiment.detections(didx);

nonsets = length(d.onsets);
result = zeros(1, nonsets);
nridxs = size(ridxs, 1);
for i = 1:nonsets
    result(i) = Inf;		% No signal onset => last.
    if (~isempty(d.onsets{i}))
        for r = 1:nridxs
            onsets = d.onsets{i};
            if (~isinf(result(i)))	
                break;			% filled in below.
            end
            for o = 1:length(onsets)
                onset = onsets(o);
                start_idx = ridxs(r,1);
                stop_idx = ridxs(r,2);
                if (start_idx <= onset & onset <= stop_idx)
                    result(i) = onset;
                    break;
                end
            end
        end
    end
end

result = result * -1;