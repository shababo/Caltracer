function fast = align_and_plot_fluorescence(signal,path,alpha,flip,vC)
% inference = align_and_plot_fluorescence(inputs):
%
% inputs (required): 
%  signal    - vector containing a fluorescence trace (vector)
%  path      - path to associated .paq file containing ephys data (path)    
%  alpha     - threshold for extracting spikes from voltage data (0-1)
%  flip      - boolean indicating whether signal should be flipped (boolean)
%  channel   - headstage channel containing voltage data (1-4)
%
% output:
%  the fast optimal optical spike inference algorithm is run on the input
%  signal. the ephys data is aligned with the fluorescence data.
%  the results are plotted on screen to a new figure.
%
%  inference - vector of length(signal) containing spike inference
%
%  tamachado (2/1/2009)

%% user modifiable parameters
if nargin < 5
    sprintf('Bad arguments provided, loading random data!\n');
    % blow away everything
    close all; clear all;
    % which voltage trace should we use (1-4 for headstage 1-4)
    vC     = 1;
    % should the traces be flipped or not
    flip   = false;
    % our fluorescence trace should be stored in a vector called 'signal'
    load('C:\Users\Tim\Desktop\s2r5.mat');
    % path the the paq file storing our ephys signals
    path   = 'Z:\Tim_Machado\From _Tanya\012110s2\s2r4.paq';
    % spike detection threshold
    alpha  = 0.1;
end

% other practice dataset
% load('C:\Users\Tim\Desktop\neurons.mat');
% signal = nn(:,2);
% path = 'C:\Users\Tim\Desktop\s2r2.paq';
% flip = true;
% alpha = 0.6;

%% load up ephys data and imaging fluorescence traces

% load up dataset
info   = paq2lab(path,'info');
dataset = paq2lab(path);
% find index of camera and voltage signals
cIndex = 0; vIndex = zeros(4,1);
for ii=1:length(info.ObjInfo.Channel)
   cc = info.ObjInfo.Channel(ii);
   switch cc.ChannelName
       case {'camera','cmera'}
           cIndex = ii;
       case {'MC1voltage','voltage1'}
           vIndex(1) = ii;
       case {'MC2voltage','voltage2'}
           vIndex(2) = ii;
       case {'MC3voltage','voltage3'}
           vIndex(3) = ii;
       case {'MC4voltage','voltage4'}
           vIndex(4) = ii;
   end
end
% give up
if cIndex == 0, error('Unable to camera index channel!'); end
if vIndex(vC) == 0, error('Voltage signal on desired channel not found!'); end

%% extract frame trigger onset times from .paq file

% find frame times
triggerAmplitude = 3;
% all trigger pulses
times = find(diff(dataset(:,cIndex)) > triggerAmplitude);
% the last frame is not real
times(end) = [];
% display how many there probably are
fprintf('movie frame times extracted: %d\n',length(times));
fprintf('actual fluorescence signal length: %d\n',length(signal));
% electrophysiology sampling rate
ephysRate = info.ObjInfo.SampleRate;
% truncate spike time vector to be of fluorescent movie length
times = times(1:length(signal));
% convert from samples to seconds
times = times * (1/ephysRate);

%% run fast optimal optical spike inference
fprintf('running fast optimal optical spike inference...\n');
% set various parameters
V.fast_iter_max = 5;                 % whether to plot with each iteration
V.fast_plot     = 0;                 % whether to generate foopsi plots
V.save          = 0;                 % whether to save results
P.a       = 1;                       % scale
P.b       = 0;                       % bias
dPlot     = 1;                       % debug plots

% flip the trace if necessary
if flip == true, fc = -1; else fc =  1; end;
% set any zero values to be equal to the mean
signal(signal == 0) = mean(signal);
% compute frame rate
V.dt =mean(diff(times));
% get the fluorescence trace and flip it if it is fura
V.F = fc*signal;
% normalize the trace
V.F=V.F-min(V.F); V.F=V.F/std(V.F);
V.F=V.F/max(V.F); V.F=V.F+realmin;
% set parameters based on real data
V.T = length(V.F);
% extract spike times from ephys data
vr  = dataset(:,vIndex(vC));
V.n = get_spike_times(vr,alpha);
% plot spike times from ephys data
if dPlot
    figure(666); subplot(3,1,1);
    cla; plot(vr./max(vr),'k');
    hold on; plot(V.n,1,'r.');
end
% convert spike times from ephys samples to movie frames
for ii = 1:length(V.n)
    [value V.n(ii)] = min(abs(times*ephysRate - V.n(ii)));
end
timeM = zeros(length(V.F),1);
timeM(V.n) = 1; V.n = timeM;
% plot spike times
if dPlot
    figure(666); ax(1) = subplot(3,1,2);
    cla; plot(V.F./max(V.F),'k'); hold on; plot(find(V.n > 0),1,'r.');
end
% run oopsi
fast    = fast_oopsi(V.F,V);
fast    = fast/max(fast);
% plot inference output
if dPlot
    figure(666); ax(2) = subplot(3,1,3);
    cla; bar(fast,'k'); hold on;
    plot(find(V.n > 0),1,'r.');
    linkaxes(ax,'x');
end
