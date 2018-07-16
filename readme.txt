This folder contains eye movement algorithms used in the VPOM lab to e.g. detect saccades or pursuit onset.
Usually the first step is to convert eye movement data from edf to asc (at least if the experiment was run
in Eyelink). This can be done using convert_edf2asc.m.
The script to view the data trial by trial, i.e. click through, is called viewEyeData.m and should be
the starting point for eye movement analysis.
Please note that this does not yet save your results.
