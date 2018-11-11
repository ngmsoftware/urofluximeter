clear();
clc();

a = dir('*.mat');

Tmedicine = datenum(2017,3,11,0,0,0);

for i = 1:length(a)
    name = a(i).name();
    disp(name);
    
    %dateTest = name(1:find(name=='_')-1);
    %hourTest = name(find(name=='_')+1:find(name=='.')-1);
    values = sscanf(name,'%d-%d-%d_%dh%dm.mat');
    day = values(1);
    month = values(2);
    year = values(3);
    hour = values(4);
    min = values(5);
    
    load(name);
    
    [Ts, Fs, Fm_t, V_t] = filter_values(name);
    
    Time(i) = datenum(year,month,day,hour,min,0);
    Fmax(i) = Fm_t;
    Volume(i) = V_t;
    
    figure(1);
    hold('on');
    plot(Ts, Fs,'color',ones(1,3)*(1-i/length(a)), 'linewidth',2);
    drawnow();
end

figure(2);
Time(Volume<180) = [];
Fmax(Volume<180) = [];
Volume(Volume<180) = [];

[Time, idx] = sort(Time);
Fmax = Fmax(idx);
Volume = Volume(idx);

maskMedicine = Time<Tmedicine;

TimeNoMedicine = Time(maskMedicine);
FmaxNoMedicine = Fmax(maskMedicine);
VolumeNoMedicine = Volume(maskMedicine);
TimeMedicine = Time(~maskMedicine);
FmaxMedicine = Fmax(~maskMedicine);
VolumeMedicine = Volume(~maskMedicine);

meanFmaxNoMedicine = mean(FmaxNoMedicine);
meanFmaxMedicine = mean(FmaxMedicine);
meanVolumeNoMedicine = mean(VolumeNoMedicine);
meanVolumeMedicine = mean(VolumeMedicine);
stdFmaxNoMedicine = std(FmaxNoMedicine);
stdFmaxMedicine = std(FmaxMedicine);
stdVolumeNoMedicine = std(VolumeNoMedicine);
stdVolumeMedicine = std(VolumeMedicine);

TimeNoMedicine = TimeNoMedicine - TimeNoMedicine(1);
TimeMedicine = TimeMedicine - TimeMedicine(1) + TimeNoMedicine(end);

hold('on');
plot(TimeNoMedicine,FmaxNoMedicine,'rx','markerSize',8.0);
plot(TimeMedicine,FmaxMedicine,'bx','markerSize',8.0);
line([TimeNoMedicine(1) TimeNoMedicine(end)],[meanFmaxNoMedicine meanFmaxNoMedicine],'color','r','lineWidth',2.0);
line([TimeMedicine(1) TimeMedicine(end)],[meanFmaxMedicine meanFmaxMedicine],'color','b','lineWidth',2.0);
line([TimeNoMedicine(1) TimeNoMedicine(end)],[-stdFmaxNoMedicine -stdFmaxNoMedicine] + meanFmaxNoMedicine,'color','r','linestyle','--','lineWidth',2.0);
line([TimeNoMedicine(1) TimeNoMedicine(end)],[stdFmaxNoMedicine stdFmaxNoMedicine] + meanFmaxNoMedicine,'color','r','linestyle','--','lineWidth',2.0);
line([TimeMedicine(1) TimeMedicine(end)],[-stdFmaxMedicine -stdFmaxMedicine] + meanFmaxMedicine,'color','b','linestyle','--','lineWidth',2.0);
line([TimeMedicine(1) TimeMedicine(end)],[stdFmaxMedicine stdFmaxMedicine] + meanFmaxMedicine,'color','b','linestyle','--','lineWidth',2.0);
xlabel('days');
ylabel('flux');

%{
figure(2);
hold('on');
plot(TimeNoMedicine,VolumeNoMedicine,'rx');
plot(TimeMedicine,VolumeMedicine,'bx');
line([TimeNoMedicine(1) TimeNoMedicine(end)],[meanVolumeNoMedicine meanVolumeNoMedicine],'color','r');
line([TimeMedicine(1) TimeMedicine(end)],[meanVolumeMedicine meanVolumeMedicine],'color','b');
line([TimeNoMedicine(1) TimeNoMedicine(end)],[-stdVolumeNoMedicine -stdVolumeNoMedicine] + meanVolumeNoMedicine,'color','r','linestyle','--');
line([TimeNoMedicine(1) TimeNoMedicine(end)],[stdVolumeNoMedicine stdVolumeNoMedicine] + meanVolumeNoMedicine,'color','r','linestyle','--');
line([TimeMedicine(1) TimeMedicine(end)],[-stdVolumeMedicine -stdVolumeMedicine] + meanVolumeMedicine,'color','b','linestyle','--');
line([TimeMedicine(1) TimeMedicine(end)],[stdVolumeMedicine stdVolumeMedicine] + meanVolumeMedicine,'color','b','linestyle','--');


figure(3);
hold('on');
plot(VolumeNoMedicine,FmaxNoMedicine,'ro');
plot(VolumeMedicine,FmaxMedicine,'bo');

%}