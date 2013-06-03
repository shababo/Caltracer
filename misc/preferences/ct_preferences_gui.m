function newhandles = ct_preferences_gui(handles, varargin)
%This handles the preferences set in the gui.

handles.app.guiopen = 1;
handles = ct_preferences_load (handles);
if (~isfield(handles.app.preferences, 'defaults'))
    handles=setdefaults(handles);
end

if nargin==1
handles = initialize_gui (handles);
end
newhandles = handles;


function newhandles = setdefaults(handles)
    %set initial default values (in case it was never run before)
    handles.app.preferences.showCheckBoxTag = 'showcheckbox';
    handles.app.preferences.showHaloCheckBoxTag = 'showhalocheckbox';
    handles.app.preferences.KeepPrevPref = 0; 
    handles.app.preferences.SpResolution = 1;
    handles.app.preferences.TpResolution = 0.1;
    handles.app.preferences.SingleRegion = 0;
    handles.app.preferences.Lcol = 0;
    handles.app.preferences.Rcol = 0;
    handles.app.preferences.Urow = 0;
    handles.app.preferences.Lrow = 0;
    handles.app.preferences.zstack = 1;
    handles.app.preferences.zstackonly = 0;
    handles.app.preferences.CellDiam = 10;
    handles.app.preferences.CellDiamOnly = 0;
    handles.app.preferences.Filter = 1;
    handles.app.preferences.FilterOnly = 0;
    handles.app.preferences.autoLoadContours = 0;
    handles.app.preferences.AutoDetect = 0;
    handles.app.preferences.AutoFind = 0;
    handles.app.preferences.AutoAdjust = 0;
    handles.app.preferences.haloMode = 1; % use halos = 1, don't = 0.
    handles.app.preferences.HaloQuest = 1;
    handles.app.preferences.AutoHalo = 0;
    handles.app.preferences.Halo_Area = 1;
    handles.app.preferences.MaskQuest.index = 0;
    handles.app.preferences.MaskPulldown = 1;
    handles.app.preferences.NumMaskVal = 0;
    handles.app.preferences.FlipSigQuest.index = 0;
    handles.app.preferences.FlipSigQuest.Options='Yes';
    handles.app.preferences.FlipSignal_PullDown = 1;
    handles.app.preferences.CutoffVal = 12;
    handles.app.preferences.MinAreaVal = 20;
    handles.app.preferences.MaxAreaVal = 1000;
    handles.app.preferences.PiLimitVal = 3.6;
    handles.app.preferences.defReadTraces = 0;
    handles.app.preferences.ReadTracesVal = 1000;
    handles.app.preferences.dimreduc = 1;
    handles.app.preferences.classifier = 1;
    handles.app.preferences.orderrout = 1;
    handles.app.preferences.Num_ClustVal = 3;
    handles.app.preferences.signaldetect = 1;
    handles.app.preferences.Num_TrialVal = 10;
    handles.app.preferences.SetDetectOptions = 0;
    handles.app.preferences.SignalDetectOptions = '';
    handles.app.preferences.preprocessorOptions = 0;
    handles.app.preferences.preprocessdefaults{1} = 'ct_dfof_options';
    handles.app.preferences.preprocessdefaults{2} = struct;
    handles.app.preferences.preprocessdefaultsstring {1} = 'dfof';
    handles.app.preferences.preprocessdefaultsstring {2} = 'halo_subtract';
    handles.app.preferences.preprocessdefaultsvalue = 1;
    handles.app.preferences.CloseButton = 0;
    handles.app.preferences.AutoExportTileRegionVals = 0;
    handles.app.preferences.AllowTraceYZoom = 0;
    handles.app.preferences.defaults = 1;
    newhandles=handles;
    ct_preferences_save(newhandles);
    

%This function initializes the gui with default values (and resets to
%default values when the reset button is hit)
function newhandles = initialize_gui(handles)

    %creates preferences figure
    handles.app.preferences.prefgui = figure('Name', ...
		     'Preferences',...
		     'NumberTitle','off',...
		     'MenuBar','none',...
		     'ToolBar', 'none', ...
		     'doublebuffer','on',...
		     'Resize', 'on', ...
             'Position', [550 350 500 500],...
             'units','pixels');
         
hObject = handles.app.preferences.prefgui;

%% -----Image Settings-----
%% Resolution settings
handles.app.preferences.gui.resolutionpanel = ...
                    uipanel('Parent',hObject,'Title','Resolution',...
                    'FontWeight', 'bold',...
                    'Position',[0 .75 .45 .155]);
                        

handles.app.preferences.gui.SpatialText = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'text',...
                    'String', 'Spatial:',...
                    'Position',[10 35 50 20]);
                
handles.app.preferences.gui.SpatialUnits = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'text',...
                    'String', 'µm/pixel',...
                    'Position',[115 35 50 20]);
handles.app.preferences.gui.SpatialValue = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'edit',...
                    'String', handles.app.preferences.SpResolution,...
                    'Position',[70 37.5 40 20],...
                    'Callback',{@SpatialValue_Callback,handles});
handles.app.preferences.gui.TemporalText = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'text',...
                    'String', 'Temporal:',...
                    'Position',[10 6 50 20]);

handles.app.preferences.gui.TemporalUnits = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'text',...
                    'String', 'sec/frame',...
                    'Position',[115 6 50 20]);

