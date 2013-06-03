function [sfns, fns] = readdir(handles, dirname)
% function [sfns fns] = readdir(handles, dirname)
% Read the directory for CalTracer type files.  
% Return the 
% shortened files names (no 'ct_' and no '.m')
% file names (no '.m')
% Also eliminates 'cta_' for caltracer signal analyzer files

% Load the various image filters from the directory.
ff = fullfile(handles.app.info.ctPath, dirname);
mt = dir(ff);

if (length(mt) < 1)
    errordlg(['You probably need to do a full checkout because a directory ' dirname ' is missing.']);
    return;
end
% Create the string names for the filter selection widget.
%st = cell(1,length(mt));
sidx = 1;
for c = 1:length(mt)
    %mt(c)
    if (isempty(mt(c).name) ...
        | ~isempty(find(strcmp({'..','.', 'CVS'},mt(c).name))) ...
        | strcmp(mt(c).name(end), '~') ...
        | ~strcmp(mt(c).name(end), 'm'))
        continue;
    end
    file_names{sidx} = mt(c).name(1:end-2); % no .m
    st{sidx} = mt(c).name(1:end-2);	% no .m
    if (strcmp(lower(st{sidx}(1:min([3 length(st{sidx})]))),'ct_'))
        st{sidx} = st{sidx}(4:end);	% no ct_
    end
    if (strcmp(lower(st{sidx}(1:min([4 length(st{sidx})]))),'cta_'))
        st{sidx} = st{sidx}(5:end);	% no ct_
    end
    sidx = sidx + 1;
end

sfns = fliplr(st);			% put _none_ at end.
fns = fliplr(file_names);		% put _none_ at end.