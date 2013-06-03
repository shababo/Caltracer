function [signals] = quantifysignals(traces);


exp_time = .1; % seconds
frame_rate = 1/exp_time;

event_length = 2; % seconds; should be determined for each slice 
frames = event_length*frame_rate;

Time_ff = 5; % seconds
ff = Time_ff*framerate;
lf = ff + frames;

tf = [ff:lf];
number_frames = length(tf);






