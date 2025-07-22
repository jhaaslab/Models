
Synaptic connections are represented by a matrix of synaptic strengths. Columns represent source neurons with target neuron along rows: 

 A = 

|       | Tgt_1    | ... | Tgt_j    |
| ----- | -------- | --- | -------- |
| Src_1 | Amp[1,1] |     | Amp[1,j] |
| ...   |          | ... |          |
| Src_i | Amp[i,1] |     | Amp[i,j] |

thus synapse strength between source cell i, and target cell j, can be set or accessed by `A[i, j] = amplitude` or by creating a matrix

```julia
A = [
	0.0 0.1 0.0 0.0 
	0.0 0.0 0.0 0.0 
	0.0 0.0 0.0 0.0 
	0.0 0.0 0.2 0.0 
] 
```

The above code would only make synapses between src1 -> tgt2, and src4 -> tgt3 with amplitudes `0.1` and `0.2` respectively.

# Electrical synapses

Electrical synapse connectivity can be similarly expressed similarly by a symmetric matrix `GJ` (unless asymmetric connections are specifically tested). To set a gap junction with strength Gc set both directions: 

```julia
GJ[TRN_x, TRN_y] = Gc
GJ[TRN_y, TRN_x] = Gc
```

# Constructors 

Chemical and electrical synapses have two separate constructor functions for producing random connectivity and strengths from a set of defined variables. These were written to be specific to TRN and TC networks, but specific constructors could be made for other systems as well.

## construct_syn_net

For chemical synapses between two populations of cells: 

```julia
construct_syn_net(num_src, num_tgt,
	recip_prob = 1.0, 
	div_prob   = 0.0, 
	mean  = 0.2, 
	sigma = 0.0, 
	normalize = "none"
)
```

Inputs are:
- size of source neuron network
- size of target neuron network
- probability of forming reciprocal synapse (between same numbered pairs)
- probability of divergent synapse (across pair connectivity)
- mean strength of synapses
- sigma of the distribution of synapse strengths
- normalization method "all",  "per-cell", "none"


## construct_gj_net

For electrical synapses, connection probability is pre-defined to constrain the connections to 1-3 and to minimize the chance that any cell has zero connections. (Inspired by the algorithm in Amsalem et al. 2016)

```julia
construct_gj_net(num_TRN, 
	mean_Gc   = 0.01, 
	sigma_Gc  = 0.0, 
	normalize = "none"
)
```

Inputs are just:
- size of the TRN network
- mean strength of electrical synapses 
- sigma of the distribution of electrical synapse strengths
- normalization method "all",  "per-cell", "none"


# External synapses


Timing of external synaptic events are drawn from a Poisson distribution using the `poisson_process` function:

```julia
t_events = poisson_process(rate, tspan, 
	# optional binning window (precision) of spike times
	bin_window=0.1
)
```

Inputs are:
- rate of events (in Hz)
- time span (in ms)

Strength of each event in `t_events` can be set to a normal distribution as in: 

```julia
Amps = sigma_Amp .* randn(length(tevents)) .+ mean_Amp
```