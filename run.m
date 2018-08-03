function pred = run(trainDir, testDir, savedir)
    files = dir(testDir);
    for i = 1:length(files)
        name = files(i).name;
        if ~contains(name, '.mat')
            continue
        end
        load(strcat(testDir,strcat('/',name)));
        sig_size = size(sig,2);

        numWindows = ceil((sig_size-1000)/250);

        if numWindows > 125
            numWindows = 125
        end

        sigWindow = sig(1:5,1:1000);
        prevBPM = -1;
        Fs = 125;
        yrecon = ssa(sigWindow,prevBPM);

        pred = zeros(numWindows,1);

        y = abs(fft(yrecon,Fs*60));
        [a, b] = findpeaks(y,'SortStr','descend');
        b = b(b>=60 & b<=170);
        pred(1) = b(1);

        for i=2:numWindows
            remaining = sig_size - (i-1)*250;
            if remaining>1000
                remaining = 1000;
            end
            sigWindow = sig(1:5,(i-1)*250+1:(i-1)*250+remaining);
            yrecon = ssa(sigWindow,pred(i-1));
            y = abs(fft(yrecon,Fs*60));
            [a, b] = findpeaks(y,'SortStr','descend');
            b = b(b>=(pred(i-1)-10) & b<=(pred(i-1)+10) & b>=60 & b<=170);
            pred(i) = b(1);
        end

        savefile = strcat('output_team_3_',name);
        savefile = strcat(savedir, strcat('/',savefile));
        save(savefile, 'pred');
    end
end