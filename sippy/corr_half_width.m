workspace=who;


for i=1:length(workspace)
    cell = eval(workspace{i});
    [maxR ind] = max(cell);
    maxR_all(i) = maxR;
    half_max = .5*maxR;
    if ind < 2005 & ind > 1995
        ind25 = find(cell>= half_max); % first find indices where R is greater than .25max
        maxRind = find(ind25 == ind); %find index within .25max that corresponds to maxR
        cont25 = diff(diff(ind25)); %find where data is continuously above .25maxR
        cont25ind = find(cont25 <0); %locating breaks in R values less greater than .25max
        below_max = find(cont25ind < maxRind); %breaks that are less than max R but greater than halfmax
        if isempty(below_max) %sometimes only period of greater than .25maxR will be 
            start_int = ind25(1);
        else start_int = ind25(cont25ind(max(below_max)) + 1);
        end       
        above_max = find(cont25ind > maxRind);
        if isempty(above_max)
            end_int = ind25(end);
        else end_int = ind25(cont25ind(min(above_max)));
        end
        half_width = (end_int-start_int)/1000;
    else
        half_width = NaN;
    end
    half_width_all(i) = half_width;
end

MEAN_half_width = getmeans(half_width_all);
SE_half_width = get_SE(half_width_all);
MEAN_maxR = getmeans(maxR_all);
SE_maxR = get_SE(maxR_all);

