function [phase,info] = rbs_recover_ac_phase(t,increment)
% Broadband AC phase from measured increments; never fits a target tone.
% Fill at most two isolated missing samples, disclose all filled positions.
% Never bridge a timestamp gap, a long dropout, or an observable near-pi step.
t=double(t(:));v=double(increment(:));phase=nan(size(v));
info=struct('available',false,'originalValidFraction',mean(isfinite(v)),...
 'filledSamples',0,'interpolatedMask',false(size(v)),'bandHz',[],...
 'edgeDiscardSeconds',.2,'reason','Insufficient continuous phase increments');
if numel(t)<50||any(diff(t)<=0),return;end
dt=median(diff(t));rate=1/dt;hi=min(200,.4*rate);stop=min(225,.45*rate);
if hi<=5,return;end
info.bandHz=[5 hi];
forbidden=isfinite(v)&abs(v)>=.8*pi;bad=~isfinite(v);
edges=diff([false;bad;false]);starts=find(edges==1);ends=find(edges==-1)-1;
for k=1:numel(starts)
 a=starts(k);b=ends(k);
 if b-a+1<=2 && a>1 && b<numel(v) && ~forbidden(a-1)&&~forbidden(b+1) && max(diff(t(a-1:b+1)))<1.5*dt
  v(a:b)=interp1(t([a-1 b+1]),v([a-1 b+1]),t(a:b),'linear');info.interpolatedMask(a:b)=true;
 end
end
info.filledSamples=sum(info.interpolatedMask);v(forbidden)=NaN;
ok=isfinite(v);gap=[false;diff(t)>1.5*dt];ok(gap)=false;
edges=diff([false;ok;false]);starts=find(edges==1);ends=find(edges==-1)-1;
for k=1:numel(starts)
 a=starts(k);b=ends(k);n=b-a+1;if n*dt<1.2,continue;end
 y=v(a:b);y=y-mean(y);pad=min(round(rate),n-1);
 padded=[flipud(y(2:pad+1));y;flipud(y(end-pad:end-1))];nf=numel(padded);
 f=(0:nf-1)'*rate/nf;f(f>rate/2)=f(f>rate/2)-rate;af=abs(f);
 gain=ones(nf,1);gain(af<2|af>stop)=0;
 ix=af>=2&af<5;gain(ix)=.5-.5*cos(pi*(af(ix)-2)/3);
 ix=af>hi&af<=stop;gain(ix)=.5+.5*cos(pi*(af(ix)-hi)/(stop-hi));
 denominator=1-exp(-2i*pi*f/rate);denominator(1)=1;
 recovered=real(ifft(fft(padded).*gain./denominator));recovered=recovered(pad+1:pad+n);
 trim=round(.2*rate);keep=trim+1:n-trim;phase(a+keep-1)=recovered(keep);
end
info.available=sum(isfinite(phase))>=round(.5*rate);
if info.available,info.reason='Broadband AC phase; DC and drift removed; bounded gap filling reported';end
end
