function options = ct_threshold_options(handles, varargin)
% function options = ct_threshold_options(handles)
% The options below will be used by
% user_check_options to create a dialogbox to get user input.
% Use preprocessed signals by not making field options.preprocessStrings
%find out whether "ct_threshold" was done before on this experiment


for idx=1:size(handles.app.experiment.detections,2);
    match(idx)=strcmpi('ct_threshold',handles.app.experiment.detections(idx).detectorName);
end
options = struct;
if sum(match)>0;
    match=find(match);
    %if was done before, find the index number of the most recent such
    %detection
    match=max(match);
    options.Amplitude_Threshold.value=handles.app.experiment.detections(match).params.AmplitudeThreshold;
    options.Min_Duration.value=handles.app.experiment.detections(match).params.MinDurationInSeconds;
    options.Max_Duration.value=handles.app.experiment.detections(match).params.MaxDurationInSeconds;
else
    options.Amplitude_Threshold.value=0.25;%1
    options.Min_Duration.value=handles.app.experiment.timeRes;
    options.Max_Duration.value=Inf;
end
options.Amplitude_Threshold.prompt = 'Minimum value of a signal.';
options.Min_Duration.prompt = 'Minimum duration of a signal (in seconds).';
options.Max_Duration.prompt = 'Maximum duration of a signal (in seconds).';