handles.app.preferences.gui.TemporalValue = ...
                    uicontrol(handles.app.preferences.gui.resolutionpanel,...
                    'Style', 'edit',...
                    'String', handles.app.preferences.TpResolution,...
                    'Position',[70 8.5 40 20],...
                    'Callback',{@TemporalValue_Callback,handles});
                
%% Region Settings

handles.app.preferences.gui.Region = ...
                    uipanel('Parent',hObject,'Title','Region Options',...
                    'FontWeight', 'bold',...
                    'Position',[0 .63 .45 .1]);
                
handles.app.preferences.gui.Single_Region = ...
                    uicontrol(handles.app.preferences.gui.Region,...
                    'Style', 'checkbox',...
                    'String','Only use a single region',...
                    'Value',handles.app.preferences.SingleRegion,...
                    'Position',[3 10 160 20],...
                    'Callback',{@Single_Region_Callback,handles});                 
    
                
%% Rows and Columns to be Excluded
handles.app.preferences.gui.RowCol = ...
                    uipanel('Parent',hObject,'Title','Rows and Columns Excluded',...
                    'FontWeight', 'bold',...
                    'Position',[0 .33 .45 .297]);
                                              
handles.app.preferences.gui.LeftCol = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'text',...
                    'String', 'Left Column:',...
                    'Position',[10 105 70 20]);
                
handles.app.preferences.gui.LeftColValue = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'edit',...
                    'String', handles.app.preferences.Lcol,...
                    'Position',[90 108.5 40 20],...
                    'Callback',{@LeftColValue_Callback,handles});                

handles.app.preferences.gui.RightCol = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'text',...
                    'String', 'Right Column:',...
                    'Position',[10 81 70 20]);
                
handles.app.preferences.gui.RightColValue = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'edit',...
                    'String', handles.app.preferences.Rcol,...
                    'Position',[90 83.5 40 20 ],...
                    'Callback',{@RightColValue_Callback,handles}); 
                
handles.app.preferences.gui.UpperRow = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'text',...
                    'String', 'Upper Rows:',...
                    'Position',[10  56 70 20]);

handles.app.preferences.gui.UpperRowValue = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'edit',...
                    'String', handles.app.preferences.Urow,...
                    'Position',[90 58.5 40 20],...
                    'Callback',{@UpperRowValue_Callback,handles}); 
                
handles.app.preferences.gui.LowerRow = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'text',...
                    'String', 'Lower Rows:',...
                    'Position',[10 31 70 20 ]);

handles.app.preferences.gui.LowerRowValue = ...
                    uicontrol(handles.app.preferences.gui.RowCol,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.Lrow,...
                    'Position',[90 33.5 40 20],...
                    'Callback',{@LowerRowValue_Callback,handles}); 
               
%% Z-stack options
handles.app.preferences.gui.Z_Stack = ...
                    uipanel('Parent',hObject,'Title','Z-Stack Option Defaults',...
                    'FontWeight', 'bold',...
                    'Position',[.5 .75 .45 .15]);

handles.app.preferences.gui.zstack_only = ...
                    uicontrol(handles.app.preferences.gui.Z_Stack,...
                    'Style', 'checkbox',...
                    'String','Only use the z-stack below:',...
                    'Value',handles.app.preferences.zstackonly,...
                    'Position',[3 30 160 20],...
                    'Callback',{@zstack_only_Callback,handles});   
                
[str,zstack_names]=readdir(handles, 'zstacks');               
handles.app.preferences.gui.zstack_pulldown = ...
                    uicontrol(handles.app.preferences.gui.Z_Stack,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.zstack,...
                    'Position',[15 5 160 20],...
                    'Callback',{@zstack_pulldown_Callback,handles});      
                
%% Filter Options 

handles.app.preferences.gui.Filter = ...
                    uipanel('Parent',hObject,'Title','Filtering Option Defaults',...
                    'FontWeight', 'bold',...
                    'Position',[.5 .425 .45 .3]);

handles.app.preferences.gui.CellDiam_Only = ...
                    uicontrol(handles.app.preferences.gui.Filter,...
                    'Style', 'checkbox',...
                    'String','Only use this cell diameter:',...
                    'Value',handles.app.preferences.CellDiamOnly,...
                    'Position',[3 55 160 20],...
                    'Callback',{@CellDiam_Only_Callback,handles});   
                
handles.app.preferences.gui.CellDiam = ...
                    uicontrol(handles.app.preferences.gui.Filter,...
                    'Style', 'text',...
                    'String', 'Cell Diameter:',...
                    'Position',[20 30 70 20 ]);

handles.app.preferences.gui.CellDiamValue = ...
                    uicontrol(handles.app.preferences.gui.Filter,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.CellDiam,...
                    'Position',[95 33.5 40 20],...
                    'Callback',{@CellDiamValue_Callback,handles}); 
                
handles.app.preferences.gui.Filter_Only = ...
                    uicontrol(handles.app.preferences.gui.Filter,...
                    'Style', 'checkbox',...
                    'String','Auto-filter initially with:',...
                    'Value',handles.app.preferences.FilterOnly,...
                    'Position',[3 107 160 20],...
                    'Callback',{@Filter_Only_Callback,handles});   
                
