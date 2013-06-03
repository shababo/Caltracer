function handles = determine_regions(handles)
% function handles = determine_regions(handles)
% The regions are redetermined each time this function is called,
% that is to say, the handles.app.experiment.regions.reg structure is
% recreated from scratch, which is why it's not loaded here, but
% saved at the end.  
%    handles.app.experiment.regions.coords is created here.

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;


bord = handles.app.experiment.regions.bord;
nx = handles.app.experiment.Image(maskidx).nX;
ny = handles.app.experiment.Image(maskidx).nY;
if length(bord) > 0
    uiset(handles, 'regions', 'bord_delete', 'enable','on');
    pt = [];
    for c = 1:length(bord)
        pt = [pt; [bord{c}(1,:) c]];
        pt = [pt; [bord{c}(end,:) c]];
    end
    lst = [];
    
    lst = [1 1 0];
    f = find(pt(:,1)==1);
    lst = [lst; sortrows(pt(f,:))];
    lst = [lst; [1 ny 0]];
    f = find(pt(:,2)==ny);
    lst = [lst; sortrows(pt(f,:))];
    lst = [lst; [nx ny 0]];
    f = find(pt(:,1)==nx);
    lst = [lst; flipud(sortrows(pt(f,:)))];
    lst = [lst; [nx 1 0]];
    f = find(pt(:,2)==1);
    lst = [lst; flipud(sortrows(pt(f,:)))];
    
    usd = zeros(1,size(lst,1));
    reg = cell(1,0);
    
    if size(lst,1) == 4
        reg{end+1} = [1 1; 1 ny; nx ny; nx 1];
    end
    
    for c = 1:size(lst,1)
        if (usd(c) == 0 & lst(c,3) > 0)
            reg{end+1} = zeros(0,3);
            j = c;
            while (size(reg{end},1) < 2 | reg{end}(1,3) ~= reg{end}(end,3))
                usd(j) = 1;
                reg{end} = [reg{end}; lst(j,:)];
                j = mod(j,size(lst,1))+1;
                if (lst(j,3) > 0)
                    reg{end} = [reg{end}; lst(j,:)];
                    if (bord{lst(j,3)}(1,1) == reg{end}(end,1) & ...
			bord{lst(j,3)}(1,2) == reg{end}(end,2));
			newreg = [bord{lst(j,3)}(2:end-1,:) lst(j,3)*ones(size(bord{lst(j,3)},1)-2,1)];
                        reg{end} = [reg{end}; newreg];
                    else
			newreg = flipud([bord{lst(j,3)}(2:end-1,:) lst(j,3)*ones(size(bord{lst(j,3)},1)-2,1)]);
                        reg{end} = [reg{end}; newreg];
                    end
                    j = setdiff(find(lst(:,3)==lst(j,3)),j);
                end
            end
            reg{end} = reg{end}(:,1:2);
        end
    end
    
    for c = setdiff(1:length(bord),lst(:,3))
        reg{end+1} = bord{c}(1:end-1,:);
    end
    
else
    reg = cell(1,1);
    reg{1} = [1 1; 1 ny; nx ny; nx 1];
    uiset(handles, 'regions', 'bord_delete', 'enable','off');
end

% Save the regs (is this a region?)
handles.app.experiment.regions.coords = reg;
draw_region_widget(handles);
