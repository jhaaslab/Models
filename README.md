# Models
Repo for all TRN and TC neuron models

---

# Setup

## Requirements 

Git, if not installed. First time using git? -> [start here](https://docs.github.com/en/get-started/quickstart/set-up-git)

Julia `ver 1.9+` -> [Julia setup](Julia%20setup.md) 

Matlab `R2023b`, latest release should work -> [Matlab setup](Matlab%20setup.md)


## Usage 

Fork this repo to create your own private repo on github for your project. 
	this allows you to commit/push changes to your local project and it will not modify the model repo itself... though you could suggest changes with a pull request if you have some new code/model to add! 

Change the name of your repo to the name of your project.

Clone your new repo onto your machine
open a terminal and type (replace with your username and repo name):
`git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT`

you will now have a folder named 'YOUR-PROJECT' with the repo files


## Julia project environment setup

Julia manages packages by environment so even though we added packages in the global environment during [Julia setup](Julia%20setup.md) we will have to make sure model code dependencies are installed and precomiled for use in your project environment:

open a terminal in your project folder and start julia:
`julia` 

enter pkg by typing `]`
and type `activate .`
you should see a propt showing we are in the project:
`(PROJECT) pkg >` 
type `instantiate` and hit enter, you should see a staus bar for precompilation. when that is done you can exit julia.

To start Julia in the project environment start with the project flag:
`julia --project`


## Matlab code setup
open matlab and add the src/matlab folder to matlabs search path, do not add subfolders to the path. If working with the matlab model only start here -> [Matlab Model](Matlab%20Model.md)


## Syncing src files

Keeping model code synced with the model repo:
Add **this** repo as an upstream remote
`git remote add upstream https://github.com/jhaaslab/models.git`

Syncing your fork
open a terminal in your project folder and execute:
`git fetch upstream` -> if fetch returns no changes to the model repo there are no updates
if there are changes:
`git checkout main`
`git merge upstream/main`


---

# Model Documentation

Documentation was written and intended to be opened in [obsidian](https://obsidian.md/), just add the cloned repo as a new vault. Docs can otherwise be viewed on Github, some links may be broken (such as the following dataview table:).

Docs:

```dataview
TABLE
FROM "docs"
```