[str,filter_names]=readdir(handles, 'imagefilters');               
handles.app.preferences.gui.filter_pulldown = ...
                    uicontrol(handles.app.preferences.gui.Filter,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.Filter,...
                    'Position',[20 85 160 20],...
                    'Callback',{@Filter_pulldown_Callback,handles});      

%% -----Cell Detection-----

%% Cell Detection Defaults

handles.app.preferences.gui.CellDetect = ...
                    uipanel('Parent',hObject,'Title','Cell Detection Defaults',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .6 .55 .3]);

handles.app.preferences.gui.Cutoff = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'text',...
                    'String', 'Cell Detect Cutoff %:',...
                    'Position',[25 97 120 30 ]);
                
handles.app.preferences.gui.Cutoff_Value = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.CutoffVal,...
                    'Position',[150 112 40 20],...
                    'Callback',{@Cutoff_Value_Callback,handles});
                
handles.app.preferences.gui.Min_Area = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'text',...
                    'String', 'Cell Detect Min Area:',...
                    'Position',[24 67 120 30 ]);
                
handles.app.preferences.gui.Min_Area_Value = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.MinAreaVal,...
                    'Position',[150 82 40 20],...
                    'Callback',{@Min_Area_Value_Callback,handles});
                
handles.app.preferences.gui.Max_Area = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'text',...
                    'String', 'Cell Detect Max Area:',...
                    'Position',[25 37 120 30 ]);
                
handles.app.preferences.gui.Max_Area_Value = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.MaxAreaVal,...
                    'Position',[150 52 40 20],...
                    'Callback',{@Max_Area_Value_Callback,handles});
                
handles.app.preferences.gui.Pi_Limit = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'text',...
                    'String', 'Pi Limit:',...
                    'Position',[30 7 45 30 ]);
                
handles.app.preferences.gui.Pi_Limit_Value = ...
                    uicontrol(handles.app.preferences.gui.CellDetect,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.PiLimitVal,...
                    'Position',[150 22 40 20],...
                    'Callback',{@Pi_Limit_Value_Callback,handles});

%% Cell Detection Auto Actions Options

handles.app.preferences.gui.AutoCellDetect = ...
                    uipanel('Parent',hObject,'Title','Automatic Actions',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .3 .8 .3]);
                
handles.app.preferences.gui.AutoLoad = ...
                    uicontrol(handles.app.preferences.gui.AutoCellDetect,...
                    'Style', 'checkbox',...
                    'String','Auto-Load contours from file',...
                    'Value',handles.app.preferences.autoLoadContours,...
                    'Position',[3 107 200 20],...
                    'Callback',{@AutoLoad_Callback,handles});                
                
handles.app.preferences.gui.Detect_Cells = ...
                    uicontrol(handles.app.preferences.gui.AutoCellDetect,...
                    'Style', 'checkbox',...
                    'String','Auto-Detect with preferred values',...
                    'Value',handles.app.preferences.AutoDetect,...
                    'Position',[3 87 200 20],...
                    'Callback',{@Detect_Cells_Callback,handles});  
                
handles.app.preferences.gui.Find_Cells = ...
                    uicontrol(handles.app.preferences.gui.AutoCellDetect,...
                    'Style', 'checkbox',...
                    'String','Auto-Find using preferred values',...
                    'Value',handles.app.preferences.AutoFind,...
                    'Position',[3 67 200 20],...
                    'Callback',{@Find_Cells_Callback,handles}); 
                
handles.app.preferences.gui.Adjust_Cells = ...
                    uicontrol(handles.app.preferences.gui.AutoCellDetect,...
                    'Style', 'checkbox',...
                    'String','Auto-Adjust using preferred values',...
                    'Value',handles.app.preferences.AutoAdjust,...
                    'Position',[3 47 200 20],...
                    'Callback',{@Adjust_Cells_Callback,handles}); 

if handles.app.preferences.autoLoadContours == 1
    set (handles.app.preferences.gui.Detect_Cells, 'Enable','Off','Value',0);
end


%% Gui for Halo Options

handles.app.preferences.gui.HaloPanel = ...
                    uipanel('Parent',hObject,'Title','Halo Options',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[.5 .6 .8 .3]);          
                
handles.app.preferences.gui.HaloQuestion = ...
                    uicontrol(handles.app.preferences.gui.HaloPanel,...
                    'Style', 'checkbox',...
                    'String','Do Not Require Update Button hit',...
                    'Value',handles.app.preferences.HaloQuest,...
                    'Position',[3 107 200 20],...
                    'Callback',{@Halo_Callback,handles});
                
handles.app.preferences.gui.HaloArea = ...
                    uicontrol(handles.app.preferences.gui.HaloPanel,...
                    'Style', 'text',...
                    'String', 'Default Halo Area:',...
                    'Position',[3 77 90 20 ]);
                
handles.app.preferences.gui.HaloArea_Value = ...
                    uicontrol(handles.app.preferences.gui.HaloPanel,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.Halo_Area,...
                    'Position',[120 80 40 20],...
                    'Callback',{@HaloArea_Value_Callback,handles});
                
handles.app.preferences.gui.AutoHalo = ...
                    uicontrol(handles.app.preferences.gui.HaloPanel,...
                    'Style', 'checkbox',...
                    'String','Autoupdate Halos with Default Area',...
                    'Value',handles.app.preferences.AutoHalo,...
                    'Position',[3 52 200 20],...
                    'Callback',{@AutoHalo_Callback,handles});



%% Gui for Mask Options

