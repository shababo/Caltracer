workspace=who;
cc = 0;
dd = 0;


for i=1:length(workspace)
    Data = eval(workspace{i});
    channels = length(Data);   
    for j = 1:channels
        if isempty(Data{j})
            EventTimesUP = NaN;
        else
            EventTimes = Data{j}(:,2);
            EventTimes(1) = [];
            EventsUP1 = find(EventTimes > 4000);
            EventsUP2 = find(EventTimes <6500);
            EventUPs_index = intersect(EventsUP1, EventsUP2);
            EventTimesUP = EventTimes(EventUPs_index);
            Events(i,j) = {EventTimesUP};
        end
    end
end


for ii= 1:size(Events,1)
    for p = 1:size(Events,2) -1
        for q = p:size(Events,2) -1
            events1 = Events{ii,p};
            events2 = Events{ii,q+1};
            if ~isempty(events1) && ~isempty(events2)
            for pp = 1:length(events1)
                for qq = 1:length(events2)
                    cc = cc+1;
                    diffs(cc) = abs(events1(pp) - events2(qq)); %time between spikes in ms
                end
                dd = dd + 1;
                diffs_min(dd) = min(diffs);
                diffs = [];
                cc = 0;
            end
            end
        end
    end
end


            
                
                
            
           
