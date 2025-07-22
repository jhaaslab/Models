# Model usage

If matlab hasn't been installed follow the setup -> [Here](Matlab%20setup.md)

Open matlab and add the 'matlab/model/common_files' folder to the search path 

Workflow:
- make a new subfolder in the simulations directory.

- Copy model files (Run_dsim.m, dsim.m, simParams.m) to new simulation folder.

- edit the [Run_dsim.m](Run_dsim.md) template script, and run the script.

- after, run extractData to extract spike times and firing rate from vm data for analysis.

- Visualize vm data from sims by running plotVm or plotFR in the sim directory.

---

# Documentation

Further information on running simulations and details of the model code can be found in the docs directory:

| doc file                  | description                                                       | code file                                   |
| ------------------------- | ----------------------------------------------------------------- | ------------------------------------------- |
| [Run_dsim](Run_dsim.md)   | Script controlling variables and driving parallel simulation runs | [Run_dsim.m](../../matlab/model/Run_dsim.m) |
| [dsim](dsim.md)           | Function containing HH equations for model cells                  | [dsim.m](../../matlab/model/dsim.m)         |
| [simParams](simParams.md) | Object containing parameters for model cells                      | [simParams](../../matlab/model/simParams.m) |
