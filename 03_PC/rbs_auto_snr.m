function result = rbs_auto_snr(t,x,z,diagnosticX)
% Blind measured FFT search. Amplitude flags are reported, never a fixed veto.
% A short all-position scan only proposes points. Both independent halves of
% the full 4.2 s record must exceed 10 dB at their pooled strongest peak.
if nargin<4,diagnosticX=[];end
n=numel(z);blank=nan(1,n);
result=struct('ready',false,'candidates',[],'snrDb',blank,'diagnosticSnrDb',blank,...
 'diagnosticPeakHz',blank,'peakHz',blank,'frequencyHz',[],'power',[],'displayPower',[],...
 'frameRateHz',NaN,'reason','Collecting at least 4 seconds',...
 'definition','Highest pooled FFT-power peak: +/-1 Hz excess power over equal-band local median noise; both independent halves >10 dB; >=95% measured phase coverage',...
 'selectionMetric','fftPeakSnrDb','selectionThresholdDb',10,...
 'spectrumSignal','Measured 20 m differential phase increments; no target-frequency fitting',...
 'diagnosticDefinition','All-position 2.047 s FFT proposes points; only full-record two-half confirmation can qualify',...
 'qualified',false(1,n),'half1SnrDb',blank,'half2SnrDb',blank,'validFraction',zeros(1,n),...
 'rankingScoreDb',blank,'amplitudeValidFraction',zeros(1,n),'screenedPositions',0,'peakPhaseAmplitudeRad',blank);
t=t(:);if numel(t)<200||t(end)-t(1)<4,return;end
keep=t>=t(end)-4.2;t=t(keep);strict=x(keep,:);
if isempty(diagnosticX),measured=strict;else,measured=diagnosticX(keep,:);end
result.amplitudeValidFraction=mean(isfinite(strict),1);
dt=median(diff(t));rate=1/dt;result.frameRateHz=rate;
if any(diff(t)<=0)||max(diff(t))>max(.010,3*dt),result.reason='Time gaps: waiting for continuous data';return;end
fmin=5;fmax=min(450,.45*rate);if fmax<=fmin,return;end
mid=floor(numel(t)/2);v1=mean(isfinite(measured(1:mid,:)),1);v2=mean(isfinite(measured(mid+1:end,:)),1);
result.validFraction=min(v1,v2);
short=t>=t(end)-2.047;
[p,df,dv]=spectrum(t(short),measured(short,:),2048,fmin,fmax,.70);
if isempty(p),result.reason='Trigger timestamp grid mismatch';return;end
[~,q]=max(p,[],1);scan=rbs_peak_snr(p,df,q);scan(dv<.70)=NaN;
result.snrDb=scan;result.peakHz=df(q).';result.diagnosticSnrDb=scan;result.diagnosticPeakHz=df(q).';
% Screening is deliberately below 10 dB. It cannot itself create candidates.
proposed=find(scan>7&v1>=.95&v2>=.95);result.screenedPositions=numel(proposed);
if ~isempty(proposed)
 nfft=2^nextpow2(ceil(max(t(mid)-t(1),t(end)-t(mid+1))*1000)+2);
 [a,f]=spectrum(t(1:mid),measured(1:mid,proposed),nfft,fmin,fmax,.95);
 [b,~]=spectrum(t(mid+1:end),measured(mid+1:end,proposed),nfft,fmin,fmax,.95);
 if isempty(a)||isempty(b),result.reason='Trigger timestamp grid mismatch';return;end
 pooled=(a+b)/2;[~,j]=max(pooled,[],1);
 s1=rbs_peak_snr(a,f,j);s2=rbs_peak_snr(b,f,j);snr=rbs_peak_snr(pooled,f,j);
 result.snrDb(proposed)=snr;result.peakHz(proposed)=f(j);
 result.half1SnrDb(proposed)=s1;result.half2SnrDb(proposed)=s2;
 result.rankingScoreDb(proposed)=min(s1,s2);
 result.qualified(proposed)=s1>10&s2>10&snr>10;
 peak=sqrt(pooled(j+(0:numel(j)-1)*size(pooled,1)));
 result.peakPhaseAmplitudeRad(proposed)=peak./max(2*sin(pi*f(j).'/rate),eps);
end
result.ready=true;result.reason='Searching measured phase at every returned position';
rank=find(result.qualified);[~,order]=sort(result.snrDb(rank),'descend');rank=rank(order);chosen=[];
for k=rank
 if isempty(chosen)||all(abs(z(k)-z(chosen))>.20),chosen(end+1)=k;end %#ok<AGROW>
 if numel(chosen)>=12,break;end
end
rows=struct('index',{},'distanceKm',{},'frequencyHz',{},'snrDb',{},'half1SnrDb',{},'half2SnrDb',{},'validFraction',{},'amplitudeValidFraction',{},'peakPhaseAmplitudeRad',{});
for m=1:numel(chosen)
 k=chosen(m);rows(m)=struct('index',k,'distanceKm',z(k),'frequencyHz',result.peakHz(k),...
  'snrDb',result.snrDb(k),'half1SnrDb',result.half1SnrDb(k),'half2SnrDb',result.half2SnrDb(k),...
  'validFraction',result.validFraction(k),'amplitudeValidFraction',result.amplitudeValidFraction(k),...
  'peakPhaseAmplitudeRad',result.peakPhaseAmplitudeRad(k));
end
result.candidates=rows;
end

function [p,f,valid]=spectrum(t,x,nfft,fmin,fmax,minimumValid)
slot=round((t-t(1))*1000)+1;valid=mean(isfinite(x),1);p=[];f=[];
if max(abs((slot-1)/1000-(t-t(1))))>5e-5||numel(unique(slot))~=numel(slot)||max(slot)>nfft,return;end
freq=(0:nfft-1)'*1000/nfft;band=freq>=fmin&freq<=fmax;f=freq(band);p=zeros(sum(band),size(x,2));
columns=find(valid>=minimumValid);w=.5-.5*cos(2*pi*(t-t(1))/(t(end)-t(1)));
% Bounded temporary allocations avoid full-fiber complex FFT memory spikes.
for first=1:256:numel(columns)
 ix=columns(first:min(first+255,numel(columns)));v=double(x(:,ix));ok=isfinite(v);v(~ok)=0;
 mu=sum(v,1)./max(sum(ok,1),1);den=sum(ok.*w,1);grid=zeros(nfft,numel(ix));
 grid(slot,:)=(v-mu).*ok.*w;a=fft(grid,[],1);p(:,ix)=4*abs(a(band,:)).^2./max(den.^2,eps);
end
end
