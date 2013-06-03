function analyze_chunks(obj,ev);

analyzerHandles = guidata(obj);
func_name = get(analyzerHandles.handles.operationDropdown,'string');
func_name = func_name{get(analyzerHandles.handles.operationDropdown,'value')};
func_name = ['cta_',func_name];

eval([func_name,'(analyzerHandles);'])