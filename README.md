To run the code, call ```net_project_dcsbm.py transport-nets``` or ```net_project_dcsbm2.py [social-offline-nets/social-online-nets]``` (the files are separated by input format).

```project_inference.py``` contains the code to get partitions from graphs (all funcs return a list of sets, which can then be fed into ```nx.community.modularity()```).

```project_hists.py``` contains the code to output data for us in matlab.

```project_plots.m``` makes all the figures.
