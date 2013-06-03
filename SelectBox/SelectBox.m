function varargout = SelectBox(varargin)
% SELECTBOX is a dialog box for the user to select several
% items from a list of available items.
%
% INPUT:
% title = the title of the box
% universe = a cellstring of available choices
% selections = an array of the indicies of pre-selected choices
% description = a short description of what to do
%
% OUTPUTS:
% out_index = an array of indicies of all selections (pre and post)
% out_cs = a cellstring of all selections (pre and post)
%
% EXAMPLE:
% sbtitle   = 'Demonstration :: Select Securites';
% sbuniverse = { ' 8.625 07/23/21',' 4.250 08/08/21', ...
%                ' 3.000 10/31/21','10.500 10/31/21', ...
%                '11.250 10/31/21',' 7.750 10/31/21', ...
%                ' 5.500 10/31/21',' 3.875 11/13/21', ...
%                ' 3.875 02/24/22',' 8.375 05/19/22', ...
%                ' 3.875 06/03/22','12.625 08/27/22', ...
%                '10.375 08/27/22'};
% sbselections = [1 2 4];
% sbdescription = {['Select the securities that you want ' ...
%     'to use in your Beta Curve analyisis one'], ...
%    ['at a time, pressing "ADD" after each' ...
%     'selection.  When done, press "OK."']};
% [i,cs] = selectbox(sbtitle,sbuniverse,sbselection,sbdescription);
%
% SAMPLE OUTPUT:
% i  =  1 2 4 
% cs =  ' 8.625 07/23/21' ' 4.250 08/08/21' '10.500 10/31/21'
%
% SEE ALSO: SearchReplaceGUI
%
% KEYWORDS: GUI guide uicontrol popup dialog box select choose pick
%
% IT'S NOT FANCY, BUT IT WORKS.
%
% REVISION HISTORY
% Rev 2
% 4/24/05 [/] Removing last selection no longer erases lisbox
% 4/24/05 [/] Allow multiple selections in both listboxes
% 4/24/05 [/] Bond Sort button and function
% 4/24/05 [/] Tooltips for all buttons
% 4/24/05 [/] Up / Down buttons and functions
% 4/24/05 [/] Help button
% 4/24/05 [/] Remove Duplicates button and function
% 4/24/05 [/] Allow selection of none, removal of all, addition of multiple
% 5/02/05 [/] Add tooltips, so they appear in the help
% TO DO
% [ ] Fix promote/demote
% Michael Robbins
% robbins@bloomberg.net
% MichaelRobbinsUsenet@yahoo.com
% Last Modified by GUIDE v2.5 29-May-2005 12:43:41
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectBox_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectBox_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% --- Executes just before SelectBox is made visible.
function SelectBox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectBox (see VARARGIN)
% Choose default command line output for SelectBox
handles.output = hObject;
% Define default values
default_title   = 'Demonstration :: Select Securites';
default_universe = { ' 8.625 07/23/21',' 4.250 08/08/21', ...
                    ' 3.000 10/31/21','10.500 10/31/21', ...
                    '11.250 10/31/21',' 7.750 10/31/21', ...
                    ' 5.500 10/31/21',' 3.875 11/13/21', ...
                    ' 3.875 02/24/22',' 8.375 05/19/22', ...
                    ' 3.875 06/03/22','12.625 08/27/22', ...
                    '10.375 08/27/22'};
default_selections = [1 2 4];
default_description = {['Select the securities that you want ' ...
    'to use in your Beta Curve analyisis one' ...
    'at a time, pressing "ADD" after each' ...
    'selection.  When done, press "OK." ' ...
    'If you made a mistake, press "CANCEL."']};
% Set GUI values in structure upon startup
handles.userdata.isCancelled = 0;
handles.userdata.title       = var_or_def(1,varargin,default_title);
handles.userdata.title = handles.userdata.title{1};
handles.userdata.universe    = var_or_def(2,varargin,default_universe);
selection_strings = var_or_def(3,varargin,default_selections);
selections = [];
for i = 1:length(selection_strings)
   idx = find(strcmp(handles.userdata.universe,selection_strings(i))); 
   selections(i) = idx(1);
end
handles.userdata.selections  = selections;
handles.userdata.description = var_or_def(4,varargin,default_description);
if (length(varargin) >= 5)
    handles.userdata.preprocessOptions = varargin{5};
else
    handles.userdata.preprocessOptions = {};
end
% Display structure values on GUI and test functions
set(handles.text_title,'string',handles.userdata.description);
set(handles.text_title,'string',handles.userdata.title);
set(handles.text_description,'string',handles.userdata.description);
set(handles.figure_selectbox,'name',handles.userdata.title);
populate_universe(handles);
populate_selection(handles);
%handles = push_pop_test_selections(handles);
% Save initial data in case cancelled
handles.userdata.init.universe   = handles.userdata.universe;
handles.userdata.init.selections = handles.userdata.selections;
% Hide the buttons we don't need.
set(handles.pushbutton_sort, 'Visible', 'Off');
set(handles.pushbutton_BondSort, 'Visible', 'Off');
set(handles.pushbutton_RemoveDuplicates, 'Visible', 'Off');
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes SelectBox wait for user response (see UIRESUME)
uiwait(handles.figure_selectbox);
% --- Outputs from this function are returned to the command line.
function varargout = SelectBox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = {};
varargout{2} = {};
varargout{3} = {};
if (~handles.userdata.isCancelled)
    varargout{1} = handles.userdata.selections;
    varargout{2} = handles.userdata.universe;
    varargout{3} = handles.userdata.preprocessOptions;
