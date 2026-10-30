function spec=rbs_increment_spectrum(t,p,targetHz)
% Spectrum of measured wrapped phase increments. Amplitude is rad/trace.
t=t(:);p=p(:);ok=isfinite(p)&isfinite(t);spec=struct('frequencyHz',[],'amplitude',[],'targetAmplitude',NaN,'peakHz',NaN);
if numel(t)<20 || mean(ok)<.95 || t(end)-t(1)<1,return;end
t=t-t(1);w=(.5-.5*cos(2*pi*t/t(end))).*ok;den=sum(w);p(~ok)=0;v=(p-sum(p.*w)/den).*w;
f=(.5:.25:min(200,.45/median(diff(t))))';a=zeros(size(f));
for j=1:128:numel(f),ix=j:min(j+127,numel(f));a(ix)=2*abs(exp(-2i*pi*f(ix)*t.')*v)/den;end
spec.frequencyHz=f;spec.amplitude=a;spec.targetAmplitude=2*abs(exp(-2i*pi*targetHz*t.')*v)/den;[~,pk]=max(a);spec.peakHz=f(pk);
end
