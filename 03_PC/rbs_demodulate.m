function [envelope, differentialPhase, valid, zKm, iq] = rbs_demodulate(raw, cfg)
% Digital heterodyne downconversion. Using the original 80 MHz LO preserves
% phase orientation at arbitrary configured Fs; current capture uses 250 MSPS.
% cfg: sampleRate, beatHz, bandwidthHz (one-sided), gaugeMeters, displayBin.
persistent key lo mask nfft indexes left right z pulseFilter
matchedPulseNs=0;if isfield(cfg,'matchedPulseNs'),matchedPulseNs=cfg.matchedPulseNs;end
n=numel(raw);newkey=[n cfg.sampleRate cfg.beatHz cfg.bandwidthHz cfg.gaugeMeters cfg.displayBin matchedPulseNs];
if isempty(key)||~isequal(key,newkey)
 key=newkey;nfft=2^nextpow2(n+1024);lo=exp(-2i*pi*cfg.beatHz/cfg.sampleRate*(0:n-1)');
 f=(0:nfft-1)'*cfg.sampleRate/nfft;f=min(f,cfg.sampleRate-f);bw=cfg.bandwidthHz;
 mask=double(f<=.8*bw);taper=f>.8*bw & f<bw;mask(taper)=.5*(1+cos(pi*(f(taper)-.8*bw)/(.2*bw)));
 dx=299792458/(2*1.468*cfg.sampleRate);g=max(1,round(cfg.gaugeMeters/dx));;
 indexes=round((0:n/cfg.displayBin-1)*cfg.displayBin+(cfg.displayBin+1)/2);
 left=max(1,indexes-floor(g/2));right=min(n,left+g);z=(indexes-1)*dx/1000;
 if matchedPulseNs>0
  filterSamples=round(matchedPulseNs*cfg.sampleRate/1e9);assert(filterSamples>=1 && filterSamples<256);
  pulseFilter=ones(filterSamples,1)/filterSamples;
 end
end
raw=double(raw(:));mixed=(raw-mean(raw)).*lo;
if matchedPulseNs>0
 iq=2*conv(mixed,pulseFilter,'same');
else
 iq=2*ifft(fft(mixed,nfft).*mask);iq=iq(1:n);
end
envelope=mean(reshape(abs(iq),cfg.displayBin,[]),1);
cross=iq(right).*conj(iq(left));differentialPhase=angle(cross).';
% Do not assume the capture tail is dark for every fiber configuration.
% Use the explicit amplitude gate, or an independently checked dark interval.
% This gate is not a calibrated phase SNR estimate.
threshold=15;
if isfield(cfg,'minIqAmplitudeCounts'),threshold=cfg.minIqAmplitudeCounts;end
if isfield(cfg,'noiseRangeSamples') && ~isempty(cfg.noiseRangeSamples)
 noiseIndexes=cfg.noiseRangeSamples;
 assert(all(noiseIndexes>=1 & noiseIndexes<=n),'Invalid dark-sample interval');
 threshold=max(threshold,3*median(abs(iq(noiseIndexes))));
end
valid=(abs(iq(right))>threshold & abs(iq(left))>threshold).';
valid=valid & left>128 & right<n-128;
differentialPhase(~valid)=NaN;zKm=z;
end
