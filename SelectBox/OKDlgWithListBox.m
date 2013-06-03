function varargout = OKDlgWithListBox(varargin)
% OKDLGWITHLISTBOX produces a simple OK dialog to
% be used to display long help messages but may really
% be used for many purposes.
% The lengthy message is displayed in a listbox, which
% has the advantage of permitting scroll bars.
%
%
% INPUT
% * QUESTION,       type = string
% * NAME,           type = string
% * LISTBOX MESSAGE,type = cell array of strings
%                          OR a filename preceeded by "-f"
%
% OUTPUT
% * SELECTEDBUTTONNAME, type = string
%
% USAGE
% out = OKDlgWithListBox( ...
%     ['Help for SearchReplaceManyGUI.  This help page has been created '
%     ...
%     'to provide some basic guidance for the program ' ...
%     'SearchReplaceManyGUI.  Unfortunately, since the programmer was ' ...
%     'very lazy, he used an automated help tool, AUTOHELP, and as a ' ...
%     'result this help may not be of much use.'], ...
%     'SearchReplaceManyGUI :: Help', ...
%     {['This is line one. It may be very long and scroll off the page. '
%     ...
%       'It may, in fact, be so long as to require scroll bars to ' ...'
%       'view.'], ...
%      'A 2nd Row','datum','more','another'});
%
% ANOTHER EXAMPLE:
% out = OKDlgWithListBox( ...
%        ['OKDLGWITHLISTBOX  This window page has been created ' ...
%        'to allow OK dialog boxes with a large listbox for long ' ...
%        'strings and cell strings.  This ' ...
%        'Example loads the file Article1.txt and displays it in ' ...
%        'the listbox.'], ...
%        'OKDLGWITHLISTBOX :: File Example', ...
%        '-fArticle1.txt');
%
% KEYWORDS
%    help helpdlg quesdlg grid_and_table spreadsheet question dialog
%
% SEE ALSO QUESTDLGWITHGRID AUTOHELP QUESTDLG GRID_AND_TABLE SPREADSHEET
%
% IT'S NOT FANCY, BUT IT WORKS
% Michael Robbins
% MichaelRobbins1@yahoo.com
% MichaelRobbinsUsenet@yahoo.com
% robbins@bloomberg.net
% OKDLGWITHLISTBOX M-file for OKDlgWithListBox.fig
%      OKDLGWITHLISTBOX by itself, creates a new OKDLGWITHLISTBOX or raises
%      the
%      existing singleton*.
%
%      H = OKDLGWITHLISTBOX returns the handle to a new OKDLGWITHLISTBOX or
%      the handle to
%      the existing singleton*.
%
%      OKDLGWITHLISTBOX('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in OKDLGWITHLISTBOX.M with the given input
%      arguments.
%
%      OKDLGWITHLISTBOX('Property','Value',...) creates a new
%      OKDLGWITHLISTBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before OKDlgWithListBox_OpeningFunction gets
%      called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to OKDlgWithListBox_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help OKDlgWithListBox
% Last Modified by GUIDE v2.5 02-May-2005 13:10:52
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OKDlgWithListBox_OpeningFcn, ...
                   'gui_OutputFcn',  @OKDlgWithListBox_OutputFcn, ...
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
% --- Executes just before OKDlgWithListBox is made visible.
function OKDlgWithListBox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OKDlgWithListBox (see VARARGIN)
% Choose default command line output for OKDlgWithListBox
handles.output = 'Yes';
% Update handles structure
guidata(hObject, handles);
%{
% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
end
end
end
%}
% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);
% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat
IconData=helpIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=helpIconMap;
Img=image(IconData, 'Parent', handles.axes1);
set(handles.figure1, 'Colormap', IconCMap);
set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );
% QUESTION
if length(varargin)>0
    set(handles.text1,'String',varargin{1});
end;
% NAME
if length(varargin)>1
    set(handles.figure1,'Name',varargin{2});
end;
% LISTBOX
if length(varargin)>2
    if isstr(varargin{3}) && strmatch(varargin{3}(1:2),'-f','exact')
        FID = fopen(which(varargin{3}(3:end)),'rt');
        if FID == -1
            errordlg('File not found','OKDlgWithListBox');
        else
            txt = fscanf(FID,'%c');
            fclose(FID);
            set(handles.listbox1,'String',regexp(txt,'[^\n]*','match'));
        end;
    else
        set(handles.listbox1,'String',varargin{3});
    end;
end;
               
% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')
% UIWAIT makes OKDlgWithListBox wait for user response (see UIRESUME)
uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = OKDlgWithListBox_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end
% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listbox1 contents as cell
% array
%        contents{get(hObject,'Value')} returns selected item from listbox1
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
