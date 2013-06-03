function handles = set_new_mask_idx(handles, label)
maskidx = find(strcmpi(handles.app.data.maskLabels, label));
if ~isempty(maskidx)
    error('Mask label already exists!');
else
    handles.app.data.maskLabels{end+1} = label;
    maskidx = find(strcmpi(handles.app.data.maskLabels, label));
end



