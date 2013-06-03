function [curve] = movie_vs_movie(movie1, movie2)


event_start_time = 4; % time of stimulus or event you want to begin summing signals
event_end_time = 7;
frame_rate = 10; % in Hz (frames/sec)

start_frame = event_start_time*frame_rate;
end_frame = event_end_time*frame_rate;

%for foopsi:

% 
% for i = 1: size(movie1,1);
%     signal_movie1(i,:) = sum(movie1(i, start_frame:end_frame));
%     signal_movie2(i,:) = sum(movie2(i, start_frame:end_frame));
% end


% use for Calcium transients 

for i = 1: size(movie1,1);
    frames_signal1(i,:) = movie1(i, start_frame:end_frame); % just frames of interest (in which there is signal)
    frames_signal2(i,:) = movie2(i, start_frame:end_frame); 
    % to find signal, take max minus baseline and divide by standard
    % deviation
    signal_movie1(i) = (max(frames_signal1(i,:)) - mean(movie1(i, 1:start_frame - 1)))/std(movie1(i, 1:start_frame - 1));
    signal_movie2(i) = (max(frames_signal2(i,:)) - mean(movie2(i, 1:start_frame - 1)))/std(movie2(i, 1:start_frame - 1));
end

for i = 1: size(movie1,1);
    frames_signal1(i,:) = movie1(i, start_frame:end_frame); % just frames of interest (in which there is signal)
    frames_signal2(i,:) = movie2(i, start_frame:end_frame);
    [signal_movie1(i), frame_max1(i)] = max(frames_signal1(i,:));
    [signal_movie2(i), frame_max2(i)] = max(frames_signal2(i,:));
    delay_cell1(i) = (frame_max1(i) - start_frame)*frame_rate;
    delay_cell2(i) = (frame_max2(i) - start_frame)*frame_rate;
end

figure;
plot(delay_cell1, delay_cell2);

figure;
plot(signal_movie1, signal_movie2, 'd');

curve = figure;




