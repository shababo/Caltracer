function assign_listbox_callback(obj,ev);

analyzerHandles = guidata(obj);
funcval = get(analyzerHandles.handles.selectCallbackDropdown,'value');
funclist = get(analyzerHandles.handles.selectCallbackDropdown,'string');
funcname = funclist{funcval};

eval(['set(analyzerHandles.handles.chunksListBox,''callback'',@cta_',funcname,');'])