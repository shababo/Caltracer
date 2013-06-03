function analyzer_closer_fcn(obj,ev);

% analyzerHandles = guidata(obj);
% handles = guidata(analyzerHandles.creatorFig);
% handles.signalAnalyzerFig = [];
% guidata(handles.fig,handles);
button = questdlg('Save Analyzer window and data?');
if strcmp(button,'Yes')
    [FileName,PathName] = uiputfile;
    if ischar(FileName) && ischar(PathName)
        hgsave(obj,[PathName,'\',FileName])
    end
elseif strcmp(button,'Cancel');
    return
end

delete(obj);