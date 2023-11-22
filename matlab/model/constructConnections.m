function [connMat] = constructConnections(num_pairs,recip_prob,div_prob,mu_recip,mu_div,sig_recip,sig_div)
%CONSTRUCTCONNECTIONS generate random synapses between TRN-TC networks
%   Each possible location has prob of occuring, with recip_prob and 
%   div_prob for connections between same cell pair and surrounding cells
%   respectively. Synapse strength values are gaussian following mu,sig
%   values. set sig = 0 for same strengths

connMat = zeros(num_pairs);
R=rand(size(connMat));
R_A=randn(size(connMat));

recipMat=diag(diag(R));
recipMat(recipMat>1-recip_prob)=1;
recipMat(recipMat<1-recip_prob)=0;

A_recip = sig_recip.*R_A+mu_recip;
recipMat = recipMat.*A_recip;

divMat=R-diag(diag(R));
divMat(divMat>1-div_prob)=1;
divMat(divMat<1-div_prob)=0;

A_div = sig_div.*R_A+mu_div;
divMat = divMat.*A_div;

connMat = recipMat+divMat;
end