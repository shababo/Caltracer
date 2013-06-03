function handles = show_save_bad_pixels(hObject,handles);
%This takes input from Remove for filtering input boxes and highlights 
%the chosen rows and columns.  
%Also saves the values of pixels to ignore in app.experiment.Image.

maskidx = handles.app.data.currentMaskIdx;
lidx = get_label_idx(handles, 'image');

button = get(hObject,'tag');
value = str2num(get(hObject,'string'));
imsz = size(handles.app.experiment.Image(maskidx).image);
thisax = handles.uigroup{lidx}.imgax;

switch button
    case 'leftcols'
        startval = 1;
        stopval = value;
        if value == 0;
            handles.app.experiment.Image(maskidx).badpixels.leftcols = [];
        else            
            handles.app.experiment.Image(maskidx).badpixels.leftcols = [startval:stopval];
        end
        if isfield (handles.app.experiment.Image(maskidx).badpixels,'leftbox')
            if ~isempty(handles.app.experiment.Image(maskidx).badpixels.leftbox);
                delete (handles.app.experiment.Image(maskidx).badpixels.leftbox)
            end
        end
        handles.app.experiment.Image(maskidx).badpixels.leftbox =... 
            plot([startval stopval stopval startval]+0.5,...
            [0 0 imsz(2) imsz(2)]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'rightcols'
        startval = (imsz(2)-value)+1;
        stopval = imsz(2);
        if value == 0;
            handles.app.experiment.Image(maskidx).badpixels.rightcols = [];
        else            
            handles.app.experiment.Image(maskidx).badpixels.rightcols = [startval:stopval];
        end
        if isfield (handles.app.experiment.Image(maskidx).badpixels,'rightbox')
            if ~isempty(handles.app.experiment.Image(maskidx).badpixels.rightbox);
                delete (handles.app.experiment.Image(maskidx).badpixels.rightbox)
            end
        end
        handles.app.experiment.Image(maskidx).badpixels.rightbox =...
            plot([stopval startval startval stopval]+0.5,...
            [0 0 imsz(2) imsz(2)]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'upperrows'
        startval = 1;
        stopval = value;
        if value == 0;
            handles.app.experiment.Image(maskidx).badpixels.upperrows = [];
        else            
            handles.app.experiment.Image(maskidx).badpixels.upperrows = [startval:stopval];
        end
        if isfield (handles.app.experiment.Image(maskidx).badpixels,'upperbox')
            if ~isempty(handles.app.experiment.Image(maskidx).badpixels.upperbox);
                delete (handles.app.experiment.Image(maskidx).badpixels.upperbox)
            end
        end
        handles.app.experiment.Image(maskidx).badpixels.upperbox =...
            plot([0,imsz(1),imsz(1),0]+0.5,...
            [startval startval stopval stopval]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'lowerrows'
        startval = (imsz(1)-value)+1;
        stopval = imsz(1);
        if value == 0;
            handles.app.experiment.Image(maskidx).badpixels.lowerrows = [];
        else            
            handles.app.experiment.Image(maskidx).badpixels.lowerrows = [startval:stopval];
        end
        if isfield (handles.app.experiment.Image(maskidx).badpixels,'lowerbox')
            if ~isempty(handles.app.experiment.Image(maskidx).badpixels.lowerbox);
                delete (handles.app.experiment.Image(maskidx).badpixels.lowerbox)
            end
        end
        handles.app.experiment.Image(maskidx).badpixels.lowerbox =... 
            plot([0,imsz(1),imsz(1),0]+0.5,...
            [startval startval stopval stopval]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
end
