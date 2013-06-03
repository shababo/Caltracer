function options = ct_discrete_wavelets_options

options.waveletName.value = 'db5';
options.waveletKeepLevels.value = [1:5 0];
options.waveletMaxLevel.value = 5;

options.waveletName.prompt = 'Enter the wavelet to use.';
options.waveletKeepLevels.prompt = ['Enter the levels to keep (0' ...
		    ' for approximation).'];
options.waveletMaxLevel.prompt = ['Enter the decomposition level.'];

