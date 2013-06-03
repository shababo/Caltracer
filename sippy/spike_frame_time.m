function [V_trace frametime spike_frame_index spframe time start_UP_index exptime] = spike_frame_time(signals, epath)

% align_ephys_fluor will align fluorescence with ephys recording
%   required INPUTS:
    % - signals - fluorescence vector (nNeurons x nFrames)
    % - epath   - path to associated .paq file containing ephys data
% OUTPUTS
    % - frametime 
% load up ephys

%variables for fucntion continuous above
%set according to level of camera output and 
baseline = 0;
thresh = 3;
mintime = 0;
maxtime = 200;
cell_attach = 1;

info   = paq2lab(epath,'info');
dataset = paq2lab(epath);

for ii=1:length(info.ObjInfo.Channel)
    cc = info.ObjInfo.Channel(ii);
    switch cc.ChannelName
        case {'camera','cmera','CameraFrames', 'Frames'}
            cIndex = ii;
        case {'MC1voltage','voltage1','Voltage1', 'Voltage'}
            vIndex(1) = ii;
        case {'MC2voltage','voltage2','Voltage2', 'Voltage'}
            vIndex(2) = ii;
        case {'MC3voltage','voltage3','Voltage3', 'Voltage'}
            vIndex(3) = ii;
        case {'MC4voltage','voltage4','Voltage4', 'Voltage'}
            vIndex(4) = ii;
    end
end

vIndex = 3;  %% use this code if know which channel ephys data is on
V_trace = dataset(:,vIndex);

if cell_attach == 1;
    V_trace = V_trace*-1;
end

sIndex = 2;
stim_trace = dataset(:,sIndex);

camera_frames = dataset(:, cIndex);

%find REAL first frame (first few frames are garbage)
frame_times = continuousabove(camera_frames, baseline, thresh, mintime, maxtime);
frame_length = diff(frame_times);
diff_frame_times = diff(frame_length);
c = length(diff_frame_times);
for j = 1:c
    if abs(diff_frame_times(j)) <= 2 && abs(diff_frame_times(j+1)) <= 2
        start_frame = j;    
    break
    else continue
    end
end

exptime = median(frame_length);

%find value in ephys samples corresponding to begining of each frame
frametime = frame_times(start_frame:length(frame_times));

dropped_frames = length(frametime)-length(signals);
if abs(dropped_frames) > 3;
    error('multiple frames dropped in this movie');
end

    
if length(frametime) > length(signals)
    frametime = frametime(1:length(signals));
end

ephysrate = info.ObjInfo.SampleRate;

%find spike times in ephys data
spike_times = get_spike_times_ca(V_trace);
stim_art_index = continuousabove(stim_trace, 0, 2, 1, 100);

for ss = 1:length(stim_art_index)
   stim_i(ss,:) = stim_art_index(ss)-10:stim_art_index(ss) + 10;
end

for s = 1:length(spike_times)
    if ismember(spike_times(s),stim_i) == 1
        delete_spike(s) = s;
    end
end

if exist('delete_spike', 'var') ==1;
delete_spike = delete_spike(find(delete_spike));
index_last_artifact = delete_spike(end);
[value1 start_UP_index] = min(abs(frametime - spike_times(index_last_artifact)));
spike_times(delete_spike) = [];
else
    [value2 start_UP_index] = min(abs(frametime - stim_art_index(end)));
end

%convert spike times to frame times
for jj = 1:length(spike_times)
[value frame_index(jj)] = min(abs(frametime - spike_times(jj)));
end
% 
%  frame_index = frame_index - 1;
%  frame_index = frame_index(find(frame_index < length(signals)));

spike_frame_index = frametime(frame_index); %sample point of frame where spike occurred
spframe(1:length(signals)) = 0;
spframe(frame_index) = 1;


% if unique(frame_index) ~= frame_index
%     error('more than one spike per frame- need to code this!');
% end



figure;
time = (1:length(camera_frames))./ephysrate;
ax(1) = subplot(3,1,1); plot(frametime/ephysrate, signals./max(signals))
hold on; plot(spike_frame_index/ephysrate,1,'r.');
ax(2) = subplot(3,1,2); plot(time, V_trace);
linkaxes(ax,'x');
























