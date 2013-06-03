function info = ct_tifinfo(filename,varargin)
% This function returns information about a given Tiff file.
% Inputs, filename (which includes the path) and a possible other variable,
% used to gather data for all frames.
% This function returns Width, Height, Number of Frames, Byte order, 
% Strip offsets and bits per sample.

% MD Last Edited: 7/27/09

% Initialize some values.
info = [];
Tif = [];
%BOS = Byte Order String
Tif.BOS= 'l';          
Tif.r = 'r';
%Open the file.
Tif.file = fopen(filename,'r','l');
if Tif.file == -1   
   error('MATLAB:imfinfo:fileOpen', ...
          'Unable to open file "%s".', filename);    
end


% Read Header
% Read Byte Order: II = little endian, MM = big endian
byte_order = fread(Tif.file, 2, '*char');
if ( strcmp(byte_order', 'II') )
    Tif.BOS = 'l';
    Tif.ByteOrder = 'little-endian';
elseif ( strcmp(byte_order','MM') )
    Tif.BOS = 'ieee-be';
    Tif.ByteOrder = 'big-endian';
else
    error('This is not a TifF file (no MM or II).');
end

%Read in a number which identifies file as TIFF format
tiff_id = fread(Tif.file,1,'uint16', Tif.BOS);
if (tiff_id ~= 42)
    error('This is not a TIFF file (missing 42).');
end

%Read the byte offset for the first image file directory (IFD)
ifd_pos = fread(Tif.file,1,'uint32', Tif.BOS);

%Set frame counter (numframes).
Tif.numframes = 0;

% While loop runs for each frame in the Tiff.
while (ifd_pos ~= 0)
    % Count frames.
    Tif.numframes = Tif.numframes+1;
    
    % Move in the file to the first IFD
    fseek(Tif.file, ifd_pos, -1);    
    
    % Read in the number of IFD entries
    num_entries = fread(Tif.file,1,'uint16', Tif.BOS);

    % Unless specified with a second input, get the following information 
    %only the first time through.
    if Tif.numframes == 1 || nargin ~= 1
        %read and process each IFD entry
        for i = 1:num_entries

            % save the current position in the file
            file_pos  = ftell(Tif.file);

            % read entry tag
            Tif.entry_tag = fread(Tif.file, 1, 'uint16', Tif.BOS);
            entry = readIFDentry (Tif);

            switch Tif.entry_tag
                case 256         % image width - number of column
                    Tif.width          = entry.val;
                case 257         % image height - number of row
                    Tif.height         = entry.val;
                     
            end

            % move to next IFD entry in the file
            fseek(Tif.file, file_pos+12,-1);
        end    
    else
        % save the current position in the file
        file_pos  = ftell(Tif.file);
        skipahead = 12*num_entries;
        fseek(Tif.file,file_pos+skipahead,-1);
    end
    ifd_pos = fread(Tif.file, 1, 'uint32', Tif.BOS);
end

% clean-up
fclose(Tif.file);
info = Tif;


%===================sub-function that reads an IFD entry:===================

function  entry = readIFDentry(Tif)

entry.tiffType = fread(Tif.file, 1, 'uint16', Tif.BOS);
entry.cnt      = fread(Tif.file, 1, 'uint32', Tif.BOS);

switch (entry.tiffType)
    case 1
        entry.nbBytes=1;
        entry.matlabType='uint8';
    case 2
        entry.nbBytes=1;
        entry.matlabType='uchar';
    case 3
        entry.nbBytes=2;
        entry.matlabType='uint16';
    case 4
        entry.nbBytes=4;
        entry.matlabType='uint32';
    case 5
        entry.nbBytes=8;
        entry.matlabType='uint32';
    case 11
        entry.nbBytes=4;
        entry.matlabType='float32';
    case 12
        entry.nbBytes=8;
        entry.matlabType='float64';
    otherwise
        error('tiff type %i not supported', tiffType)
end

if entry.nbBytes * entry.cnt > 4
    %next field contains an offset:
    offset = fread(Tif.file, 1, 'uint32', Tif.BOS);
    fseek(Tif.file, offset, -1);
end

if Tif.entry_tag == 33629   %special metamorph 'rationals'
    entry.val = fread(Tif.file, 6*entry.cnt, entry.matlabType, Tif.BOS);
else
    if entry.tiffType == 5
        entry.val = fread(Tif.file, 2*entry.cnt, entry.matlabType, Tif.BOS);
    else
        entry.val = fread(Tif.file, entry.cnt, entry.matlabType, Tif.BOS);
    end
end
if ( entry.tiffType == 2 ); 
    entry.val = char(entry.val'); 
end

return;