function [info,data,exp] = ct_appDefaults(handles)
%Set up initial default values

%Check to see if variables exist.
try
    info = handles.info;
    data = handles.data;
    exp = handles.experiment;
catch
    handles.info = [];
    handles.data = [];
    handles.experiment = [];
    exp = [];
end



%% Information about CalTracer
if (~isfield(handles.info, 'title'))
    info.title = 'CalTracer';
end

if (~isfield(handles.info, 'versionNum'))
    info.versionNum = 3.0;
end

if (~isfield(handles.info, 'logo'))    
    info.logo = imread('hippo.bmp');
end

if (~isfield(handles.info, 'ctPath'))
    [pathstr, name, ext] = fileparts(which('caltracer2'));
    info.ctPath = pathstr;
end

% For keeping track of whether the expt has been saved since opening
if (~isfield(handles.info, 'didSaveExperiment'))
    info.didSaveExperiment = 0;
end

% For keeping track of whether the experiment has been set up.
if (~isfield(handles.info, 'didSetupExperiment'))
     info.didSetupExperiment = 0;
end

if (~isfield(handles.info, 'issplit'))%was it split from another movie?
   info.issplit = 0;
end



% To use in error state detection.
if (~isfield(handles.info, 'error'))
    info.error = 0;
end


%% Image Open Defaults
%"Image" is the name of the original image (no mask)
if (~isfield(handles, 'app'))
    
    data.maskLabels = {'Image'};
    
    % Type of image input
    data.currentImageInputType = 'file';

    % The current clustering or 'partition' of the data.  This is a set of
    % clusters.
    data.currentPartitionIdx = 0;
    
    % Initialize and define a default region index (set to 1).
    data.currentRegionIdx = 1;
    
    data.currentDetectionIdx = 1;
    
    data.currentContourOrderIdx = 1;
    
    data.useContourSlider = 1;
    
    data.currentCellId = 1;
    
    data.activeCells = [];
    
    % For downward signals such as Fura2
    data.centroidDisplay.on = 0;
    data.centroidDisplay.points = [];
    data.centroidDisplay.text = [];   
   
   
   
    
else 
    if (~isfield(handles.app.data, 'maskLabels'))
        data.maskLabels = {'Image'};
    end    

    % Type of image input
    if (~isfield(handles.app.data, 'currentImageInputType'))
        data.currentImageInputType = 'file';
    end

    % Initialize and define a default region index (set to 1).
    if (~isfield(handles.app.data, 'currentRegionIdx'))
         data.currentRegionIdx = 1;
    end

    % The current clustering or 'partition' of the data.  This is a set of
    % clusters.
    if (~isfield(handles.app.data, 'currentPartitionIdx'))
        data.currentPartitionIdx = 0;
    end
    
    % Initialize a current contour order (used in tile region, anything to
    % do with contour order in the signal detection gui, etc.)
    if (~isfield(handles.app.data, 'currentContourOrderIdx'))
        data.currentContourOrderIdx = 1;
        data = rmfield(app_data, 'currentContourOrderId');
    end
    
    
    % The following are used in plot_gui.m
    if (isfield(handles.data, 'currentDetectionIdx'))
        if (handles.data.currentDetectionIdx==0)
            data.currentDetectionIdx = 1;
        end
    end
    
    if (~isfield(handles.data, 'currentDetectionIdx'))
        data.currentDetectionIdx = 1;
    end
    
    if (~isfield(handles.data, 'useContourSlider'))
        data.useContourSlider = 1;
    end
    
    if (~isfield(handles.data, 'currentCellId'))
        data.currentCellId = 1;
    end
    
    if (~isfield(handles.data, 'activeCells'))
         data.activeCells = [];
    end
    
    %For downward signals such as Fura2.
    if (~isfield(handles.data, 'centroidDisplay'))
        data.centroidDisplay.on = 0;
        data.centroidDisplay.points = [];
        data.centroidDisplay.text = [];
    end

    
    end
end