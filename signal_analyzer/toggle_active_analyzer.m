function toggle_active_analyzer(obj,ev);

analyzerHandles = guidata(obj);
thistag = get(analyzerHandles.handles.figure,'tag');

switch thistag
    case 'analyzerFigure';
        set(analyzerHandles.handles.figure,'tag','inactiveanalyzerFigure');
        set(analyzerHandles.handles.activeAnalyzerMenu,'checked','off');
    case 'inactiveanalyzerFigure'
        others = findobj('tag','analyzerFigure');
        for oidx = 1:length(others);
            set(others(oidx),'tag','inactiveanalyzerFigure');
            oh = guidata(others(oidx));
            set(oh.handles.activeAnalyzerMenu,'checked','off');
        end
        
        set(analyzerHandles.handles.figure,'tag','analyzerFigure');
        set(analyzerHandles.handles.activeAnalyzerMenu,'checked','on');
end