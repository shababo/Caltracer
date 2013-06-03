function ct_signaleditcallback
%user just clicked the trace axes when in "edit signals" mode

%% get object and basic info
obj = gcbo;
cp = get(obj,'currentpoint');
x = cp(1,1);%get position of click in datapoint values
y = cp(1,2);%

handles = guidata(gcbo);%get guidata
clicktype = get(handles.fig,'SelectionType');%get click type (ie Right vs Left)

starts = handles.guiOptions.face.startmarks;
stops = handles.guiOptions.face.stopmarks;

%% figure out whether the click was on a marker
set(gca,'units','pixels');
numpix = get(gca,'position');
numpix = numpix(3:4);
set(gca,'units','normalized');
xl = get(gca,'xlim');
yl = get(gca,'ylim');
xresol = (xl(2)-xl(1))/numpix(1);%gives data value/pixel
yresol = (yl(2)-yl(1))/numpix(2);
%default markersize = 6 points = 6/72inch = 1/12 inch
ppi = get(0,'ScreenPixelsPerInch');
pixelspermarker = ceil(ppi/12)+2;
markradx = pixelspermarker * xresol/2;%how wide the marker is in xvalue... add 2 to make easier
markrady = 1.2 * pixelspermarker * yresol/2;%how wide the marker is in yvalue
instart = 0;
instop = 0;
for sigidx = 1:length(starts);%check to see if click was on a start/stop marker (ie to edit it)
    startx = get(starts(sigidx),'xdata');
    starty = get(starts(sigidx),'ydata');
    if x>(startx-markradx) && x<(startx+markradx)
        if y>(starty-markrady) && y<(starty+markrady)
            instart = 1;
            signum = sigidx;
            cellnum = handles.app.data.currentCellId;
            break%note starts trump overlapping stops
        end
    end
    stopx = get(stops(sigidx),'xdata');
    stopy = get(stops(sigidx),'ydata');
    if x>(stopx-markradx) && x<(stopx+markradx)
        if y>(stopy-markrady) && y<(stopy+markrady)
            instop = 1;
            signum = sigidx;
            cellnum = handles.app.data.currentCellId;
            break
        end
    end
end

didx = handles.app.data.currentDetectionIdx;
if instart || instop%if clicked on a pre-existing on/off marker
    if strcmp(clicktype,'alt');%if right click...
        handles.app.experiment.detections(didx).onsets{cellnum}(signum) = [];%delete onset...
        handles.app.experiment.detections(didx).offsets{cellnum}(signum) = [];%... and offset
        if numel(handles.app.experiment.detections(didx).onsets{cellnum}) == 0;
            handles.app.experiment.detections(didx).onsets{cellnum}=[];
            handles.app.experiment.detections(didx).offsets{cellnum}=[];
        end
    elseif strcmp(clicktype,'normal');%if left click...
        [x,y] = ginput(1);
        x = round(x/handles.app.experiment.timeRes)+1;%round to nearest frame - add one b/c Dave called Frame 1 Time = 0
        if instart
            if x <= handles.app.experiment.detections(didx).offsets{cellnum}(signum,1)%if not after the stop
                handles.app.experiment.detections(didx).onsets{cellnum}(signum,1) = x;
            end
        elseif instop
            if x >= handles.app.experiment.detections(didx).onsets{cellnum}(signum,1)%if not before its start
                handles.app.experiment.detections(didx).offsets{cellnum}(signum,1) = x;
            end
        end
    end
elseif strcmp(clicktype,'normal')%ie if click was elsewhere and was a left click... add a new event
    ontime = round(x/handles.app.experiment.timeRes);%round initial click to nearest frame
    [x,y] = ginput(1);%prompt for next click for offset time
    offtime = round(x/handles.app.experiment.timeRes);%round second click to nearest frame
    if offtime >= ontime;
        cellnum = handles.app.data.currentCellId;
        cellons = handles.app.experiment.detections(didx).onsets{cellnum};
        %% make SURE the list is vertical, should still work this way for
        %% exp.mat files that were messed up in the past by horizontal
        %% lists
        csz = size(cellons);
        if prod(csz)>0
            cellons = reshape(cellons,[max(csz) 1]);
        else
            cellons = [];
        end
        %%
        cellons = sort(cat(1, cellons, ontime));%slap new event on the end and then sort to put in right place
        idx = find(cellons == ontime);%find which event number the new event became (ie first, 4th, last etc)
        handles.app.experiment.detections(didx).onsets{cellnum} = cellons;%store
        celloffs = handles.app.experiment.detections(didx).offsets{cellnum};
        %% same as above, now with list of offs
        csz = size(celloffs);
        if prod(csz)>0
            celloffs = reshape(celloffs,[max(csz) 1]);
        else
            celloffs = [];
        end
        %%
        if idx(end)<=size(celloffs,1);%can't just sort celloffs into order, in case a particular offset may need to be with an onset that's not right before it (why?)
            celloffs = cat(2, (celloffs(1:idx(end)-1))', offtime, (celloffs(idx(end):end))');%need to make this horizontal because of 1x0 matrices
            celloffs = celloffs';%then flip it so it's right
        elseif idx(end)>size(celloffs,1);
            celloffs = cat(1, celloffs, offtime);
        end
        handles.app.experiment.detections(didx).offsets{cellnum} = celloffs;
    end
else
    return
end


handles = plot_gui(handles);
guidata(handles.fig,handles);