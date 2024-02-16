# Models
Repo for all TRN and TC neuron models

---

# Setup

## Requirements 

Git, if not installed. First time using git? -> [start here](https://docs.github.com/en/get-started/quickstart/set-up-git)

Julia `ver 1.9+` -> [Julia setup](docs/Julia%20setup.md) 

Matlab `R2023b`, latest release should work -> [Matlab setup](docs/matlab/Matlab%20setup.md)


## Usage 

- Create your own repo on github for your project. 
this allows you to commit/push changes to your project and it will not modify the model repo itself... though you could suggest changes with a pull request if you have some new code/model to add! 

- Mirror model files to your project repo.
open a terminal and type (replace with your username and repo name):
```
git clone --bare https://github.com/jhaaslab/Models.git
# Make a bare clone of the repository

cd Models.git
git push --mirror https://github.com/YOUR-USERNAME/YOUR-PROJECT.git
# Mirror-push to the new repository

cd ..
rm -rf Models.git
# Remove our temporary local repository
```

- Clone your new repo onto your machine
open a terminal and type (replace with your username and repo name):
`git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT`

You will now have a folder with your project name containing the model files

## Syncing src files

Keeping model code synced with your project repo

Open a terminal in your project folder:
Add **this** repo as an upstream remote
```
git remote add upstream https://github.com/jhaaslab/models.git
```

Syncing your fork
```
git fetch upstream
git checkout main
git merge upstream/main
```

remove accidental pushing to upstream
`git remote set-url --push upstream no_push`


## Julia project environment setup

Julia manages packages by environment so even though we added packages in the global environment during [Julia setup](docs/Julia%20setup.md) we will have to make sure model code dependencies are installed and precomiled for use in your project environment:

Open a terminal in your project folder and start julia:
`julia` 

enter pkg by typing `]`

You should see a propt showing we are in the project:

`(PROJECT) pkg >` 

Type `instantiate` and hit enter, you should see a staus bar for precompilation. when that is done you can exit julia.

To start Julia in the project environment start with the project flag:

`julia --project`


## Matlab code setup
Open matlab and add the src/matlab folder to matlabs search path, do not add subfolders to the path. 


## Running simulations

Creating sim run scripts -> [Run Script](Run%20Script.md)

To see the details of the model src start here -> [Julia Model](Julia%20Model.md)

If working with the matlab model only start here -> [Matlab Model](Matlab%20Model.md)


---

# Model Documentation

Documentation was written and intended to be opened in [obsidian](https://obsidian.md/), just add the cloned repo as a new vault. Docs can otherwise be viewed on Github, some links may be broken (such as the following dataview table:).

Docs:

```dataview
TABLE
FROM "docs"
```

