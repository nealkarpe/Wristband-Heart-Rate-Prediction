function DC = roc(prevBPM, x, y, z, ppgy)
% This module essentially takes care of removal of motion artefacts.

k = 1;
% Step 1 : calculate fft of the accelerometer signal and normalize it.
    xdash = abs(fft(x,7500));
    ydash = abs(fft(y,7500));
    zdash = abs(fft(z,7500));
    xdash = xdash/max(xdash);
    ydash = ydash/max(ydash);
    zdash = zdash/max(zdash);

% Step 2 : Band pass filtering of the normalized signal to remove the
% frequencies outside human heart range.
    xdash = abs(bpf(xdash,125));
    ydash = abs(bpf(ydash,125));
    zdash = abs(bpf(zdash,125));

% Step 3 : Check if the signal has peaks or not.
    kxdash = kurtosis(xdash);
    kydash = kurtosis(ydash);
    kzdash = kurtosis(zdash);

    
MA = [];
f = (0:125/(7500-1):125)*60;
% Step 4: finding out all the peaks where the motion artefacts occur.
if kxdash>130 || kydash>130 || kzdash>130
    % Indicates that there are peaks in either f the accelerometer data
    if kxdash>130
        [xpeaks, xind] = findpeaks(xdash, 'SortStr', 'descend');
        for i = 1:3
            if xpeaks(i)>=0.5
                    MA = [MA f(xind(i))];             
            end
        end
    end
       
    if kydash>130
        [ypeaks, yind] = findpeaks(ydash, 'SortStr', 'descend');
        for i = 1:3
            if ypeaks(i)>=0.5
                    MA = [MA f(yind(i))];
            end
        end
    end
       
    if kzdash>130

        [zpeaks, zind] = findpeaks(zdash, 'SortStr', 'descend');
        for i = 1:3
            if zpeaks(i)>=0.5
                    MA = [MA f(zind(i))];
            end
        end
    end  
end
MA = unique(MA);
emp = isempty(MA);
DC = [];
for i=1:size(ppgy,1)
    Y(1,:) = abs(fft(ppgy(i,:),7500));
    [~,ind_y] = max(Y(1,1:210)); 
    location_y(i) = f(1,ind_y); 
    for j=1:size(MA,1)
        if(prevBPM<=0 && emp == 0 && location_y(i) + 5 > MA(j) && location_y - 5 < MA(j))
            DC(k) = 0;
            k = k+1;
        else
            if(prevBPM > 0 && (location_y(i) + 5 > MA(j) && location_y(i) - 5 < MA(j) && (location_y(i) + 11 < prevBPM || ...
                location_y(i) - 11 > prevBPM)))
                DC(k) = i;
                k = k+1;
            end
        end
    end
    if(prevBPM > 0 && (location_y(i) + 44 < prevBPM || location_y(i) - 44 > prevBPM))
        DC(k) = i;
        k = k+1;
    end
end
DC = unique(DC);
end
