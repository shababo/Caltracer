function handles = redraw_regions(handles, hObject)
% Delete and redraw region lines based on the values for them in the input
% handles structure.


for a = 1:length(handles.app.experiment.regions.bhand) 
    x = [handles.app.experiment.regions.coords{a+1}(:,1); ...
       handles.app.experiment.regions.coords{a+1}(1,1)];
    y = [handles.app.experiment.regions.coords{a+1}(:,2); ...
       handles.app.experiment.regions.coords{a+1}(1,2)];
    delete(handles.app.experiment.regions.bhand(a));
    handles.app.experiment.regions.bhand(a) = plot(x,y,':+y');
end
1;