handles.app.preferences.gui.MaskPanel = ...
                    uipanel('Parent',hObject,'Title','Mask Options',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[.5 .4 .55 .2]);
                                              


%checks to see if options loaded are present (to make Mask options visible)
if (handles.app.preferences.MaskQuest.index ==0)
    MaskEnable = 'off';
    NumMaskEnable = 'off';
else
    MaskEnable = 'on';
    if (handles.app.preferences.MaskPulldown == 2)
        NumMaskEnable = 'off';
    else
        NumMaskEnable = 'on';
    end
end

handles.app.preferences.gui.MaskQuestion = ...
                    uicontrol(handles.app.preferences.gui.MaskPanel,...
                    'Style','checkbox',...
                    'String','Set Mask Question, Load Masks?',...
                    'Value',handles.app.preferences.MaskQuest.index,...
                    'Position',[3 60 250 20],...
                    'Callback',{@MaskQuestion_Callback,handles});
                
handles.app.preferences.gui.MaskPullDown = ...
                    uicontrol(handles.app.preferences.gui.MaskPanel,...
                    'Style','popupmenu',...
                    'String',{'Yes, open masks','No, do not use masks'},...
                    'Value',handles.app.preferences.MaskPulldown,...
                    'Position',[23 40 200 20],...
                    'Enable',MaskEnable,...
                    'Callback',{@MaskPullDown_Callback,handles});
                
handles.app.preferences.gui.NumMasks = ...
                    uicontrol(handles.app.preferences.gui.MaskPanel,...
                    'Style', 'text',...
                    'String', 'If yes, how many?',...
                    'Enable', NumMaskEnable,...
                    'Position',[23 10 120 20]);
                
handles.app.preferences.gui.NumMask_Value = ...
                    uicontrol(handles.app.preferences.gui.MaskPanel,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.NumMaskVal,...
                    'Enable',NumMaskEnable,...
                    'Position',[150 13 40 20],...
                    'Callback',{@NumMask_Value_Callback,handles});
                

%% Gui for Flip Signal Question               

handles.app.preferences.gui.FlipSigPanel = ...
                    uipanel('Parent',hObject,'Title','Signal Flipping Properties',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .7 .8 .2]);

%checks to see if options loaded are present (to make FlipSignal options visible)
if (handles.app.preferences.FlipSigQuest.index ==0)
    FlipEnable = 'off';
else
    FlipEnable = 'on';
end
                
handles.app.preferences.gui.FlipSignal_PullDown = ...
                    uicontrol(handles.app.preferences.gui.FlipSigPanel,...
                    'Style','popupmenu',...
                    'String',{'Yes, flip the traces','No, do not flip the traces'},...
                    'Value',handles.app.preferences.FlipSignal_PullDown,...
                    'Position',[23 30 150 20],...
                    'Enable',FlipEnable,...
                    'Callback',{@FlipSignal_PullDown_Callback,handles});
                
handles.app.preferences.gui.FlipSignal_Quest = ...
                    uicontrol(handles.app.preferences.gui.FlipSigPanel,...
                    'Style','checkbox',...
                    'String','Set Flip traces Question, Flip Signal?',...
                    'Value',handles.app.preferences.FlipSigQuest.index,...
                    'Position',[3 50 250 20],...
                    'Callback',{@FlipSignal_Quest_Callback,handles});

                
%% Gui for Working Memory Estimate               

handles.app.preferences.gui.WorkMemPanel = ...
                    uipanel('Parent',hObject,'Title','Working Memory Estimate',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[.5 .7 .8 .2]);

%checks to see if options loaded are present (to make WorkMem options visible)
if (handles.app.preferences.defReadTraces==0)
    TiffNumEnable = 'off';
else
    TiffNumEnable = 'on';
end
                               
handles.app.preferences.gui.WorkMem_Quest = ...
                    uicontrol(handles.app.preferences.gui.WorkMemPanel,...
                    'Style','checkbox',...
                    'String','Set working memory estimate?',...
                    'Value',handles.app.preferences.defReadTraces,...
                    'Position',[3 50 250 20],...
                    'Callback',{@WorkMem_Quest_Callback,handles});
                
handles.app.preferences.gui.TiffStack = ...
                    uicontrol(handles.app.preferences.gui.WorkMemPanel,...
                    'Style', 'text',...
                    'String', 'Default number of tiffs to open at once:',...
                    'Enable', TiffNumEnable,...
                    'Position',[5 20 100 30 ]);
                
handles.app.preferences.gui.TiffStack_Value = ...
                    uicontrol(handles.app.preferences.gui.WorkMemPanel,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.ReadTracesVal,...
                    'Position',[120 25 40 20],...
                    'Enable', TiffNumEnable,...
                    'Callback',{@TiffStack_Value_Callback,handles});
    
                
%% Signal Preference Defaults                
handles.app.preferences.gui.SignalPrefs = ...
                    uipanel('Parent',hObject,'Title','Signal Preference Defaults',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .3 .97 .35]);


handles.app.preferences.gui.dim_reducer = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Dimensionality Reducer:',...
                    'Position',[10 120 120 30 ]);
                 
[str,dimreduc_names]=readdir(handles, 'dimreducers');               
handles.app.preferences.gui.dimreduc_pulldown = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.dimreduc,...
                    'Position',[130 135 160 20],...
                    'Callback',{@dimreduc_pulldown_Callback,handles}); 
                
