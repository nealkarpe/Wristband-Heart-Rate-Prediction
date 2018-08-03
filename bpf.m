function x = bpf(sig,fs)
	% Preprocessing - band pass filtering to remove frequencies outside normal human heart beat
	% range.
	% Signature - sig => ppg signal vector.
	% fs - sampling frequency of the dataset.


	% find the size of the vector
	cols = size(sig,2);

	% time for which the signal was sampled
	time = cols/fs;

	% bpf range
	% The maximum possible human heart rate is 200. Minimum 40.
	normal_range = [floor(2/3*time) ceil(10/3*time)];

	% take the fft
	ffted_sig = fft(sig);
	% plot(abs(ffted_sig));


	% Rect function
	rectangle = zeros(1,cols);
	rectangle(normal_range(1): normal_range(2)) = 1; 
	x= ffted_sig.*rectangle;

	% figure; plot(abs(x));
	% Take the ifft here.
	x = ifft(x);
end
