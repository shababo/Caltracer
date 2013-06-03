workspace=who;

%this function will go through data imported from the workspace into cell
%arrays. Each entry in the cell array is a matrix representing imported
%data from excel, originally imported from minianalysis. Each column of the
%matrix represents a variable about the data, for example column 2 is event
%times, column 3 is event amplitudes. 

c = 1;

for i=1:length(workspace)
    Data = eval(workspace{i});
    channels = length(Data);   
    for j = 1:channels
        if isempty(Data{j})
            EventsUP_amp = NaN;
        else
            EventTimes = Data{j}(:,2);
            EventTimes(1) = [];
            events_after_start = find(EventTimes > 4160); % indices of events after beginning of stim
            events_before_end = find(EventTimes <6500);
            EventUPs_index = intersect(events_after_start, events_before_end);
            Event_amps_all = Data{j}(:,3);
            EventsUP_amp = Event_amps_all(EventUPs_index);
            for e = 1:length(EventsUP_amp)
                all_amps(c) = EventsUP_amp(e);
                c = c+1;
            end
        end
    end
end