handles.app.preferences.gui.classifier = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Cluster Method:',...
                    'Position',[10 90 75 30 ]);
                 
[str,classifier_names]=readdir(handles, 'classifiers');               
handles.app.preferences.gui.classifier_pulldown = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.classifier,...
                    'Position',[130 105 160 20],...
                    'Callback',{@classifier_pulldown_Callback,handles});                  
          
handles.app.preferences.gui.Num_Clust = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Number of clusters:',...
                    'Position',[10 60 95 30 ]);
                
handles.app.preferences.gui.Num_Clust_Value = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.Num_ClustVal,...
                    'Position',[130 75 40 20],...
                    'Callback',{@Num_Clust_Value_Callback,handles});
                
handles.app.preferences.gui.Num_Trial = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Number of trials:',...
                    'Position',[210 60 80 30 ]);
                
handles.app.preferences.gui.Num_Trial_Value = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'edit',...
                    'String',handles.app.preferences.Num_TrialVal,...
                    'Position',[300 75 40 20],...
                    'Callback',{@Num_Trial_Value_Callback,handles});                
                          
handles.app.preferences.gui.order_routine = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Order Routine:',...
                    'Position',[10 30 72 30 ]);
                 
[str,orderrout_names]=readdir(handles, 'orderroutines');               
handles.app.preferences.gui.orderrout_pulldown = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.orderrout,...
                    'Position',[130 45 160 20],...
                    'Callback',{@orderrout_pulldown_Callback,handles});          
                
handles.app.preferences.gui.signal_detector = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'text',...
                    'String', 'Signal Detector:',...
                    'Position',[10 0 82 30 ]);
                 
[str,signaldetect_names]=readdir(handles, 'signaldetectors');               
handles.app.preferences.gui.signaldetect_pulldown = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style', 'popupmenu',...
                    'String', str,...
                    'Value', handles.app.preferences.signaldetect,...
                    'Position',[130 15 160 20],...
                    'Callback',{@signaldetect_pulldown_Callback,handles});     
                          
handles.app.preferences.gui.SetDetectOptions = ...
                    uicontrol(handles.app.preferences.gui.SignalPrefs,...
                    'Style','checkbox',...
                    'String','Autodetect signals?',...
                    'Value',handles.app.preferences.SetDetectOptions,...
                    'Position',[300 15 250 20],...
                    'Callback',{@SetDetectOptions_Callback,handles});
                
                
%% Preprocessing Default Options
handles.app.preferences.gui.PreprocessDefaults = ...
                    uipanel('Parent',hObject,'Title','Preprocessing Defaults',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .4 .97 .5]);

handles.app.preferences.gui.proprocessoptions = ...
                    uicontrol(handles.app.preferences.gui.PreprocessDefaults,...
                    'Style','checkbox',...
                    'String','Set Default Preprocessors',...
                    'Value',handles.app.preferences.preprocessorOptions,...
                    'Position',[10 210 250 20],...
                    'Callback',{@PreprocessorOptions_Callback,handles});
                
%checks to see if options loaded are present (to make Preprocess options visible)
if (handles.app.preferences.preprocessorOptions ==0)
    PreprocessEnable = 'off';
else
    PreprocessEnable = 'on';
end
                
[str,preprocessor_names]=readdir(handles, 'preprocessors');     
handles.app.preferences.gui.preprocessors_pulldown = ...
                    uicontrol(handles.app.preferences.gui.PreprocessDefaults,...
                    'Style', 'listbox',...
                    'Max', length(str),...
                    'String', str,...
                    'Value', handles.app.preferences.preprocessdefaultsvalue,...
                    'Enable', PreprocessEnable,...
                    'Position',[30 0 250 200],...
                    'Callback',{@preprocess_defaults_Callback,handles});  

%% Other Options
handles.app.preferences.gui.OtherOptions = ...
                    uipanel('Parent',hObject,'Title','Other Options',...
                    'FontWeight', 'bold',...
                    'Visible', 'Off',...
                    'Position',[0 .25 .97 .1]);
                
handles.app.gui.AutoExportTileRegionVals = ...
                    uicontrol(handles.app.preferences.gui.OtherOptions,...
                    'Style','checkbox',...
                    'String','Export values when tiling at angle?',...
                    'Value',handles.app.preferences.AutoExportTileRegionVals,...
                    'Position',[10 10 250 20],...
                    'Callback',{@AutoExportTileRegionVals_Callback,handles});
                
handles.app.gui.AllowTraceYZoom = ...
                    uicontrol(handles.app.preferences.gui.OtherOptions,...
                    'Style','checkbox',...
                    'String','Enable Y-Zooming of Traces?',...
                    'Value',handles.app.preferences.AllowTraceYZoom,...
                    'Position',[10 -10 250 20],...
                    'Callback',{@AllowTraceYZoom_Callback,handles});      
                
%% Buttons 
% Default open:

