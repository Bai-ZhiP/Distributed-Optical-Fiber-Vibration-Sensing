function spec = rbs_wave_spectrum(t,y)
% FFT of the waveform actually plotted, at real hardware timestamp slots.
spec=struct('frequencyHz',[],'amplitude',[],'peakHz',NaN,'seconds',0);
t=double(t(:));y=double(y(:));ok=isfinite(y);
if sum(ok)<100,return;end
a=find(ok,1);b=find(ok,1,'last');t=t(a:b);y=y(a:b);ok=isfinite(y);
if t(end)-t(1)<.5||mean(ok)<.7,return;end
dt=median(diff(t));rate=1/dt;slot=round((t-t(1))/dt)+1;
if numel(unique(slot))~=numel(slot)||max(abs((slot-1)*dt-(t-t(1))))>.05*dt,return;end
y(~ok)=0;mu=sum(y)/sum(ok);w=(.5-.5*cos(2*pi*(t-t(1))/(t(end)-t(1)))).*ok;
nfft=2^nextpow2(max(slot));grid=zeros(nfft,1);grid(slot)=(y-mu).*w;
v=fft(grid);f=(0:nfft-1)'*rate/nfft;use=f>=0&f<=.45*rate;
spec.frequencyHz=f(use);spec.amplitude=2*abs(v(use))/max(sum(w),eps);spec.seconds=t(end)-t(1);
band=spec.frequencyHz>=5;ff=spec.frequencyHz(band);aa=spec.amplitude(band);
if ~isempty(ff),[~,j]=max(aa);spec.peakHz=ff(j);end
end
