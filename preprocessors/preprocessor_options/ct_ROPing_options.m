function options = ct_ROPing_options(handles, varargin)
%CT_ROPING_OPTIONS Summary of this function goes here
%   Detailed explanation goes here

[Ephys_file,Ephys_path] = uigetfile('*.mat','Select the Ephys file');
options.EphysPath.value = [Ephys_path Ephys_file];
options.EphysPath.prompt = 'Ephys Path';

options.CutOffFreq.value = 50;
options.CutOffFreq.prompt = 'Current filtering cut-off freq (Hz)';

options.PSPThresh.value = -10;
options.PSPThresh.prompt = 'PSP Detection Threshold';

options.EphysRes.value = 0.1;
options.EphysRes.prompt = 'Ephys Resolution (ms)';

options.plot.value = 1;
options.plot.prompt = 'Plot the PSC?';



% 
% for idx=1:size(handles.app.experiment.detections,2);
%     match(idx)=strcmpi('ct_fast_oopsi',handles.app.experiment.detections(idx).detectorName);
% end
% options = struct;
% if sum(match)>0;
%     match=find(match);
%     %if was done before, find the index number of the most recent such
%     %detection
%     match=max(match);
%     options.Amplitude_Threshold.value=handles.app.experiment.detections(match).params.AmplitudeThreshold;
%     options.V_MaxIter.value=handles.app.experiment.detections(match).params.V_MaxIter;
%     options.PValue.value=handles.app.experiment.detections(match).params.PValue;
%     
% else
%     options.Amplitude_Threshold.value=1;
%     options.V_MaxIter.value=10;
%     options.PValue.value = 0.05;
% end
% options.Amplitude_Threshold.prompt = 'Set Fast Oopsi Threshold.';
% options.V_MaxIter.prompt='Maximum number of iterations';
% options.PValue.prompt='P value?';
% 
% end

