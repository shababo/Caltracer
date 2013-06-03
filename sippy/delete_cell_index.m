function [F] = delete_cell_index(rawF);


d = 1;
delete(1) = 1;
for dd = 2:size(rawF,2)-1
    delete(dd) = delete(dd-1) + 2;
end

delete = delete(find(delete<(size(rawF,2))));
rawF(:,delete) = [];
F = rawF';

    
    