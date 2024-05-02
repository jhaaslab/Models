
Synaptic connections are represented by a matrix of synaptic strengths. Columns represent source neurons with target neuron along rows: 

 Amp = 

|       | Tgt_1    | ... | Tgt_j    |
| ----- | -------- | --- | -------- |
| Src_1 | Amp[1,1] |     | Amp[1,j] |
| ...   |          | ... |          |
| Src_i | Amp[i,1] |     | Amp[i,j] |

thus synapse strength between source cell i, and target cell j, can be set or accessed by Amp[i, j]


# Electrical synapses

Electrical synapses between TRN cells differ in that src and tgt cells are the same, making this a symmetric matrix (unless asymmetric connections are specifically tested). To set a gap junction with strength Gc set both directions to Gc: gj[TRN_x, TRN_y] = Gc; gj[TRN_y, TRN_x] = Gc


# Constructors 

Chemical and electrical synapses have two separate constructor functions for producing random connectivity and strengths from a set of defined variables. 

## constructConnections

For chemical synapses between two populations of cells: 

```julia
constructConnections(num_src, num_tgt, recip_prob, div_prob, mean_amp, sig_amp)
```

Inputs are:
- size of source neuron network
- size of target neuron network
- probability of forming reciprocal synapse (between same numbered pairs)
- probability of divergent synapse (across pair connectivity)
- mean strength of synapses
- sigma of the distribution of synapse strengths


## constructGJ

For electrical synapses, connection probability is pre-defined to constrain the connections to 1-3 and to minimize the chance that any cell has zero connections. (Inspired by the algorithm in Amsalem et al. 2016)

```julia
constructGJ(num_TRN, mean_Gc, sig_Gc)
```

Inputs are just:
- size of the TRN network
- mean strength of electrical synapses 
- sigma of the distribution of electrical synapse strengths


# External synapses


Timing of external synaptic events are drawn from a poisson distribution using the poissonProc function:

```julia
poissonProc(r,T)
```

Inputs are:
- rate of events (in Hz)
- time (in ms)

Strength of each event can be set to a distribution as in: 

```julia
Amp = sig_Amp .* randn(length(tevents)) .+ mean_Amp
```
