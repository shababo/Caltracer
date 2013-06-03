workspace=who;


for i=1:length(workspace)
    cell = eval(workspace{i});
    [maxR ind] = max(cell);
    quarter_max = .25*maxR;
    if ind < 2005 & ind > 1995
        ind25 = find(cell>= quarter_max); % first find indiced where R is greater than .25max
        maxRind = find(ind25 == ind); %find index within .25max that corresponds to maxR
        cont25 = diff(diff(ind25)); %find where data is continuously above .25maxR
        cont25ind = find(cont25 <0); %locating breaks in R values less greater than .25max
        below_max = find(cont25ind < maxRind); 
        if isempty(below_max) %sometimes only period of greater than .25maxR will be 
            start_int = ind25(1);
        else start_int = ind25(cont25ind(max(below_max)) + 1);
        end       
        above_max = find(cont25ind > maxRind);
        if isempty(above_max)
            end_int = ind25(end);
        else end_int = ind25(cont25ind(min(above_max)));
        end
        integ_cell = trapz(cell(start_int:end_int));
    else
        integ_cell = NaN;
    end
    integ_cell_all(i) = integ_cell;
end


        
    