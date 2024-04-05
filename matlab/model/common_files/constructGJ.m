function [gjMat] = constructGJ(num_TRN,mu_gc,sig_gc)
%CONSTRUCTGJ generate random coupling within TRN network
%   Each cell makes 1-3 connections with P 0.45 0.5 0.05 respectively
%   P synapse will favor cells with no GJs (0.2 bias)
%   Coupling strength values are gaussian following mu,sig

gjMat=zeros(num_TRN);
for i=randperm(num_TRN)
    r=rand;
    if r>=0.95
    numGJ=3;
    elseif r>0.45 && r<0.95
    numGJ=2;
    elseif r<=0.45
    numGJ=1;
    end
    
    numGJ=numGJ-sum(gjMat(:,i));
    if numGJ<0
        numGJ=0;
    end
    
    r2=rand(1,9);
    for ii=1:num_TRN
        if gjMat(i,ii)==1 || sum(gjMat(:,ii))>=3
          r2(ii)=0;  
        end
        if sum(gjMat(:,ii))==0
          r2(ii)=r2(ii)+0.2;
        end
    end
    r2(i)=0;
    
    [~,I]=maxk(r2,numGJ);
    gjMat(i,I)=1;
    
    gjMat=gjMat+gjMat';
    gjMat(gjMat>1)=1;
end

gjMat = triu(gjMat);

gc = sig_gc.*randn(size(gjMat))+mu_gc;
gjMat = gjMat.*gc;

gjMat=gjMat+gjMat';
end