end
delete(handles.figure_selectbox);
% --- Executes on selection change in listbox_universe.
function listbox_universe_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_universe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listbox_universe contents
% as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listbox_universe
% --- Executes during object creation, after setting all properties.
function listbox_universe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_universe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in listbox_selection.
function listbox_selection_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listbox_selection
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listbox_selection
% --- Executes during object creation, after setting all properties.
function listbox_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = add_selection(handles);
% Update handles structure
guidata(hObject, handles);
% --- Executes on button press in pushbutton_take.
function pushbutton_take_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_take (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = take_selection(handles);
% Update handles structure
guidata(hObject, handles);
% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure_selectbox);
% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Restore initial data
handles.userdata.universe   = handles.userdata.init.universe;
handles.userdata.selections = handles.userdata.init.selections;
handles.userdata.isCancelled = 1;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure_selectbox);
% --- Executes on selection change in listbox_selections.
function listbox_selections_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_selections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listbox_selections
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listbox_selections
% --- Executes during object creation, after setting all properties.
function listbox_selections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_selections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in pushbutton_sort.
function pushbutton_sort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = sort_listboxes(handles);
% Update handles structure
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outstr = var_or_def(n,vararginstr,default)
% VAR_OR_DEF checks to see if parameter was provided by user,
% if not, uses default
if ~isempty(vararginstr) && length(vararginstr)>n-1
    outstr = vararginstr{n};
else
    outstr = default;
end;
%--------------------------------------------------
function handles = add_selection(handles)
% ADD_SELECTION adds the selected item from the universe
i = get(handles.listbox_universe,'value'); 
handles.userdata.selections = [handles.userdata.selections i(:)']; 
populate_selection(handles);
% Since we've added the selection to the list, we have to add the
% selection to the preprocessOptions.
strings = get(handles.listbox_universe, 'String');
for s = 1:length(i)
    selected_string = strings{i(s)};
    options = feval(['ct_' selected_string '_options']);
    handles.userdata.preprocessOptions{end+1} = options;
end
%--------------------------------------------------
function handles = take_selection(handles)
% TAKE_SELECTION takes the selected item back
i=get(handles.listbox_selections,'value'); 
set(handles.listbox_selections,'value',[]); 
handles.userdata.selections(i)=[];
populate_selection(handles);
% Since we've added removed the selection from the list, we have to
% remove the selection from the preprocessOptions.  A cell array using
% array indexing to ditch the ith element.
handles.userdata.preprocessOptions(i) = [];
%--------------------------------------------------
function populate_selection(handles)
% POPULATE_SELECTION puts the selected items
i=handles.userdata.selections;
if isempty(i)
    set(handles.listbox_selections,'string',[]);
else
    if iscell(i) i=[i{:}]; end;
    set(handles.listbox_selections,'string',handles.userdata.universe(i));
end;
%--------------------------------------------------
function handles = sort_listboxes(handles,i)
% SORT_LISTBOXES sorts the universe and selections listboxes
% sort universe
old_universe = handles.userdata.universe;
if nargin<2
    handles.userdata.universe = sort(handles.userdata.universe);
else
    handles.userdata.universe = handles.userdata.universe(i);
end;
populate_universe(handles);
% sort selections
for i=1:length(handles.userdata.selections)
    handles.userdata.selections(i) = strmatch( ...
        old_universe(handles.userdata.selections(i)), ...
        handles.userdata.universe, ...
        'exact');
end;
handles.userdata.selections = sort(handles.userdata.selections);
%push_pop_test_selections(handles);
populate_selection(handles);
%--------------------------------------------------
%function handles = push_pop_test_selections(handles)
%% PUSH_POP_TEST_SELECTIONS populates the selections listbox and tests
%if (isempty(handles.userdata.selections))
%    return;
%end
%% add the last item in universe to select listbox
%set(handles.listbox_universe,'value',handles.userdata.selections(end));
%handles = add_selection(handles);
%% remove the last item in the select listbox
%set(handles.listbox_selections,'value',length(handles.userdata.selections)-1);
%handles = take_selection(handles);
%--------------------------------------------------
function populate_universe(handles)
% POPULATE_UNIVERSE populates the universe listbox
set(handles.listbox_universe,'string',handles.userdata.universe);
%--------------------------------------------------
% --- Executes on button press in pushbutton_BondSort.
function pushbutton_BondSort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_BondSort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[temp,i] = sort(sum(str2num(char(regexprep(handles.userdata.universe, ...
    '(\d+\.\d+)\s+(\d{2})[\-/](\d{2})[\-/](\d{2,4})','$4$2$3 $1'))),2));
handles = sort_listboxes(handles,i);
% Update handles structure
guidata(hObject, handles);
% --- Executes on button press in pushbutton_RemoveDuplicates.
function pushbutton_RemoveDuplicates_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RemoveDuplicates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.userdata.universe = unique(handles.userdata.universe);
handles.userdata.selections = unique(handles.userdata.selections);
%push_pop_test_selections(handles);
populate_selection(handles);
% Update handles structure
guidata(hObject, handles);
% --- Executes on button press in pushbutton_PromoteSelection.
function pushbutton_PromoteSelection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PromoteSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Promote_Demote(hObject, handles,'promote');
    
% --- Executes on button press in pushbutton_DemoteSelection.
function pushbutton_DemoteSelection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DemoteSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Promote_Demote(hObject, handles,'demote');
% --- Executes on button press in pushbutton_Help.
function pushbutton_Help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OKDlgWithListBox('This is the automatically generated help screen.', ...
		 'SelectBox :: Help',AutoHelp(handles));%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c,d]=swapem(a,b)
