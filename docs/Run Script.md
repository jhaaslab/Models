These template scripts are written specifically for model files to be used, but will still need to be modified for your simulation runs. the work flow should be:

make a sim run directory in your project/simulations folder. be consise and specific as possible, and organize folders by aim/experiments as needed.

copy a runscript template

commit the initial script 
	state in the commit comment sim initialization

make changes to the script for your simulation

run finalized script 

commit the script after with a 'sim run finished' comment after the run was successful
>[!warning]
>make sure .mat files were put into the .gitignore file if you see the simResults files in your staging area and **do not commit those simResults.mat files**