handles.app.preferences.gui.Buttons = uibuttongroup ('SelectionChangeFcn',{@ButtonBehavior, handles});

                    handles.app.preferences.gui.ImageSettings = ...
                    uicontrol(handles.app.preferences.gui.Buttons,...
                    'Tag','Image_Settings',...
                    'String','Image Settings',...
                    'Style', 'togglebutton',...
                    'Value', 1,...
                    'Position', [50 470 100 25]);

                    handles.app.preferences.gui.CellDetect = ...
                    uicontrol(handles.app.preferences.gui.Buttons,...
                    'Tag','Cell_Detection',...
                    'String','Cell Detection',...
                    'Style', 'togglebutton',...
                    'Position', [150 470 100 25]);
                
                    handles.app.preferences.gui.SignalDetect = ...
                    uicontrol(handles.app.preferences.gui.Buttons,...
                    'Tag','Signal_Detection',...
                    'String','Signal Detection',...
                    'Style', 'togglebutton',...
                    'Position', [250 470 100 25]);
                
                    handles.app.preferences.gui.Other = ...
                    uicontrol(handles.app.preferences.gui.Buttons,...
                    'Tag','Other',...
                    'String','Other',...
                    'Style', 'togglebutton',...
                    'Position', [350 470 100 25]);
                
            
                
                
                
                
%% CloseButton
handles.app.preferences.gui.CloseButton = ...
                    uicontrol(hObject,...
                    'Style','togglebutton',...
                    'String','Close',...
                    'Value',handles.app.preferences.CloseButton,...
                    'Callback',{@CloseButton_Callback,handles});
                      
ct_preferences_save(handles);
newhandles = handles;
% --- End of initialize.



% --- Executes on Hit of any button.
function ButtonBehavior (hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'Image_Settings' % --- Executes on change in Image Settings Hit.
      set(handles.app.preferences.gui.resolutionpanel,'Visible','On');
      set(handles.app.preferences.gui.Region,'Visible','On');
      set(handles.app.preferences.gui.RowCol,'Visible','On');
      set(handles.app.preferences.gui.Z_Stack,'Visible','On');
      set(handles.app.preferences.gui.Filter,'Visible','On');
      set(handles.app.preferences.gui.CellDetect,'Visible','Off');
      set(handles.app.preferences.gui.AutoCellDetect,'Visible','Off');
      set(handles.app.preferences.gui.HaloPanel,'Visible','Off');
      set(handles.app.preferences.gui.MaskPanel,'Visible','Off');
      set(handles.app.preferences.gui.SignalPrefs,'Visible','Off');   
      set(handles.app.preferences.gui.FlipSigPanel,'Visible','Off'); 
      set(handles.app.preferences.gui.WorkMemPanel,'Visible','Off');
      set(handles.app.preferences.gui.PreprocessDefaults,'Visible','Off'); 
      set(handles.app.preferences.gui.OtherOptions,'Visible','Off');
      
    case 'Cell_Detection' % --- Executes on change in Cell Detection Hit.
      set(handles.app.preferences.gui.resolutionpanel,'Visible','Off');
      set(handles.app.preferences.gui.Region,'Visible','Off');
      set(handles.app.preferences.gui.RowCol,'Visible','Off');
      set(handles.app.preferences.gui.Z_Stack,'Visible','Off');
      set(handles.app.preferences.gui.Filter,'Visible','Off');
      set(handles.app.preferences.gui.CellDetect,'Visible','On');
      set(handles.app.preferences.gui.AutoCellDetect,'Visible','On');
      set(handles.app.preferences.gui.HaloPanel,'Visible','On');
      set(handles.app.preferences.gui.MaskPanel,'Visible','On');
      set(handles.app.preferences.gui.SignalPrefs,'Visible','Off');
      set(handles.app.preferences.gui.FlipSigPanel,'Visible','Off'); 
      set(handles.app.preferences.gui.WorkMemPanel,'Visible','Off');
      set(handles.app.preferences.gui.PreprocessDefaults,'Visible','Off'); 
      set(handles.app.preferences.gui.OtherOptions,'Visible','Off');
 
    case 'Signal_Detection' % --- Executes on change in Signal Detection Hit.
      set(handles.app.preferences.gui.resolutionpanel,'Visible','Off');
      set(handles.app.preferences.gui.Region,'Visible','Off');
      set(handles.app.preferences.gui.RowCol,'Visible','Off');
      set(handles.app.preferences.gui.Z_Stack,'Visible','Off');
      set(handles.app.preferences.gui.Filter,'Visible','Off');
      set(handles.app.preferences.gui.CellDetect,'Visible','Off');
      set(handles.app.preferences.gui.AutoCellDetect,'Visible','Off');
      set(handles.app.preferences.gui.HaloPanel,'Visible','Off');
      set(handles.app.preferences.gui.MaskPanel,'Visible','Off');
      set(handles.app.preferences.gui.SignalPrefs,'Visible','On');
      set(handles.app.preferences.gui.FlipSigPanel,'Visible','On'); 
      set(handles.app.preferences.gui.WorkMemPanel,'Visible','On');
      set(handles.app.preferences.gui.PreprocessDefaults,'Visible','Off'); 
      set(handles.app.preferences.gui.OtherOptions,'Visible','Off');
      
    case 'Other' % --- Executes on change in Other Hit.
      set(handles.app.preferences.gui.resolutionpanel,'Visible','Off');
      set(handles.app.preferences.gui.Region,'Visible','Off');
      set(handles.app.preferences.gui.RowCol,'Visible','Off');
      set(handles.app.preferences.gui.Z_Stack,'Visible','Off');
      set(handles.app.preferences.gui.Filter,'Visible','Off');
      set(handles.app.preferences.gui.CellDetect,'Visible','Off');
      set(handles.app.preferences.gui.AutoCellDetect,'Visible','Off');
      set(handles.app.preferences.gui.HaloPanel,'Visible','Off');
      set(handles.app.preferences.gui.MaskPanel,'Visible','Off');
      set(handles.app.preferences.gui.SignalPrefs,'Visible','Off'); 
      set(handles.app.preferences.gui.FlipSigPanel,'Visible','Off'); 
      set(handles.app.preferences.gui.WorkMemPanel,'Visible','Off'); 
      set(handles.app.preferences.gui.PreprocessDefaults,'Visible','On'); 
      set(handles.app.preferences.gui.OtherOptions,'Visible','On');
end

% --- Executes on change in Z-Stack .
function newhandles = zstack_only_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');

handles.app.preferences.zstackonly = val;    
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Z-Stack Selsection.
function newhandles = zstack_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.zstack = val;
handles.app.preferences.zstackname = str{val};
      
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Filter Checkbox .
function newhandles = Filter_Only_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
handles.app.preferences.FilterOnly = val;    
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Filter Selsection.
function newhandles = Filter_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.Filter = val;
handles.app.preferences.FilterName = str{val};
      
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Cell Diameter Checkbox .
function newhandles = CellDiam_Only_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
handles.app.preferences.CellDiamOnly = val;    
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Cell Diameter.
function newhandles = CellDiamValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val = get(hObject,'string');
val = str2double(val);
handles.app.preferences.CellDiam = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Spatial Resolution Value.
function newhandles = SpatialValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.SpResolution = val;
     
lidx = get_label_idx(handles, 'resolution');
set(handles.uigroup{lidx}.inptsr,'string',val);

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Temporal Resolution Value.
function newhandles = TemporalValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.TpResolution = val;
  
lidx = get_label_idx(handles, 'resolution');
set(handles.uigroup{lidx}.inpttr,'string',val);
      
ct_preferences_save(handles);

newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Single Region Checkbox .
function newhandles = Single_Region_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
handles.app.preferences.SingleRegion = val;    
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Left Column.
function newhandles = LeftColValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Lcol = val;

lidx = get_label_idx(handles, 'filterimagebadpixels');      
set(handles.uigroup{lidx}.leftcols,'String',num2str(val));

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject);

