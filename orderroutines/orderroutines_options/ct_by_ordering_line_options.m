function options  = ct_by_ordering_line_options
options = struct;
options.doUseRaster.value = 0;		% Won't use raster data.
options.doUseClickMap.value = 1;
options.numRegions.value = 1;		% one line
options.numClicks.value = 2;		% one line is made by two points.