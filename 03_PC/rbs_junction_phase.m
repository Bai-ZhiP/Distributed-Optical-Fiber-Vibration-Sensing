function [phase,amplitude,centerKm,coherence,increment] = rbs_junction_phase(raw,cfg,tick)
% Weighted temporal phase increments in fixed upstream/downstream groups.
% No sinusoidal fit, target-frequency filter, or interpolation across gaps.
persistent s
phase=NaN;amplitude=NaN;coherence=NaN;increment=NaN;centerKm=20.15;
if isempty(raw),s=[];return;end
origin=cfg.firstSampleIndex;fs=cfg.sampleRate;dx=299792458/(2*1.468*fs);
groups=[20 20.10;20.20 20.30];if isfield(cfg,'junctionGroupsKm'),groups=cfg.junctionGroupsKm;end
centerKm=mean(groups(:));span=round(cfg.matchedPulseNs*fs/1e9);
key=[numel(raw) origin fs cfg.beatHz span groups(:).'];
if isempty(s)||~isequal(s.key,key)
 centers=(floor(groups(1,1)*1000/dx):13:floor((groups(2,2)+.001)*1000/dx)-1)';z=centers*dx/1000;
 first=centers(1)-30;last=centers(end)+30;assert(first>=origin && last<origin+numel(raw) && span==50,'Invalid junction ROI or averaging span');
 indexes=(first:last)';upper=centers-first+floor(span/2)+1;lower=upper-span;
 s=struct('key',key,'indexes',indexes-origin+1,'lo',exp(-2i*pi*cfg.beatHz/fs*indexes),'upper',upper+1,'lower',lower+1,...
  'left',z>=groups(1,1)&z<=groups(1,2),'right',z>=groups(2,1)&z<=groups(2,2),'previous',[],'tick',NaN,'phase',0);
end
a=double(raw(s.indexes));a=a(:);cs=[0;cumsum((a-mean(a)).*s.lo)];iq=2*(cs(s.upper)-cs(s.lower))/span;
amplitude=min(sqrt(mean(abs(iq(s.left)).^2)),sqrt(mean(abs(iq(s.right)).^2)));
gap=.003;if numel(raw)>4096,gap=.015;end
if isempty(s.previous)||tick<=s.tick||(tick-s.tick)/fs>gap
 s.previous=iq;s.tick=tick;s.phase=0;return;
end
v=iq.*conj(s.previous);aa=abs(iq).^2;bb=abs(s.previous).^2;
w=aa.*bb./max(aa+bb,eps);w(aa<cfg.minIqAmplitudeCounts^2|bb<cfg.minIqAmplitudeCounts^2)=0;w=min(w,2500);
u=v./max(abs(v),eps);mask={s.left,s.right};q=zeros(2,1);c=zeros(2,1);count=zeros(2,1);
for k=1:2,m=mask{k};q(k)=sum(w(m).*u(m));c(k)=abs(q(k))/max(sum(w(m)),eps);count(k)=sum(w(m)>0);end
coherence=min(c);
if coherence>=.7 && min(count)>=3
 increment=angle(q(2)*conj(q(1)));s.phase=s.phase+increment;phase=angle(exp(1i*s.phase));
else
 s.phase=0;
end
s.previous=iq;s.tick=tick;
end
