function [pixels, laststackidx, imageinfo] = ct_readtifstack(moviename,varargin)
%This function reads tifstack movies into matlab.  You must direct matlab
%to the directory your file is in and in quotes type the name of the file
%to be loaded in.  The output, "pixels" will be a 3D matrix of pixel
%values, first two dimensions are height and width, third dimension is frame number. 
%   First argument in is always the moviename.  The second argument does
%   not have to be there... if it is there it specifies "outputmode" it 
%   specifies the nature of the output frames... as 2d frames (images) 
%   or as linear vectors (as strings of values).  This can save memory
%   later.  
%   The default outputmode is "frames", user may specify "linear"

% Updated 7/29/09 (Called by ct_readtraces_mem.m) -MD

pixels = [];
imageinfo = [];
outputmode='frames';
maxstacksize = Inf;
startstackidx = 1;
nargs = length(varargin);
for i = 1:2:nargs
    switch(varargin{i})
        case 'outputmode'
      outputmode = varargin{i+1};
        case 'maxstacksize'
      maxstacksize = varargin{i+1};
        case 'startstackidx'
      startstackidx = varargin{i+1};
        case 'imageinfo'
            imageinfo = varargin{i+1};
    end
end

if ~isfield (imageinfo, 'height')
    %get basic info about the movie. including image dimensions & number of frames
    imageinfo=ct_tifinfo(moviename,1);
end
    
stacksize = min([maxstacksize imageinfo.numframes]);
laststackidx = startstackidx+stacksize-1;
if (laststackidx > imageinfo.numframes)
    stacksize = stacksize - (laststackidx - imageinfo.numframes);
    laststackidx = imageinfo.numframes;
end
height=imageinfo.height;
width=imageinfo.width;

pixels=uint16(zeros(1));
pixperframe = height*width;
pixtemp=repmat(pixels,[height,width,stacksize]);
pixels = repmat(pixels,[pixperframe,stacksize]);


% Read the Tiff image and depending on output mode, reorganize the data.
h = waitbar(0, ...
		'Please wait, reading Tiff image');        
switch(outputmode)
    case 'linear'
        numrun = 1;
        idx2 = 0;
        for idx = startstackidx:laststackidx
            waitbar(idx2/stacksize);
            idx2= idx2+1;
            pixtemp = imread(moviename,idx);
            for count = 1:width:pixperframe
            pixels(count:width+count-1,idx2)= pixtemp(numrun,:);
            numrun = numrun+1;
            end
            numrun = 1;
        end
    case 'frames'
        for idx = startstackidx:laststackidx
            waitbar(idx2/stacksize);
            pixels (:,:,idx) = imread(moviename,idx);
        end
end
close (h);
laststackidx = idx;