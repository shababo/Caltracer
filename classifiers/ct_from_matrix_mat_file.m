function [result, data, options] = ct_by_matrix_mat_file(data, handles, clustered_contour_ids,cluster_size, options)
% [result, data, options] = ct_by_matrix_mat_file(data,...
% handles, clustered_contour_ids,cluster_size, options)
%  Function that allows clustering based on a mat file that's on the disk.
%  User must find this file for import.  The file will have a single column
%  and the column will be the length of all the cells detected and the
%  value of each row will denote the cluster number for the cell with that
%  row number.  This matrix file could come from the Signal Analyzer.
%
%  Inputs: 
%  data = the rastermap (matrix of cell brightness vs frame number for all
%      cells in non-killed clusters)
%  handles = CalTracer handles
%  clustered_contour_ids = the ids of the cells represented in data... in
%      their original order
%  cluster_size = ? always = 3?
%  options = from options file
%
%  Outputs:
%  result = result.data.f is a matrix giving cluster assignments for each
%  cell.  Must have one column for each cluster and each cell must have a 1
%  in one and only one column, indicating which cluster it's in.
%  data = unchanged data in
%  options = potentially changed version of options in

warning off
result = [];
[FileName,PathName] = uigetfile;

load([PathName,'\',FileName]);%should load something called "cellClusterAssignments"
try
    availvalues = unique(cellClusterAssignments);%get which unique values exist in the matrix
    result.data.f = zeros(size(cellClusterAssignments,1),length(availvalues));%set up for output
    for avidx = 1:length(availvalues);%make a cluster for each unique value found
        result.data.f(cellClusterAssignments == availvalues(avidx),avidx) = 1;
    end
    result.data.f = result.data.f(clustered_contour_ids,:);%eliminate cells that were not in the incoming cluster
catch
    errordlg('.mat file must have vector called "cellClusterAssignments" with a row for each cell.')
    params.wasError = 1;
    return
end