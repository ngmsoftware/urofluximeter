clear();
clc();

% medicine: 11/03/2017

F = figure();

source = 'WEB';

if strcmp(source,'SERIAL')
    comm = serial('/dev/cu.usbmodemFA1221','BaudRate',115200,'Timeout',10);

    fopen(comm);
end

if strcmp(source,'WEB')
    R = webread('http://192.168.4.1');
    pause(0.1);
    R = webread('http://192.168.4.1');
    pause(0.1);
end

timeOld = int16(0);
V = [];
Vf = [];
T = [];
Vavg = 0.0;
f = 0.8;
disp('calibrating...');
tic();

notFinished = 1;
a = 'C';
while ishandle(F)&&(notFinished)
    
    switch source
    
        case 'SERIAL'
    
            a = fscanf(comm,'%s');

            switch a(1)

                case 'V'
                    a = fscanf(comm,'%f');
                    Vavg = f*Vavg+(1-f)*a;
                    V = [V a];
                    Vf = [Vf Vavg];

                    a = fscanf(comm,'%d');
                    T = [T a];

                    a = fscanf(comm);
                case 'C'
                    %disp('still calibrating...');

            end

        case 'WEB'
            
            R = webread('http://192.168.4.1');
            pause(0.1);
            if ~isempty(R),
                [v, t] = processWebData(R);

                Vavg = v;
                
                Vf = [Vf Vavg];
                V = [V v];
                T = [T t];
            end
            
    end            
    
    if (length(Vf)>3)
        notFinished = (Vf(end)-Vf(end-1))>-5.0;
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
        title(sprintf('weight: %.4f g',Vavg(1)));
    end

    drawnow();
end

if strcmp(source,'SERIAL')
    fclose(comm);
end

if (input('save? 1 - yes, 0 - no  '))
    D = uint64(clock);
    filename = sprintf('%d-%d-%d_%dh%dm',D(3),D(2),D(1),D(4),D(5));
    save(filename, 'V','T');
    filter_values(filename); 
end