% --- Executes on change in Right Column.
function newhandles = RightColValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Rcol = val;
      
lidx = get_label_idx(handles, 'filterimagebadpixels');      
set(handles.uigroup{lidx}.rightcols,'String',num2str(val));
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Upper Row.
function newhandles = UpperRowValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Urow = val;
      
lidx = get_label_idx(handles, 'filterimagebadpixels');      
set(handles.uigroup{lidx}.upperrows,'String',num2str(val));
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Lower Row.
function newhandles = LowerRowValue_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Lrow = val;
      
lidx = get_label_idx(handles, 'filterimagebadpixels');      
set(handles.uigroup{lidx}.lowerrows,'String',num2str(val));

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);



% --- Executes on button press in Halo_Question.
function newhandles = Halo_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.skipThroughSettings.haloUpdate.index = 1;
    handles.app.preferences.HaloQuest = 1;
else
    %not checked    
    handles.app.skipThroughSettings.haloUpdate.index = 1;
    handles.app.preferences.HaloQuest = 1;
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on hit of Auto Halo Checkbox.
function newhandles = AutoHalo_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.AutoHalo = 1;
else
    %not checked    
    handles.app.preferences.AutoHalo = 0;
end
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);
                   
% --- Executes on change in Halo Area.
function newhandles = HaloArea_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Halo_Area = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on button press in Mask_Question.
function newhandles = MaskQuestion_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.MaskQuest.index = 1;
    set (handles.app.preferences.gui.MaskPullDown,'Enable','on');
    set (handles.app.preferences.gui.NumMask_Value, 'Enable', 'On');
    set (handles.app.preferences.gui.NumMasks, 'Enable', 'On');
    
else
    %not checked    
    handles.app.preferences.MaskQuest.index = 0;
    set (handles.app.preferences.gui.MaskPullDown,'Enable','off');
    set (handles.app.preferences.gui.NumMask_Value, 'Enable', 'Off');
    set (handles.app.preferences.gui.NumMasks, 'Enable', 'Off');
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on selection change in MaskPullDown.
function newhandles = MaskPullDown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
    switch val;
        case 1
            handles.app.preferences.MaskQuest.Options='Yes';
            handles.app.preferences.MaskPulldown = 1;
            set (handles.app.preferences.gui.NumMask_Value, 'Enable', 'On');
            set (handles.app.preferences.gui.NumMasks, 'Enable', 'On');
        case 2
            handles.app.preferences.MaskQuest.Options='No';
            handles.app.preferences.MaskPulldown = 2;
            set (handles.app.preferences.gui.NumMask_Value, 'Enable', 'Off');
            set (handles.app.preferences.gui.NumMasks, 'Enable', 'Off');
    end  

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Number of Masks.
function newhandles = NumMask_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.NumMaskVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);




% --- Executes on button press in FlipSignal_Quest.
function newhandles = FlipSignal_Quest_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.FlipSigQuest.index=1;
    set (handles.app.preferences.gui.FlipSignal_PullDown,'Enable','on');
