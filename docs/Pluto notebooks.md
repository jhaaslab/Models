
# Running Pluto notebooks locally

Make sure Julia is installed, or follow the [Julia setup](docs/Julia%20setup.md).

Open a julia REPL in the models folder. 

```
julia --project
```

Instantiate the project if you haven't done so.

type: `]`
(Models) pkg>`instantiate`
type `backspace` to exit pkg>

in the julia command window start the notebook with:

```
import Pluto; Pluto.run()
```

Pluto will launch in your web browser, click on the drop down under 'open a notebook' and navigate to 'Pluto_notebooks/' then select the notebook for the model you would like to view and click 'open'. 

# Editing notebook files 

To add a new slider:

find the code block that contains:

```julia
@bind var_i_dc PlutoUI.Slider(-2:0.05:2, default=0.0, show_value=true)
```

click the `+` button under that section to add a new code block.

create a slider with the variable of your choice, and give it a range of values and a default value. 
The following makes the variable `var_leak` with the values from `0.1` to `0.2` in steps of `0.001` and defaults to `0.1`

```julia
@bind var_leak PlutoUI.Slider(0.1:0.001:0.2, default=0.1, show_value=true)
```

Edit the following block containing the parameter constructor with your variable, make sure the name matches the variable name in the model structure:

```julia
p = TRNmodel(
	i_dc = var_i_dc,
	i_dc_start=[200],
	i_dc_stop=[t_end-200],
	# add your vars:
	g_l = var_leak,
)
```

`ctrl-s` or click the save button at the top right to and changes will be saved and run in the notebook. 