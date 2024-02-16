These template scripts are written specifically for model files to be used, but will still need to be modified for your simulation runs. the work flow should be:

make a sim run directory in your project/simulations folder. be consise and specific as possible, and organize folders by aim/experiments as needed.

copy a runscript template

make changes to the script for your simulation

run finalized script/extract data/make plots 

commit the script after the run was successful

>[!warning]
>simResult .mat files should be ignored from the .gitignore file, if you see the simResults files in your staging area **do not commit those simResults.mat files** and check the .gitignore and that sim files are saved with the correct filenames.  

