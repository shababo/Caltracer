function varargout = caltracer2(varargin)
%Caltracer - Version 2.5 Last Edited 4/21/09

% The following determine whether or not to launch internally with callbacks.
is_even = mod(nargin,2) == 0;
if (is_even == 1)
    ct_OpeningFcn(varargin{:});
elseif (nargin == 0)
    ct_OpeningFcn([]);
elseif (nargin == 1) % The case when we split masks.
    ct_OpeningFcn(varargin{1});
elseif (nargin == 3)
    feval(varargin{1}, varargin{2}, varargin{3});
end
%%

function hObject = ct_OpeningFcn(varargin)
% ct-OpeningFcn sets up some variables that will be used throughout the application.

if nargin == 1 % If handles are pushed through to new instance.
    handles = varargin{1};
    [handles.app.info handles.app.data handles.app.experiment] = ct_appDefaults(handles.app);
else
    %Set up program defaults
    [handles.app.info handles.app.data handles.app.experiment] = ct_appDefaults([]);
    handles.app.data.currentMaskIdx = get_mask_idx(handles, 'Image');
    handles.app.experiment.regions.bord = [];
    handles.app.experiment.regions.bhand = []; 
end

% Create preferences file if it does not exist.
if ~exist('ct_preferences.mat','file')
    handles=ct_preferences_gui(handles,'initilize_only');
end

%Load new default preferences saved in ct_preferences.mat
try
    handles = ct_preferences_load (handles);
end


if (~isfield(handles.app, 'preferences'))
       % Signal GUI checkbox initialization
    handles.app.preferences.showCheckBoxTag = 'showcheckbox';
    handles.app.preferences.showHaloCheckBoxTag = 'showhalocheckbox';
end



[hObject, handles] = ct_createGUI(handles);

%Chooses between inputs into OpeningFcn, then sends appropriate handles to
%open the image.
if (nargin>1)
    for a=1:length(varargin);
        switch lower(varargin{a})
            case 'inputfilename'
                handles.appData.currentImageInputType = 'inputfilename';
                handles = open_image(handles,[],varargin{a+1});
                handles.app_data.currentImageInputType = 'file';%reset to default
                hObject=handles.fig;%for consistency with rest of program
                guidata(hObject,handles);
                break
            case 'inputimage'
                handles.appData.currentImageInputType = 'inputarg';
                handles.app.experiment.Image.image=varargin{a+1};
                handles = open_image(handles);  
                handles.app_data.currentImageInputType = 'file';%reset to default
                hObject=handles.fig;%for consistency with rest of program
                guidata(hObject,handles);
                break
        end
    end
end
guidata(hObject,handles);
% if the image was a result of splitting, open it automatically.
if handles.app.info.issplit == 1 
    open_image_callback (hObject,handles);
end
%%
% ct_ClosingFcn
function ct_ClosingFcn(hObject, handles)
%This runs when the program closes, asks to save and closes the figure.
sem = findobj ('label', 'Save Experiment');%get ahold of the Save Experiment Menu
sem = sem(1);
sem = strcmpi ('on', get(sem,'Enable'));%if it's been made active (ie can save)
if sem%then ask user if wants to save
    if ~handles.app.info.didSaveExperiment%if not saved since opening
        button = questdlg('Would you like to save before quitting?','Save Experiment');
        switch button
            case 'Cancel'%don't close
                return
            case []
                return
            case 'Yes'
                save_experiment_callback(hObject, handles)
        %     case 'No'
        end
    end
end
    
delete(handles.fig);
%%
% ct_createGUI
function [hObject, handles] = ct_createGUI(handles)
% Setup the GUI, this means defining every widget that will be
% used, ever. So naturally, the Visible property is off for most of
% these uicontrols.
opengl neverselect;

%to make figure size work for all screens
screensize=get(0,'ScreenSize');
screensize=screensize(3:4);
taskbarheight=35;%pixels (true for all screens?)
figtoolbarheight=79;%pixels (true for all screens?)
vertpix=taskbarheight+figtoolbarheight;%to subtract from height of fig
proportion=(screensize(2)-vertpix)/screensize(2);



%Title
handles.fig = figure('Name', ...
		     [handles.app.info.title ' ' num2str(handles.app.info.versionNum,'%6g')],...
		     'NumberTitle','off',...
		     'MenuBar','none',...
		     'ToolBar', 'figure', ...
		     'doublebuffer','on',...
		     'closerequestfcn','caltracer2(''ct_ClosingFcn'',gcbo,guidata(gcbo))',...
		     'Resize', 'on', ...
             'units','pixels',...
             'position',[5 taskbarheight screensize(1)*proportion screensize(2)-vertpix]);

hObject = handles.fig;


%% Taskbar Menu
handles.uimenuLabels = {'File', 'Preferences', 'Import', 'Export', 'Contours', 'Preprocessing', 'Clustering', 'Functions', 'Debug'};
% Setup menu and menu group.
menu_idx = get_menu_label_idx(handles, 'File');
handles.menugroup{menu_idx}.file = uimenu('Label', 'File');

% Add the menu items

% File Menu.
uimenu(handles.menugroup{menu_idx}.file, ...
       'Label', 'Open Experiment', ...
       'Callback', 'caltracer2(''open_experiment_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.file, ...
       'Label', 'Save Experiment', ...
       'Enable', 'off', ...
       'Callback', 'caltracer2(''save_experiment_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.file, ...
       'Label', 'New CalTracer', ...
       'Enable', 'on', ...
       'Callback', 'caltracer2(''new_ct_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.file, ...
       'Label', 'Quit', ...
       'Callback', 'caltracer2(''ct_ClosingFcn'', gcbo, guidata(gcbo))');

   
% Preferences Menu.
menu_idx = get_menu_label_idx(handles, 'Preferences');
handles.menugroup{menu_idx}.preferences = uimenu('Label', 'Preferences');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Edit Caltracer Preferences', ...
       'Callback', 'caltracer2(''ct_preferences_gui_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'on');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Long Raster', ...
       'Callback', 'caltracer2(''long_raster_callback'', gcbo, guidata(gcbo))', ...
       'Checked', 'on', ...
       'Enable', 'off');

uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Display centroids on selected (pixels)', ...
       'Callback', 'caltracer2(''display_centroids_on_selection_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Display ids on all contours', ...
       'Callback', 'caltracer2(''display_ids_on_all_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Display ids on selected contours', ...
       'Callback', 'caltracer2(''display_ids_on_selected_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Show ordering line', ...
       'Callback', 'caltracer2(''show_ordering_line_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.preferences, ...
       'Label', 'Show contour ordering', ...
       'Callback', 'caltracer2(''show_contour_ordering_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');

% Import Menu.
menu_idx = get_menu_label_idx(handles, 'Import');
handles.menugroup{menu_idx}.import = ...
    uimenu('Label', 'Import', ...
	   'Enable', 'on');
uimenu(handles.menugroup{menu_idx}.import, ...
       'Label', 'Import Current Trace', ...
       'Enable', 'On', ...
       'Callback', 'caltracer2(''import_current_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.import, ...
       'Label', 'Import Voltage Trace', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''import_voltage_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.import, ...
       'Label', 'Import LFP', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''import_lfp_callback'',gcbo,guidata(gcbo))');   
   
% Export Menu.
menu_idx = get_menu_label_idx(handles, 'Export');
handles.menugroup{menu_idx}.export = ...
    uimenu('Label', 'Export', ...
	   'Enable', 'on');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Copy axis as metafile to clipboard', ...
       'Enable', 'On', ...
       'Callback', 'caltracer2(''copy_axis_as_meta_to_clipboard_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Copy axis to new figure', ...
       'Enable', 'On', ...
       'Callback', 'caltracer2(''copy_axis_to_new_figure_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Export contours', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''export_contours_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Export contours to file', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''export_contours_to_file_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Export traces', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''export_traces_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Export traces with signals', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''export_traces_with_signals_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
       'Label', 'Export active cell traces', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer2(''export_active_cell_traces_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
    'Label', 'All centroids to vnt file', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer2(''all_centroids_to_vnt_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
    'Label', 'All centroids to vnt file (more than once)', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer2(''all_centroids_to_vnt_repeat_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
    'Label', 'All centroids to vnt file (more than one pulse per target)', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer2(''all_centroids_to_vnt_pulses_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
    'Label', 'Active cells to vnt file', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer2(''active_cells_to_vnt_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{menu_idx}.export, ...
    'Label', 'Export ids of overlapping masks', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer2(''overlapping_mask_ids_callback'',gcbo,guidata(gcbo))');





% Preprocessing Menu.
menu_idx = get_menu_label_idx(handles, 'Preprocessing');
handles.menugroup{menu_idx}.preprocessing = ...
    uimenu('Label', 'Preprocessing', ...
	   'Enable', 'On');
uimenu(handles.menugroup{menu_idx}.preprocessing, ...
       'Label', 'Preprocessing Options', ...
       'Callback', 'caltracer2(''preprocessing_options_callback'', gcbo, guidata(gcbo))',...
       'Enable', 'off');


% Contours Menu.
menu_idx = get_menu_label_idx(handles, 'Contours');
handles.menugroup{menu_idx}.contours = ...
    uimenu('Label', 'Contours', ...
	   'Enable', 'On');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Tile Region', ...
       'Callback', 'caltracer2(''tile_region_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Tile Region at angle', ...
       'Callback', 'caltracer2(''tile_region_angle_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Tile Region with rectangles',...
       'Callback', ...
       'caltracer2(''tile_region_with_rectangles_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Randomize contour order',...
       'Callback', ...
       'caltracer2(''randomize_contour_order_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Keep only brightest contours',...
       'Callback', ...
       'caltracer2(''keep_only_brightest_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Keep random contours',...
       'Callback', ...
       'caltracer2(''keep_random_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Keep last contours',...
       'Callback', ...
       'caltracer2(''keep_last_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Keep last contours & randomize order',...
       'Callback', ...
       'caltracer2(''keep_last_contours_randomize_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Convert contours to parallel image',...
       'Callback', ...
       'caltracer2(''convert_contours_to_parallel_image_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');   
uimenu(handles.menugroup{menu_idx}.contours, ...
   'Label', 'Make all contours active', ...
   'Callback', 'caltracer2(''make_all_contours_active_callback'',gcbo,guidata(gcbo))',...
   'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Highlight contours by order', ...
       'Callback','caltracer2(''highlight_contours_by_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Highlight contours by order (in partition)', ...
       'Callback','caltracer2(''highlight_contours_by_order_in_partition_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Highlight contours by cluster id', ...
       'Callback','caltracer2(''highlight_contours_by_cluster_id_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Connect highlighted contours in order', ...
       'Callback', 'caltracer2(''connect_highlighted_contours_in_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Plot highlighted contours', ...
       'Callback', 'caltracer2(''plot_highlighted_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Plot highlighted contours with zeroed signals', ...
       'Callback', 'caltracer2(''plot_highlighted_contours_zero_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');      
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Turn active contours off', ...
       'Callback', 'caltracer2(''turn_active_contours_off_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Delete contour by id', ...
       'Callback', 'caltracer2(''delete_contours_by_id_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');   
uimenu(handles.menugroup{menu_idx}.contours, ...
       'Label', 'Delete active contours', ...
       'Callback', 'caltracer2(''delete_active_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off'); 

% Clustering Menu.
menu_idx = get_menu_label_idx(handles, 'Clustering');
handles.menugroup{menu_idx}.clustering = ...
    uimenu('Label', 'Clustering', ...
	   'Enable', 'On');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Highlight all clusters', ...
       'Callback', 'caltracer2(''highlight_all_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Unhighlight all clusters', ...
       'Callback', 'caltracer2(''unhighlight_all_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Merge highlighted clusters', ...
       'Callback', 'caltracer2(''merge_highlighted_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Delete clusters by id', ...
       'Callback', 'caltracer2(''delete_clusters_by_id_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Delete clusters by size', ...
       'Callback', 'caltracer2(''delete_clusters_by_size_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Delete contours by order', ...
       'Callback','caltracer2(''delete_contours_by_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{menu_idx}.clustering, ...
       'Label', 'Order clusters by intensity peak', ...
       'Callback', 'caltracer2(''order_clusters_by_intensity_peak_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');

      
% Functions Menu.
menu_idx = get_menu_label_idx(handles, 'Functions');
handles.menugroup{menu_idx}.functions = uimenu('Label', 'Functions');

% In the case of the functions menu, the menu items are functions that
% are created by individual users.  As such, the directory is read at
% the opening of the epo program and the menu is loaded with all the
% functions that are prefaced with 'ct_'.  The functions are then
% enabled during the signals part of the program, where program
% control is passed to the called function upon user menu selection.
% -DCS:2005/08/02
[st, function_names] = readdir(handles, 'signalfunctions');
for i = 1:length(st)
   uimenu(handles.menugroup{menu_idx}.functions, ...
       'Label', st{i}, ...
       'Enable', 'off', ...
       'UserData', function_names{i}, ...
       'Callback', 'caltracer2(''signal_functions_callback'',gcbo,guidata(gcbo))');
end
% Sort of a hack because there should be a general mechanism for
% functions that don't disturb the handles and can be enabed earlier.
% This simply measures the distanre on the axis. -DCS:2005/08/11
handles = menuset(handles, 'functions','functions','measure_distance','Enable','on');

% Debug Menu.
menu_idx = get_menu_label_idx(handles, 'Debug');
handles.menugroup{menu_idx}.debug = ...
    uimenu('Label', 'Debug', ...
	   'Enable', 'On');
uimenu(handles.menugroup{menu_idx}.debug, ...
       'Label', 'Save handles struct to workspace', ...
       'Callback', 'caltracer2(''save_handles_callback'', gcbo, guidata(gcbo))',...
       'Enable', 'on');


% The GUI flow goes basicall in this order, too:
% logo->image->...->filterimage->detectcells->...
handles.uigroupLabels = ...
    {'logo', 'image', 'resolution', 'regions', 'filterimage', ...
     'filterimagebadpixels','detectcells', 'consolidatemaps', 'halos',...
     'signals'};


% Load the CalTracer Logo.
lidx = get_label_idx(handles, 'logo');
handles.uigroup{lidx}.logoim = axes('position',[0.25 0.3 0.4 0.4]);
handles.uigroup{lidx}.logoname = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',[handles.app.info.title ' ' num2str(handles.app.info.versionNum,4)],...
	      'Position',[.25 .7 .4 .05], ...
	      'HorizontalAlignment','left', ...
	      'FontSize',18, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'foregroundcolor',[1 0 0]);
handles.uigroup{lidx}.authors = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',{'by Mor Dar, David Sussillo, Dmitry Aronov,';'Brendon Watson, Adam Packer';'and Conrad Stern-Ascher'}, ...
	      'Position',[.25 .2 .4 .05], ...
	      'HorizontalAlignment','center', ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'foregroundcolor',[1 0 0]);

     
      
%% Image Window
% This is the initial view within caltracer2.
lidx = get_label_idx(handles, 'image');
handles.uigroup{lidx}.imgax = ...
    axes('position', [0.02 0.02 0.82 0.94], ...
	 'Visible', 'off');

% Text: "Image"
handles.uigroup{lidx}.textstring1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Image', ...
	      'Position',[.87 .955 .11 0.03], ...
	      'FontSize', 12, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8]);

% Open Button      
handles.uigroup{lidx}.bopenimage = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Open', ...
	      'Position',[.87 .91 .055 .03], ...
	      'FontSize',9, ...
	      'Callback','caltracer2(''open_image_callback'',gcbo,guidata(gcbo))');
      
% Open Sequence Button.  
handles.uigroup{lidx}.bopenimage = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Open Sequence', ...
	      'Position',[.93 .91 .055 .03], ...
	      'FontSize',9, ...
	      'Callback','caltracer2(''open_image_sequence_callback'',gcbo,guidata(gcbo))');

% Text: Brightness      
handles.uigroup{lidx}.textstring2 = ...
    uicontrol('Style','text', ...
	      'units','normalized', ...
	      'string','Brightness', ...
	      'position',[.87 .88 .11 .02], ...
	      'FontSize',9, ...
	      'BackgroundColor',[.8 .8 .8]);
      
% Brightness Slider
handles.uigroup{lidx}.bbright = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[.87 .86 .11 .02], ...
	      'Min',0, ...
	      'Max',1, ...
	      'Sliderstep',[.01 .05], ...
	      'Value',1/3, ...
	      'Enable','off', ...
	      'Callback','caltracer2(''adjust_contrast_callback'',gcbo,guidata(gcbo))');
      
%Text: Contrast      
handles.uigroup{lidx}.textstring3 = ...
    uicontrol('Style','text', ...
	      'units','normalized', ...
	      'string','Contrast', ...
	      'position',[.87 .83 .11 .02], ...
	      'FontSize',9, ...
	      'BackgroundColor',[.8 .8 .8]);
      
%Contrast Slider
handles.uigroup{lidx}.bcontrast = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[.87 .81 .11 .02], ...
	      'Min',0, ...
	      'Max',1, ...
	      'Sliderstep',[.01 .05], ...
	      'Value',1/3, ...
	      'Enable','off', ...
	      'Callback', 'caltracer2(''adjust_contrast_callback'',gcbo, guidata(gcbo))');
      
      
      
%% Resolution
%This is the Resolution settings gui
lidx = get_label_idx(handles, 'resolution');

%Text: Resolution
handles.uigroup{lidx}.res_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Resolution', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8]);

% Text "Spatial" with Units
handles.uigroup{lidx}.txlabsr = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Spatial (µm/pixel)', ...
	      'Position',[.87 .715 .11 0.02], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'HorizontalAlignment','left');
      
% Spatial value inside input box
handles.uigroup{lidx}.inptsr = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','1', ...
	      'Position',[.87 .715-0.0275 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment', 'left', ...
	      'enable', 'off');
      
% Text "Temporal" with Units
handles.uigroup{lidx}.txlabtr = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Temporal (sec/frame)', ...
	      'Position',[.87 .715-0.0275-0.025 .11 0.02], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'HorizontalAlignment','left');

% Temporal value inside input box      
handles.uigroup{lidx}.inpttr = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','1', ...
	      'Position',[.87 .715-2*0.0275-0.025 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left', ...
	      'Enable','off');
      
