function uistate = ct_suspend(fig, setdefaults)
% This function is based on MathWorks function uisuspend but was changed
% because uisuspend stopped working for our purpose as a result of a newer
% version.  -MD

%  CT_SUSPEND suspends all interactive properties of the figure.
%
%   UISTATE=CT_SUSPEND(FIG) suspends the interactive properties of a 
%   figure window and returns the previous state in the structure
%   UISTATE.  This structure contains information about the figure's
%   WindowButton* functions and the pointer.  It also contains the 
%   ButtonDownFcn's for all children of the figure.
%
%   UISTATE=CT_SUSPEND(FIG,FALSE) returns the structure as above but leaves
%   the current settings unchanged.


    if nargin < 2
        setdefaults = true;
    end
    
    chi = findobj(fig);
    % fig can be an array of handles, not necessarily figures
    if ~isa(handle(fig),'figure')
        %sz = length(fig);
        if length(fig) > 1
            fig = fig(1);
        end
        fig = ancestor(fig,'figure');
    end

    uistate = struct(...
            'ploteditEnable',        plotedit(fig,'getenabletools'), ...        
            'figureHandle',          fig, ...
            'Children',              chi, ...
            'WindowButtonMotionFcn', Lwrap(get(fig, 'WindowButtonMotionFcn')), ...
            'WindowButtonDownFcn',   Lwrap(get(fig, 'WindowButtonDownFcn')), ...
            'WindowButtonUpFcn',     Lwrap(get(fig, 'WindowButtonUpFcn')), ...
            'WindowScrollWheelFcn',  Lwrap(get(fig, 'WindowScrollWheelFcn')), ...
            'WindowKeyReleaseFcn',   Lwrap(get(fig, 'WindowKeyReleaseFcn')), ...
            'WindowKeyPressFcn',     Lwrap(get(fig, 'WindowKeyPressFcn')), ...
            'KeyPressFcn',           Lwrap(get(fig, 'KeyPressFcn')), ...
            'Pointer',               get(fig, 'Pointer'), ...
            'PointerShapeCData',     get(fig, 'PointerShapeCData'), ...
            'PointerShapeHotSpot',   get(fig, 'PointerShapeHotSpot'), ...
            'ButtonDownFcns',        Lwrap(get(chi, {'ButtonDownFcn'})), ...
            'Interruptible',         Lwrap(get(chi, {'Interruptible'})), ...
            'BusyAction',            Lwrap(get(chi, {'BusyAction'})), ...
            'UIContextMenu',         Lwrap(get(chi, {'UIContextMenu'})) );

    if setdefaults
        % disable plot editing and annotation buttons
        plotedit(fig,'setenabletools','off'); % ploteditEnable
        % Set some app data to inform calling tools that we are in a
        % non-interruptable state:
        setappdata(fig,'UISuspendActive',true);
        % do nothing figureHandle
        % do nothing for Children
        set(fig, 'WindowButtonMotionFcn', get(0, 'DefaultFigureWindowButtonMotionFcn'))
        set(fig, 'WindowButtonDownFcn',   get(0, 'DefaultFigureWindowButtonDownFcn'))
        set(fig, 'WindowButtonUpFcn',     get(0, 'DefaultFigureWindowButtonUpFcn'))
        set(fig, 'WindowScrollWheelFcn',  get(0, 'DefaultFigureWindowScrollWheelFcn'))
        set(fig, 'WindowKeyPressFcn',     get(0, 'DefaultFigureWindowKeyPressFcn'))
        set(fig, 'WindowKeyReleaseFcn',   get(0, 'DefaultFigureWindowKeyReleaseFcn')) 
        set(fig, 'KeyPressFcn',           get(0, 'DefaultFigureKeyPressFcn'))
        set(fig, 'Pointer',               get(0, 'DefaultFigurePointer'))
        set(fig, 'PointerShapeCData',     get(0, 'DefaultFigurePointerShapeCData'))
        set(fig, 'PointerShapeHotSpot',   get(0, 'DefaultFigurePointerShapeHotSpot'))
        set(chi, 'ButtonDownFcn',         '')
        set(chi, 'Interruptible',         'on');
        set(chi, 'BusyAction',            'Queue')
        % do nothing for UIContextMenu
    end
end

% wrap cell arrays in another cell array for passing to the struct command
function x = Lwrap(x)
    if iscell(x), 
      x = {x}; 
    end
end
