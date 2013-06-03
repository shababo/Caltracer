function handles = change_uigroup(handles, label, properties, values)
% label is the uigroup
% properties is a cell array of strings of properties to change.
% values is a cell array of strings of values for the properties.
if (isnumeric(label))
    error('Label must be a string!')
    return;
end
lidx = get_label_idx(handles, label);
fns = fieldnames(handles.uigroup{lidx});
hc = struct2cell(handles.uigroup{lidx});
hc_flat = [hc{:}];			% flatten struture;
for i = 1:length(hc_flat)
    %hc_flat{i}
    if ~ishandle(hc_flat(i))
        0;
        %errordlg('Invalid handle, for some reason.');
    end
    for j = 1:length(properties)
        % hack here, should be placed up the stack. -DCS:2005/04/03
        if ~(strcmpi(get(hc_flat(i), 'Type'), 'Axes') & ...
             strcmpi(properties{j}, 'Enable'))
            set(hc_flat(i), properties{j}, values{j});
        end

        % Special case for hiding the chidren of the axis, which
            % does not happen by default.
        if (strcmpi(get(hc_flat(i), 'Type'), 'Axes') & ...
            strcmpi(properties{j}, 'Visible') & ...
            strcmpi(values{j}, 'off'))
            hide_axis(hc_flat(i));
        end
        if (strcmpi(get(hc_flat(i), 'Type'), 'Axes') & ...
            strcmpi(properties{j}, 'Visible') & ...
            strcmpi(values{j}, 'on'))
            show_axis(hc_flat(i));
        end
    end
end
handles.uigroup{lidx} = cell2struct(hc, fns);

