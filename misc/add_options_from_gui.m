function options = add_options_from_gui(handles, options, varargin)
% function options = add_options_from_gui(options)
%
% Put all the options from the GUI into the options structure.
% This is useful for clustering / ordering or signal detecting.
start_idxs = [];
stop_idxs = [];

nargs = length(varargin);
for i = 1:2:nargs
   switch varargin{i}
       case 'startidxs'
           start_idxs = varargin{i+1};
       case 'stopidxs'
           stop_idxs = varargin{i+1};
   end
end


options.timeRes.value = handles.app.experiment.timeRes;
options.timeRes.prompt = 'Time resolution of sampling (secs/frame).';
options.spaceRes.value = handles.app.experiment.spaceRes;
options.spaceRes.prompt = 'Space resolution of image (microns/pixel).';
options.haloMode.value = handles.app.experiment.haloMode;
options.haloMode.prompt = 'HaloMode (0|1).';

if (~isempty(start_idxs))
    options.startIdxs.value = start_idxs;
    options.startIdxs.prompt = '';
end

if (~isempty(stop_idxs))
    options.stopIdxs.value = stop_idxs;
    options.stopIdxs.prompt = '';
end