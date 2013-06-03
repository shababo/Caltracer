function handles = open_image(handles,varargin)
% function handles = open_image(handles)
% Open an image and display a listdlg to create a zstack.  Save the
% results.

zstack_name = [];

% Maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;

if strcmpi(handles.app.data.currentImageInputType, 'inputarg') %if an image was 
    %input to epo at initiation and this is the first time an image is being 
    %opened (if after first time, ='s 2);
    filename = 'Workspace Variable';
    pathname = '';
    zstack=double(handles.app.experiment.Image.image);
    param.frameType='variable';
else %if no image yet... get one
    if strcmpi(handles.app.data.currentImageInputType, 'inputfilename');
        [pathname,filename,ext]=fileparts(varargin{2})
        filename = [filename ext];
        if isempty(pathname);
            pathname = [cd '\'];
        else
            pathname = [pathname '\'];
        end
        set(handles.fig, 'Name', [handles.app.info.title ' - ' filename ext]);
        fnm = [pathname filename];
        handles.app.experiment.fileName = fnm;
    else
        if handles.app.info.issplit ==1
            filename = handles.app.experiment.Image(maskidx).fileName;
            pathname = handles.app.experiment.Image(maskidx).pathName;
            fnm = [pathname filename];
            handles.app.experiment.fileName = fnm;
            set(handles.fig, 'Name', [handles.app.info.title ' - ' filename]);
        else
        [filename, pathname] = uigetfile({'*.tif'}, 'Choose image to open');
        if ~ischar(filename)
            handles = [];
            return
        end
        set(handles.fig, 'Name', [handles.app.info.title ' - ' filename]);
        fnm = [pathname filename];
        handles.app.experiment.fileName = fnm;
        end
    end	
    

        
        % Load the various zstack routines from the directory.
        [str, zstack_names] = readdir(handles, 'zstacks');
        
        %Allow user to specify favorite zstack function... or default=1;
        try
            match = handles.app.preferences.zstack;
        catch
            match=1;
        end
        
        if handles.app.preferences.zstackonly ==1
            s = handles.app.preferences.zstack;
        else
        [s,v] = listdlg('PromptString','Select a zstack option:',...
                'SelectionMode','single',...
                'ListString', str,...
                'InitialValue',match);
        if (~v)
            handles = [];
            return;
        end
        end
        % Process the image stack.
        zstack_name = zstack_names{s};
    %end
	[zstack, param] = feval(zstack_name, filename, pathname, handles.app.experiment.opensequential);
end

handles.app.experiment.fileName = filename;
% Save the output of the zstack routine.
[maxy maxx] = size(zstack);
handles.app.experiment.Image(maskidx).title = filename;
handles.app.experiment.Image(maskidx).fileName = filename;
handles.app.experiment.Image(maskidx).pathName = pathname;
handles.app.experiment.Image(maskidx).nX = maxx;
handles.app.experiment.Image(maskidx).nY = maxy;
handles.app.experiment.Image(maskidx).frameType = param.frameType;
handles.app.experiment.Image(maskidx).image = zstack;
handles.app.experiment.Image(maskidx).maskLoadedFromFile = 'not loaded';
handles.app.experiment.Image(maskidx).movementVector = [0 0];
handles.app.experiment.Image(maskidx).rotationRadians = 0;
handles.app.experiment.Image(maskidx).badpixels.leftcols = [];
handles.app.experiment.Image(maskidx).badpixels.rightcols = [];
handles.app.experiment.Image(maskidx).badpixels.upperrows = [];
handles.app.experiment.Image(maskidx).badpixels.lowerrows = [];


%%% This is a hack, we should have an index explainined the the
%current GUI index.  But instead we just look at active widgets. -DCS:2005/04/04
handles = hide_uigroup(handles, 'logo');
handles = enable_uigroup(handles, 'image');
handles = enable_uigroup(handles, 'resolution');
handles = display_zstack_image(handles);
handles = adjust_contrast(handles);

if (strcmp(uiget(handles, 'filterimage', 'det_tx1', 'Visible'), 'on'))
    draw_region_widget(handles);
end

ran = 1;