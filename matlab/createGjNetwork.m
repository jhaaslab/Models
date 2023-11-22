function createGjNetwork()
% CREATEGJNETWORK creates a coupled TRN network from coupling parameters and,
%   adjusts Rin of cells in the network
%   recalculates initial conditions for network
%   calculates coupling coefficients (CC) between all cells

rng("shuffle")

load('g_L_func.mat', 'g_L_func')

% vars
namesOfNeurons = {'TRN1','TRN2','TRN3','TRN4','TRN5','TRN6','TRN7','TRN8','TRN9'};
numNeurons = length(namesOfNeurons);
Gc_total = 0.005:0.005:0.03;
numGc = length(Gc_total);
%Gc_sig = 0;
numNets = 1;

Rin_tgt = 7.89;
iDC = -0.3:0.05:0.15;

gj{numGc,numNets}  =[];
g_L{numGc,numNets} =[];
Rin{numGc,numNets} =[];
bias{numGc,numNets}=[];


save_dir = [pwd '/TRN_network'];
if ~isfolder(save_dir)
    mkdir(save_dir)

    save([save_dir '/netVars.mat'], 'namesOfNeurons','Gc_total','numNets',...
                                    'gj', 'g_L', 'Rin', 'bias')

    m=1; n=1;
    save([save_dir '/tmpVars.mat'], 'm','n')
else
    load([save_dir '/tmpVars.mat'], 'm','n')

    load([save_dir,'/netVars.mat'], 'gj', 'g_L', 'Rin', 'bias')
end


% Iterate networks
while m <= numGc
    Gc = Gc_total(m);
    while n <= numNets
        %gj_tmp = constructGJ(numNeurons,Gc,Gc_sig);

        % Ring
        gj_tmp = [0 Gc 0 0 0 0 0 0 Gc;
                  Gc 0 Gc 0 0 0 0 0 0;
                  0 Gc 0 Gc 0 0 0 0 0;
                  0 0 Gc 0 Gc 0 0 0 0;
                  0 0 0 Gc 0 Gc 0 0 0;
                  0 0 0 0 Gc 0 Gc 0 0;
                  0 0 0 0 0 Gc 0 Gc 0;
                  0 0 0 0 0 0 Gc 0 Gc;
                  Gc 0 0 0 0 0 0 Gc 0];

        %Estimate Rin adjust
        g_L_tmp = g_L_func(sum(gj_tmp));

        Rin_tmp = zeros(1,numNeurons);
        bias_tmp= zeros(1,numNeurons);

        save([save_dir '/gj_tmp.mat'], 'gj_tmp')
        save([save_dir '/g_L_tmp.mat'],'g_L_tmp')

        % Rin calculation//adjustment
        adjRin();

        gj(m,n)  = {gj_tmp};
        g_L(m,n) = {g_L_tmp};
        Rin(m,n) = {Rin_tmp};
        bias(m,n)= {bias_tmp};

        save([save_dir,'/netVars.mat'], 'gj', 'g_L', 'Rin', 'bias')

        n = n+1;
        save([save_dir '/tmpVars.mat'],'n')
    end


    m = m+1;
    save([save_dir '/tmpVars.mat'],'m')
end


% Recalculate initial conditions
! julia --profile -e 'using Models.CalcVm;main()'

% Calculate CC
! julia --profile -e 'using Models.CalcCC;main()'


% rm *_tmp.mat


% functions
function adjRin()

    %Calculate Rin
    ! julia --profile -e 'using Models.calcRin;main()'
        %;exit()' ??

    load([save_dir, '/vm_tmp.mat'],'vm')

    for i=1:numNeurons
        [fit1] = fit(iDC',vm(i,:)','poly1');
        Rin_tmp(i) = fit1.p1;
        bias_tmp(i) = (-70-(fit1.p2))/fit1.p1;
    end

    Rin_diff = Rin_tmp-Rin_tgt;

    if any(abs(Rin_diff)./Rin_tgt > 0.01)
    %Adjust leak
    gL_adj = 0.0025*(0.6^counter); % ?? change this based of Rin diff?
    for i=1:numNeurons
        if Rin_diff(i)/Rin_tgt <= 0.01

        elseif Rin(i)>Rin_tgt
            g_L_tmp(i)=g_L_tmp(i)+gL_adj;
        else
            g_L_tmp(i)=g_L_tmp(i)-gL_adj;
        end
    end

    save([save_dir '/g_L_tmp.mat'],'g_L_tmp')

    %Recalculate Rin recursively
    adjRin();

    end

end %adjRin


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
end %constructGJ

end %main
