function [zstack, param] = ct_firstframe(filename, pathname,sequential)
param.frameType = 'firstframe';
% Updated 7/28/09 - Removed useless code. 
% Updated 7/15/11 - added sequential code.-MD

fnm = [pathname filename];
if sequential==0
    zstack = double(imread(fnm,1));
else
   zstack=double(imread(fnm)); 
end