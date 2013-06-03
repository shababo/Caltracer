function options = ct_detectspikesintegrals_options(handles);
% Use preprocessed signals by not making field options.preprocessStrings
% The options below will be used by
% user_check_options to create a dialogbox to get user input.
% Use preprocessed signals by not making field options.preprocessStrings
%find out whether "ct_detectspikesintegrals" was done before on this experiment
% Updated 7/29/09

options = struct;

options.preprocessStrings{1} = 'dfof';
options.preprocessStrings{2} = 'halo_subtract';
options.preprocessStrings{3} = 'baseline_subtract';

options.preprocessOptions{1} = {};
options.preprocessOptions{2} = {};
options.preprocessOptions{3} = {};


for idx=1:size(handles.app.experiment.detections,2);
    match(idx)=strcmpi('ct_detectspikesintegrals',handles.app.experiment.detections(idx).detectorName);
end
if sum(match)>0;
    match=find(match);
    %if was done before, find the index number of the most recent such
    %detection
    match=max(match);
    options.RawIntegralHardThreshHi.value = handles.app.experiment.detections(match).params.RawIntegralHardThreshHi;
    options.RawIntegralTimesNoiseHi.value = handles.app.experiment.detections(match).params.RawIntegralTimesNoiseHi;
    options.RawIntegralHardThreshLo.value = handles.app.experiment.detections(match).params.RawIntegralHardThreshLo;
    options.RawIntegralTimesNoiseLo.value = handles.app.experiment.detections(match).params.RawIntegralTimesNoiseLo;
    options.RiseIntegralHardThresh.value = handles.app.experiment.detections(match).params.RiseIntegralHardThresh;
    options.RiseIntegralTimesNoise.value = handles.app.experiment.detections(match).params.RiseIntegralTimesNoise;
    options.BasicFiltLenInSec.value = handles.app.experiment.detections(match).params.BasicFiltLenInSec;
else
    options.RawIntegralHardThreshHi.value = .15;
    options.RawIntegralTimesNoiseHi.value = min([100 handles.app.experiment.fs*5]);%depends on frame rate ie number of samples
    options.RawIntegralHardThreshLo.value = .1;
    options.RawIntegralTimesNoiseLo.value = handles.app.experiment.fs/2;%depends on frame rate ie number of samples
    options.RiseIntegralHardThresh.value = .01;
    options.RiseIntegralTimesNoise.value = 5;
    options.BasicFiltLenInSec.value = .2;%200ms = default)
end


options.RawIntegralHardThreshHi.prompt = 'Minimum CUTOFF of DEFINITELY POSITIVE INTEGRAL of a signal in df units';
options.RawIntegralTimesNoiseHi.prompt = 'Minimum amount TIMES NOISE a DEFINITELY POSITIVE INTEGRAL must be';
options.RawIntegralHardThreshLo.prompt = 'Minimum CUTOFF of CONDITIONALLY POSITIVE INTEGRAL of a signal in df units';
options.RawIntegralTimesNoiseLo.prompt = 'Minimum amount TIMES NOISE a CONDITIONALLY POSITIVE INTEGRAL must be';
options.RiseIntegralHardThresh.prompt = 'Minimum CUTOFF of a CONSISTENT RISE of a signal in df units';
options.RiseIntegralTimesNoise.prompt = 'Minimum amount TIMES NOISE a CONSISTENT RISE must be';
options.BasicFiltLenInSec.prompt = 'Filter length in seconds';
