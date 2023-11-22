
To determine the number of parallel workers to speed up simulations run the following code:

speedtest.m
#script
```matlab
primeNumbers = primes(uint64(2^21));
compositeNumbers = primeNumbers.*primeNumbers(randperm(numel(primeNumbers)));
factors = zeros(numel(primeNumbers),2);

numWorkers = [1 2 4 8 12 14 16 18 20];

tLocal = zeros(size(numWorkers));

for w = 1:numel(numWorkers)
	
	% Connecting parallel pool
	c = parcluster;
	parpool(c, numWorkers(w));
	
	tic;
	parfor idx = 1:numel(compositeNumbers)
		factors(idx,:) = factor(compositeNumbers(idx));
	end
	
	tLocal(w) = toc;
	
	delete(gcp('nocreate'));
end

f = figure;
speedup = tLocal(1)./tLocal;
plot(numWorkers, speedup);
title('Speedup with the number of workers');
xlabel('Number of workers');
xticks(numWorkers);
ylabel('Speedup');
```

The maximum number of workers to gain performance should be slightly less than the number of logical processors on the system, the number of workers where you get ~90% of the maximum speedup is good. You may specify fewer workers in the simulation run script if the computer will be in use while running simulations. Systems with lower RAM may need to use fewer workers, estimate at least 1GB will be used per worker for most sims. 
