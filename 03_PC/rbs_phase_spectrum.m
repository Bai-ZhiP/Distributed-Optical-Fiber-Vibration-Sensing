function result=rbs_phase_spectrum(t,p,targetHz)
% Fourier projection at genuine hardware timestamps, without interpolation.
t=t(:);p=p(:);keep=isfinite(t);t=t(keep);p=p(keep);
result=struct('frequencyHz',[],'amplitude',[],'peakHz',NaN,'targetAmplitude',NaN,'validFraction',0,'seconds',0,...
 'unwrappedFrequencyHz',[],'unwrappedAmplitudeRadians',[],'unwrappedPhase',[],'highpassPhase',[],'unwrappedPeakHz',NaN,'unwrappedTargetRadians',NaN);
if numel(t)<20 || any(diff(t)<=0),return;end
result.seconds=t(end)-t(1);ok=isfinite(p);result.validFraction=mean(ok);
if result.seconds<1 || sum(ok)<20 || result.validFraction<.7,return;end
maxFreq=min(45,.45/median(diff(t)));if maxFreq<targetHz,return;end
f=(.5:.1:maxFreq)';q=exp(1i*p);q(~ok)=0;
w=double(ok).*(.5-.5*cos(2*pi*(t-t(1))/result.seconds));den=sum(w);if den<=0,return;end
y=(q-sum(w.*q)/den).*w;t=t-t(1);
a=sqrt(2*(abs(exp(-2i*pi*f*t.')*y).^2+abs(exp(2i*pi*f*t.')*y).^2))/den;
target=sqrt(2*(abs(exp(-2i*pi*targetHz*t.')*y)^2+abs(exp(2i*pi*targetHz*t.')*y)^2))/den;
[~,j]=max(a);result.frequencyHz=f;result.amplitude=a;result.peakHz=f(j);result.targetAmplitude=target;
% Only unwrap uninterrupted, fully amplitude-qualified records. This checks
% observable discontinuities; it is not a proof against hidden phase aliasing.
step=angle(exp(1i*diff(p)));dt=median(diff(t));
if all(ok) && max(diff(t))<1.5*dt && max(abs(step))<.9*pi
 up=unwrap(p);design=[ones(size(t)) t-mean(t)];up=up-design*(design\up);
 uf=(.5:.25:min(200,.45/dt))';ua=2*abs(exp(-2i*pi*uf*t.')*(up.*w))/den;
 result.unwrappedTargetRadians=2*abs(exp(-2i*pi*targetHz*t.')*(up.*w))/den;
 result.unwrappedFrequencyHz=uf;result.unwrappedAmplitudeRadians=ua;result.unwrappedPhase=up;
 span=max(3,2*floor(.125/dt)+1);hp=up-movmean(up,span);edge=floor(span/2);hp(1:edge)=NaN;hp(end-edge+1:end)=NaN;
 result.highpassPhase=hp;[~,pk]=max(ua);result.unwrappedPeakHz=uf(pk);
end
end
