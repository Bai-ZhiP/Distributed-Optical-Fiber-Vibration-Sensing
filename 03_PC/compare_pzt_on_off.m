function summary=compare_pzt_on_off(offDir,onDir,outDir,driveVpp,searchRangeKm)
% Controlled comparison at genuine hardware timestamps. Candidates are not detections.
if nargin<4,driveVpp=.1;end
if nargin<5,searchRangeKm=[49 51.5];end
if ~exist(outDir,'dir'),mkdir(outDir);end
a=load(fullfile(offDir,'pzt_analysis.mat'),'result');off=a.result;
a=load(fullfile(onDir,'pzt_analysis.mat'),'result');on=a.result;clear a;
assert(isequal(off.distanceKm,on.distanceKm) && isequal(off.gaugeMeters,on.gaugeMeters));
assert(off.summary.lowpassBandwidthHz==on.summary.lowpassBandwidthHz);
if isfield(off.summary,'filterOptions') || isfield(on.summary,'filterOptions')
 assert(isfield(off.summary,'filterOptions') && isfield(on.summary,'filterOptions') && isequal(off.summary.filterOptions,on.summary.filterOptions),'Filter options differ');
end
if isfield(off.metadata,'userReportedPulseWidthNs') && isfield(on.metadata,'userReportedPulseWidthNs')
 assert(isequal(off.metadata.userReportedPulseWidthNs,on.metadata.userReportedPulseWidthNs),'Pulse width differs');
