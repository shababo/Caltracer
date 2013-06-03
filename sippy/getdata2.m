close all; clear all;



files = dir('C:\Tanya_Data\Physiology\data_struct_analyze'); % 3

DirCount=0;
for k=1:length(files);
    DirCount = DirCount + files(k).isdir;
end

for k = 1:length(files);
    if (files(k).isdir==0)
        Thisfile = fullfile('C:\Tanya_Data\Physiology\data_struct_analyze', files(k).name);
        load(Thisfile)
    end
end


