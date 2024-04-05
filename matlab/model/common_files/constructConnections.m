function [connMat] = constructConnections(num_pairs,recip_prob,div_prob,A_mean,A_sig)
%CONSTRUCTCONNECTIONS generate random synapses between TRN-TC networks
%   Each possible location has prob of occuring, with recip_prob and 
%   div_prob for connections between same cell pair and surrounding cells
%   respectively. Synapse strength values are gaussian following mu,sig
%   normalized to total number of synapses recieved by each cell.

connMat = zeros(num_pairs);
R=rand(size(connMat));

recipMat=diag(diag(R));
recipMat(recipMat>1-recip_prob)=1;
recipMat(recipMat<1-recip_prob)=0;

divMat=R-diag(diag(R));
divMat(divMat>1-div_prob)=1;
divMat(divMat<1-div_prob)=0;

connMat = recipMat+divMat;

A_mat = A_sig.*randn(size(connMat)) + A_mean;

connMat = (connMat.*A_mat) ./ sum(connMat);
connMat = fillmissing(connMat,'constant',0);
end
