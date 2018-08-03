function y_reconstructed = ssa(signal,prevBPM)

	sig = signal(1,:);
	acc_data = signal(3:5,:);

	% 1st step of the process - singular spectrum analysis of the signal.
	cols = size(sig,2);

	% M is the window length, best value according to experimentation.
	M = 215;

	% Number of slides you can do with that window size on the signal of size
	% N.
	K = cols-M+1;

	X = zeros(M,K);

	% Constructing the X matrix. Dimensions of X = M*K 
	for j=1:K
	    X(:,j) = sig(j:j+M-1);
	end

	% S matrix same as one in research paper. Dimensions of S - M*M. 
	S = X*X';

	% Doing the eigen decomposition of S here. U is the eigen vectors and
	% lambda is the eigen values.
	[U, lambda] = eig(S);


	% lambda is a vector which contains all the eigen values. 
	% lambda is a diagnol matrix, so you take all the diagnol elements and put
	% in a vector.
	lambda = diag(lambda); %column vector

	% Sort the eigenvalues, and correspondingly the eigenvectors too. 
	[lambda,idx] = sort(lambda(:,1), 'descend');
	U = U(:,idx);

	V = (X')*U;

	y_reconstructed = reconstruction(lambda,U,V,acc_data,prevBPM);
end
