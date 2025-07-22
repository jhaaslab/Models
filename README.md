# Models
Repo for all TRN and TC neuron models

---

# Julia Model

## Requirements 

Git, if not installed. First time using git? -> [start here](https://docs.github.com/en/get-started/quickstart/set-up-git) 

Julia -> [Julia setup](docs/Julia%20setup.md) 

Matlab `R2024b`, latest release should work -> [Matlab setup](docs/matlab/Matlab%20setup.md)

## Usage 

For basic usage clone this repo and follow the setup below

```
git clone https://github.com/jhaaslab/models.git
```

For use in your own modelling project, create a fork.
this allows you to commit/push changes to your project and it will not modify the model repo itself... though you could suggest changes with a pull request if you have some new code/model to add! 

- Clone your new repo onto your machine
open a terminal and type (replace with your username and repo name):

```
git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT
```

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

```
git remote set-url --push upstream no_push
```


## Julia project environment setup

Julia manages packages by environment so even though we added packages in the global environment during [Julia setup](docs/Julia%20setup.md) we will have to make sure model code dependencies are installed and precompiled for use in your project environment:

Open a terminal in your project folder and start julia:

`julia --project` 

enter pkg by typing `]`

You should see a prompt showing we are in the project:

`(PROJECT) pkg >` 

Type `instantiate` and hit enter, you should see a status bar for precompilation. when that is done you can exit julia.


## Matlab code setup

Open matlab and add the 'matlab' folder to matlabs search path, subfolders not needed if only running the julia model. 


## Running simulations

Creating sim run scripts -> [Run Script](docs/Run%20Script.md)


## Model Documentation

Documentation was written and accessed offline through [obsidian](https://obsidian.md/), just add the cloned repo as a new vault. Docs can otherwise be viewed on Github, though some features may not render.

To see the details of the model src start here -> [Julia Model](docs/Julia%20Model.md)


---

# Matlab Model

## Requirements 

Git, if not installed. First time using git? -> [start here](https://docs.github.com/en/get-started/quickstart/set-up-git) 

Matlab `R2024b`, latest release should work -> [Matlab setup](docs/matlab/Matlab%20setup.md)

## model usage 

Start here -> [Matlab Model](docs/matlab/Matlab%20Model.md)

