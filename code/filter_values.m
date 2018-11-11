function [varargout] = filter_values(varargin)


if isempty(varargin)
    % pick file
    [p, f] = uigetfile();
    load([f p]);
elseif length(varargin)==1
    load(varargin{1});
else
    T = varargin{1};
    V = varargin{2};
end

% normalize time
Ts = (T-T(1))/1000;

% convert weight to urinal ml
urimDensity = 1.02;
Vml = V/urimDensity;


% compute flow
rawFlow =   (diff(Vml)./diff(Ts));


filter = 'spline';

switch filter 
    case 'pre_fft'
        preFreq = 0.9;
        cutOff = 100;

        Vs = 0;
        for i=2:length(Vml)
            Vs(i) = Vs(i-1)*preFreq + Vml(i)*(1.0-preFreq);
        end

        preRawFlow =   (diff(Vs)./diff(Ts));

        preRawFlowFreq = fft(preRawFlow);
        preRawFlowFreq(cutOff:end-cutOff-1) = 0;
        filteredFlow = abs(ifft(preRawFlowFreq));

    case 'medfilt_pos'
        preOrder = 10;
        posFreq = 0.7;

        rawFlowMedFilt = medfilt1(rawFlow, preOrder);

        Vs = 0;
        for i=2:length(rawFlowMedFilt)
            Vs(i) = Vs(i-1)*posFreq + rawFlowMedFilt(i)*(1.0-posFreq);
        end      
        
        filteredFlow = Vs;
        
    case 'spline'
        n = 9;
        N = 10;

        V = medfilt1(Vml,5);
        
        dV = [0 diff(V)];
        dV(dV<0) = 0;
        V = cumsum(dV);
        
        Vs = zeros(size(V));
        for i=1:n
            Vs = Vs + spline(T(n:N:end), V(n:N:end), T);
        end
        Vs = Vs/n;

        filteredFlow = (diff(Vs)./diff(Ts));   
        
end

% crop negative flows
filteredFlow(filteredFlow<0) = 0;



% create non-zero flow mask
[FMax, idxMax] = max(filteredFlow);
flowMask = (filteredFlow>(0.04*FMax));

% adjust time vector size (for ploting)
Ts = Ts(1:end-1);

% volume
volume = mean(Vml(end-10:end));

if nargout==0

    hold('on');
    patch([Ts Ts(end)] ,[flowMask*FMax 0],'b','edgecolor','none','facealpha',0.2);
    plot(Ts,rawFlow,'color',[1.0 0.9 0.9]);
    plot(Ts,filteredFlow,'b','linewidth',2);
    xlabel('time (s)');
    ylabel('flow (ml/s)');
    title(sprintf('Max Flow: %.2f ml/s, Volume: %.2f ml', FMax, volume));
    line([Ts(idxMax) Ts(idxMax)],[-0.5 1.1*FMax],'color','k');
    %axis([0 Ts(end) -0.5 1.1*FMax]);
    axis([0 Ts(end) -0.5 20]);
    grid('on');
    box('on');
else
    if nargout == 2
        varargout{1} = FMax;
        varargout{2} = volume;
    else
        varargout{1} = Ts;
        varargout{2} = filteredFlow;
        varargout{3} = FMax;
        varargout{4} = volume;
    end
        
end