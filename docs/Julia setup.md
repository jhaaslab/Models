Windows: Install from MS store to get latest release and comes with [Juliaup](https://github.com/JuliaLang/juliaup) for version managment 
open a powershell and type:
```
winget install julia -s msstore
```

Mac/linux terminal type:
```
curl -fsSL https://install.julialang.org | sh
```
Arch based systems use the AUR package:
```
pamac install juliaup
```

Model code was written as of Julia 1.9, if issues arise in future releases set the default to 1.9.X using Juliaup.

to install latest julia version:
```
juliaup add release
```
# Usage

Simply open a terminal and type `julia` to start julia's REPL. You can execute commands here as you would with the matlab terminal. Function calls require parentheses' even with no inputs: i.e. >> `pwd()`
Files can be run by `include` 'ing the filename: >> `include("path/to/file.jl")`

# Packages

## adding packages

type `]` to enter pkg setup:
necessary pkgs:

ODE solver suite
pkg> `add OrdinaryDiffEq`

.mat file loading/saving
pkg> `add MAT`

optional:
plotting
pkg> `add Plots`

installed packages must still be imported into the scope by `using <PKG_NAME>` before their contents can be accessed by that scope.

## updating/precompiling packages

in Pkg, to check the staus of installed packages:
pkg> `status` or `st`

there will be arrows and a message indicating if packages need updating or installing, if so run:
pkg> `update` or `up`
pkg> `instantiate`


# IDE

You can use the Julia REPL with your text editor of choice, VS Code is easiest with the [Julia extension](https://www.julia-vscode.org/docs/dev/gettingstarted/), this will also give you access to a GUI workspace and debugger if you need those.

# Multithreading 

to run simulations in parallel you will need to change the [numthreads Environmental variable.](https://docs.julialang.org/en/v1/manual/multi-threading/) Setting this to "auto" will set threads to number of logical processors you have, and provide best performance. If the computer is slow or needs to be used while running sims lower the number of threads.

To set for the current session use the threads flag:
`julia --threads="auto"`

To set globally:
on windows pwsh:
`$env:JULIA_NUM_THREADS="auto"` 

on mac/linux:
`export JULIA_NUM_THREADS="auto"`
 