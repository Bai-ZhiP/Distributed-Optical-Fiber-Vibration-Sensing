function echo = rbs_echo_snr(meanPower,z,noiseRangeKm)
% Electrical IQ return SNR. The specified tail must be beyond the fiber end.
% Average power over actual received traces BEFORE subtracting noise power.
if nargin<3,noiseRangeKm=[31.5 32.5];end
meanPower=double(meanPower(:).');z=double(z(:).');
assert(numel(meanPower)==numel(z));
ref=z>=noiseRangeKm(1)&z<=noiseRangeKm(2)&isfinite(meanPower)&meanPower>=0;
echo=struct('ready',false,'distanceKm',z,'snrDb',nan(size(z)),...
 'meanPowerAdcCountsSquared',meanPower,'noisePowerAdcCountsSquared',NaN,...
 'noiseReferenceRangeKm',noiseRangeKm,'noiseReferenceBins',sum(ref),...
 'noiseReferenceAssumedPostFiber',true,'calibratedOpticalSnr',false,...
 'above10Db',false(size(z)),'definition',...
 '10log10((time-mean abs(IQ)^2 - mean post-fiber noise power)/noise power); nonpositive excess is unresolved (NaN)');
if sum(ref)<20,return;end
noise=mean(meanPower(ref));if ~isfinite(noise)||noise<=0,return;end
excess=meanPower/noise-1;ok=excess>0&isfinite(excess);
echo.snrDb(ok)=10*log10(excess(ok));echo.noisePowerAdcCountsSquared=noise;
echo.above10Db=echo.snrDb>10;echo.ready=true;
end
