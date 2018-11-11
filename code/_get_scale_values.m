clear();
clc();

F = figure();

comm = serial('/dev/cu.usbmodemFD1431','BaudRate',115200);

fopen(comm);

timeOld = int16(0);
V = [];
Vf = [];
T = [];
Vavg = 0.0;
f = 0.8;
disp('calibrating...');
tic();
while ishandle(F)
    while comm.BytesAvailable
        bytesA = comm.BytesAvailable;
        a = fscanf(comm,'%s');
        
        disp(sprintf('bytes: %d, string: %s',bytesA, a));
        
        if find(a=='.')
            a = str2num(a);
            if ~isempty(a)
                Vavg = f*Vavg+(1-f)*a;
                V = [V a];
                Vf = [Vf Vavg];
            end
        else
            a = str2num(a);
            if ~isempty(a)
                T = [T a];
            end
        end
    end
    
    
    
    time = int16(toc());
    if time~=timeOld
        disp(sprintf('time: %d',time));
        timeOld = time;
    end
    
    
    if length(V)<801
        Vplot = V;
        Vfplot = Vf;
        Tplot = T;
    else
        Vplot = V(end-800:end);
        Vfplot = Vf(end-800:end);
        Tplot = T(end-800:end);
    end
    if ishandle(F) && (length(T)>1)
        cla();
        plot((Tplot - Tplot(1))/1000,Vplot,'r');
        hold('on');
        plot((Tplot-Tplot(1))/1000,Vfplot,'b');
        title(sprintf('weight: %.4f g',Vavg));
    end

    drawnow();
end

fclose(comm);

if (input('save? 1 - yes, 0 - no  '))
    D = uint64(clock);
    save(sprintf('%d-%d-%d_%dh%dm',D(3),D(2),D(1),D(4),D(5)), 'V','T');
end