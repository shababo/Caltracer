function options  = ct_manually_reassign_actives_options
options = struct;
options.doUseRaster.value = 0;
options.doManyTrials.value = 0;		% no local minimum.
options.doOrderClusters.value = 0;