% Setup Regions Callback = "Next" button
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','off', ...
	      'Callback','caltracer2(''setup_regions_callback'',gcbo,guidata(gcbo))');

      
%% Regions.
lidx = get_label_idx(handles, 'regions');
handles.uigroup{lidx}.regax = ...
    axes('position',[0.87 0.64 0.11 0.10], ...
	 'Visible', 'Off');

%Text: Regions
handles.uigroup{lidx}.bord_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized',...
	      'String','Regions', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'Off', ...
	      'BackgroundColor',[.8 .8 .8]);
      
% Create Region Callback = Add Button      
handles.uigroup{lidx}.bord_add = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.90 .595 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...
	      'Enable','on', ...
	      'Callback','caltracer2(''create_region_callback'',gcbo,guidata(gcbo))');
      
% Delete Region Callback = Delete Button
handles.uigroup{lidx}.bord_delete = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.90 .555 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...
	      'Enable','off', ...
	      'Callback','caltracer2(''delete_region_callback'',gcbo,guidata(gcbo))');

% Name Regions = The "Next" button
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','on', ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer2(''name_regions'',gcbo,guidata(gcbo))');

%% Image filtering functions.
lidx = get_label_idx(handles, 'filterimage');

% Text: Image Filter Heading
handles.uigroup{lidx}.det_tx1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Image filter', ...
	      'Position',[.87 .60 .11 0.02], ...
	      'FontSize',9,...
	      'FontWeight','Bold',...
          'HorizontalAlignment','left', ...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[.8 .8 .8]);
      
% Pulldown Menu under Image filter
handles.uigroup{lidx}.dpfilters = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .5725 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[1 1 1]);
      
% Filter Button
handles.uigroup{lidx}.det_loc = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Filter', ...
	      'Position',[.87 .535 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer2(''ct_filter_callback'',gcbo,guidata(gcbo))');
      
% View Button
handles.uigroup{lidx}.det_view = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','View', ...
	      'Position',[.93 .535 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer2(''view_filtered_image'',gcbo,guidata(gcbo))',...
	      'enable','off');

lidx = get_label_idx(handles, 'filterimagebadpixels');  
% Text: Remove for filtering heading
handles.uigroup{lidx}.badpixtitle = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Remove for filtering', ...
	      'Position',[.87 .4925 .11 0.02], ...
	      'FontSize',9,...
	      'FontWeight','Bold',...
          'HorizontalAlignment','left', ...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[.8 .8 .8]);

% Text: Right Columns
handles.uigroup{lidx}.leftcolslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Left Columns', ...
	      'Position',[.87 .4625 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer2(''view_filtered_image'',gcbo,guidata(gcbo))');      
      
% Left Column input box under Remove for filtering   
handles.uigroup{lidx}.leftcols = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .46 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','leftcols',...
          'Callback','caltracer2(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 

% Text: Right Columns       
handles.uigroup{lidx}.rightcolslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Right Columns', ...
	      'Position',[.87 .4325 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);   
      
% Right Column input box under Remove for filtering  
handles.uigroup{lidx}.rightcols = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .43 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','rightcols',...
          'Callback','caltracer2(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 

% Text: Upper Rows       
handles.uigroup{lidx}.upperrowslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Upper Rows', ...
	      'Position',[.87 .4025 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
      
% Upper Row input box under Remove for filtering        
handles.uigroup{lidx}.upperrows = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .40 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','upperrows',...
          'Callback','caltracer2(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 

% Text: Lower Rows      
handles.uigroup{lidx}.lowerrowslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Lower Rows', ...
	      'Position',[.87 .3725 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
      
% Lower Row input box under Remove for filtering        
handles.uigroup{lidx}.lowerrows = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .37 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','lowerrows',...
          'Callback','caltracer2(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 
           
%% Detect Cells
lidx = get_label_idx(handles, 'detectcells');
%widgets actually novel to this group
handles.uigroup{lidx}.txlab = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .49 .11 0.025], ...
	      'FontSize',10, ...
	      'FontWeight','Bold',...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1]); %%% bgcolor too!