end
assert(off.metadata.userConfirmedDriveHz==0 && on.metadata.userConfirmedDriveHz==20);
z=on.distanceKm;gauges=on.gaugeMeters;
maxFrequency=min(60,.45/max(median(diff(off.timeSeconds)),median(diff(on.timeSeconds))));
freq=(.5:.05:maxFrequency)';near=[17.7 18.3 18.9 20.9 21.5 22.1];
assert(maxFrequency>max(near),'Trace rate is insufficient for the requested comparison');
records={off,on};target=nan(2,numel(gauges),numel(z));floorAmp=target;coverage=target;
segments=nan(2,4,numel(gauges),numel(z));phasors=cell(2,numel(gauges));validity=phasors;
for state=1:2
 r=records{state};t=r.timeSeconds(:);nf=numel(t);win=.5-.5*cos(2*pi*(0:nf-1)'/(nf-1));
 for g=1:numel(gauges)
  p=double(r.phase(:,:,g));ok=isfinite(p);q=exp(1i*p);q(~ok)=0;
  phasors{state,g}=q;validity{state,g}=ok;
  target(state,g,:)=line_amplitude(q,ok,t,win,20);
  noise=line_amplitude(q,ok,t,win,near);
  floorAmp(state,g,:)=sqrt(mean(noise.^2,1));coverage(state,g,:)=mean(ok,1);
  for block=1:4
   ix=(1:nf)'>floor((block-1)*nf/4) & (1:nf)'<=floor(block*nf/4);
   nb=sum(ix);wb=.5-.5*cos(2*pi*(0:nb-1)'/(nb-1));
   segments(state,block,g,:)=line_amplitude(q(ix,:),ok(ix,:),t(ix),wb,20);
  end
 end
end
offAmp=squeeze(target(1,:,:));onAmp=squeeze(target(2,:,:));
offNoise=squeeze(floorAmp(1,:,:));onNoise=squeeze(floorAmp(2,:,:));
usable=squeeze(min(coverage,[],1))>=.9;
onOffDb=20*log10(max(onAmp,eps)./max(offAmp,eps));
contrast=20*log10(max(onAmp,eps)./max(onNoise,eps));
% Conservative screening: larger of OFF target and ON neighboring-frequency background.
score=20*log10(max(onAmp,eps)./max(max(offAmp,onNoise),eps));
region=z>=searchRangeKm(1) & z<=searchRangeKm(2);
score(~usable)=NaN;score(:,~region)=NaN;
sc=score;sc(~isfinite(sc))=-Inf;[best,ix]=max(sc(:));assert(isfinite(best));
[bg,bz]=ind2sub(size(sc),ix);
spectra=zeros(numel(freq),2);halfPeak=zeros(2,2);
for state=1:2
 t=records{state}.timeSeconds(:);nf=numel(t);w=.5-.5*cos(2*pi*(0:nf-1)'/(nf-1));
 q=phasors{state,bg}(:,bz);ok=validity{state,bg}(:,bz);
 spectra(:,state)=line_amplitude(q,ok,t,w,freq);
 for half=1:2
  sel=(1:nf)'<=floor(nf/2);if half==2,sel=~sel;end
  nh=sum(sel);wh=.5-.5*cos(2*pi*(0:nh-1)'/(nh-1));fh=(18:.05:22)';
  h=line_amplitude(q(sel),ok(sel),t(sel),wh,fh);[~,pk]=max(h);halfPeak(state,half)=fh(pk);
 end
end
[~,peak]=max(spectra);fullPeaks=freq(peak);
synthetic=isfield(on.metadata,'syntheticTest') && on.metadata.syntheticTest;
summary=struct('targetHz',20,'spectrumUpperHz',maxFrequency,'searchRangeKm',searchRangeKm,'userDriveAmplitudeVolts',driveVpp,'voltageConvention','User reported Vpp; not instrument verified',...
 'syntheticAlgorithmTest',synthetic,'triggerAndLaserSameSourceUserConfirmed',~synthetic,'framesOff',off.summary.frames,'framesOn',on.summary.frames,...
 'candidateLocationKm',z(bz),'candidateGaugeMeters',gauges(bg),'candidateOnVsOffDb',onOffDb(bg,bz),...
 'candidateOnVsNearbyFrequencyDb',contrast(bg,bz),'candidateScreeningScoreDb',best,...
 'candidateTargetAmplitudeOffOn',squeeze(target(:,bg,bz)),'candidateFourBlockAmplitudeOffOn',squeeze(segments(:,:,bg,bz)),...
 'candidateWholeRecordPeakHzOffOn',fullPeaks,'candidateHalfRecordPeakHzOffOn',halfPeak,...
 'searchRegionMedian20HzAmplitudeOffOn',[median(offAmp(usable & repmat(region,numel(gauges),1))) median(onAmp(usable & repmat(region,numel(gauges),1)))],...
 'controlledSwitchingUserConfirmed',~synthetic,'detectionAutomaticallyDeclared',false,'distanceZeroCalibrated',false,...
 'method','Symmetric +/- frequency projection of centered unit differential phasor at actual timestamps; amplitude is chord modulation, approximately radians only for small phase',...
 'interpretation','Location is selected by searching many points and is not a validated PZT location. Review OFF/ON spectra, split-record stability, spatial localization and repeated switching.');
disp(summary);fid=fopen(fullfile(outDir,'comparison_summary.json'),'w');fprintf(fid,'%s',jsonencode(summary));fclose(fid);
save(fullfile(outDir,'comparison.mat'),'summary','target','floorAmp','coverage','segments','z','gauges','freq','spectra','score','onOffDb','contrast','-v7.3');
fig=figure('Visible','off','Color','w','Position',[50 50 1400 900]);
subplot(2,2,1);hold on;labels={};for gg=1:numel(gauges),plot(z,offAmp(gg,:),'--');plot(z,onAmp(gg,:));labels=[labels {sprintf('OFF, %.0f m',gauges(gg)),sprintf('ON, %.0f m',gauges(gg))}];end;grid on;xlim([z(1) z(end)]);xlabel('Distance (km), zero uncalibrated');ylabel('20 Hz phasor modulation');legend(labels);title(sprintf('Controlled PZT OFF / 20 Hz, %.3g Vpp ON',driveVpp));
subplot(2,2,2);plot(z,score);grid on;xlim(searchRangeKm);xlabel('Distance (km)');ylabel('ON / max(OFF target, ON local noise), dB');legend(arrayfun(@(g) sprintf('%.0f m gauge',g),gauges,'UniformOutput',false));title('Spatial search; maxima require validation');
subplot(2,2,3);plot(freq,20*log10(max(spectra,1e-6)));grid on;xlim([0 maxFrequency]);xlabel('Frequency (Hz)');ylabel('Phasor modulation (dB)');legend('PZT OFF','PZT ON');xline(20,'--k','HandleVisibility','off');title(sprintf('Candidate %.3f km, %.0f m gauge; not a detection',z(bz),gauges(bg)));
subplot(2,2,4);plot(1:4,squeeze(segments(:,:,bg,bz)).','-o');grid on;xticks(1:4);xlabel('Consecutive quarter-record blocks');ylabel('20 Hz phasor modulation');legend('PZT OFF','PZT ON');title('Repeatability within each recording');
saveas(fig,fullfile(outDir,'pzt_on_off_comparison.png'));close(fig);
fprintf('PZT_ON_OFF_COMPARISON_COMPLETE\n');
end

function amplitude=line_amplitude(q,ok,t,window,frequencies)
w=double(ok).*window;den=max(sum(w,1),eps);center=sum(q.*w,1)./den;
y=(q-center).*w;f=frequencies(:);positive=exp(-2i*pi*f*t.')*y;negative=exp(2i*pi*f*t.')*y;
amplitude=sqrt(2*(abs(positive).^2+abs(negative).^2))./den;
end
