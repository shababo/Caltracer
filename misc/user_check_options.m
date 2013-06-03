function options = user_check_options(options)
% Allow the user to fill in options as they see fit.

% These options are not intended for the user to see.
options_to_ignore = {'preprocessOptions', 'preprocessStrings', ...
		    'doUseRaster', 'doUseClickMap', 'clusterValidity', ...
		    'numRegions', 'numClicks', 'doManyTrials', ...
		    'doOrderClusters'};

if isempty(options)
    return;
end

field_names = fieldnames(options);
noptions = length(field_names);
idx = 1;
prompt = {};
def = {};
for i = 1:noptions
    % Not working with these yet, if ever.
    if (find(strcmp(field_names{i}, options_to_ignore)))
        continue;
    end
    %BP
    if ~isfield(options.(field_names{i}), 'prompt')
        options.(field_names{i}).prompt = '';
    end
    prompt{idx} = options.(field_names{i}).prompt;
    v = options.(field_names{i}).value;
    if ~ischar(v)
        v = num2str(v);
    end
    def{idx} = v;
    idx = idx + 1;
end

% No need if there are no options.
if (idx == 1)
    return;
end

lineNo = 1;
dlgTitle='Modify Options.';
answer = inputdlg(prompt,dlgTitle,lineNo,def);

if ~isempty(answer)
    idx = 1;
    for i = 1:noptions
        if (find(strcmp(field_names{i}, options_to_ignore)))
            continue;
        end

        v = answer{idx};
        if ~ischar(options.(field_names{i}).value)
            v = str2num(v);
        end
        options.(field_names{i}).value = v;
        idx = idx + 1;
    end
else
    options = 'error';
end