c=b;
d=a;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Promote_Demote(hObject, handles,sPD)
BROKEN = 0;
if BROKEN
    errordlg('Promote_Demote is not working properly.', ...
        'SelectBox :: Promote_Demote');
else
    % GET VALUES FROM LISTBOX
    sel_i  = get(handles.listbox_selections,'value');
    string_selections = get(handles.listbox_selections,'string');
    idx = 1:length(string_selections);
    switch sPD
        case 'promote', OK = (min(sel_i)>min(idx)); os = -1;
        case 'demote' , OK = (min(sel_i)<max(idx)); os =  1;
            sel_i = flipud(sel_i(:));
        otherwise, error('SELECTBOX :: PROMOTE_DEMOTE :: This should never happen');
    end;        
    if OK
        % PROMOTE THEM
        new_sel_i = sel_i+os;
        [idx(sel_i),idx(new_sel_i)] = swapem(idx(sel_i),idx(new_sel_i));
        moved_string_selections = string_selections(idx);
        handles.userdata.selections = handles.userdata.selections(idx);
        % ADJUST SELECTIONS TO REFLECT NEW POSITIONS
        %[temp,sel_i]=intersect(sel_i,idx);
        % PUT EM BACK INTO THE LISTBOX
        set(handles.listbox_selections,'string',moved_string_selections);
	
        % RESELECT
        %[dummy,i]=intersect(1:length(idx),sel_i);
        set(handles.listbox_selections,'value', new_sel_i);
	% Update the preprocessOptions data structure.
	preprocessOptions = handles.userdata.preprocessOptions;
	preprocessOptions = preprocessOptions(idx);
	handles.userdata.preprocessOptions = preprocessOptions;
	
        % Update handles structure
        guidata(hObject, handles);
    else
        errordlg('You cannot promote an item beyond the top of the stack.', ...
            'SelectBox :: Promote_Demote');
    end;
end;
% --- Executes on button press in modify_options_pushbutton.
function modify_options_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to modify_options_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sidxs = get(handles.listbox_selections, 'value');
if (isempty(sidxs))
    return;
end
listbox_strings = get(handles.listbox_selections, 'string');
preprocessOptions = handles.userdata.preprocessOptions;
for sidx = sidxs
    selected_string = listbox_strings{sidx};
   
    % Create the input dialog box with appropriate values.
    dlgTitle = [selected_string];
    fnames = fieldnames(preprocessOptions{sidx});
    hc = struct2cell(preprocessOptions{sidx});
    answer = {};
    prompt = {};
    default = {};
    for i = 1:length(hc)
	prompt{i} = hc{i}.prompt;
	if isstr(hc{i}.value)
	    default{i} = hc{i}.value;
	else
	    default{i} = num2str(hc{i}.value);
	end
    end
    lineNo = 1;
    answer = {};
    if (isempty(prompt))
	warndlg(['There are no options for ' selected_string '.'], ...
		'No options');
    else    
	answer = inputdlg(prompt,dlgTitle,lineNo,default);
    end
    
    % BP.  The cancel option.
    if isempty(answer)
	continue;
    end
    
    % Retreive the input dialog box values.  This string issue could 
    % make an error. -DCS:2005/05/29
    for i = 1:length(hc)
	% We don't allow empty answers. -DCS:2005/05/29
	if (isempty(answer{i}))
	    continue;
	end
	value = answer{i};
	if (isstr(hc{i}.value))
	    hc{i}.value = value;
	else
	    hc{i}.value = str2num(value);
	end
    end
    
    % Put everything back together again.
    option = {};
    for i = 1:length(hc)
	option.(fnames{i}) = hc{i};
    end
    preprocessOptions{sidx} = option;
end
% Save and return;
handles.userdata.preprocessOptions = preprocessOptions;
guidata(hObject, handles);