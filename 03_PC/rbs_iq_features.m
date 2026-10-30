function [amp,inc,z,quality,diagnosticInc] = rbs_iq_features(iq,tick,reset)
persistent state
if reset,state=[];end
[power,inc,diagnosticInc,state,z]=rbs_iq_batch(iq(:),tick,state);
amp=sqrt(double(power(:))).';inc=inc(:).';diagnosticInc=diagnosticInc(:).';
quality=single(isfinite(inc));
end