handles.uigroup{lidx}.dummyp(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Cutoff %', ...
	      'Position',[.87 .4625 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txthres = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','(Uninitialized)', ...
	      'Position',[.95 .46 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
% Doesn't work in uicontros but does in titles. -DCS:2005/08/08
units = '(um^2)';
handles.uigroup{lidx}.dummyp(2) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',['Min area ' units], ...
	      'Position',[.87 .4325 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txarlow = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .43 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.dummyp(3) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',['Max area ' units], ...
	      'Position',[.87 .4025 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txarhigh = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .40 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btdetect = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Detect', ...
	      'Position',[.87 .3625 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detect_cells_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.bthide = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Hide', ...
	      'Position',[.93 .3625 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''bthide_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummyp(4) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Pi limit', ...
	      'Position',[.8725 .32 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txpilim = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .32 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btfindbad = ...
    uicontrol('Style','pushbutton', ...		      
	      'Units','normalized', ...
	      'String','Find', ...
	      'Position',[.87 .286 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''find_bad_cells_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadjust = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Adjust', ...
	      'Position',[.93 .286 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''adjust_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdeletepi = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .255 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''delete_high_pi_contours_callback'',gcbo,guidata(gcbo))');

handles.uigroup{lidx}.dummyp(6) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Move contours', ...
	      'Position',[.87 .215 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.moveall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move All', ...
	      'Position',[.87 .1875 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''move_all_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.rotateall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Rotate All', ...
	      'Position',[.93 .1875 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''rotate_all_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.moveone = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move One', ...
	      'Position',[.87 .1565 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''move_one_contour_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummyp(5) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Manual add/delete shape', ...
	      'Position',[.87 .135 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.shaperad1 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Circle', ...
	      'Position',[.87 .115 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detectcells_shaperad1_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad2 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Freehand', ...
	      'Position',[.9 .115 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detectcells_shaperad2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad3 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Custom', ...
	      'Position',[.945 .115 .055 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detectcells_shaperad3_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadd = ...
    uicontrol('Style','togglebutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.87 .085 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''manual_contour_add_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdelete = ...
    uicontrol('Style','togglebutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .085 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''manual_contour_delete_callback'',gcbo,guidata(gcbo))',...
	      'enable','off');
handles.uigroup{lidx}.bteditcontours = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Edit', ...
	      'Position',[.87 .054 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''edit_contour_callback'',gcbo,guidata(gcbo))',...
	      'enable','off');      
handles.uigroup{lidx}.btloadcontours = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Load', ...
	      'Position', [.93 0.054 .05 0.03], ...
	      'FontSize', 9, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''load_contours_callback'',gcbo,guidata(gcbo))');

handles.uigroup{lidx}.btnextscr = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detect_cells_next_callback'',gcbo,guidata(gcbo))', ...
 	      'enable','off');
handles.uigroup{lidx}.adddeletetext = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Hit Esc to leave add/delete mode', ...
	      'Position',[.75 .02 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
          'ForegroundColor',[.8 .8 .8], ...
	      'BackgroundColor',[.8 .8 .8]);
%% Consolidate Maps
lidx = get_label_idx(handles, 'consolidatemaps');
handles.uigroup{lidx}.map_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Consolidate', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dummyp(5) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Manual add shape', ...
	      'Position',[.87 .1725 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.stoverlap = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Overlap %', ...
	      'Position',[.87 .34 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txoverlap = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','10', ...
	      'Position',[.95 .34 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.classifyoverlap = ...
   uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Classify Overlap', ...
	      'Position',[.87 .30 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''classifyoverlap_callback'',gcbo,guidata(gcbo))');

handles.uigroup{lidx}.eliminaterest = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Eliminate Rest', ...
	      'Position',[.87 .26 .07 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''eliminaterest_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.eliminateoverlap = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Eliminate Overlap', ...
	      'Position',[.87 .28 .08 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''eliminateoverlap_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btfindbad = ...
    uicontrol('Style','pushbutton', ...		      
	      'Units','normalized', ...
	      'String','Find', ...
	      'Position',[.945 .29 .04 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''find_overlap_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadjust = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Adjust', ...
	      'Position',[.945 .26 .04 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''adjust_overlap_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.movetext = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Move contours', ...
	      'Position',[.87 .235 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.moveall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move All', ...
	      'Position',[.87 .2075 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''move_all_contours2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.rotateall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Rotate All', ...
	      'Position',[.93 .2075 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''rotate_all_contours2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad1 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Circle', ...
	      'Position',[.87 .145 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''consolidatemaps_shaperad1_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad2 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Freehand', ...
	      'Position',[.9 .145 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''consolidatemaps_shaperad2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad3 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Custom', ...
	      'Position',[.945 .145 .055 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''consolidatemaps_shaperad3_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadd = ...
    uicontrol('Style','togglebutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.87 .11 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''manual_contour_add_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdelete = ...
    uicontrol('Style','togglebutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .11 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''manual_contour_delete_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btsplit = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Split', ...
	      'Position',[.87 .02 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''mask_split_callback'',gcbo,guidata(gcbo))');    
handles.uigroup{lidx}.btnextscr = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''setup_halos_callback'',gcbo,guidata(gcbo))', ...
 	      'enable','on');
handles.uigroup{lidx}.adddeletetext = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Hit Esc to leave add/delete mode', ...
	      'Position',[.75 .02 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
          'ForegroundColor',[.8 .8 .8], ...
	      'BackgroundColor',[.8 .8 .8]);      
% The widgets that read the traces and create halos..
lidx = get_label_idx(handles, 'halos');
handles.uigroup{lidx}.trace_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Traces', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.halo_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Use halos', ...
	      'Value', 1, ...
	      'Position',[.87 .715 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''halo_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummy(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Halo area', ...
	      'Position',[.87 0.6875 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.inpthaloar = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 0.6625 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'enable','on');
handles.uigroup{lidx}.btupdate = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Update', ...
	      'Position',[.93 .6175 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''halo_update_callback'',gcbo,guidata(gcbo))',...
	      'enable','on');
handles.uigroup{lidx}.dummy(2) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Trace reader', ...
	      'Position',[.87 0.575 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpreaders = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .55 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''setup_signals_callback'',gcbo,guidata(gcbo))');

% Signals for plotgui functions.
lidx = get_label_idx(handles, 'signals');
 handles.uigroup{lidx}.textstring1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Signals', ...
	      'Position',[.87 .955 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.trace_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show raw', ...
	      'Position',[.87 .93 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Value', 0, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Tag', handles.app.preferences.showCheckBoxTag,...
	      'UserData', 1, ...
	      'Callback','caltracer2(''trace_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.clean_trace_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show clean', ...
	      'Position',[.87 .91 .11 0.025], ...
	      'FontSize',9,...
          'Value', 1, ...
          'Visible', 'off', ...
	      'Tag', handles.app.preferences.showCheckBoxTag,...
	      'UserData', 2, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer2(''clean_trace_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.halo_raw_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show halo raw', ...
	      'Position',[.87 .89 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Tag', handles.app.preferences.showHaloCheckBoxTag,...
	      'UserData', 1, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer2(''halo_raw_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.halo_preprocess_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show halo clean', ...
	      'Position',[.87 .87 .11 0.025], ...
	      'FontSize',9,...
	      'Tag', handles.app.preferences.showHaloCheckBoxTag,...
	      'UserData', 2, ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer2(''halo_preprocess_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.signals_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show signals', ...
	      'Position',[.87 .850 .11 0.025], ...
	      'FontSize',9,...
          'Value',1,...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer2(''signals_checkbox_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.FrameSpecTitle = ...
    uicontrol('Style','Text',...
        'String','Frame Input Type',...
        'FontWeight','Bold',...
        'Units','Normalized',...
        'Position',[.855 .82 .13 .025],...
        'Visible','off',...
        'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.use_frame_click_input_checkbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Click Input', ...
	      'Position',[.87 .81 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Value',0,...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer2(''click_frame_input_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.use_numerical_frame_input_checkbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Number Input', ...
	      'Position',[.87 .79 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Value',0,...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer2(''numerical_frame_input_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.use_numerical_frame_input_min = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
          'Position',[.88 .775 .035 0.0175], ...
	      'FontSize',9,...
	      'Visible', 'Off',...	
          'Enable','Off',...
          'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.use_numerical_frame_input_max = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
          'Position',[.93 .775 .035 0.0175], ...
	      'FontSize',9,...
	      'Visible', 'Off',...
          'Enable','Off',...
          'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.numslider = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[0.05 0.0 0.79 0.03], ...
	      'Callback','caltracer2(''numslider_callback'',gcbo,guidata(gcbo))', ... 
	      'Min', 0, ...
	      'Max', 1, ...		% (Uninitialized)
	      'Sliderstep', 0:1, ...	% (Uninitialized)
	      'Visible', 'off', ...
	      'Value', 1);

% Clustering widgets.
handles.uigroup{lidx}.stxdimreduxmethod = ...
    uicontrol('Style', 'text', ...
	      'Units', 'normalized', ...
	      'String', 'Dim Reduction', ...
	      'Position', [.87 .7500 .11 0.02], ...
	      'FontSize', 9, ...
	      'Visible', 'off', ...
	      'HorizontalAlignment', 'left', ...
	      'BackgroundColor', [.8 .8 .8]);
handles.uigroup{lidx}.dpdimreducers = ...
    uicontrol('Style', 'popupmenu', ...
	      'String', '(Uninitialized)', ...
	      'Units', 'normalized', ...
	      'Position', [.87 .7250 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize', 9, ...
	      'HorizontalAlignment', 'left', ...
	      'BackgroundColor', [1 1 1]);
handles.uigroup{lidx}.stxclustermethod = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Cluster method', ...
	      'Position',[.87 .7000 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpclassifiers = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .6750 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.stxnclusters = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Num clusters  Num trials', ...
	      'Position',[.87 .6500 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txnclusters = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '1', ...
	      'Position',[.87 .6250 .05 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.txntrials = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '1', ...
	      'Position',[.94 .6250 .05 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btcluster = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Cluster', ...
	      'Position',[.87 .5900 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''cluster_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.stsavedclusterings = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Partitions', ...
	      'Position',[.87 .5650 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.clusterpopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .5400 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer2(''clusterpopup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);

% Contour order widgets.
handles.uigroup{lidx}.stxcontourorder = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Contour Order', ...
	      'Position',[.87 .4500 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dporderroutines = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .4250 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.btreorder = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Order', ...
	      'Position',[.87 .3900 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''order_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.stsavedcontourorders = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Contour Orders', ...
	      'Position',[.87 .3650 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.contourorderpopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .3400 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer2(''contour_order_popup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);

% Signal detector stuff.
handles.uigroup{lidx}.dummy(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Signal Detector', ...
	      'Position',[.87 0.2525 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpdetectors = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .2275 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.btdetect = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Detect', ...
	      'Position',[.87 .1925 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''detect_signals_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.stsavedsignals = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Signals', ...
	      'Position',[.87 .1675 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.signalspopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .1425 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer2(''signals_popup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);

handles.uigroup{lidx}.btexporttoanalyzer = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','To Analyzer', ...
	      'Position',[.87 .05 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer2(''export_signals_to_analyzer_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.signaleditmodecheckbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Edit Signals', ...
	      'Position',[.87 .02 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Callback', 'caltracer2(''signal_edit_mode_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[.8 .8 .8]);    
      
%contour slider checkbox at bottom
handles.uigroup{lidx}.contourslidercheckbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Single Contour Display', ...
	      'Position',[.87 0 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Callback', 'caltracer2(''use_contour_slider_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[.8 .8 .8]);

lidx = get_label_idx(handles, 'logo');
axes(handles.uigroup{lidx}.logoim);
handles.app.info.logoImage = imagesc(handles.app.info.logo);
axis equal;
axis off;

% Save the data before we leave.
guidata(hObject, handles);


%% Callbacks
function open_image_callback(hObject, handles)
% Callback for Open button
% Check if previous preferences should be kept (in the case of mask
% loading, splitting instances, etc.
handles.app.experiment.opensequential=0;
if isfield (handles.app.preferences, 'KeepPrevPref')
    if handles.app.preferences.KeepPrevPref ==0
        handles = ct_preferences_load (handles);
        newhandles = open_image(handles);
    else 
        newhandles = open_image (handles);
    end
else
    handles = ct_preferences_load (handles);
    newhandles = open_image(handles);
end

if isempty(newhandles)
    return
else
    handles = newhandles;
end

% Once the image is loaded, delete the logo from handles.
if isfield(handles.app.info,'logoImage');
    delete(handles.app.info.logoImage);
    handles.app.info = rmfield(handles.app.info,'logoImage');
end
guidata(hObject, handles);

%if this image is part of a split image, automove to the setup regions callback.
if handles.app.info.issplit == 1 
    setup_regions_callback (hObject,handles);
end

function open_image_sequence_callback (hObject,handles)
% Callback for Open button
% Check if previous preferences should be kept (in the case of mask
% loading, splitting instances, etc.
handles.app.experiment.opensequential=1; 
if isfield (handles.app.preferences, 'KeepPrevPref')
    if handles.app.preferences.KeepPrevPref ==0
        handles = ct_preferences_load (handles);
        newhandles = open_image_sequence(handles);
    else 
        newhandles = open_image_sequence (handles);
    end
else
    handles = ct_preferences_load (handles);
    newhandles = open_image_sequence(handles);
end

if isempty(newhandles)
    return
else
    handles = newhandles;
end

% Once the image is loaded, delete the logo from handles.
if isfield(handles.app.info,'logoImage');
    delete(handles.app.info.logoImage);
    handles.app.info = rmfield(handles.app.info,'logoImage');
end
guidata(hObject, handles);

%if this image is part of a split image, automove to the setup regions callback.
if handles.app.info.issplit == 1 
    setup_regions_callback (hObject,handles);
end

function adjust_contrast_callback(hObject, handles)
% Callback occurs when Brightness and Contrast sliders are moved.

handles = adjust_contrast(handles);
guidata(hObject, handles);


function setup_regions_callback(hObject, handles)
% Callback occurs after "Next" is hit for the first time.
% Read the spatial and temporal resolution, then show the regions gui.
handles.app.experiment.spaceRes = ...
    str2num(uiget(handles, 'resolution', 'inptsr', 'string'));
handles.app.experiment.mpp = handles.app.experiment.spaceRes;	% microns per pixel
handles.app.experiment.ppm = 1./handles.app.experiment.mpp;	% pixels per micron.
handles.app.experiment.timeRes = ...
    str2num(uiget(handles, 'resolution', 'inpttr', 'string'));
handles.app.experiment.fs = 1./handles.app.experiment.timeRes;
handles = uiset(handles, 'image', 'bopenimage', 'enable','off');
handles = hide_uigroup(handles, 'resolution');
handles = show_uigroup(handles, 'regions');
handles = determine_regions(handles);
guidata(hObject, handles);
% if there is only one region or image was a result of splitting, go to name regions.
if handles.app.preferences.SingleRegion == 1||handles.app.info.issplit == 1
    caltracer2('name_regions',hObject, handles);
end


function regionmap_buttondown_callback(hObject, handles)
% This is called when the user clicks on the map above the add button in
% the regions screen.
user_data = get(hObject, 'UserData');
ridx = user_data(1);
midx = user_data(2);
handles = save_detectcell_widget_values(handles);
% Get the new region index.
names = handles.app.experiment.regions.name;
handles.app.data.currentRegionIdx = ridx;
handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);


function create_region_callback(hObject, handles)
% This Callback occurs after the "Add" button is hit in the regions window.
% Calls the create region function.
handles = create_region(handles);
guidata(hObject, handles);



function delete_region_callback(hObject, handles)
% This Callback occurs after the "Delete" button is hit in the regions window.
% Calls the delete region function.
handles = delete_region(handles);
guidata(hObject, handles);


function name_regions(hObject, handles)
% This is the name regions gui called by hitting "Next" in the region
% creating screen or via skipthrough settings.

coords = handles.app.experiment.regions.coords;

% Hide the create and delete region widgets as well as the 'regions' next button.
handles = hide_uiwidget(handles, 'regions', 'bord_add');
handles = hide_uiwidget(handles, 'regions', 'bord_delete');
handles = hide_uiwidget(handles, 'regions', 'bnext');

% Make colorcoded labels for each region and title.
cl = hsv(length(coords));
for c = 1:length(coords)
    lidx = get_label_idx(handles, 'regions');
    handles.uigroup{lidx}.txlab(c) = ...
	uicontrol('Style','text', ...
		  'Units','normalized', ...
		  'String',['Region ' num2str(c)], ...
		  'Position',[.87 .60-(c-1)*.07 .11 0.025], ...
		  'FontSize',9,...
		  'HorizontalAlignment','left', ...
		  'BackgroundColor',cl(c,:));
      
% Ask for name input.
    handles.uigroup{lidx}.inpt(c) = ...
	uicontrol('Style','edit', ...
		  'Units','normalized', ...
		  'String',['Name ' num2str(c)], ...
		  'Position',[.87 .60-(c-1)*.07-0.035 .11 0.03], ...
		  'FontSize',9,...
		  'BackgroundColor',[1 1 1], ...
		  'HorizontalAlignment','left');
end




% Reset the next button to move on to the filter setup gui.
% FYI, this resets bnext, so if we ever allow backwards, this
% will break. -DCS:2005/03/16
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','on', ...
	      'Callback','caltracer2(''setup_filter_image'',gcbo,guidata(gcbo))');
guidata(hObject, handles);
% if the image was a result of splitting, open it automatically.
if handles.app.info.issplit == 1 ||handles.app.preferences.SingleRegion == 1
    setup_filter_image (hObject,handles);
end


function setup_filter_image(hObject, handles)
% This is called by the next button AFTER it is reset in the NAME_REGIONS
% function.

% This function sets up the GUI to filter the image.  
% This occurs before cell detection.


% Before filtering, set the regions structures in the handles.
lidx = get_label_idx(handles, 'regions');
nregions = length(handles.app.experiment.regions.coords);

% Get the region names and add to handles.
for c = 1:nregions
    inpt = handles.uigroup{lidx}.inpt(c);
    handles.app.experiment.regions.name{c} = get(inpt,'String');
end

% Add Number of Regions and corresponding colors to handles.
handles.app.experiment.numRegions = nregions;
handles.app.experiment.regions.cl = hsv(nregions);

%Making sure not to replace current contours if image is from split.
if handles.app.info.issplit ~= 1 
    % Creates an array of contours by region.
    handles.app.experiment.regions.contours = cell(1, nregions);

    % Blanking out the new array of contours by region.
    for r = 1:nregions
        handles.app.experiment.regions.contours{r}{1} = [];
    end
end
% Enable some taskbar settings.
handles = menuset(handles, 'Contours','contours','Tile Region','Enable','on');
handles = menuset(handles, 'Contours','contours','Tile Region at angle','Enable','on');
handles = menuset(handles, 'Contours','contours','Tile region with rectangles','Enable','on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show contour ordering', 'Enable', 'on');
      
% Should this be part of the regions?  I don't think so because they
% can be constructed from the region data above, and they have no life
% outside of the GUI.
handles.guiOptions.face.handl = cell(1, nregions);
% Include a cell array for the map index as well.
for r = 1:nregions
    handles.guiOptions.face.handl{r} = cell(1);
end
% Some initialization is going on here but only the first time.
handles.guiOptions.face.thresh = 15*ones(1, nregions);
handles.guiOptions.face.oldThresh = inf*ones(1, nregions);
handles.guiOptions.face.minArea = 10*ones(1, nregions);
handles.guiOptions.face.maxArea = repmat(inf,1, nregions);
handles.guiOptions.face.piLimit = 4*ones(1, nregions);
handles.guiOptions.face.isAdjusted = zeros(1, nregions);
handles.guiOptions.face.isDetected = zeros(1, nregions);
handles.guiOptions.face.isHid = zeros(1, nregions);


%% MD Check

%try%allow user to set cell detection preferences
    %handles=ct_guiOptionsFacePreferences(handles,nregions);
    handles.guiOptions.face.thresh = handles.app.preferences.CutoffVal*ones(1, nregions);
    handles.guiOptions.face.minArea = handles.app.preferences.MinAreaVal*ones(1, nregions);
    handles.guiOptions.face.maxArea = repmat(handles.app.preferences.MaxAreaVal,1, nregions);
    handles.guiOptions.face.piLimit = handles.app.preferences.PiLimitVal*ones(1, nregions);
%end
%%

% Now we switch the GUI from regions to filtering.
handles = hide_uigroup(handles, 'regions');
% Keep the region widget on for a little longer.
show_axis(handles.uigroup{lidx}.regax);
handles = show_uigroup(handles, 'filterimage');
handles = show_uigroup(handles, 'filterimagebadpixels');

% Load the various image filters from the directory.
[st, filter_names] = readdir(handles, 'imagefilters');
handles.app.data.filterNames = filter_names;
handles = uiset(handles, 'filterimage', 'dpfilters', 'String', st);


% Check to see if preferences were set for columns and rows, then update.
if handles.app.preferences.Lcol || handles.app.preferences.Rcol || handles.app.preferences.Urow || handles.app.preferences.Lrow ~= 0;
    lidx = get_label_idx(handles, 'filterimagebadpixels');   
    if handles.app.preferences.Lcol ~=0;
        handles = show_save_bad_pixels(handles.uigroup{lidx}.leftcols,handles);
    end
    if handles.app.preferences.Rcol ~=0;
        handles = show_save_bad_pixels(handles.uigroup{lidx}.rightcols,handles);
    end
    if handles.app.preferences.Urow ~=0;
        handles = show_save_bad_pixels(handles.uigroup{lidx}.upperrows,handles);
    end
    if handles.app.preferences.Lrow ~=0;
        handles = show_save_bad_pixels(handles.uigroup{lidx}.lowerrows,handles);
    end   
end
guidata(hObject, handles);

% Check if a auto-filter preference is on or if image is part of split,if it is, show bad pixels and filter.
if handles.app.preferences.FilterOnly == 1||handles.app.info.issplit == 1 
   uiset(handles, 'filterimage', 'dpfilters', 'value',handles.app.preferences.Filter);
  caltracer2('ct_filter_callback',hObject, handles);
end



function show_save_bad_pixels_callback(hObject, handles);
% This is called when the values inside the Remove for filtering options
% are changed.
handles = show_save_bad_pixels(hObject,handles);
guidata(hObject, handles);


function ct_filter_callback(hObject, handles)
% This is called when the "Filter" button is hit.


maskidx = handles.app.data.currentMaskIdx;
lidx = get_label_idx(handles, 'filterimagebadpixels');      

% First delete the values from the Remove for filtering section
imsz = size(handles.app.experiment.Image(maskidx).image);

% Left Columns
value = str2num(get(handles.uigroup{lidx}.leftcols,'String'));
startval = 1;
stopval = value;
if value == 0;
    handles.app.experiment.Image(maskidx).badpixels.leftcols = [];
else            
    handles.app.experiment.Image(maskidx).badpixels.leftcols = [startval:stopval];
end

% Right Columns
value = str2num(get(handles.uigroup{lidx}.rightcols,'String'));
startval = (imsz(2)-value)+1;
stopval = imsz(2);
if value == 0;
    handles.app.experiment.Image(maskidx).badpixels.rightcols = [];
else            
    handles.app.experiment.Image(maskidx).badpixels.rightcols = [startval:stopval];
end

% Upper Rows
value = str2num(get(handles.uigroup{lidx}.upperrows,'String'));
startval = 1;
stopval = value;
if value == 0;
    handles.app.experiment.Image(maskidx).badpixels.upperrows = [];
else            
    handles.app.experiment.Image(maskidx).badpixels.upperrows = [startval:stopval];
end

% Lower Rows
value = str2num(get(handles.uigroup{lidx}.lowerrows,'String'));
startval = (imsz(1)-value)+1;
stopval = imsz(1);
if value == 0;
    handles.app.experiment.Image(maskidx).badpixels.lowerrows = [];
else            
    handles.app.experiment.Image(maskidx).badpixels.lowerrows = [startval:stopval];
end


% Remove excess figure handle information from view.
if isfield (handles.app.experiment.Image(maskidx).badpixels,'leftbox')
    if ~isempty(handles.app.experiment.Image(maskidx).badpixels.leftbox);
        delete (handles.app.experiment.Image(maskidx).badpixels.leftbox)
    end
end
if isfield (handles.app.experiment.Image(maskidx).badpixels,'rightbox')
    if ~isempty(handles.app.experiment.Image(maskidx).badpixels.rightbox);
        delete (handles.app.experiment.Image(maskidx).badpixels.rightbox)
    end
end
if isfield (handles.app.experiment.Image(maskidx).badpixels,'upperbox')
    if ~isempty(handles.app.experiment.Image(maskidx).badpixels.upperbox);
        delete (handles.app.experiment.Image(maskidx).badpixels.upperbox)
    end
end
if isfield (handles.app.experiment.Image(maskidx).badpixels,'lowerbox')
    if ~isempty(handles.app.experiment.Image(maskidx).badpixels.lowerbox);
        delete (handles.app.experiment.Image(maskidx).badpixels.lowerbox)
    end
end

% Actually delete the boxes created for user (necessary if filtering is done a number of times).
handles.app.experiment.Image(maskidx).badpixels.leftbox = [];
handles.app.experiment.Image(maskidx).badpixels.rightbox = [];
handles.app.experiment.Image(maskidx).badpixels.upperbox = [];
handles.app.experiment.Image(maskidx).badpixels.lowerbox = [];

% This part is the actual filtering.
handles = ct_filter(handles);

% If the cancel button was pressed or something went wrong.  Sort
% of ghetto but gets the job done.
if ~isfield(handles.app.experiment.Image(maskidx), 'filteredImage');
    return;
end

handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);

if handles.app.preferences.autoLoadContours == 1;
    load_contours_callback(hObject,handles)
end




function handles = sync_detectcell_buttons(handles,varargin)
% This is called by the Filter Callback and by the Consolidate maps gui
% (when the minimaps on the right are clicked on).

% This function loads the correct regions settings in the buttons and enables the next gui.
ridx = handles.app.data.currentRegionIdx;
region = handles.app.experiment.regions;
face = handles.guiOptions.face;
if strcmp(uiget(handles, 'filterimage', 'det_view','enable'),'off')
    handles = uiset(handles, 'filterimage', 'det_view', 'enable', 'on');
    handles = show_uigroup(handles, 'detectcells');
end
if strcmp(uiget(handles, 'filterimagebadpixels', 'leftcolslabel','visible'),'on')
    handles = hide_uigroup(handles,'filterimagebadpixels');
end

handles = uiset(handles, 'detectcells', 'txlab', ...
		'BackgroundColor',region.cl(ridx,:), ...
		'String', region.name{ridx});
handles = uiset(handles, 'detectcells', 'txthres', ...
		'String', num2str(face.thresh(ridx)));
handles = uiset(handles, 'detectcells', 'txarlow', ...
		'String', num2str(face.minArea(ridx)));
handles = uiset(handles, 'detectcells', 'txarhigh', ...
		'String', num2str(face.maxArea(ridx)));
handles = uiset(handles, 'detectcells', 'txpilim', ...
		'String', num2str(face.piLimit(ridx)));


if (handles.guiOptions.face.isHid(ridx))
    str = 'Show';
else
    str = 'Hide';
end
handles = uiset(handles, 'detectcells', 'bthide', 'String', str);

% If the image was a result of splitting, do not auto-detect contours.
% If detect is hit, it will overwrite saved ones from split.

if handles.app.info.issplit ==1
    handles = draw_cell_contours(handles, 'ridx', 'all');
end
if handles.app.preferences.AutoDetect==1 && nargin<2
    if handles.app.info.issplit == 0 
        handles = detect_cells_callback (gcbo, handles);
    end
end


function view_filtered_image(hObject, handles)
% This is called when the view button is pressed.  This is only enabled
% after the filter is run.

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;
indicator = 0;
if isfield(handles.app.data,'mainImageSource');
   if strcmp(handles.app.data.mainImageSource,'filtered')    
       indicator = 1;
   end
end
if indicator == 1;
   set(handles.app.data.mainImage,'CData',handles.app.experiment.Image(maskidx).image)
   handles.app.data.mainImageSource = 'original';
elseif indicator == 0;
   set(handles.app.data.mainImage,'CData',handles.app.experiment.Image(maskidx).filteredImage)
   handles.app.data.mainImageSource = 'filtered';
end
guidata(hObject, handles);




function handles = detect_cells_callback(hObject, handles)
% This is called when the "Detect" button is hit in the detect cells gui.

handles = save_detectcell_widget_values(handles);
handles = detect_cells(handles);
handles = draw_cell_contours(handles);
if handles.app.info.error == 1
    handles.app.info.error = 0;
    return;
end

% Allow export of contours
handles = menuset(handles, 'Contours','contours','Randomize contour order','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep only brightest contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep random contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours & randomize order','Enable','on');
handles = menuset(handles, 'Export', 'export', 'Export contours', 'Enable', 'on');
handles = menuset(handles, 'Export', 'export', 'Export contours to file', 'Enable', 'on');
if handles.app.preferences.AutoFind==1
    handles = find_bad_cells_callback (gcbo, handles);
end
guidata(hObject,handles);

function bthide_callback(hObject, handles)
% This is called when the Hide button is hit in the cell detection gui.
handles = hide_region_contours(handles);
guidata(hObject, handles);


function handles = find_bad_cells_callback(hObject, handles)
% This is called when "Find" is hit in the cell detection window.
% Calls find_bad_cells which uses the pi info to detect how close to a
% circle the cells are and emphasizes the ones which are not.
handles = find_bad_cells(handles);
guidata(hObject, handles);

if handles.app.preferences.AutoAdjust==1
   handles = adjust_contours_callback (gcbo, handles);
end

function handles =  adjust_contours_callback(hObject, handles)
% This is called when "Adjust" is hit in the cell detection window.

% Update numbers from input boxes
handles = save_detectcell_widget_values(handles);
% Adjust the contours.
handles = adjust_contours_towards_pi(handles);
% Draw updated contours
handles = draw_cell_contours(handles);
guidata(hObject, handles);



function delete_high_pi_contours_callback(hObject, handles);
handles=delete_high_pi_contours(handles);
guidata(hObject,handles);



function handles = save_detectcell_widget_values(handles)
% This is called by the detect cells callback as well as the adjust contours callback, 
% both from the detect cells gui.
% This sets the values for cell detection based on the values in the widgets.
ridx = handles.app.data.currentRegionIdx;
thresh = str2num(uiget(handles, 'detectcells', 'txthres', 'String'));
min_area = str2num(uiget(handles, 'detectcells', 'txarlow', 'String'));
max_area = str2num(uiget(handles, 'detectcells', 'txarhigh', 'String'));
pi_lim = str2num(uiget(handles, 'detectcells', 'txpilim', 'String'));
handles.guiOptions.face.thresh(ridx) = thresh;
handles.guiOptions.face.minArea(ridx) = min_area;
handles.guiOptions.face.maxArea(ridx) = max_area;
handles.guiOptions.face.piLimit(ridx) = pi_lim;


function handles = hide_region_contours(handles)
% This function hides/shows the current region contours from view (does not
% delete them).
% This is called by the bthide callback (the hide button in the cell
% detection window).

ridx = handles.app.data.currentRegionIdx;
maskidx = handles.app.data.currentMaskIdx;

if handles.guiOptions.face.isHid(ridx) == 0
    handles = uiset(handles, 'detectcells', 'bthide', 'string', 'Show');
    set(handles.guiOptions.face.handl{ridx}{maskidx}, 'visible', 'off');
    handles.guiOptions.face.isHid(ridx) = 1;
else
    handles = uiset(handles, 'detectcells', 'bthide', 'string', 'Hide');
    set(handles.guiOptions.face.handl{ridx}{maskidx}, 'visible', 'on');   
    handles.guiOptions.face.isHid(ridx) = 0;
end



function move_all_contours_callback(hObject,handles)
% This is called by the "Move All" button in the cell detection window.
% Lets the user click twice, once for initial and once for new position.

%First, disable options to redraw the contours until movement has completed
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

% Let the user select two points and find the amount to move in x and y.
[x,y] = ginput(2);
x = x(2)-x(1);
y = y(2)-y(1);

maskidx = handles.app.data.currentMaskIdx;
% Call the move all contours function, then redraw contours and regions.
handles = move_all_contours(handles,x,y,maskidx);
handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);

% Reenable options.
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);



function rotate_all_contours_callback(hObject,handles)
% This is called by the "Rotate All" button in the cell detection window.
% Lets the user click twice, once for initial and once for new position.
% This assumes that rotation occurs around the center point in the image.

% First, disable options to redraw the contours until movement has completed
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

% Find the center.
fulcrum = size(handles.app.experiment.Image(1).image);
fulcrum = (fulcrum * .5) + .5;

% Let the user input designate how far to rotate about the fulcrum.
[x,y] = ginput(2);
x1 = x(1) - fulcrum(1);
x2 = x(2) - fulcrum(1);
y1 = y(1) - fulcrum(2);
y2 = y(2) - fulcrum(2);

ang1 = atan2(y1,x1);
ang2 = atan2(y2,x2);
diffang = ang2 - ang1;

maskidx = handles.app.data.currentMaskIdx;
% Call the rotate all contours function, then redraw contours and regions.
handles = rotate_all_contours(handles,diffang,fulcrum,maskidx);
handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);

% Reenable options.
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);



function move_one_contour_callback(hObject,handles)
% This is called by the "Move One" button in the cell detection window.
% Lets the user click twice, once for initial and once for new position.

% First, disable options to redraw the contours until movement has completed
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

% Let the user select two points and find the amount to move in x and y.
[ox,oy] = ginput(2);
x = ox(2)-ox(1);
y = oy(2)-oy(1);

maskidx = handles.app.data.currentMaskIdx;
[contouridx,ridx] = determine_cell_clicked(handles,maskidx,1:handles.app.experiment.numRegions,ox(1),oy(1));

% In case a user does not click on a cell.
if length(contouridx) > 1 | isempty(contouridx);
    msgbox('You must click inside one cell');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return
end

% Call the move one contour function, then redraw contours and regions.
handles = move_one_contour(handles,x,y,ridx,contouridx,maskidx);
handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);

% Reenable options.
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);


function detectcells_shaperad1_callback(hObject, handles)
% This is called when the "Circle" Radio button is activated in the cell
% detection gui.  This Deactivates "Custom"
handles = uiset(handles, 'detectcells', 'shaperad1', 'value', 1);
handles = uiset(handles, 'detectcells', 'shaperad2', 'value', 0);
handles = uiset(handles, 'detectcells', 'shaperad3', 'value', 0);
guidata(hObject, handles);


function detectcells_shaperad2_callback(hObject, handles)
% This is called when the "Custom" Radio button is activated in the cell
% detection gui.  This Deactivates "Circle"
handles = uiset(handles, 'detectcells', 'shaperad1', 'value', 0);
handles = uiset(handles, 'detectcells', 'shaperad2', 'value', 1);
handles = uiset(handles, 'detectcells', 'shaperad3', 'value', 0);
guidata(hObject, handles);

function detectcells_shaperad3_callback(hObject, handles)
% This is called when the "Custom" Radio button is activated in the cell
% detection gui.  This Deactivates "Circle"
handles = uiset(handles, 'detectcells', 'shaperad1', 'value', 0);
handles = uiset(handles, 'detectcells', 'shaperad2', 'value', 0);
handles = uiset(handles, 'detectcells', 'shaperad3', 'value', 1);
guidata(hObject, handles);

function manual_contour_add_callback(hObject, handles)
% Called when the Add button is hit in the cell detection gui 
%and the consolidate maps gui.

%Disable numerous features within cell detection gui.
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');
handles = uiset(handles,'detectcells','btdelete','value',0);
handles = uiset(handles,'detectcells','btadd','value',1);
%enable add/delete mode text to appear
handles=uiset(handles,'detectcells','adddeletetext','ForegroundColor',[1 0 0],'enable','on');
% Make that the correct image is selected (not the miniregion widget).
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
% Call the function.
handles = manual_contour_add(handles);
% Enable numerous features within cell detection gui.
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
handles=uiset(handles,'detectcells','adddeletetext','ForegroundColor',[.8 .8 .8]);
guidata(hObject, handles);

   
function manual_contour_delete_callback(hObject, handles)
% Called when "Delete" button is hit in cell detection gui.
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');
handles = uiset(handles,'detectcells','btdelete','value',1);
handles = uiset(handles,'detectcells','btadd','value',0);
handles=uiset(handles,'detectcells','adddeletetext','ForegroundColor',[1 0 0],'enable','on');
% Make that the correct image is selected (not the miniregion widget).
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
% Call the function.
handles = manual_contour_delete(handles);
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
handles=uiset(handles,'detectcells','adddeletetext','ForegroundColor',[.8 .8 .8]);
guidata(hObject, handles);


function edit_contour_callback(hObject, handles)
% Called when "Edit" button is hit in cell detection gui.
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');
% Call the function.
handles = edit_contour(handles,hObject);
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);


function load_contours_callback(hObject, handles)
% This is called when "Load" is hit in the Cell Detection gui.
[hObject, handles] = load_contours(hObject,handles);
guidata(hObject, handles);



%% MD - Do we need a reset button???
%function reset_detect_screen_callback(hObject, handles)
%turn off ginput
%interrupt all functions
%handles = uiset(handles,'detectcells','all','enable','on');



function detect_cells_next_callback(hObject, handles)
% This function is called when "Next" is hit in the Cell Detection Gui.

%First, we turn off toolbar options relating to changing contour number after contours have been finalized
handles = menuset(handles, 'Contours','contours','Randomize contour order','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep only brightest contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep random contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep last contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep last contours & randomize order','Enable','off');
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file', 'Enable', 'on');  
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than once)', 'Enable', 'on'); 
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than one pulse per target)', 'Enable', 'on');

% Then, we check if any masks are to be added (if not in the preferences
% file we ask the question in a dialog box).
if handles.app.preferences.MaskQuest.index > 0;
    button_name = handles.app.preferences.MaskQuest.Options;
    % If no masks are added or if the image comes from a split.
    if handles.app.preferences.NumMaskVal == 0 || handles.app.info.issplit ==1
        button_name = 'No';
        handles.app.preferences.KeepPrevPref = 0;
    else 
        handles.app.preferences.NumMaskVal = handles.app.preferences.NumMaskVal -1;
        handles.app.preferences.KeepPrevPref = 1;
    end
else
    button_name=questdlg('Would you like to load a mask, such as a sulfarhodamine or GFP labelled interneuron mask?', ...
        'Load mask', ...
        'Yes','No', 'Yes');
end


switch button_name
    %If "Yes" is selected, we add the new mask.
   case 'Yes'
      % Create a mask name.
      prompt={'Enter the name for the new mask:'};
      nummasks=size(handles.app.experiment.Image,2);
      %%%
      def = {['new',num2str(nummasks)]};
      dlgTitle='Mask title';
      lineNo=1;
      answer=inputdlg(prompt,dlgTitle,lineNo,def);
      if isempty(answer)
          errordlg('You must enter a valid name');
          return;
      end

      % Create a new mask index.
      handles = set_new_mask_idx(handles, answer{1});
      % Quick check to see if the number of masks was already defined in
      % the handles, if not it is added (1 mask by default).
      if (~isfield(handles.app.experiment, 'numMasks'))
        handles.app.experiment.numMasks = 1;
      end
      handles.app.experiment.numMasks = handles.app.experiment.numMasks + 1;
      handles.app.data.currentMaskIdx = get_mask_idx(handles,answer{1});
      % Increase the size of the handle cell array.
      nregions = handles.app.experiment.numRegions;
      for r = 1:nregions
          handles.app.experiment.regions.contours{r}{end+1} = [];
          handles.guiOptions.face.handl{r}{end+1} = [];
      end
      guidata(hObject, handles);
      % Determine the detectcells uigroup.
      handles = uiset(handles, 'filterimage', 'det_view', 'enable', 'off');
      handles = hide_uigroup(handles, 'detectcells');
      handles = show_uigroup(handles, 'filterimagebadpixels');
      handles = delete_contour_handles(handles, 'ridx', 'all', 'maskidx', handles.app.data.currentMaskIdx-1);
      open_image_callback(hObject, handles);
    case 'No'
      handles = delete_contour_handles(handles, 'ridx', 'all', 'maskidx', handles.app.data.currentMaskIdx);
      drawnow;
      
    
      %% MD moved from setup_consolidate_maps (not necessary to call that
      %% function if no masks are added?
      % Since there are no masks, and no overlap, define some default handles and
      % move on to the halo screen.
      if ~isfield(handles.app.experiment, 'numMasks')
        handles.app.experiment.numMasks = length(handles.app.experiment.Image);
        nregions = handles.app.experiment.numRegions;
        handles.app.experiment.contourMaskIdx={};
        for ridx = 1:nregions;
            numcontours=length(handles.app.experiment.regions.contours{ridx}{1});
            handles.app.experiment.contourMaskIdx{ridx}=ones(1,numcontours); 
        end
        handles = setup_halos(handles);
      else
          if handles.app.experiment.numMasks ==1
          handles = setup_halos(handles);
          else
          handles = setup_consolidate_maps(handles);
          end
      end
      guidata(hObject, handles);
    otherwise%ie if question box is closed and not answered
        return
end





%% Consolidate Maps Gui
function handles = setup_consolidate_maps(handles)
% This function is called by the detect cells next callback after the
% completion of mask questions and file loading.

% This function displays a combination of contour maps based
% upon the mask selections and the original images.

handles.app.experiment.numMasks = length(handles.app.experiment.Image);
nmaps = handles.app.experiment.numMasks;
nregions = handles.app.experiment.numRegions;



% For each region set up a system to track contour overlap.
handles.app.experiment.contourMaskIdx={};
for ridx = 1:nregions;
    numcontours=length(handles.app.experiment.regions.contours{ridx}{1});
    handles.app.experiment.contourMaskIdx{ridx}=ones(1,numcontours);%default for which mask the 
%         movie contours overlapped with
    for maskidx = 1:nmaps;
        numcontours = length(handles.app.experiment.regions.contours{ridx}{maskidx});
        handles.app.experiment.overlapsInfo{ridx}{maskidx} = zeros(numcontours, 2);
    end
end

% Change the gui groups shown.
lidx = get_label_idx(handles, 'consolidatemaps');
handles = hide_uigroup(handles, 'detectcells');
handles = hide_uigroup(handles, 'filterimage');
handles = hide_uigroup(handles, 'regions');
handles = show_uigroup(handles, 'consolidatemaps');

% Draw the multiple small region widgets on the right.
button_down_fnc = 'caltracer2(''consolidate_smmap_buttondown_callback'',gcbo,guidata(gcbo))'; 
mapcl = hsv(nmaps);
for i = 1:nmaps   
    handles.uigroup{lidx}.mapax(i) = ...
	axes('position',[0.87 0.60-(i-1)*0.15 0.11 0.10]);
    draw_region_widget(handles, ...
		       'axes', handles.uigroup{lidx}.mapax(i), ...
		       'maskidx', i, ...
		       'dotitle', 1, ...
		       'mapcolor', mapcl(i,:),...
		       'buttondownfnc', button_down_fnc);
    
end

% Draw an average of all the zstacks in the main image axis. Could use
% display_zstack_image to do this, with proper modifications. -DCS:2005/04/05

I = zeros(handles.app.experiment.Image(1).nY, handles.app.experiment.Image(1).nX);
I3 = zeros(handles.app.experiment.Image(1).nY, handles.app.experiment.Image(1).nX,3);
avg_title = [];
for i = 1:nmaps%get z-scored images
    m = mean2(handles.app.experiment.Image(i).filteredImage);
    s = std2(handles.app.experiment.Image(i).filteredImage);
    if (i < 4)
        I3(:,:,i) = (handles.app.experiment.Image(i).filteredImage-m)/s;
    end
    avg_title = [avg_title ' + ' handles.app.experiment.Image(i).title];
end
mostmin = min(min(min(I3)));
for i = 1:nmaps
    I3(:,:,i) = I3(:,:,i) - mostmin;			% min to 0.
end
m2 = mean2(I3(:,:,1:nmaps));
s2 = std2(I3(:,:,1:nmaps));
I3 = I3/(m2 + 2*s2);
for cidx = 1:size(I3,3);%normalize each color plane...
    thisplane = I3(:,:,cidx);
    thisplane =  thisplane - min(thisplane(:));
    I3(:,:,cidx) = thisplane / max(thisplane(:));
end
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
set(handles.app.data.mainImage,'CData',I3);
title(texlabel(avg_title, 'literal'));
% Put the region border in front.
if ~isempty(handles.app.experiment.regions.bhand)
    c = get(handles.uigroup{lidx}.imgax, 'Children');    
    cch = find(strcmpi(get(c, 'Tag'), 'cellcontour'));
    delete(c(cch));
    %%% Delete the handles from the array. -DCS:2005/04/04
    c = get(handles.uigroup{lidx}.imgax, 'Children');
    ctag = get(c, 'Tag');
    rbh_idx = find(strcmpi(ctag, 'regionborder'));
    not_rbh_idx = find(~strcmpi(ctag, 'regionborder')); 
    newc = [c(rbh_idx); c(not_rbh_idx)];
    set(handles.uigroup{lidx}.imgax, 'Children', newc);
end

% Else we enter an optional phase of the GUI where the user decides
% how to consolidate the various contours we've found from the
% different regions of each time collapsed image.

% First draw all the maps on the side, for selection.
mapcolors = hsv(nmaps);


% Draw all the contours for the user to see.
for r = 1:nregions
    handles.app.data.currentRegionIdx = r;
    for m = 1:nmaps
	handles.app.data.currentMaskIdx = m;
	handles = draw_cell_contours(handles, ...
				     'ridx', r, ...
				     'maskidx', m, ...
				     'color', mapcolors(m,:), ...
				     'savehandles', 1);
    end
end
handles.app.experiment.masks.cl = mapcolors;



function consolidate_smmap_buttondown_callback(hObject, handles)
% This is called when the small maps on the right side of the consolidate
% maps gui are clicked.

user_data = get(hObject, 'UserData')
ridx = user_data(1);
maskidx = user_data(2);
handles.app.data.currentRegionIdx = ridx;
handles.app.data.currentMaskIdx = maskidx;
handles = hide_region_contours(handles);
% Get the new region index.
handles = sync_detectcell_buttons(handles,1);
guidata(hObject, handles);


function classifyoverlap_callback(hObject, handles)
% This is called when the "Classify Overlap" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'classifyoverlap', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'eliminateoverlap', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'eliminaterest', 'value', 0);
guidata(hObject, handles);


function eliminateoverlap_callback(hObject, handles)
% This is called when the "Eliminate Overlap" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'classifyoverlap', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'eliminateoverlap', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'eliminaterest', 'value', 0);
guidata(hObject, handles);


function eliminaterest_callback(hObject, handles)
% This is called when the "Eliminate Rest" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'classifyoverlap', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'eliminateoverlap', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'eliminaterest', 'value', 1);
guidata(hObject, handles);


function find_overlap_callback(hObject, handles)
% This is called when the "Find" Button is hit in the consolidate maps gui.
% If the "Eliminate Rest" radio is selected, then find non-overlapping
% contours, otherwise find overlapping contours.
notoverlap = uiget(handles, 'consolidatemaps', 'eliminaterest', 'value');
handles = find_overlap(handles,notoverlap);
guidata(hObject, handles);


function adjust_overlap_callback(hObject, handles)
% This is called when the "Adjust" Button is hit in the consolidate maps gui.
% If the "Eliminate Overlap" radio is selected then eliminate overlapping contours.
% If the "Eliminate Rest" radio is selected then eliminate all non-overlappins contours.
handles = adjust_overlap(handles);
colors = handles.app.experiment.masks.cl;
%m=1;
for r = 1:handles.app.experiment.numRegions
     for m = 1:handles.app.experiment.numMasks
        handles = draw_cell_contours(handles, 'ridx', r, 'maskidx', m, ...
            'color', colors(m,:));
     end
end
guidata(hObject, handles);


function move_all_contours2_callback(hObject,handles)
% This function is called when the "Move All" button is hit in the
% consolidate maps gui.
% Allows the user to click twice, once for initial and once for new
% position.

handles = uiset(handles,'consolidatemaps','btfindbad','enable','off');
handles = uiset(handles,'consolidatemaps','btadjust','enable','off');
handles = uiset(handles,'consolidatemaps','rotateall','enable','off');
[x,y] = ginput(2);
x = x(2)-x(1);
y = y(2)-y(1);
maskidx = handles.app.data.currentMaskIdx;
handles = move_all_contours(handles,x,y,maskidx);
nmaps = length(handles.app.experiment.Image);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx','all', ...
			     'color', mapcolors(maskidx,:));

handles = uiset(handles,'consolidatemaps','btfindbad','enable','on');
handles = uiset(handles,'consolidatemaps','btadjust','enable','on');
handles = uiset(handles,'consolidatemaps','rotateall','enable','on');
guidata(hObject, handles);


function rotate_all_contours2_callback(hObject,handles)
% This function is called when the "Move All" button is hit in the
% consolidate maps gui.
% Allows the user to click twice, once for initial and once for new
% position.

handles = uiset(handles,'consolidatemaps','btfindbad','enable','off');
handles = uiset(handles,'consolidatemaps','btadjust','enable','off');
handles = uiset(handles,'consolidatemaps','rotateall','enable','off');

fulcrum = size(handles.app.experiment.Image(1).image);
fulcrum = (fulcrum * .5) + .5;
[x,y] = ginput(2);
x1 = x(1) - fulcrum(1);
x2 = x(2) - fulcrum(1);
y1 = y(1) - fulcrum(2);
y2 = y(2) - fulcrum(2);
maskidx = handles.app.data.currentMaskIdx;
ang1 = atan2(y1,x1);
ang2 = atan2(y2,x2);
diffang = ang2 - ang1;
handles = rotate_all_contours(handles,diffang,fulcrum,maskidx);
nmaps = length(handles.app.experiment.Image);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx','all', ...
			     'color', mapcolors(maskidx,:));
handles = uiset(handles,'consolidatemaps','btfindbad','enable','on');
handles = uiset(handles,'consolidatemaps','btadjust','enable','on');
handles = uiset(handles,'consolidatemaps','rotateall','enable','on');
guidata(hObject, handles);


function consolidatemaps_shaperad1_callback(hObject, handles)
% This is the callback when the "circle" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'shaperad1', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'shaperad2', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'shaperad3', 'value', 0);
guidata(hObject, handles);

function consolidatemaps_shaperad2_callback(hObject, handles)
% This is the callback when the "custom" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'shaperad1', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'shaperad2', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'shaperad3', 'value', 0);
guidata(hObject, handles);

function consolidatemaps_shaperad3_callback(hObject, handles)
% This is the callback when the "custom" radio button is hit in the
% consolidate maps gui.
handles = uiset(handles, 'consolidatemaps', 'shaperad1', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'shaperad2', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'shaperad3', 'value', 1);
guidata(hObject, handles);

function mask_split_callback (hObject,handles)
% This is the callback for the "Split" button in the consolidate maps gui.
% This function splits the two masks into two instances of caltracer.

% First we duplicate the handles.
handlestosplit = handles;

% Set both as split.
handlestosplit.app.info.issplit = 1;
handles.app.info.issplit = 1;

if handlestosplit.app.experiment.numMasks>2
    errordlg ('Splitting currently only works with a single mask')
    return;
end


% Next we delete the original information from the handles to be split.
handlestosplit.app.experiment.Image = handlestosplit.app.experiment.Image(1,2);
handlestosplit.app.data.maskLabels = handlestosplit.app.data.maskLabels (1,1);
handlestosplit.app.data.currentMaskIdx = get_mask_idx(handlestosplit,handlestosplit.app.data.maskLabels{1});
% Decrease the size of the handle cell array.
      nregions = handlestosplit.app.experiment.numRegions;
      for r = 1:nregions
         Temp1= handlestosplit.app.experiment.regions.contours{r}{end};
         handlestosplit.app.experiment.regions=...
             rmfield (handlestosplit.app.experiment.regions, 'contours');
         handlestosplit.app.experiment.regions.contours{r}{1} = Temp1;
         
         Temp2 = handlestosplit.guiOptions.face.handl{r}{end};
         handlestosplit.guiOptions.face = ...
             rmfield(handlestosplit.guiOptions.face,'handl');
         handlestosplit.guiOptions.face.handl{r}{1} = Temp2;
      end
handlestosplit.app.experiment = rmfield(handlestosplit.app.experiment, 'numMasks');
      
      
% Now we delete the information split from our original handles.
handles.app.experiment.Image = handles.app.experiment.Image(1,1);
handles.app.data.maskLabels = handles.app.data.maskLabels (1,1);
handles.app.data.currentMaskIdx = get_mask_idx(handles,handles.app.data.maskLabels{1});
% Decrease the size of the handle cell array.
      nregions = handles.app.experiment.numRegions;
      for r = 1:nregions
         Temp1= handles.app.experiment.regions.contours{r}{1};
         handles.app.experiment.regions=...
             rmfield (handles.app.experiment.regions, 'contours');
         handles.app.experiment.regions.contours{r}{1} = Temp1;
         
         Temp2 = handles.guiOptions.face.handl{r}{1};
         handles.guiOptions.face = ...
             rmfield(handles.guiOptions.face,'handl');
         handles.guiOptions.face.handl{r}{1} = Temp2;
      end
handles.app.experiment = rmfield(handles.app.experiment, 'numMasks');

% Here we return to the cell detection gui with our current contours.

% Prepare the file to be sent to the new instance of Caltracer.

% Now we call a new caltracer instance with the split handles.
caltracer2(handlestosplit);
caltracer2(handles);
delete (handles.fig);

function setup_halos_callback(hObject, handles)
% This is the callback when "No" radio button is hit in the
% Mask Question.
handles = setup_halos(handles);
guidata(hObject, handles);


function handles = setup_halos(handles)
% This function sets up the Halos gui and initializes some variables.  

% Copy the GUI parameters into the experiment now that we are done changing them.
handles.app.experiment.regions.cutoff = handles.guiOptions.face.thresh;
minArea = handles.guiOptions.face.minArea;
handles.app.experiment.regions.minArea = minArea;
maxArea = handles.guiOptions.face.maxArea;
handles.app.experiment.regions.minArea = minArea;
handles.app.experiment.regions.maxArea = maxArea;
handles.app.experiment.regions.isDetected = handles.guiOptions.face.isDetected;
handles.app.experiment.regions.piLimit = handles.guiOptions.face.piLimit;
handles.app.experiment.regions.isAdjusted = handles.guiOptions.face.isAdjusted;
cn = handles.app.experiment.regions.contours;
nregions = handles.app.experiment.numRegions;
nmaps = handles.app.experiment.numMasks;
contours = {};
centroids = {};
areas = {};
cridx = [];
cmaskidx = [];

% Once this button is hit, we recompute everything from the contour
% because the previous actions (adjusting pi / adding deleting
% cells all only modify the contours.  So every other structure
% might be out of sync.
for r = 1:nregions
    cmaskidx = [cmaskidx handles.app.experiment.contourMaskIdx{r}];
    for m = 1:nmaps			% -DCS:2005/08/04
        for c = 1:length(cn{r}{m})
            %centroids{end+1} = centr{c}(d,:);BW
            areas{end+1} = polyarea(cn{r}{m}{c}(:,1), cn{r}{m}{c}(:,2));
            cridx = [cridx r];
            if m==1;%only for first region -BW
                contours{length(contours)+1} = cn{r}{m}{c};%keep each contour from each region
                centroids{end+1} = create_centroid(cn{r}{m}{c});
            end
        end
    end
end
handles.app.experiment.centroids = centroids;	% not indexed by region anymore.
handles.app.experiment.contourLines = contours;	% not indexed by region anymore.
handles.app.experiment.areas = areas;
handles.app.experiment.contourRegionIdx = cridx;	% an index into regions.
handles.app.experiment.contourMaskIdx = cmaskidx;	% an index into Image... now a vector

% Now we are done with many uigroups, so hide them.
handles = hide_uigroup(handles, 'regions');
handles = hide_uigroup(handles, 'filterimage');
handles = hide_uigroup(handles, 'detectcells');
if handles.app.info.issplit == 0; %if not part of split.
    handles = hide_uigroup(handles, 'consolidatemaps');
end
handles = show_uigroup(handles, 'halos');

% This is a bit of a hack because one cannot turn 'visible' to
% 'off' for an axes.
lidx = get_label_idx(handles, 'regions');
hide_axis(handles.uigroup{lidx}.regax);


% Redraw the contours because the colors might not be in region
% mode, which is what we want.
handles = draw_movie_cell_contours(handles);


%%% Initialize some new varaibles. 
handles.app.data.haloHands = [];
handles.app.data.haloBorderHands = [];
handles.app.data.halos = {};
handles.app.data.haloBorders = {};

% Read the tracereaders directory and fill in the pulldown menu.
[st, tracereader_names] = readdir(handles, 'tracereaders');
handles.app.data.traceReaderNames = tracereader_names;
handles = uiset(handles, 'halos', 'dpreaders', 'String', st);
% Set the default halo area to the value defined in preferences.
handles = uiset(handles, 'halos', 'inpthaloar', ...
		'String', handles.app.preferences.Halo_Area);


% Check if a auto-halo preference is on.     
if (handles.app.preferences.AutoHalo == 1)
     handles = setup_signals_callback (gcbo,handles);
end

function halo_check_callback(hObject, handles)
% This function is called when the checkbox is hit in the halo gui

if (uiget(handles, 'halos', 'halo_check', 'value') == 0)
    % if the checkbox is unchecked delete halo handles and disable
    % updating.
    if (~isempty(handles.app.data.haloHands))
        delete(handles.app.data.haloHands);
    end
    if (~isempty(handles.app.data.haloBorderHands))
        delete(handles.app.data.haloBorderHands);
    end
    handles.app.data.haloHands = [];
    handles.app.data.haloBorderHands = [];
    handles.app.data.halos = {};
    handles.app.preferences.haloMode = 0;
    handles = uiset(handles, 'halos', 'inpthaloar', 'enable','off');
    handles = uiset(handles, 'halos', 'btupdate', 'enable','off');
else
    % if checkbox is checked, enable halo update.
    handles.app.preferences.haloMode = 1;
    handles = uiset(handles, 'halos', 'btupdate','enable','on');
    handles = uiset(handles, 'halos', 'inpthaloar','enable','on');
    
end
guidata(hObject, handles);


function halo_update_callback(hObject, handles)
% This function is called when the "Update" button is hit in the halo gui.

% First, delete previous halo data.
if isfield(handles.app.data,'haloHands')
    if (~isempty(handles.app.data.haloHands))
        delete(handles.app.data.haloHands);
        delete(handles.app.data.haloBorderHands);
    end
end

% Pull some variables out of handles.
regions = handles.app.experiment.regions;
nregions = handles.app.experiment.numRegions;
maskidx = handles.app.data.currentMaskIdx;
nx = handles.app.experiment.Image(maskidx).nX;
ny = handles.app.experiment.Image(maskidx).nY;

% Initialize some values.
handles.app.data.haloHands = [];
handles.app.data.halos = cell(1,length(handles.app.experiment.contourLines));
regions.haloArea = str2num(uiget(handles, 'halos','inpthaloar','string'));
cridx = handles.app.experiment.contourRegionIdx;
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);

% For the number of countours
for c = 1:length(handles.app.experiment.contourLines)
    cent = create_centroid(handles.app.experiment.contourLines{c});
    ct = repmat(cent,size(handles.app.experiment.contourLines{c},1),1);
    % Halo contour is created 2*area is out, but because of the halo
    % border the halo is still haloArea in area.
    halos{c} = (handles.app.experiment.contourLines{c}-ct)*sqrt((1+2*regions.haloArea))+ct;
    halo_borders{c} = (handles.app.experiment.contourLines{c}-ct)*sqrt((1+1*regions.haloArea))+ct;
    halos{c}(find(halos{c}(:,1) < 1),1) = 1;
    halos{c}(find(halos{c}(:,2) < 1),2) = 1;
    halos{c}(find(halos{c}(:,1) > nx),1) = nx;
    halos{c}(find(halos{c}(:,2) > ny),2) = ny;
    halo_borders{c}(find(halo_borders{c}(:,1) < 1),1) = 1;
    halo_borders{c}(find(halo_borders{c}(:,2) < 1),2) = 1;
    halo_borders{c}(find(halo_borders{c}(:,1) > nx),1) = nx;
    halo_borders{c}(find(halo_borders{c}(:,2) > ny),2) = ny;

    
    color = regions.cl(cridx(c),:);  
    halo_hands(c) = plot(halos{c}([1:end 1],1), halos{c}([1:end 1],2),...
			 'Color', color,...
			 'LineWidth', 1,...
			 'LineStyle', ':');
    border_hands(c) = plot(halo_borders{c}([1:end 1],1), halo_borders{c}([1:end 1],2),...
			   'Color', color,...
			   'LineWidth', 1,...
			   'LineStyle', '--');
end
%zoom on;
handles.app.data.haloHands = halo_hands;
handles.app.data.halos = halos;
handles.app.data.haloBorderHands = border_hands;
handles.app.data.haloBorders = halo_borders;
guidata(hObject, handles);


function handles = setup_signals_callback(hObject, handles)
% This function is called when "Next" is hit in the Halo Gui.

% First it checks if the "Update" button was hit and if the update checkbox is checked. 
% If not updated it auto-updates before continuing to set signals.
if (isempty(handles.app.data.halos) & handles.app.preferences.haloMode)
    halo_update_callback(hObject, handles);
    handles=guidata(hObject);
end

handles = setup_signals(hObject,handles);
guidata(hObject, handles);


function handles = setup_signals(hObject,handles)
% This function sets up the signals.
% Set up GUI to allow the user to save and activate other menu options.

% File
handles = menuset(handles, 'File', 'file', 'Save Experiment', 'Enable', 'on');
handles = menuset(handles, 'File', 'file', 'Open Experiment', 'Enable', 'off');

% Preferences
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display centroids on selected (pixels)' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display ids on selected contours' ,...
		  'Enable', 'on', ...
		  'Checked', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display ids on all contours' ,...
		  'Enable', 'on', ...
		  'Checked', 'off');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Long Raster', 'Enable', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show ordering line', 'Enable', 'on');
% The only version of this works for finding contours but not the
% later map, therefore disable.
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show contour ordering', 'Enable', 'off');
      
% Export 
handles = menuset(handles,'Export','export',...
            'Active cells to vnt file' ,...
            'Enable','on');
handles = menuset(handles,'Export','export',...
            'Export traces' ,...
            'Enable','on');
handles = menuset(handles,'Export','export',...
            'Export traces with signals' ,...
            'Enable','on');
handles = menuset(handles,'Export','export',...
            'Export active cell traces' ,...
            'Enable','on');
     
        
        
% Preprocessing.
handles = menuset(handles, 'Preprocessing', 'preprocessing', ...
		  'Preprocessing Options', 'Enable', 'on');
        
% Contours
handles = menuset(handles, 'Contours','contours','Tile Region','Enable','off');
handles = menuset(handles, 'Contours','contours','Tile Region at angle','Enable','off');
handles = menuset(handles, 'Contours','contours','Tile Region with rectangles','Enable','off');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Delete contour by id' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Delete active contours' ,...
		  'Enable', 'on');      
handles = menuset(handles, 'Contours', 'contours', ...
		  'Turn active contours off' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Connect highlighted contours in order', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Plot highlighted contours', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
          'Plot highlighted contours with zeroed signals', ...
          'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Highlight contours by order', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Highlight contours by order (in partition)', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...		   
		   'Highlight contours by cluster id', ...
		   'Enable', 'on');

handles = menuset(handles, 'Contours', 'contours', ...
      'Convert contours to parallel image' ,...
      'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Make all contours active' ,...
		  'Enable', 'on');        
               
% Clustering
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Highlight all clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Unhighlight all clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Merge highlighted clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by id', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by size', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete contours by order', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Order clusters by intensity peak', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by size', 'Enable', 'on');
          
% User defined signal functions under the "Functions" menu.
[st, function_names] = readdir(handles, 'signalfunctions');
for i = 1:length(st)
    handles = menuset(handles, 'Functions', 'functions', ...
		      st{i}, 'Enable', 'on');
end


      
% Setup the intensity map for clustering.
% Setup the cluster image axis.
% Load the clustering algorithms must be above create_clusters_gui.
[cluster_methods, cluster_method_names] = readdir(handles, 'classifiers');
uiset(handles, 'signals', 'dpclassifiers', 'String', cluster_methods);
uiset(handles, 'signals', 'dpclassifiers', 'Value', handles.app.preferences.classifier);

% MD - Load Experiment Defaults if they aren't loaded already.
if (~isfield(handles.app.data, 'preprocessStrings'))
[handles.app.experiment, handles.app.data] = ct_add_missing_options_exp(handles.app.experiment, handles.app.data);
if handles.app.preferences.preprocessorOptions==1
    handles.app.experiment.preprocessOptions = [];
    handles.app.experiment.preprocessStrings = [];
    for count = 1:length (handles.app.preferences.preprocessdefaults)
        handles.app.experiment.preprocessOptions{count} = feval([handles.app.preferences.preprocessdefaults{count} '_options']);
        handles.app.experiment.preprocessStrings{count} = handles.app.preferences.preprocessdefaultsstring{count};
    end
end
end

% If the experiment was not set up, set it up.
if (~handles.app.info.didSetupExperiment)
    handles = create_experiment_from_app(handles);
    handles = setup_clickmap_image(handles);
    handles = setup_traceplot(handles);
    handles = setup_rasterplot(handles);
    % Put the axes creation after create call so that it doen't show
    % up on the screen in annoying fashion.  this means we have to
    % wait to do first create-clusters until it's created, which is
    % why it's right below, and not in create_experiment.

    handles = create_clusters_gui(handles, 1 , ...
				  'onecluster', 1);
    handles.info.didSetupExperiment = 1;
    handles = hide_uigroup(handles, 'image');
    handles = hide_uigroup(handles, 'halos');
else					% loaded experiment.
    handles = setup_traceplot(handles);
    handles = setup_clickmap_image(handles);   
    handles = setup_rasterplot(handles);

    % Bug with this function so only use in this case.
    handles = hide_all_uigroups(handles);
end

% Now that traceplot is set, see if the preferences are set to constrain 
% the zoom and pan to horizontal so the user won't run into an anoying  
% situation where they "lose" their plot when changing zoom.
try
    if handles.app.preferences.AllowTraceYZoom==0
        h=zoom;
        ax3 = handles.guiOptions.face.tracePlot;
        setAxesZoomMotion(h,ax3,'horizontal');
        zoom off;
        h=pan;
        setAxesPanMotion(h,ax3,'horizontal');
        pan off;
    end
end

if (handles.app.experiment.haloMode == 0)
    handles = uiset(handles, 'signals', 'halo_raw_check' ,'enable','off');
    handles = uiset(handles, 'signals', 'halo_preprocess_check' ,'enable','off');
end

% Turn off the contour finding images.
lidx = get_label_idx(handles, 'image');
hide_axis(handles.uigroup{lidx}.imgax);

% Turn on the GUI widgets for analyzing the signals.
handles = show_uigroup(handles, 'signals');
% Set the default number of clusters and trials to what is in the
% preferences.
if (isfield(handles.app, 'preferences'))
    handles = uiset(handles, 'signals', 'txnclusters' ,'string',handles.app.preferences.Num_ClustVal);
    handles = uiset(handles, 'signals', 'txntrials' ,'string',handles.app.preferences.Num_TrialVal);
end
ncontours = length(handles.app.experiment.contours);


% Load the dimension reduction methods.
[dimredux_methods, dimredux_method_names] = readdir(handles, 'dimreducers');
uiset(handles, 'signals', 'dpdimreducers', 'String', dimredux_methods);
uiset(handles, 'signals', 'dpdimreducers', 'Value', handles.app.preferences.dimreduc);


% Set the partition names.  
npartitions = length(handles.app.experiment.partitions);
for p = 1:npartitions
    partition_names{p} = (handles.app.experiment.partitions(p).title);
end
uiset(handles, 'signals', 'clusterpopup', 'String', ...
      partition_names);
partition_order_value = handles.app.data.currentPartitionIdx;
uiset(handles, 'signals', 'clusterpopup', 'Value', partition_order_value);


% Load the Contour Order routines.
[st, orderroutine_names] = readdir(handles, 'orderroutines');
handles.app.data.contourOrderRoutines = orderroutine_names;
handles = uiset(handles, 'signals', 'dporderroutines', 'String', st);
handles = uiset(handles, 'signals', 'dporderroutines', 'Value', handles.app.preferences.orderrout);

% Set the contour orders.  The default is the first partition.
norders = length(handles.app.experiment.contourOrder);
for c = 1:norders
   contour_order_names{c} = (handles.app.experiment.contourOrder(c).title); 
end
uiset(handles, 'signals', 'contourorderpopup', 'String', contour_order_names);
contour_order_value = handles.app.data.currentContourOrderIdx;
uiset(handles, 'signals', 'contourorderpopup', 'Value', contour_order_value);


% Load the signal detectors.
[st, signaldetector_names] = readdir(handles, 'signaldetectors');
handles.app.data.signalDetectorNames = signaldetector_names;
handles = uiset(handles, 'signals', 'dpdetectors', 'String', st);
handles = uiset(handles, 'signals', 'dpdetectors', 'Value', handles.app.preferences.signaldetect);

% Load the saved signal detections.
ndetections = length(handles.app.experiment.detections);
for c = 1:ndetections
   detection_names{c} = (handles.app.experiment.detections(c).title); 
end
uiset(handles, 'signals', 'signalspopup', 'String', detection_names);
detection_order_value = handles.app.data.currentDetectionIdx;
uiset(handles, 'signals', 'signalspopup', 'Value', detection_order_value);

% Contour slider.
% The contour slider is off by default.
handles = uiset(handles, 'signals', 'numslider', ...
		'Min', 1, ...
		'Max', ncontours, ...
		'Sliderstep', [1/ncontours 10/ncontours]);

uiset(handles, 'signals', 'numslider', 'Visible', 'off');
handles.app.data.useContourSlider = 0;
handles = plot_gui(handles);  %GA tracking

% If autodetect is checked from preferences, call the detect button.
if handles.app.preferences.SetDetectOptions==1;
detect_signals_callback(hObject,handles);
handles=guidata(hObject);
end


function handles = create_experiment_from_app(handles)
% Setup the experiment structure by reading traces and filling out
% the structure, etc.
set(handles.fig, ...
    'Name', [handles.app.info.title ' - ' handles.app.experiment.Image(1).title]);

maskidx = get_mask_idx(handles, 'Image');

% Get the correct colormap for the time collapsed image.
brightness = uiget(handles, 'image', 'bbright', 'value');
contrast = uiget(handles, 'image', 'bcontrast', 'value');

% Now that we are done setting up the halos, we can copy the latest
% halos to the experiment.
handles.app.experiment.haloMode = handles.app.preferences.haloMode;

% Add them here and then remove them after the tracereader call.  Data
% is saved in the contour array.
handles.app.experiment.halos = handles.app.data.halos;
handles.app.experiment.haloBorders = handles.app.data.haloBorders;

% Read the traces.
rid = uiget(handles, 'halos', 'dpreaders', 'value');
reader_name = handles.app.data.traceReaderNames(rid);
reader_name = reader_name{1};

% Check flip signal question in preferences.
if handles.app.preferences.FlipSigQuest.index > 0;
button = handles.app.preferences.FlipSigQuest.Options;
else
    qstring = ['Some dyes produce a downward signal.  The rest of the program works on the assumption that a signal is a higher value than baseline.  Would you like to flip the traces about their means?'];
    button = questdlg(qstring, 'Signal Direction.', ...
              'Yes', 'No', 'Cancel', 'No');
end
if (strcmpi(button, 'Yes'))
    handles.app.data.multiplySignalsbyNegOne = 1;
elseif (strcmpi(button, 'No'))
    handles.app.data.multiplySignalsbyNegOne = 0;
else
    return;
end

if handles.app.experiment.opensequential==1 %if file opened sequentially
    [traces, halo_traces, param] = ct_readtraces_sequential_mem(handles.app.experiment, maskidx,handles.app.preferences);
else
%     [traces, halo_traces, param] = feval(reader_name, handles.app.experiment, maskidx,handles.app.preferences);
    [traces, halo_traces, param] = ct_readtraces_mem(handles.app.experiment, maskidx,handles.app.preferences);
end
warning off
if (handles.app.data.multiplySignalsbyNegOne)
    [ncontours, len] = size(traces);
    trace_means = mean(traces,2);
    trace_means_mat = repmat(trace_means, 1, len);
    traces = traces * -1 + 2*trace_means_mat;
    if ~isempty(halo_traces)
        halo_trace_means = mean(halo_traces,2);
        halo_trace_means_mat = repmat(halo_trace_means, 1, len);    
        halo_traces = halo_traces * -1 + 2*halo_trace_means_mat;
    end
end
handles.app.experiment = rmfield(handles.app.experiment, 'halos');
handles.app.experiment = rmfield(handles.app.experiment, 'haloBorders');

handles.app.experiment.traces = traces;
handles.app.experiment.haloTraces = halo_traces;
handles.app.experiment.traceReaderName = reader_name;
handles.app.experiment.traceReaderParams = param;

ncontours = length(handles.app.experiment.contourLines);
halos = handles.app.data.halos;
halo_borders = handles.app.data.haloBorders;
if (~handles.app.preferences.haloMode)
    halos = cell(1,ncontours);
    halo_borders = cell(1,ncontours);
end
contours = handles.app.experiment.contourLines;
centroids = handles.app.experiment.centroids;
cridx = handles.app.experiment.contourRegionIdx;
cmidx = handles.app.experiment.contourMaskIdx;
areas = handles.app.experiment.areas;

% Integration with David Sussillo's movie_analysis.
handles.app.experiment.numContours = size(traces, 1);

% Do the simple order of the contours reflect the ordering set earlier
% in the program?
coidx = 1;
new_order = neworder;
new_order.id = 1;
new_order.title = 'cell_number_id1'; % default name.
new_order.orderName = 'default';
new_order.order = [1:handles.app.experiment.numContours];
new_order.index = [1:handles.app.experiment.numContours];
handles.app.experiment.contourOrder(coidx) = new_order;
handles.app.data.currentContourOrderIdx = 1;
handles.app.experiment.numContourOrders = 1;
enduseless = round(.1*handles.app.experiment.numContours);
colors = hsv(round(1.7*handles.app.experiment.numContours));
stopcolors = size(colors,1)-enduseless;
startcolors = stopcolors - (handles.app.experiment.numContours-1);
handles.app.experiment.contourColors = colors(startcolors:stopcolors,:);
for i = 1:handles.app.experiment.numContours
    handles.app.experiment.contours(i).id = i;
    handles.app.experiment.contours(i).regionIdx = cridx(i);
    handles.app.experiment.contours(i).maskIdx = cmidx(i);
    handles.app.experiment.contours(i).intensity = traces(i,:);
    handles.app.experiment.contours(i).contour = contours{i};
    handles.app.experiment.contours(i).Centroid = centroids{i};
    handles.app.experiment.contours(i).area = areas{i};
    handles.app.experiment.contours(i).haloIntensity = halo_traces(i,:);
    handles.app.experiment.contours(i).haloContour = halos{i};
    handles.app.experiment.contours(i).haloBorderContour = halo_borders{i};
end
handles.app.experiment.globals.numImagesProcess = size(traces,2);
handles.app.experiment.globals.name = handles.app.experiment.fileName;
handles.app.experiment.globals.height = handles.app.experiment.Image(maskidx).nY;
handles.app.experiment.globals.width = handles.app.experiment.Image(maskidx).nX;
handles.app.experiment.globals.fs = 1/handles.app.experiment.timeRes;
handles.app.experiment.globals.timeRes = handles.app.experiment.timeRes;
handles.app.experiment.globals.mpp = handles.app.experiment.spaceRes;
handles.app.experiment.globals.spaceRes = handles.app.experiment.spaceRes;
handles.app.experiment.globals.movie_start_idx = 1;
handles.app.experiment.globals.haloMode = handles.app.preferences.haloMode;
handles.app.experiment.globals.haloArea = handles.app.preferences.Halo_Area;
d = newdetection;
d.title = '1';
d.id = 1;
d.detectorName = 'default';
d.onsets = cell(1, ncontours);
d.offsets = cell(1, ncontours);
handles.app.experiment.detections(1) = d;


%% Signal Gui Callbacks

function contour_buttondown_callback(hObject, handles)
%Calls when a cell contour is clicked on in the map.
cid = get(hObject, 'UserData');
active_color = handles.app.data.activeContourColor;
face_color = get(hObject, 'FaceColor');
if (handles.app.data.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end
% Not selected, cluster not selected. (Could use UserData here.).
% Since the active cell and current cell GUI concepts conflict
% (i.e. the user gets confused.  It's either one or the other.
if (~do_use_current_cell)
    if (ischar(face_color) & strcmpi(face_color, 'none'))
        handles.app.data.activeCells = [handles.app.data.activeCells cid];
    elseif (length(find(face_color == active_color)) < 3)
        handles.app.data.activeCells = [handles.app.data.activeCells cid];
    else					% it was active, get rid of it.
        handles.app.data.activeCells = ...
            setdiff(handles.app.data.activeCells, cid);
    end
else
    % Make sure contour selected is in current partition, else ignore.
    pidx = handles.app.data.currentPartitionIdx;
    p = handles.app.experiment.partitions(pidx);
    contour_ids = [p.clusters.contours];    
    ncontours = length(contour_ids);
    nonnan_contour_idxs = find(~isnan([p.clusterIdxsByContour{1:end}]) == 1);
    contour_idx = find(nonnan_contour_idxs == cid);    
    % Only update the id from here when things are no good.
    if (isempty(contour_idx) | contour_idx < 1 | contour_idx > ncontours)
	warndlg(['In contour slider mode, you can only select contours' ...
		 ' that are in the current partition.  Deselect' ...
		 ' Preferences->Use Contour Slider to select this contour.']);
	return;
    end
    handles.app.data.currentCellId = cid;
end
handles = plot_gui(handles);
guidata(hObject, handles);

function clustermap_buttondown_callback(hObject, handles)
% Called when a cell contour is selected via the raster plot.
st = get(handles.fig, 'SelectionType');
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
cmenu = get(hObject, 'UIContextMenu');
% Show context menu.
if strcmpi(st, 'alt')
    old_units = get(handles.fig, 'Units');
    set(handles.fig, 'Units', 'pixels');
    current_mouse_point = get(handles.fig, 'CurrentPoint');
    set(handles.fig, 'Units', old_units);
    set(cmenu, 'Position', current_mouse_point);
    set(cmenu, 'Visible', 'on');
	
    % Else plot cells in cluster.
else
    highlighted_contour_id = determine_highlighted_contour_leftclick(handles);

    if (handles.app.data.useContourSlider)
        do_use_current_cell = 1;
    else
        do_use_current_cell = 0;
        current_cell = [];			% checks for empties.
    end
    if isempty(find(handles.app.data.activeCells==highlighted_contour_id));%if cell not on before this
        if (~do_use_current_cell)		% many active cells
            handles.app.data.activeCells(end+1) = highlighted_contour_id;
            handles.app.data.activeCells = unique(handles.app.data.activeCells);
        else
            handles.app.data.currentCellId = highlighted_contour_id;
        end
    else %if cell was already on
        if (~do_use_current_cell)		% many active cells
            nidx = find(handles.app.data.activeCells == highlighted_contour_id);
            handles.app.data.activeCells(nidx) = [];
            handles.app.data.activeCells = unique(handles.app.data.activeCells);
            if (isempty(handles.app.data.activeCells))
                handles.app.data.activeCells = [];
            end
        else
            if (highlighted_contour_id == handles.app.data.currentCellId)
                handles.app.data.currentCellId = [];
            end
        end
    end
    handles = plot_gui(handles);
    guidata(handles.fig, handles);
end

function highlighted_contour_id = determine_highlighted_contour_leftclick(handles)
% This hObject is the context menu, so this function only works for
% the context menu items on the intensity plot (that show the
% temporal clusters.)
% Remember!:  Position is [left bottom width height], 
% except for the context menu where it's [width height].
% First figure out the number or contours and the contour ids, in order.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
num_contours = sum([p.clusters.numContours]);
displayed_contours = handles.app.data.partitions(pidx).displayedContours;
% Now do the height computation to figure out which contour the user wants
% to become active.
clickpoint = get(handles.fig,'CurrentPoint'); % Point on figure where clicked.
fig_pos = get(handles.fig, 'Position');	% in pixels.
% normalized units -> pixel units
set(handles.guiOptions.face.imagePlotH, 'Units', 'Pixels');
imap_pos = get(handles.guiOptions.face.imagePlotH, 'Position');
set(handles.guiOptions.face.imagePlotH, 'Units', 'normalized');
imap_bottom = imap_pos(2);
imap_height = imap_pos(4);
% Now put the click point in terms of the imap axis.
click_height =  clickpoint(2) - imap_bottom;
% How many pixels does each raster get (in terms of height)?
pixels_per_raster = imap_height / num_contours;
% Contour_height is the order of the contour we are interested in.
contour_height = num_contours - ceil(click_height/pixels_per_raster)+1;
highlighted_contour_id = displayed_contours(contour_height);


%% Signal Detection GUI - Checkboxes
function trace_check_callback(hObject, handles)
% This is the "Show Raw" checkbox callback.
handles = toggle_other_show_checkboxes(hObject, handles, handles.app.preferences.showCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);


function clean_trace_check_callback(hObject, handles)
% This is the "Show Clean" checkbox callback.
handles = toggle_other_show_checkboxes(hObject, handles, handles.app.preferences.showCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);

function halo_raw_callback(hObject, handles)
% This is the "Show Halo Raw" checkbox callback.
handles = toggle_other_show_checkboxes(hObject, handles, handles.app.preferences.showHaloCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);

function halo_preprocess_callback(hObject, handles)
% This is the "Show Halo Clean" checkbox callback.
handles = toggle_other_show_checkboxes(hObject, handles, handles.app.preferences.showHaloCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);

function handles = toggle_other_show_checkboxes(hObject,handles, tag)
% This is a manual toggle between checkboxes in the Signals GUI.
if (get(hObject,'Value') == get(hObject,'Max'))
    do_uncheck_others = 1;
else
    do_uncheck_others = 0;
end
hs = findobj(handles.fig, 'Tag', tag);
for i = 1:length(hs)
    h = hs(i);
    if (~(get(h, 'UserData') == get(hObject, 'UserData')))
	if (do_uncheck_others)
	    set(h, 'Value', get(h, 'Min'));
	end
    end
end

function signals_checkbox_callback(hObject, handles)
% This is the "Show Signals" checkbox callback.
handles = plot_gui(handles);
guidata(hObject,handles);

%% Frame Input Type Checkboxes
function click_frame_input_callback(hObject, handles);
% This is called when the "Click Input" checkbox is hit.
if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.use_numerical_frame_input_checkbox,'value',0);
    set(handles.uigroup{lidx}.use_numerical_frame_input_min,'enable','off');
    set(handles.uigroup{lidx}.use_numerical_frame_input_max,'enable','off');
    guidata(hObject, handles);
end

function numerical_frame_input_callback(hObject, handles);
% This is called when the "Number Input" checkbox is hit.
if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.use_frame_click_input_checkbox,'value',0);
    set(handles.uigroup{lidx}.use_numerical_frame_input_min,'enable','on');
    set(handles.uigroup{lidx}.use_numerical_frame_input_max,'enable','on');
    guidata(hObject, handles);
end

function cluster_callback(hObject, handles)
% This Callback is called when "Cluster" is hit in the Signal Detection
% gui.
nclusters = str2num(uiget(handles, 'signals', 'txnclusters', 'String'));
handles = create_clusters_gui(handles, nclusters);
handles = plot_gui(handles);
guidata(hObject, handles);

function handles = create_clusters_gui(handles, nclusters, varargin)
% Call create clusters AND create the application patches.
ntrials = str2num(uiget(handles, 'signals', 'txntrials', 'string'));
varargin{end+1} = 'numtrials';
varargin{end+1} = ntrials;
handles = createclusters(handles, nclusters, varargin{:});
pidx = handles.app.data.currentPartitionIdx;
partition_names = cellstr(uiget(handles, 'signals', 'clusterpopup', 'String'));
npartitions = length(partition_names)+1;
partition_names{end+1} = handles.app.experiment.partitions(pidx).title;
uiset(handles, 'signals', 'clusterpopup', 'String', partition_names);
uiset(handles, 'signals', 'clusterpopup', 'Value', npartitions);
axes(handles.guiOptions.face.imagePlotH);
handles = plot_gui(handles);


function clusterpopup_callback(hObject, handles)
% Called when a Saved Partition (saved from cluster method) is selected in
% the Signals Gui.
partition_names = uiget(handles, 'signals', 'clusterpopup', 'String');
pnidx = uiget(handles, 'signals', 'clusterpopup', 'Value');
pname = partition_names{pnidx};
% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(pname, 'id[0-9]+');
if isempty(match)
   errordlg(['Error in clusterpopup_callback with name: ' pname]); 
   return;
end
pidx = str2num(pname(start+2:fin));
handles.app.data.currentPartitionIdx = pidx;
handles.app.data.currentContourOrderIdx = ...
    handles.app.experiment.partitions(pidx).contourOrderId;
handles = plot_gui(handles);
guidata(hObject, handles);


function detect_signals_callback(hObject, handles)
% Called when "Detect" is hit in the Signals Gui
handles = detect_signals(handles);
% Now fill the popup with the saved detections.
signals_names = uiget(handles, 'signals', 'signalspopup', 'String');
didx = handles.app.data.currentDetectionIdx;

new_signal_name = handles.app.experiment.detections(didx).title;
signals_names{end+1} = new_signal_name;
val = length(signals_names);
handles = uiset(handles, 'signals', 'signalspopup', ...
		'String', signals_names);
handles = uiset(handles, 'signals', 'signalspopup', ...
		'Value', val);
handles = plot_gui(handles);
guidata(hObject, handles);


function signals_popup_callback(hObject, handles)
% Called when a Saved Signal (saved from signal detector) is selected in
% the Signals Gui.
signals_names = uiget(handles, 'signals', 'signalspopup', 'String');
didx_popup = uiget(handles, 'signals', 'signalspopup', 'Value');
signal_name = signals_names{didx_popup};

% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(signal_name, 'id[0-9]+');
if isempty(match)
    didx = str2num(signal_name);		% simple name for early stuff.
else
    didx = str2num(signal_name(start+2:fin));
end
handles.app.data.currentDetectionIdx = didx;
handles = plot_gui(handles);
guidata(hObject, handles);

function order_contours_callback(hObject, handles)
% Called by pressing the "Order" button in the Signals Gui.
old_num_contour_orders = handles.app.experiment.numContourOrders;
handles = ordercontours(handles);

if (old_num_contour_orders >= handles.app.experiment.numContourOrders)
    return;
end

% Now fill the popup with the saved contour orders.
contour_order_names = uiget(handles, 'signals', 'contourorderpopup', 'String');
coidx = handles.app.data.currentContourOrderIdx;
new_coname = handles.app.experiment.contourOrder(coidx).title;
contour_order_names{end+1} = new_coname;
val = length(contour_order_names);
handles = uiset(handles, 'signals', 'contourorderpopup', ...
		'String', contour_order_names);
handles = uiset(handles, 'signals', 'contourorderpopup', ...
		'Value', val);
handles = plot_gui(handles);
guidata(hObject, handles);

function contour_order_popup_callback(hObject, handles)
% Called by changing the "Saved Contour Orders" popup.
contour_order_names = uiget(handles, 'signals', 'contourorderpopup', 'String');
coidx_popup = uiget(handles, 'signals', 'contourorderpopup', 'Value');
coname = contour_order_names{coidx_popup};

% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(coname, 'id[0-9]+');
if isempty(match)
    coidx = str2num(coname);		% simple name for early stuff.
else
    coidx = str2num(coname(start+2:fin));
end

handles.app.data.currentContourOrderIdx = coidx;
handles = plot_gui(handles);
guidata(hObject, handles);

%% Signal Analyzer
function export_signals_to_analyzer_callback(hObject, handles);
% 1) get frames of interest by user clicks
pidx = handles.app.data.currentPartitionIdx;
%gather all contours in all clusters of this partition
clustered_contour_ids = [];
for clidx = 1:handles.app.experiment.partitions(pidx).numClusters;
    clustered_contour_ids = cat(2,clustered_contour_ids,...
        handles.app.experiment.partitions(pidx).clusters(clidx).contours);
end
clean_traces = handles.app.experiment.partitions(pidx).cleanContourTraces;
clean_traces = clean_traces(clustered_contour_ids,:);

[intensitymap start_idx, stop_idx, x, y] = ...
        get_raster_input(handles, clean_traces);

% 2) get onsets and offsets, transform into a logical matrix
didx = handles.app.data.currentDetectionIdx;
tempons = handles.app.experiment.detections(didx).onsets;
onsets = cell(size(tempons));
onsets(clustered_contour_ids) = tempons(clustered_contour_ids);
tempoffs = handles.app.experiment.detections(didx).offsets;
offsets = cell(size(tempons));
offsets(clustered_contour_ids) = tempoffs(clustered_contour_ids);


activitymtx = logical(zeros(size(onsets,2),size(clean_traces,2)));
onsmtx = activitymtx;
for cidx = 1:size(onsets,2);%for each cell
    for oidx = 1:length(onsets{cidx});%for each onset/activation
        frameson = onsets{cidx}(oidx):offsets{cidx}(oidx);
        activitymtx(cidx,frameson) = 1;%activity matrix has 1 between on and
        % off of any cell activation and zeros everywhere else
        onsmtx(cidx,onsets{cidx}(oidx)) = 1;
    end
end
%this does not work because of places where an onset is the frame after an offset
% onsmtx = ct_keepfirstonframe(activitymtx')';%onsmtx has 1s only where onsets are, zeros all else


%for each specified region of frames (ie if multiple)
figthere = 0;%default that analyzer figure not already there
for chunk_idx = 1:length(start_idx);    
% 2) For each clicked region get all signals from current detection with onsets 
% within those frames
    thisstart = start_idx(chunk_idx);
    thisstop = stop_idx(chunk_idx);
    thisonsmtx = onsmtx(:,thisstart:thisstop);%ons starting in these frames
    thisactivitymtx = activitymtx(:,thisstart:thisstop);
    thisactivitymtx(~sum(thisonsmtx,2),:)=0;%all activity of cells with ons starting in these frames
    %get name ready to pass
    filename = handles.app.experiment.fileName;
    perspot = strfind(filename,'.');
    filename(perspot:end) = [];
    chunkname = [filename,'_Detect',num2str(didx),...
        '_Frm',num2str(thisstart),'-',num2str(thisstop)];
    %evaluate whether the Analyzer Figure is already there or not
    if chunk_idx == 1;
        analyzerFigure = findobj('type','figure','tag','analyzerFigure');
        if ~isempty(analyzerFigure)
            figthere = 1;
        end
    end
    %    if the analyzer does not exist, create it first
    if ~figthere
        analyzerFigure = create_signal_analyzer(handles);
        figthere = 1;
    end

% 3) pass data to the analyzer
    data_to_analyzer(analyzerFigure,...
        handles,...
        thisactivitymtx,...
        thisonsmtx,...
        chunkname);
end
guidata(hObject, handles);

%% Signal Edit
function signal_edit_mode_callback(hObject, handles)
% Called by the "Edit Signals" checkbox. Allows to turn on/off signal edit mode
if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.contourslidercheckbox,'value',1);%put on contour slider
    set(handles.uigroup{lidx}.signals_check,'value',1);%turn on show signals mode
    caltracer2('use_contour_slider_callback',gcbo,guidata(gcbo))
end

function use_contour_slider_callback(hObject, handles)
% Called by the "Edit Signals Callback" and "Single Contour Display"
val = get(hObject, 'value');
if val == 1   
    uiset(handles, 'signals', 'numslider', 'Visible', 'on');
    handles.app.data.useContourSlider = 1;
    if (~isempty(handles.app.data.activeCells))
        cid = handles.app.data.activeCells(1);
        handles.app.data.currentCellId = cid;
    else
        handles.app.data.currentCellId = 1;
    end
else
    uiset(handles, 'signals', 'numslider', 'Visible', 'off');
    handles.app.data.useContourSlider = 0;
    if (~isempty(handles.app.data.currentCellId))
	handles.app.data.activeCells = ...
	    handles.app.data.currentCellId(1); 
    end
end
handles = plot_gui(handles);
guidata(hObject, handles);


function numslider_callback(hObject, handles)
% This is the slider that comes back in the Signal Detection GUI when
% editing signals.
% This can handle contours that have been deleted/killed.
nonnan_order = round(uiget(handles, 'signals', 'numslider', 'Value'));

% Find all the contours in the current partition.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
nonnan_contour_ids = find(~isnan([p.clusterIdxsByContour{1:end}]) == 1);

% Look up the id for the order taken from the numslider.
coidx = handles.app.data.currentContourOrderIdx;
nonnan_contour_order = ...
    handles.app.experiment.contourOrder(coidx).index(nonnan_contour_ids);

nn = [nonnan_contour_order; nonnan_contour_ids]';
sorted_nn = sortrows(nn,1);
contour_id = sorted_nn(nonnan_order,2);

if (isempty(contour_id))
    errordlg('Something wrong in numslider_callback.');
end

% Store the updated id.
handles.app.data.currentCellId = contour_id;

% Replot the GUI and save.
handles = plot_gui(handles);
guidata(hObject, handles);


%% File Menu
%Open a Caltracer Experiment.
function open_experiment_callback(hObject, handles)
[filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
if (filename == 0)			% returns 0 for some reason.
    return;
end
fnm = [pathname filename];
savestruct = load(fnm);
%% If the saved experiment was made in caltracer 2.x
if (isfield(savestruct,'handles'))
    handles.app = savestruct.handles.app;
    handles.app.info.didSetupExperiment=1;
    set(handles.fig, 'Name', [handles.app.info.title ' - ' filename]);
    [pathstr, name, ext] = fileparts(which('caltracer2'));
    handles.app.info.ctPath = pathstr;
    handles = setup_signals(hObject,handles);
         % Activate some exporting options.
        handles = menuset(handles, 'Export', 'export', 'Export contours', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'Export contours to file', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than once)', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than one pulse per target)', 'Enable', 'on');
    guidata(hObject, handles);
%% If the experiment was made in caltracer 1.x 
else
    if (isfield(savestruct, 'A')&&isfield(savestruct,'E'))
        % An attempt to make Caltracer 2 backwards compatible with old Caltracer
        % experiments.
        % Set up info, data and experiment in Caltracer 2 standards.
        % Information about CalTracer
            info.title = 'CalTracer';
            info.versionNum = 2.2;
            info.logo = imread('hippo.bmp');
            info.issplit = 0; % splitting not available in Caltracer 1.x
            info.error = 0;
        if (1 | ~isfield(handles.info, 'ctPath'))
            [pathstr, name, ext] = fileparts(which('caltracer2'));
            info.ctPath = pathstr;
        end
        if (~isfield(savestruct.A, 'didSetupExperiment'))
            info.didSetupExperiment = 0;
        else
            info.didSetupExperiment = savestruct.A.didSetupExperiment;
        end

        if (~isfield(savestruct.A, 'didSaveExperiment'))
            info.didSaveExperiment = 0;
        else
            info.didSaveExperiment = savestruct.A.didSaveExperiment;
        end
        % app.data values
        %"Image" is the name of the original image (no mask)
            if (~isfield(savestruct.A, 'maskLabels'))
                data.maskLabels = {'Image'};
            else
                if strcmp(savestruct.A.maskLabels{1}, 'tcImage')
                    data.maskLabels = savestruct.A.maskLabels;
                    data.maskLabels{1} = 'Image';
                else
                    data.maskLabels = savestruct.A.maskLabels;
                end
            end    
            % Type of image input
            if (~isfield(savestruct.A, 'currentImageInputType'))
                data.currentImageInputType = 'file';
            else
                data.currentImageInputType = savestruct.A.currentImageInputType;
            end
            % Initialize and define a default region index (set to 1).
            if (~isfield(savestruct.A, 'currentRegionIdx'))
                 data.currentRegionIdx = 1;
            else
                 data.currentRegionIdx = savestruct.A.currentRegionIdx;
            end
            % The current clustering or 'partition' of the data.  This is a set of
            % clusters.
            if (~isfield(savestruct.A, 'currentPartitionIdx'))
                 data.currentPartitionIdx = 0;
            else
                 data.currentPartitionIdx = savestruct.A.currentPartitionIdx;
            end
            % Initialize a current contour order (used in tile region, anything to
            % do with contour order in the signal detection gui, etc.)
            if (~isfield(savestruct.A, 'currentContourOrderIdx'))
                data.currentContourOrderIdx = 1;
            else
                data.currentContourOrderIdx = savestruct.A.currentContourOrderIdx;
            end
            % The following are used in plot_gui.m
            if (isfield(savestruct.A, 'currentDetectionIdx'))
                if (savestruct.A.currentDetectionIdx==0)
                    data.currentDetectionIdx = 1;
                else
                    data.currentDetectionIdx = savestruct.A.currentDetectionIdx;
                end
            else
                data.currentDetectionIdx = 1;
            end
            if (~isfield(savestruct.A, 'useContourSlider'))
                data.useContourSlider = 1;
            else
                data.useContourSlider = savestruct.A.useContourSlider;
            end 
            if (~isfield(savestruct.A, 'currentCellId'))
                data.currentCellId = 1;
            else
                data.currentCellId = savestruct.A.currentCellId;
            end    
            if (~isfield(savestruct.A, 'activeCells'))
                 data.activeCells = [];
            else
                data.activeCells = savestruct.A.activeCells;
            end   
            %For downward signals such as Fura2.
            if (~isfield(savestruct.A, 'centroidDisplay'))
                data.centroidDisplay.on = 0;
                data.centroidDisplay.points = [];
                data.centroidDisplay.text = [];
            else
                data.centroidDisplay.on=savestruct.A.centroidDisplay.on;
                data.centroidDisplay.points=savestruct.A.centroidDisplay.points;
                data.centroidDisplay.text=savestruct.A.centroidDisplay.text;
            end
        [experiment data] = ct_add_missing_options_exp(savestruct.E, data);
        if (~isfield(data, 'partitions'))
            for pidx = 1:experiment.numPartitions
            numclusters = experiment.partitions(pidx).numClusters;
            data.partitions(pidx) = newpartition_appdata(numclusters);
            end
        end
        for i = 1:experiment.numPartitions
           if (~isfield(data.partitions(i), 'displayedContours'))
               data.partitions(i).displayedContours = [];
           end
        end
        handles.app.info = info;
        handles.app.data = data;
        handles.app.experiment = experiment;
        %Load new default preferences saved in ct_preferences.mat
            handles = ct_preferences_load (handles);
        %Rename tcImage to Image
        handles.app.experiment.Image = handles.app.experiment.tcImage;
        handles.app.experiment=rmfield(handles.app.experiment,'tcImage');
        handles.app.experiment.ImageTitle = handles.app.experiment.tcImageTitle;
        handles.app.experiment=rmfield(handles.app.experiment,'tcImageTitle');
        set(handles.fig, 'Name', [handles.app.info.title ' - ' filename]);
        handles = setup_signals(hObject,handles); 
         % Activate some exporting options.
        handles = menuset(handles, 'Export', 'export', 'Export contours', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'Export contours to file', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than once)', 'Enable', 'on');
        handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than one pulse per target)', 'Enable', 'on');
        guidata(hObject, handles);    
    else
        errordlg ('This file is not a supported caltracer experiment format')
        return;
    end
end

% Saves the current experiment as a .mat file
function save_experiment_callback(hObject, handles)
maskidx = get_mask_idx(handles, 'Image');
filename = [handles.app.experiment.Image(maskidx).title(1:end-4) '_exp.mat'];
[filename, pathname] = uiputfile(filename, 'Save experiment as');
fnm = [pathname filename];
if (~ischar(fnm))
    return;
end
save (fnm, 'handles');
handles.app.info.didSaveExperiment = 1;
guidata(handles.fig, handles);

function new_ct_callback(hObject, handles)
caltracer2

%% Preferences menu.
% Reads and writes values into caltracer2 preferences to make defaults
function ct_preferences_gui_callback(hObject, handles) %MD made
newhandles = ct_preferences_gui(handles);
guidata(hObject, handles);


function long_raster_callback(hObject, handles)
% Called by checking or unchecking "Long Raster" in the preferences menu.
% This function changes the height of the raster plot and width of trace.
val = get(hObject, 'Checked');
if(strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');    
    set(handles.guiOptions.face.tracePlot, ...
	'position', [0.05 0.05 0.42 0.3]);
    set(handles.guiOptions.face.imagePlotH, ...
	'position', [0.50 0.05 0.35 0.90]);
else
    set(hObject, 'Checked', 'off');
    set(handles.guiOptions.face.tracePlot, ...
	'position', [0.05 0.05 0.79 0.3]);
    set(handles.guiOptions.face.imagePlotH, ...
	'position', [0.50 0.40 0.35 0.55]);
end
guidata(hObject, handles);


function display_centroids_on_selection_callback(hObject, handles)
% This function shows the centroid location (in pixels) of selected
% contours when checked.
% Selecting this will toggle this value on/off and then redraw. 
if handles.app.data.centroidDisplay.on == 1;
    set(hObject, 'Checked', 'off');    
    handles.app.data.centroidDisplay.on = 0;
elseif handles.app.data.centroidDisplay.on == 0;
    set(hObject, 'Checked', 'on');    
    handles.app.data.centroidDisplay.on = 1;
end
handles = plot_gui(handles);
guidata(hObject, handles);


function display_ids_on_all_contours_callback(hObject, handles)
% Toggles showing the id of all the contours on the map.
val = get(hObject, 'Checked');    
if (strcmp(val, 'on'))
    set(hObject, 'Checked', 'off');    
else
    set(hObject, 'Checked', 'on');    
end
handles = plot_gui(handles);
guidata(hObject, handles);


function display_ids_on_selected_contours_callback(hObject, handles)
% Toggles showing the id of the selected contour on the map.
val = get(hObject, 'Checked');    
if (strcmp(val, 'on'))
    set(hObject, 'Checked', 'off');    
else
    set(hObject, 'Checked', 'on');    
end
handles = plot_gui(handles);
guidata(hObject, handles);

function show_contour_ordering_callback(hObject, handles)
is_visible = uiget(handles, 'signals', 'clusterpopup', 'Visible');
is_early = strcmpi(is_visible, 'off');
if (is_early)
    lidx = get_label_idx(handles, 'image');
    ax = handles.uigroup{lidx}.imgax;
else    
    ax = handles.guiOptions.face.clickMap;
end
handles = show_contour_ordering(handles, ax, 1);
guidata(hObject, handles);


function show_ordering_line_callback(hObject, handles)
% Toggles showing the contours
is_visible = uiget(handles, 'signals', 'clusterpopup', 'Visible');
is_early = strcmpi(is_visible, 'off');
if (is_early)
    lidx = get_label_idx(handles, 'image');
    axes(handles.uigroup{lidx}.imgax);
else    
    ax = handles.guiOptions.face.clickMap;
end
handles = show_ordering_line(handles, ax, 1);
guidata(hObject, handles);




%% Import Menu

function import_current_callback(hObject, handles)

% make sure user knows how to properly import a current
confirm = questdlg('Confirm that you are about load a .mat file containg two vectors of equal length named "current" and "time"...','Confirmation','Confirm','Cancel','Confirm');

switch confirm
    case 'Confirm'
        
        [filename,pathname] = uigetfile('.mat');
        loaded_data = load([pathname filename]);
        if isfield(loaded_data,'current') && isnumeric(loaded_data.current) &&...
                isnumeric(loaded_data.time) && length(loaded_data.current) == length(loaded_data.time)
            current = loaded_data.current;
            current_t = loaded_data.time;
            current_dt = mean(diff(current_t));
        else
            errordlg('No acceptable data in that .mat file...');
        end
        
    case 'Cancel'
end


%% Export Menu.

function copy_axis_as_meta_to_clipboard_callback(hObject, handles)
% Copies the axis to the clipboard.
ax = get_axis_handle(handles);
if (ax == 0)
    errordlg('Error in axis selection.');
    return;
end
m = findobj(handles.fig, 'Type','uicontrol');
f = figure; 
ax_copy = copyobj(ax, f);
set(ax_copy,'position',[.05 .10 .90 .85]);
figure(f);

print ('-dmeta', '-r600', f);
%       print -depsc -tiff -r300 matilda 
delete(f);

function copy_axis_to_new_figure_callback(hObject, handles)
% Copies the axis to a new figure.
ax = get_axis_handle(handles);
if (ax == 0)
    errordlg('Error in axis selection.');
    return;
end
m = findobj(handles.fig, 'Type','uicontrol');
f = figure; 
ax_copy = copyobj(ax, f);
set(ax_copy,'position',[.05 .10 .90 .85]);
figure(f);

function export_contours_callback(hObject,handles)
% This function exports contours to the base workspace.
% The contours are exported as a a variable called "contours" which is
% a cell containing contours.

% if contours exist (and there is at least two... as a test of
% detection having been done);
try
    assignin('base','Contours',handles.app.experiment.regions.contours{1}{1});
catch
    errordlg('Cell contours do not yet exist')
end
try
    %in case were waiting on this to continue... as in vovan's case
    uiresume
end


function export_contours_to_file_callback(hObject,handles)
% exports to the base workspace a variable called "contours" which is
% a cell containing contours

% if contours exist (and there is at least two... as a test of
% detection having been done);

try
    deffilename = [handles.app.experiment.fileName(1:end-4),'_conts'];
    [FileName,PathName,FilterIndex] = uiputfile('.mat','Contour File Name',deffilename);
    if FileName==0 & PathName==0 & FilterIndex==0
        return
    end
    CONTS = handles.app.experiment.regions.contours{1}{1};
    save([PathName,FileName],'CONTS')
catch
%if any of the above fail
errordlg('Cell contours do not yet exist')       
end

function export_traces_callback(hObject,handles)
export_traces(handles);

function export_traces_with_signals_callback(hObject,handles)
export_traces_with_signals(handles);

function export_active_cell_traces_callback(hObject,handles)
export_active_cell_traces(handles);

function all_centroids_to_vnt_callback(hObject,handles)
all_centroids_to_vnt(handles);

function all_centroids_to_vnt_repeat_callback(hObject,handles)
all_centroids_to_vnt_repeat(handles);

function all_centroids_to_vnt_pulses_callback(hObject,handles)
all_centroids_to_vnt_pulses(handles);

function active_cells_to_vnt_callback(hObject,handles)
active_cells_to_vnt(handles);

function overlapping_mask_ids_callback (hObject,handles)
% This function exports contours to the base workspace.
% After a mask is added and overlap is detected this option is enabled (in
% the find_overlap.m file).

% This function exports the ids of the Masks to the base workspace.

% handles.app.experiment.overlapmaskids{r}{n-1}{mc}(overlapsfound)

numregions = handles.app.experiment.numRegions;
nummasks = handles.app.experiment.numMasks;
if nummasks~=1
    for mask = 1:nummasks-1
        for region = 1:numregions
    MaskIds.Region(region).Mask(mask).Overlaps = handles.app.experiment.overlapmaskids{region}{mask};
        end
    end
else
    for region = 1:numregions
    MaskIds.Region(region).Mask(1).Overlaps = handles.app.experiment.overlapmaskids{region}{1};
    end
end

try
    assignin('base','MaskIds',MaskIds);
catch
    errordlg('No overlapping masks exist')
end


%% Preprocessing Menu.

function preprocessing_options_callback(hObject, handles)
% Sets preprocessing options.
[st, filter_names] = readdir(handles, 'preprocessors');	
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);

do_one_cluster = 1;
keep_same_contours = 0;
keep_same_clusters = 0;

qstring = ['Would you like to keep the same CONTOURS as partition ' ...
	   handles.app.experiment.partitions(pidx).title ...
	   ' or would you like to reset them?'];
button = questdlg(qstring, 'Reset contours', ...
		  'Keep', 'Reset', 'Cancel', ...
		  'Keep') ;
if (strcmpi(button, 'Keep'))
    keep_same_contours = 1;
elseif (strcmpi(button, 'Reset'))
    keep_same_contours = 0;
else
    return;
end

if (keep_same_contours)
    qstring = ['Would you like to keep the same CLUSTERS as partition ' ...
	       handles.app.experiment.partitions(pidx).title ...
	       ' or would you like to reset them?'];
    button = questdlg(qstring, 'Reset clusters', ...
		      'Keep', 'Reset', 'Cancel', ...
		      'Keep') ;
    if (strcmpi(button, 'Keep'))
        keep_same_clusters = 1;
        do_one_cluster = 0;
    elseif (strcmpi(button, 'Reset'))
        keep_same_clusters = 0;
        do_one_cluster = 1;
    else
    	return;
    end
end

universe = st;
[sidxs,universe2,preprocess_options] = ...
    SelectBox({'Preprocessing Options'}, universe, ...
	      p.preprocessStrings, ...
	      'Please select the appropriate preprocessing steps.', ...
	      p.preprocessOptions);
if isempty(universe2) & isempty(sidxs) & isempty(preprocess_options)
    return;
end
handles.app.experiment.preprocessOptions = preprocess_options;
handles.app.experiment.preprocessStrings = universe2(sidxs);
handles = create_clusters_gui(handles, 1 , ...
			      'onecluster', do_one_cluster, ...
			      'newpreprocessing', 1, ...
			      'keepcontours', keep_same_contours, ...
			      'keepclusters', keep_same_clusters);

% Plot the new data.
handles = plot_gui(handles);
guidata(hObject, handles);


%% Contours Menu.

function tile_region_callback(hObject, handles)
% This function tiles a region.
prompt = {'Enter the side length in um for each tile:'};
def = {'10'};
dlgTitle = 'Tile Side Length';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    errordlg('You must enter a valid side length.');
    return;
end

% Get the data from the uicontrols to find the cells.
ridx = handles.app.data.currentRegionIdx;
% answer{1} is in um. So tileSide is in pixels!
handles.face.tileSide(ridx) = str2num(answer{1})/handles.app.experiment.mpp;
handles = tile_region(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function tile_region_angle_callback (hObject,handles)
% This function tiles a region and rotates it based on user input.
prompt = {'Enter the side length in um for each tile:'};
def = {'10'};
dlgTitle = 'Tile Side Length';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    errordlg('You must enter a valid side length.');
    return;
end

% Get the data from the uicontrols to find the cells.
ridx = handles.app.data.currentRegionIdx;
% answer{1} is in um. So tileSide is in pixels!
handles.face.tileSide(ridx) = str2num(answer{1})/handles.app.experiment.mpp;
handles = tile_region_angle(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);


function tile_region_with_rectangles_callback(hObject, handles)
% This function tiles a region.
prompt = {'Enter the short side length in um of the rectangle:'};
def = {'10'};
dlgTitle = 'Tile with Rectangles Short Side Length';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('You must enter a valid side length.');
    return;
end
ridx = handles.app.data.currentRegionIdx;
handles.face.tileType(ridx) = {'rectangle'};
handles.face.tileSide(ridx) = str2num(answer{1})/handles.app.experiment.spaceRes;
handles = tile_region_with_rectangles(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function randomize_contour_order_callback(hObject, handles);
% Randomizes the order of contours (enables on cell detection gui).
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;
contours = handles.app.experiment.regions.contours{ridx}{midx};
numcells = size(contours,2);
[trash,inds]=sort(rand(1,numcells));
contours = contours(inds);
handles.app.experiment.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function keep_only_brightest_contours_callback(hObject, handles)
% Keeps the brightest cell contours (enables on cell detection gui).
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of brightest contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;
contours = handles.app.experiment.regions.contours{ridx}{midx};
if size(contours,2)>numcells;
    contours = keepbrightestcontours(contours,numcells,handles.app.experiment.Image.image);
end
handles.app.experiment.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function keep_random_contours_callback(hObject, handles)
% Keeps random contours (enables on cell detection gui).
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;

contours = handles.app.experiment.regions.contours{ridx}{midx};
if numcells<size(contours,2);
    inds = randperm(size(contours,2));
end
contours = contours(inds(1:numcells));
handles.app.experiment.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function keep_last_contours_callback(hObject, handles)
% Keeps the last contours created(enables on cell detection gui).
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;
contours = handles.app.experiment.regions.contours{ridx}{midx};
if numcells<size(contours,2);
    inds = size(contours,2)-(numcells-1):size(contours,2);
    contours = contours(inds);
end
handles.app.experiment.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function keep_last_contours_randomize_callback(hObject, handles)
% Keeps the last contours created then randomizes their order (enables on cell detection gui).
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;
contours = handles.app.experiment.regions.contours{ridx}{midx};
if numcells<size(contours,2);
    inds = size(contours,2)-(numcells-1):size(contours,2);
    contours = contours(inds);
end
[trash,inds]=sort(rand(1,numcells));
contours = contours(inds);

handles.app.experiment.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

function convert_contours_to_parallel_image_callback(hObject, handles)
convert_contours_to_parallel_image(handles)

function make_all_contours_active_callback(hObject, handles)
% Makes contours active.
handles.app.data.activeCells = [1:handles.app.experiment.numContours];
handles = plot_gui(handles);
guidata(hObject, handles);

function highlight_contours_by_order_callback(hObject, handles)
if (handles.app.data.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

prompt = {'Enter the ORDER (not Id) of contours to highlight:'};
def = {''};
dlgTitle = 'Highlight contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});
% BP.
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > handles.app.experiment.numContours) = [];
% First we translate from order to id.
coidx = handles.app.data.currentContourOrderIdx;
contour_ids = handles.app.experiment.contourOrder(coidx).order(contour_orders);
handles.app.data.activeCells = [handles.app.data.activeCells contour_ids];
handles.app.data.activeCells = unique(handles.app.data.activeCells);
handles = plot_gui(handles);
guidata(hObject, handles);

function highlight_contours_by_order_in_partition_callback(hObject, handles)
% Makes contours active in certain partitions.
if (handles.app.data.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

% Get the orders that the user would like.
prompt = {'Enter the ORDER (not Id) of contours to highlight:'};
def = {''};
dlgTitle = 'Highlight contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});

% Get the correct partition and the correct contour ids.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
nonnan_contour_ids = find(~isnan([p.clusterIdxsByContour{1:end}]));
num_contours = length(nonnan_contour_ids);

% BP.
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > num_contours) = [];

% Get the orders for all the contours in the partition.
coidx = handles.app.data.currentContourOrderIdx;
nonnan_ordering = handles.app.experiment.contourOrder(coidx).index(nonnan_contour_ids);

% Sort by the order and pick out the contour_orders worth of ids.
nn = [nonnan_ordering; nonnan_contour_ids]';
sorted_nn = sortrows(nn, 1);
contour_ids = sorted_nn(contour_orders,2)';

% Put these contoru ids into the correct structure.
handles.app.data.activeCells = [handles.app.data.activeCells contour_ids];
handles.app.data.activeCells = unique(handles.app.data.activeCells);

% Plot 'n go.
handles = plot_gui(handles);
guidata(hObject, handles);

function highlight_contours_by_cluster_id_callback(hObject, handles)
% Makes contours active based on cluster id
if (handles.app.data.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

prompt = {'Enter the cluster ids:'};
def = {''};
dlgTitle = 'Highlight contours by cluster id';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
cluster_ids_for_highlight = str2num(answer{1});

pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
cluster_ids = [p.clusters.id];

% BP.
cluster_ids_for_highlight = intersect(cluster_ids_for_highlight, cluster_ids);

if(isempty(cluster_ids_for_highlight))
    errordlg('There are no clusters with those ids.');
    return;
end

% First we translate from order to id.
for cid = cluster_ids_for_highlight    
    cidx = find([p.clusters.id] == cid);    
    contour_ids = p.clusters(cidx).contours;    
    handles.app.data.activeCells = [handles.app.data.activeCells contour_ids];
end
handles.app.data.activeCells = unique(handles.app.data.activeCells);

handles = plot_gui(handles);
guidata(hObject, handles);

function connect_highlighted_contours_in_order_callback(hObject, handles)
val = get(hObject, 'Checked');
if (strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');
else
    set(hObject, 'Checked', 'off');
end
handles = plot_gui(handles);
guidata(hObject, handles);

function plot_highlighted_contours_callback(hObject, handles)
plot_highlighted_contours(handles);

function plot_highlighted_contours_zero_callback(hObject, handles)
plot_highlighted_contours_zero_signals(handles);

function delete_contours_by_id_callback(hObject, handles)
% This function 'kills' the appropriate contours.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  If the user wants the
% contour back he/she must reset the clustering.  Reseting the contours
% loses all the information about the 'killed cluster' of deleted contours  
% deleted.  Thus the cluster is really lost, while the contours are not.

% Ask which contours to delete:
prompt={'Enter the ids of the contour to delete:'};
def = {''};
dlgTitle='Kill contour by id';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end

% Set the ids of the contours to be deleted from the active cells handle.
contourtodelete = str2num(answer{1});
% Call to the killcontour function.
handles = killcontour(handles, contourtodelete);
% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
handles = plot_gui(handles);
guidata(handles.fig, handles);

function delete_active_contours_callback(hObject, handles)
% This function 'kills' the appropriate contours.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  If the user wants the
% contour back he/she must reset the clustering.  Reseting the contours
% loses all the information about the 'killed cluster' of deleted contours  
% deleted.  Thus the cluster is really lost, while the contours are not.

% Set the ids of the contours to be deleted from the active cells handle.
contourtodelete = handles.app.data.activeCells;
% Call to the killcontour function.
handles = killcontour(handles, contourtodelete);

%Deactivate the contours which were killed.
handles.app.data.activeCells = [];

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
handles = plot_gui(handles);
guidata(handles.fig, handles);

function turn_active_contours_off_callback(hObject, handles)
% Sometimes it's a pain to turn off all the active contours by
% clicking on them individually, so this function will turn them all
% off without the user having to hunt through the clickmap.
handles.app.data.activeCells = [];
handles = plot_gui(handles);
guidata(hObject, handles);

%% Clustering Menu.

function highlight_all_clusters_callback(hObject, handles)
% Highlights which contours fall into which clusters.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
for cid = 1:p.numClusters
    cluster_color = p.clusters(cid).color;
    new_edge_color = cluster_color;
    handles.app.experiment.partitions(pidx).clusters(cid).doShow = 1;
    set(handles.guiOptions.face.clusterPatchH(cid), 'edgecolor', new_edge_color);
end
handles = plot_gui(handles);
guidata(handles.fig, handles);

function unhighlight_all_clusters_callback(hObject, handles)
% Removes highlights separating contours into clusters.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
for cid = 1:p.numClusters
    handles.app.experiment.partitions(pidx).clusters(cid).doShow = 0;
    set(handles.guiOptions.face.clusterPatchH(cid), 'edgecolor', 'none');
end
handles = plot_gui(handles);
guidata(handles.fig, handles);

function merge_highlighted_clusters_callback(hObject, handles)
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
merge_cluster_ids = [];
for c = 1:p.numClusters
    if (p.clusters(c).doShow == 1)
	cid = p.clusters(c).id;
	merge_cluster_ids(end+1) = cid;
    end
end
if (isempty(merge_cluster_ids))
    return;
end
% Merge the clusters.
handles = mergeclusters(handles, pidx, {merge_cluster_ids});
% Redisplay.
handles = plot_gui(handles);
guidata(hObject, handles);

function delete_clusters_by_id_callback(hObject, handles)
% First we 'kill' the appropriate cluster.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  Of course if the
% user decides to reset the clustering, then the user can have the
% contours back (that composed the cluster.)  Reseting the contours
% loses all the information about the 'killed' cluster.  Thus the
% cluster is really lost, while the contours are not.

% Note that this function uses the old setup of (globals, exp) that
% was used in the early version of this code.

% Get the cluster sizes for deletion.
prompt={'Enter the ids of clusters to delete:'};
def = {''};
dlgTitle='Kill clusters by id';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
% Set up the variable argument used to kill the clusters.
varargin{1} = 'clusters';
varargin{2} = str2num(answer{1});
handles = killclusters(handles, handles.app.experiment, varargin{:});

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
handles = plot_gui(handles);
guidata(handles.fig, handles);

%% delete_clusters_by_size_callback
function delete_clusters_by_size_callback(hObject, handles)
% First we 'kill' the appropriate cluster.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  Of course if the
% user decides to reset the clustering, then the user can have the
% contours back (that composed the cluster.)  Reseting the contours
% loses all the information about the 'killed' cluster.  Thus the
% cluster is really lost, while the contours are not. 

% Note that this function uses the old setup of (globals, exp) that
% was used in the early version of this code.

% This is the menu item, and the data is in the context menu, which
% is the parent.

% Get the cluster sizes for deletion.
prompt={'Enter the sizes of clusters to delete:'};
def = {''};
dlgTitle='Mask title';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
% Set up the variable argument used to kill the clusters.
varargin{1} = 'bysize';
varargin{2} = str2num(answer{1});
handles = killclusters(handles, handles.app.experiment, varargin{:});

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
handles = plot_gui(handles);
guidata(handles.fig, handles);


function delete_contours_by_order_callback(hObject, handles)
% Get the cluster sizes for deletion.
prompt = {'Enter the ORDER (not Id) of contours to delete:'};
def = {''};
dlgTitle = 'Kill contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > handles.app.experiment.numContours) = [];
% First we translate from order to id.
coidx = handles.app.data.currentContourOrderIdx;
contour_ids = handles.app.experiment.contourOrder(coidx).order(contour_orders);
handles = delete_contours_from_partition(handles, contour_ids);
handles = plot_gui(handles);
guidata(hObject, handles);

function order_clusters_by_intensity_peak_callback(hObject, handles);
%Take the clean version of the mean intensity of each cluster, find the
%peak intensity and then set up their cluster order by when their peaks 
%occur relative to each other.
pidx = handles.app.data.currentPartitionIdx;
handles = order_clusters_by_intensity_peak (handles, pidx);
handles = plot_gui(handles);
guidata(hObject, handles);


%% Functions Menu.
function signal_functions_callback(hObject, handles)
fname = get(hObject, 'UserData');
handles = feval(fname, handles);
% There is a question of how to handle the graphics handles that might
% be changed as a result of these calls.  I'm not sure what to do here
% but I'm inclined to save only the experiment part of handles and
% show any graphics changes, but not save them.  -DCS:2005/08/02
guidata(hObject, handles);

%% Debug Menu
function save_handles_callback(hObject, handles)
assignin('base','caltracer_handles',handles);