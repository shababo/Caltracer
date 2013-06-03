function x = ct_discrete_wavelets(x, options)
% function x = ct_discrete_wavelets(x, options)
%
% Use wavelet coeffecifients of signal. The envelope, if needed, can
% be taken from the magnitude of the Hilbert transform (below).  If 0
% is in the keep levels, this means to keep the wavelet approximation
% as well as the details.
%  
% In this code you will see two cases, one for decomposition (into
% many signals) and one for reconstruction (to one signal).  For
% ct 

[nrecordings len] = size(x);
% Get the options for the reconstruction.
wavelet_keep_levels = options.waveletKeepLevels.value;
wavelet_maxlevel = options.waveletMaxLevel.value;
wavelet_usage = 'reconstruction';
wavelet_name = options.waveletName.value;

if (find(wavelet_keep_levels == 0))
    do_include_last_approx = 1;
else
    do_include_last_approx = 0;
end

switch(wavelet_usage)
 case 'reconstruction'
  do_reconstruct_signal = 1;
 case 'multi'
  do_reconstruct_signal = 0;
 otherwise 
  error(['Unknow wavelet usage option: ' wavelet_usage '.']);
end


for i = 1:nrecordings
    recording = x(i,:)';
    [C, L] = wavedec(recording, wavelet_maxlevel, wavelet_name);  
    ndims = length(wavelet_keep_levels);
    % Get the details and make a multidimenstional signal.  This code
    % works but isn't an option for ct since we need a signal that is
    % the exact same dimensions back.
    if (0 & ~do_reconstruct_signal)
	ndims = length(wavelet_keep_levels);
	dN = zeros(length(recording), ndims);
	idx = 1;    
	for i = 1:wavelet_maxlevel
	    if (find([wavelet_keep_levels] == i))
		c = wrcoef('d', C, L, wavelet_name, i);	   
		dN(:,idx) = c;
		idx = idx+1;
	    end
	end
	if (do_include_last_approx)
	    aN = wrcoef('a', C, L, wavelet_name, wavelet_maxlevel);
	    dN(:,idx) = aN;
	end
	recording = dN;
	
	% Get the pseudofrequency.
	%a = 2.^[1:wavelet_maxlevel];
	wavelet_keep_levels
	2.^wavelet_keep_levels
	pseudofreqs = scal2frq(2.^wavelet_keep_levels, wavelet_name, 1/Fs)
	
	% Reconstruct the signal from the keep levels.
    else				
	idx = 1;
	for j = 1:wavelet_maxlevel
	    % If we don't find the level, we zero it.
	    if (isempty(find([wavelet_keep_levels] == j)))
		start_idx = sum(L(1:wavelet_maxlevel-j+1))+1;
		stop_idx = start_idx+L(wavelet_maxlevel-j+2)+1;
		C(start_idx:stop_idx) = 0;
		%pause;
	    end
	end
	if (~do_include_last_approx)
	    C(1:L(1)) = 0;
	end
	recording = waverec(C, L, wavelet_name);	
	x(i,:) = recording';
    end
end
