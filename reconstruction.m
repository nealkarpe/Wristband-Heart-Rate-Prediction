function y_reconstructed = reconstruction(lambda, U, V, acc_data, prevBPM)
	% Implementing the reconstruction phase of ssa.
	M = size(U,1);
	K = size(V,1);
	N = M + K - 1; % length of signal

	V = V';

	% Grouping stage
	num_eigs = 9;
	groupNum = 1;
	sumOfEigs = sum(lambda(1:num_eigs,1));
    i = 1;

	while i <= num_eigs
		if (lambda(i,1) - lambda(i+1,1))/sumOfEigs >= 0.02
			% Don't group.
			Xgrouped(:,:,groupNum) = U(:,i)*V(i,:);
			i = i + 1;
		else
			% The eigen values are close to eachother. Group them.
			Xgrouped(:,:,groupNum) = U(:,i)*V(i,:) + U(:,i+1)*V(i+1,:);
			i = i + 2;
		end
		groupNum = groupNum + 1;
	end

	num_groups = groupNum - 1;
	%diagonal averaging
	timeSeriesVectors = zeros(num_groups,N);

	if M<K
		for i = 1:num_groups
			X = Xgrouped(:,:,i);
			vector = zeros(N,1);
			for j = 0:N-1
				if j < M-1
					total = 0;
					for k = 1:j+1
						total = total + X(k,j-k+2);
					end
					total = total / (j+1);
					vector(j+1,1) = total;
				elseif j<K
					total = 0;
					for k = 1:M
						total = total + X(k,j-k+2);
					end
					total = total / M;
					vector(j+1,1) = total;
				else
					total = 0;
					for k = j-K+2:N-K+1
						total = total + X(k,j-k+2);
					end
					total = total / (N-j);
					vector(j+1,1) = total;
				end
			end
			timeSeriesVectors(i,:) = vector(:,1);
		end
	else
		for i = 1:num_groups
			X = Xgrouped(:,:,i)';
			vector = zeros(N,1);
			for j = 0:N-1
				if j < K-1
					total = 0;
					for k = 1:j+1
						total = total + X(k,j-k+2);
					end
					total = total / (j+1);
					vector(j+1,1) = total;
				elseif j<M
					total = 0;
					for k = 1:K
						total = total + X(k,j-k+2);
					end
					total = total / K;
					vector(j+1,1) = total;
				else
					total = 0;
					for k = j-M+2:N-M+1
						total = total + X(k,j-k+2);
					end
					total = total / (N-j);
					vector(j+1,1) = total;
				end
			end
			timeSeriesVectors(i,:) = vector(:,1);
		end
	end

	deleteComponents = roc(prevBPM,acc_data(1,:),acc_data(2,:),acc_data(3,:),timeSeriesVectors);

	y_reconstructed = zeros(1,N);

	if(length(deleteComponents) == num_groups)
		deleteComponents = 0;
	end

	for i=1:num_groups
		if ~(ismember(i,deleteComponents))
			y_reconstructed = y_reconstructed + timeSeriesVectors(i,:);
		end
	end

	%Temporal Difference
	% don t do temporal difference if the signal is still the original
	if(length(deleteComponents) >= (num_groups-2))
		y_reconstructed=diff(y_reconstructed);
		y_reconstructed=diff(y_reconstructed);
	end
end
