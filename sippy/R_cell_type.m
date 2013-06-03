%plot correlation within and across cell types

folders = dir('C:\Tanya_Data\Physiology\workspace_phys\correlation\all_expts\R_cell_type');

for i = 1:length(folders)
    if (strcmp(folders(i).name, '.') == 0);
        if (strcmp(folders(i).name, '..') == 0);
        Thisfolder = fullfile('C:\Tanya_Data\Physiology\workspace_phys\correlation\all_expts\R_cell_type', folders(i).name);
        all_R{i-2,1} = folders(i).name;
        temp = open(Thisfolder);
        expt_names = fieldnames(temp);
        all_R{i-2,2} = expt_names;
        for ii = 1:length(expt_names)
            R(ii) =  eval(['temp' '.' expt_names{ii}]);
        end
        all_R{i-2,3} = R;
        end
    end
    R = [];
end


%relevant plotting

figure; plot(ones(length(all_R{1,3})), all_R{1,3}, 'rd');
hold on; plot(ones(length(all_R{3,3})),  all_R{3,3}, 'bd')
hold on; plot(zeros(length(all_R{2,3})),  all_R{2,3}, 'rd')
hold on; plot(zeros(length(all_R{4,3})),  all_R{4,3}, 'bd')
hold on; plot(zeros(length(all_R{6,3})),  all_R{6,3}, 'gd')
hold on; plot(ones(length(all_R{5,3})),  all_R{5,3}, 'gd')
hold off;



