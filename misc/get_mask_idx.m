function maskidx = get_mask_idx(handles, label)
% Get the index to a mask given the label.
maskidx = find(strcmpi(handles.app.data.maskLabels, label));
if isempty(maskidx)
    error('You must input a valid mask label string');
end

