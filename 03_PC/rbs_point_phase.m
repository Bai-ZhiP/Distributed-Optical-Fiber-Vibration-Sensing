function [phase,amplitude,actualKm]=rbs_point_phase(raw,cfg,locationKm)
% Small exact slice of the same rectangular-average DDC as rbs_demodulate.
persistent key indexes lo left right kernel center dx
origin=0;if isfield(cfg,'firstSampleIndex'),origin=cfg.firstSampleIndex;end
n=numel(raw);newKey=[n cfg.sampleRate cfg.beatHz cfg.matchedPulseNs cfg.gaugeMeters locationKm origin];
if isempty(key)||~isequal(key,newKey)
 key=newKey;dx=299792458/(2*1.468*cfg.sampleRate);center=round(locationKm*1000/dx)+1-origin;
 span=round(cfg.matchedPulseNs*cfg.sampleRate/1e9);g=round(cfg.gaugeMeters/dx);
 a=center-floor(g/2);b=a+g;start=a-span-2;finish=b+span+2;
 assert(start>=1 && finish<=n && span>=1,'Selected point outside captured samples');
 indexes=(start:finish)';lo=exp(-2i*pi*cfg.beatHz/cfg.sampleRate*(origin+indexes-1));
 left=a-start+1;right=b-start+1;kernel=ones(span,1)/span;
end
x=double(raw(indexes))-mean(double(raw));x=x(:);iq=2*conv(x.*lo,kernel,'same');
amplitude=min(abs(iq(left)),abs(iq(right)));phase=angle(iq(right)*conj(iq(left)));actualKm=(origin+center-1)*dx/1000;
if amplitude<cfg.minIqAmplitudeCounts,phase=NaN;end
end