else
    %not checked    
    handles.app.preferences.FlipSigQuest.index=0;
    set (handles.app.preferences.gui.FlipSignal_PullDown,'Enable','off');
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on selection change in FlipSignal_PullDown.
function newhandles = FlipSignal_PullDown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
    switch val;
        case 1
            handles.app.preferences.FlipSigQuest.Options='Yes';
            handles.app.preferences.FlipSignal_PullDown = 1;
        case 2
            handles.app.preferences.FlipSigQuest.Options='No';
            handles.app.preferences.FlipSignal_PullDown = 2;
    end  

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on button press in WorkMem_Quest.
function newhandles = WorkMem_Quest_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.defReadTraces=1;
    set (handles.app.preferences.gui.TiffStack,'Enable','on');
    set (handles.app.preferences.gui.TiffStack_Value,'Enable','on');
else
    %not checked    
    handles.app.preferences.defReadTraces=0;
    set (handles.app.preferences.gui.TiffStack,'Enable','off');
    set (handles.app.preferences.gui.TiffStack_Value,'Enable','off');
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in TiffStack_Value.
function newhandles = TiffStack_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.ReadTracesVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Cutoff.
function newhandles = Cutoff_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.CutoffVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Halo Area.
function newhandles = Min_Area_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.MinAreaVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Halo Area.
function newhandles = Max_Area_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.MaxAreaVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Halo Area.
function newhandles = Pi_Limit_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.PiLimitVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Auto Load Contours
function newhandles = AutoLoad_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.autoLoadContours=1;
    handles.app.preferences.AutoDetect=0;
    set (handles.app.preferences.gui.Detect_Cells, 'Enable','Off','Value',0);
else
    %not checked    
    handles.app.preferences.autoLoadContours=0;
    set (handles.app.preferences.gui.Detect_Cells, 'Enable','On');
end
ct_preferences_save(handles);
newhandles = handles;
guidata (hObject,handles);
        

% --- Executes on change in Auto Detect Cells
function newhandles = Detect_Cells_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.AutoDetect=1;
else
    %not checked    
    handles.app.preferences.AutoDetect=0;
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Auto Find Cells
function newhandles = Find_Cells_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    %checked
    handles.app.preferences.AutoFind=1;
else
    %not checked    
    handles.app.preferences.AutoFind=0;
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


% --- Executes on change in Auto Adjust Cells
function newhandles = Adjust_Cells_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
handles.app.preferences.AutoAdjust=val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

function newhandles = dimreduc_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.dimreduc = val;
handles.app.preferences.dimreducname = str{val};
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


function newhandles = classifier_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.classifier = val;
handles.app.preferences.classifiername = str{val};
      
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


function newhandles = orderrout_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.orderrout = val;
handles.app.preferences.orderroutname = str{val};
      
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);


function newhandles = signaldetect_pulldown_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'Value');
str=get(hObject,'String');
handles.app.preferences.signaldetect = val;
handles.app.preferences.signaldetectname = str{val};
%if handles.app.preferences.SetDetectOptions==1
%ShowHideOptions(handles.app.preferences.SetDetectOpions,handles);
%end    
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in the number of trials.
function newhandles = Num_Trial_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Num_TrialVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Number of clusters.
function newhandles = Num_Clust_Value_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);
val=get(hObject,'string');
val = str2double(val);
handles.app.preferences.Num_ClustVal = val;
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on change in Set Detector Options Checkbox.
function newhandles = SetDetectOptions_Callback (hObject,eventdata,handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.app.preferences.SetDetectOptions=1;
else
    handles.app.preferences.SetDetectOptions=0;
end
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

function newhandles = PreprocessorOptions_Callback (hObject,eventdata,handles)
handles = ct_preferences_load(handles);
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.app.preferences.preprocessorOptions=1;
    set (handles.app.preferences.gui.preprocessors_pulldown, 'Enable','On');
    handles.app.preferences.preprocessdefaults = [];
    handles.app.preferences.preprocessdefaultsstring = [];
    
else
    handles.app.preferences.preprocessorOptions=0;
        set (handles.app.preferences.gui.preprocessors_pulldown, 'Enable','Off');
end

ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

function newhandles = preprocess_defaults_Callback (hObject,eventdata,handles)
handles = ct_preferences_load(handles);
val = get(hObject,'Value');

[str,preprocessor_names]=readdir(handles, 'preprocessors');     
preprocessdefaults = preprocessor_names(val);
preprocessdefaultsstring = str(val);
handles.app.preferences.preprocessdefaultsvalue = val;

for count = 1 : length(val)
handles.app.preferences.preprocessdefaults{count} = preprocessdefaults{count};
handles.app.preferences.preprocessdefaultsstring{count} = preprocessdefaultsstring{count};
end
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

function AutoExportTileRegionVals_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.app.preferences.AutoExportTileRegionVals=1;
else
    handles.app.preferences.AutoExportTileRegionVals=0;
end
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

function AllowTraceYZoom_Callback(hObject, eventdata, handles)
handles = ct_preferences_load(handles);

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.app.preferences.AllowTraceYZoom=1;
else
    handles.app.preferences.AllowTraceYZoom=0;
end
ct_preferences_save(handles);
newhandles = handles;
guidata(hObject, handles);

% --- Executes on Close Button press    
function CloseButton_Callback(hObject, eventdata, handles)
%This function loads the correct handles then closes the preferences
handles = ct_preferences_load (handles);
close (handles.app.preferences.prefgui);