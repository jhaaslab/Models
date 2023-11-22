function [gjMat] = constructGJ(num_TRN,gj_prob,mu_gc,sig_gc)
%CONSTRUCTGJ generate random coupling within TRN network
%   Each possible GJ location has gj_prob of occuring. gj_prob =0.3 makes
%   ~1-3 connections per cell with 5% chance a cell will have 0 GJs.
%   Coupling strength values are gaussian following mu,sig:
%   TRN av cc = .12+/-0.08 (Haas 2011), requires mu_gc =0.02,sig_gc =0.003.

gj = zeros(1,num_TRN*(num_TRN-1)/2);

R=rand(size(gj));
gj(R<gj_prob)=1;

gc = sig_gc.*randn(size(gj))+mu_gc;
gj = gj.*gc;

gjMat=zeros(num_TRN);
counter=1;
for i=1:num_TRN
    gjMat(i,i+1:num_TRN)=gj(counter:counter+num_TRN-i-1);
    counter=counter + (num_TRN-i);
end

gjMat=gjMat+gjMat';
end