function [x,handles] = ct_ROPing(x, handles, options)
%ct_ROPing created by Baktash Babadi, Edited for Caltracer by Mor Dar 
% Last edit on 12/22/09

% This preprocessor loads an Ephys trace, finds PSCs, and then averages
% together all the movie frames two seconds prior to the PSC, thus pulling
% out likely contributers of the individual cell's input. 

    %Pull Values out of options.
        dt = options.EphysRes.value;
        PSPs_file =options.EphysPath.value;
        current = cell2mat(struct2cell(load(PSPs_file)));
        current = reshape(current,1,length(current));
        t = [0 : length(current)-1 ] *dt;       
        cutoff_f = 50;
        EPSC_th = -10;
        
    % Filter the current trace firts, put a threshold on it, pick the segments
    % that are above threshold, find their peaks

        % cuttoff filter of the current 
        L = length(current);
        NFFT = 2^nextpow2(L); % Next power of 2 from length of y
        Y = fft(current,NFFT)/L;
        m = NFFT/2 + 1;
        N_cf = round( cutoff_f * m / (1000/(2*dt)));
        Y ( m - (NFFT/2 - N_cf) : m + (NFFT/2 - N_cf) ) = 0;
        current_filtered = L * ifft(Y);
        current_filtered(L+1:end) =[];

        % Select segments higher than threshold EPSC_th
        current_filtered = current_filtered - mean(current_filtered);
        current_peaks = (current_filtered < EPSC_th) .* current_filtered;

        % finding peaks
        PSC_times = ( find( diff( diff(- current_peaks)>0 ) <0 ) );       
        PSCs = zeros(size(t));
        PSCs (PSC_times) = 1;        

    % If Show plot option is set to 1 (true), create a plot.
        if options.plot.value == 1        
                    %  Initialize and hide the GUI as it is being constructed.
            f = figure('Visible','on','Position',[200,500,500,300]);
                haxes1 = axes('Units','Pixels','Position',[50,50,400,200]);  
                PSC_num = uicontrol('Style','text','String','# PSCs : 0',...
                   'Position',[100,250,100,25],'FontSize',12,...
                   'HorizontalAlignment','left'); 
                   % plotting the current and detected EPSCs
                current_min = min(current);
               hold(haxes1,'on');
               plot(haxes1,t,PSCs * current_min,'r');
               plot(haxes1,t,current);  
               set(PSC_num,'String',['#PSPs : ' num2str(sum(PSCs))]);
        end  

    % This is the main part of the code. Using the dtected EPSCs, it looks
    % back 2 seconds into the movie and averages all frames that occur before the EPSC.
    % So any "frequent" contributer to the EPSc would be expected to pop-out
    % in average movie. 
    
        PSC_times = t .* PSCs;
        PSC_times(PSC_times == 0) =[];    
        frame_dur = handles.app.experiment.timeRes;
        frame_dur = frame_dur*1000;
        average_movie_frames = ceil(5000/frame_dur);        
        frame_num = length(x(1,:));
        traces = handles.app.experiment.traces;
        htraces = handles.app.experiment.haloTraces;
        raster_avg = zeros(length(x(:,1)), average_movie_frames);
        trace_avg = zeros(length(handles.app.experiment.traces(:,1)), average_movie_frames);
        halo_traces = trace_avg;
%% The main loop: calculationg the PSP-averaged movie
numtraces = length(handles.app.experiment.traces(:,1));
    %for each contour
    for s = 1:length(x(:,1))
        %for each PSC
            for i = 1 : length(PSC_times)
                %Find the PSC in the movie.
                to = max(1,ceil(PSC_times(i) / frame_dur));
               
                % Set the start of the "averager" to two seconds before the PSC
                from = max(1, to - average_movie_frames + 1);            
                              
                %w1 is the amount of time before the frame that the PSC occured
                w1 = to - PSC_times(i) / frame_dur ;
                
                %w2 is the time after the PSC that the frame occurs.
                w2 = 1 - w1 ;

                %If the PSC is beyond the end of the movie for some reason.
                if to > frame_num 
                    continue;
                end
                
                % If the PSC is on the last frame
                if  to == 1
                    raster_avg (:, 1) = raster_avg (:, 1) + ...
                              w2 * x(:,1);
                  %if contours and not halos are being calculated: 
                  if s<numtraces
                    trace_avg (:, 1) = trace_avg (:, 1) + ...
                              w2 * traces(:,1);
                  end
                %if the PSC is within two seconds of the first frame.
                elseif from ==1
                    
                    %% This THROWS OUT ALL FRAMES when PSC is within two
                    %% seconds from the start of the movie.
                    
%                     framesbeforepsc = average_movie_frames - to;
%                     raster_avg (s, 1 : to - from) = raster_avg (s, 1: to - from) + ...
%                               w2 * x(s,to:-1:from+1) + w1 * x(s,to-1:-1:from);    
%                   %if contours and not halos are being calculated: 
%                   if s<numtraces     
%                     trace_avg (s, 1 : to - from) = trace_avg (s, 1: to - from) + ...
%                               w2 * traces(s,to:-1:from+1) + w1 * traces(s,to-1:-1:from); 
%                   end

                %Otherwise
                else               
                     raster_avg (s,1:1+to-from) = raster_avg (s,1:1+to-from) + ...
                       w2*x(s,to:-1:from) + w1 * x(s,to-1:-1:from-1);
                  %if contours and not halos are being calculated: 
                  if s<=numtraces
                     trace_avg (s,1:1+to-from) = trace_avg (s,1:1+to-from) + ...
                       w2*traces(s,to:-1:from) + w1 * traces(s,to-1:-1:from-1);
                  else %if halos exist
                      cnum = s - numtraces;
                      halo_traces (cnum,1:1+to-from) = halo_traces (cnum,1:1+to-from) + ...
                       w2*htraces(cnum,to:-1:from) + w1 * htraces(cnum,to-1:-1:from-1);
                  end
                end
            end
    end
    raster_avg = raster_avg/length(PSC_times);
    trace_avg = trace_avg/length(PSC_times);
    x=raster_avg;

    %% Adjust handles for average movie.
handles.app.experiment.globals.numImagesProcess = average_movie_frames;
handles.app.experiment.traces = trace_avg;
handles.app.experiment.haloTraces = halo_traces;
% If halos are not used:
if (handles.app.experiment.haloMode == 0)
    contourlength = length(x(:,1));
    for test = 1:contourlength
        handles.app.experiment.contours(test).intensity = handles.app.experiment.contours(test).intensity (1,1:average_movie_frames);
    end
else
    % If halos are used:
    contoursplushalos = length(x(:,1));
    contoursonly = contoursplushalos/2;
    for test = 1:contoursonly
        handles.app.experiment.contours(test).intensity = handles.app.experiment.contours(test).intensity (1,1:average_movie_frames);
        handles.app.experiment.contours(test).haloIntensity = handles.app.experiment.contours(test).haloIntensity (1,1:average_movie_frames);
    end
end