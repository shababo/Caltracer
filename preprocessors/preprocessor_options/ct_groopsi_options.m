function options  = ct_groopsi_options
% Frame rate recieved from caltracer.
% options.V.dt.value = 30;		% frame rate.
% options.V.dt.prompt = 'Enter the framerate in Hz';
% options.V.dt.value = 1/options.V.dt.value;

options.Plam.value = 0.5;		
options.Plam.prompt = 'Enter the P.lam';

options.idxlist.value = [];
options.idxlist.prompt = 'Index list of cells to run through foopsi, default is all.';