function [connMat] = constructConnections(num_src,num_tgt,recip_prob,div_prob,A_mean,A_sig)
%CONSTRUCTCONNECTIONS generate random synapses between TRN-TC networks
%   Each possible location has prob of occuring, with recip_prob and 
%   div_prob for connections between same cell pair and surrounding cells
%   respectively. Synapse strength values are gaussian following mu,sig
%   normalized to total number of synapses recieved by each cell.

connMat = zeros(num_src,num_tgt);
R=rand(size(connMat));

if num_src>num_tgt
    R = R';
end

recipMat=R.*(R==diag(R));
recipMat(recipMat>1-recip_prob)=1;
recipMat(recipMat<1-recip_prob)=0;

divMat=R.*(R~=diag(R));
divMat(divMat>1-div_prob)=1;
divMat(divMat<1-div_prob)=0;

connMat = recipMat+divMat;

if num_src>num_tgt
    connMat = connMat';
end

A_mat = A_sig.*randn(size(connMat)) + A_mean;

connMat = (connMat.*A_mat) ./ sum(connMat);
connMat = fillmissing(connMat,'constant',0);
end
