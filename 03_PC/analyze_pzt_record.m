function result=analyze_pzt_record(recordDir,targetHz,bandwidthHz,outputDir,searchRangeKm,minIqCounts,options)
% Timestamp-aware analysis of genuine 250 MS/s ROI recordings.
% Estimates wrapped differential phase; it does not calibrate strain.
if nargin<2,targetHz=20;end
if nargin<3,bandwidthHz=35e6;end
if nargin<4,outputDir=recordDir;end
if nargin<5,searchRangeKm=[49 51.5];end
if nargin<6,minIqCounts=15;end
if nargin<7,options=struct;end
if ~isfield(options,'spatialStepSamples'),options.spatialStepSamples=20;end
if ~isfield(options,'matchedPulseNs'),options.matchedPulseNs=0;end
if ~isfield(options,'gaugeMeters'),options.gaugeMeters=[10 100];end
if ~exist(outputDir,'dir'),mkdir(outputDir);end
meta=jsondecode(fileread(fullfile(recordDir,'metadata.json')));
fs=meta.sampleRateHz;n=meta.samplesPerTrace;nf=meta.frames;
fid=fopen(fullfile(recordDir,'ticks.uint64'),'rb','ieee-le');ticks=fread(fid,Inf,'uint64=>double');fclose(fid);
t=(ticks-ticks(1))/fs;nf=min(nf,numel(t));t=t(1:nf);
dx=299792458/(2*meta.groupIndex*fs);centers=301:options.spatialStepSamples:n-300;
z=(meta.firstSampleIndex+centers-1)*dx/1000;gauges=options.gaugeMeters;
gaugeLabels=arrayfun(@(g) sprintf('%.0f m gauge',g),gauges,'UniformOutput',false);
nfft=2^nextpow2(n+1024);lo=exp(-2i*pi*80e6/fs*(0:n-1)');
f=(0:nfft-1)'*fs/nfft;f=min(f,fs-f);bw=bandwidthHz;
mask=double(f<=.8*bw);tap=f>.8*bw & f<bw;mask(tap)=.5*(1+cos(pi*(f(tap)-.8*bw)/(.2*bw)));
filterDescription=sprintf('Raised-cosine lowpass, cutoff %.3g Hz',bandwidthHz);
filterSamples=0;effectiveFilterSpanNs=0;
if options.matchedPulseNs>0
 filterSamples=round(options.matchedPulseNs*fs/1e9);
 assert(filterSamples>=1 && filterSamples<600);
 pulseFilter=ones(filterSamples,1)/filterSamples;
 effectiveFilterSpanNs=filterSamples/fs*1e9;
 bandwidthHz=fs/(2*filterSamples);
 filterDescription=sprintf('Centered average: %d samples (%.0f ns); reported pulse %.0f ns',filterSamples,effectiveFilterSpanNs,options.matchedPulseNs);
end
phase=nan(nf,numel(z),numel(gauges),'single');amp=phase;
fid=fopen(fullfile(recordDir,'samples.int16'),'rb','ieee-le');guard=onCleanup(@() fclose(fid));
for k=1:nf
 raw=fread(fid,n,'int16=>double');assert(numel(raw)==n,'Truncated ROI record');
 mixed=(raw-mean(raw)).*lo;
 if options.matchedPulseNs>0
  iq=2*conv(mixed,pulseFilter,'same');
 else
  iq=2*ifft(fft(mixed,nfft).*mask);iq=iq(1:n);
 end
 for g=1:numel(gauges)
  gs=round(gauges(g)/dx);left=centers-floor(gs/2);right=left+gs;
  cross=iq(right).*conj(iq(left));am=min(abs(iq(right)),abs(iq(left)));
  p=angle(cross);p(am<minIqCounts)=NaN;
  phase(k,:,g)=single(p);amp(k,:,g)=single(am);
 end
end
clear guard;
traceKind='genuine';if isfield(meta,'syntheticTest') && meta.syntheticTest,traceKind='synthetic test';end
fprintf('DEMODULATED %d %s traces, %.3f s\n',nf,traceKind,t(end));
win=.5-.5*cos(2*pi*(0:nf-1)'/(nf-1));
noiseFreq=targetHz+[-2.3 -1.7 -1.1 .9 1.5 2.1];
freq=(.5:.05:min(60,.45/median(diff(t))))';
targetAmp=nan(numel(gauges),numel(z));snrDb=targetAmp;coverage=targetAmp;
ys=cell(size(gauges));weights=ys;halves=nan(2,numel(gauges),numel(z));
for g=1:numel(gauges)
 p=double(phase(:,:,g));ok=isfinite(p);q=exp(1i*p);q(~ok)=0;
 center=angle(sum(q,1));y=angle(exp(1i*(p-center)));y(~ok)=0;
 w=double(ok).*win;den=sum(w,1);avg=sum(w.*y,1)./max(den,eps);
 y=y-avg;y(~ok)=0;wy=y.*w;ys{g}=y;weights{g}=w;
 targetAmp(g,:)=2*abs(exp(-2i*pi*targetHz*t.')*wy)./max(den,eps);
 noise=2*abs(exp(-2i*pi*noiseFreq(:)*t.')*wy)./max(den,eps);
 snrDb(g,:)=20*log10(max(targetAmp(g,:),eps)./max(sqrt(mean(noise.^2,1)),eps));
 coverage(g,:)=mean(ok,1);
 targetAmp(g,coverage(g,:)<.9)=NaN;snrDb(g,coverage(g,:)<.9)=NaN;
 for half=1:2
  sel=(1:nf)'<=floor(nf/2);if half==2,sel=~sel;end
  halves(half,g,:)=2*abs(exp(-2i*pi*targetHz*t(sel).')*wy(sel,:))./max(sum(w(sel,:),1),eps);
 end
end
% Search the terminal region with an explicit tolerance for uncalibrated zero.
terminal=z>=searchRangeKm(1) & z<=searchRangeKm(2);score=snrDb;score(:,~terminal)=NaN;
sc=score;sc(~isfinite(sc))=-Inf;[bestScore,bestLinear]=max(sc(:));
[bestG,bestZ]=ind2sub(size(score),bestLinear);
assert(isfinite(bestScore),'No terminal point has sufficient valid samples');
referenceCandidates=find(z>=43 & z<=45 & coverage(bestG,:)>.95);
if isempty(referenceCandidates),referenceCandidates=find(~terminal & coverage(bestG,:)>.9);end
assert(~isempty(referenceCandidates),'No usable reference interval');
referenceAmp=targetAmp(bestG,referenceCandidates);referenceAmp(~isfinite(referenceAmp))=Inf;
[~,refOrder]=sort(referenceAmp);refIndex=referenceCandidates(refOrder(max(1,round(numel(refOrder)/2))));
signal=ys{bestG}(:,bestZ);reference=ys{bestG}(:,refIndex);
selectedW=weights{bestG}(:,[bestZ refIndex]);selectedY=[signal reference];
spectrum=2*abs(exp(-2i*pi*freq*t.')*(selectedY.*selectedW))./max(sum(selectedW,1),eps);
[~,peakIndex]=max(spectrum(:,1));peakHz=freq(peakIndex);
halfPeaks=zeros(2,1);
for half=1:2
 sel=(1:nf)'<=floor(nf/2);if half==2,sel=~sel;end
 fNear=(max(.5,targetHz-2):.05:targetHz+2)';
 spec=abs(exp(-2i*pi*fNear*t(sel).')*(signal(sel).*selectedW(sel,1)));
 [~,hi]=max(spec);halfPeaks(half)=fNear(hi);
end
summary=struct('targetHz',targetHz,'lowpassBandwidthHz',bandwidthHz,'filterDescription',filterDescription,'filterOptions',options,'spatialSampleSpacingMeters',options.spatialStepSamples*dx,'minimumIqCounts',minIqCounts,'searchRangeKm',searchRangeKm,'candidateSelectionIsDetection',false,'frames',nf,'seconds',t(end),'medianTraceRateHz',1/median(diff(t)),...
 'bestLocationKm',z(bestZ),'gaugeMeters',gauges(bestG),'bestSpectrumPeakHz',peakHz,...
 'targetPhaseAmplitudeRadians',targetAmp(bestG,bestZ),'targetVsNearbyFrequencyDb',bestScore,...
 'referenceLocationKm',z(refIndex),'referenceTargetAmplitudeRadians',targetAmp(bestG,refIndex),...
 'validFraction',coverage(bestG,bestZ),'halfRecordPeakHz',halfPeaks,'distanceZeroCalibrated',false,...
 'stimulusIsolationVerified',false,'method','Hann-weighted projection at actual timestamps; wrapped phase, no strain calibration');
summary.matchedFilterSamples=filterSamples;summary.effectiveMatchedFilterSpanNs=effectiveFilterSpanNs;
disp(summary);
result=struct('summary',summary,'metadata',meta,'timeSeconds',t,'distanceKm',z,'gaugeMeters',gauges,...
 'targetAmplitudeRadians',targetAmp,'targetContrastDb',snrDb,'validFraction',coverage,...
 'phase',phase,'minimumIqAmplitudeCounts',amp,'frequencyHz',freq,'selectedSpectra',spectrum,...
 'selectedPhase',selectedY,'selectedValidity',selectedW>0,'halfTargetAmplitude',halves);
save(fullfile(outputDir,'pzt_analysis.mat'),'result','-v7.3');
fid=fopen(fullfile(outputDir,'pzt_summary.json'),'w');fprintf(fid,'%s',jsonencode(summary));fclose(fid);
fig=figure('Color','w','Position',[70 50 1350 900],'Visible','off');
subplot(2,2,1);plot(z,targetAmp,'LineWidth',1);grid on;xlim([z(1) z(end)]);xlabel('Distance (km), zero uncalibrated');ylabel(sprintf('%.1f Hz phase component (rad)',targetHz));legend(gaugeLabels);title(filterDescription);
subplot(2,2,2);plot(z,snrDb,'LineWidth',1);grid on;xlim([z(1) z(end)]);xlabel('Distance (km)');ylabel('Target / nearby frequency RMS (dB)');title('Frequency contrast; low-coverage points excluded');
subplot(2,2,3);show=t<=2;signalPlot=signal;signalPlot(selectedW(:,1)==0)=NaN;plot(t(show),signalPlot(show));grid on;xlabel('Hardware time (s)');ylabel('Wrapped differential phase (rad)');title(sprintf('Candidate %.3f km, gauge %.0f m',z(bestZ),gauges(bestG)));
subplot(2,2,4);plot(freq,20*log10(max(spectrum,1e-6)));grid on;xlim([0 60]);xlabel('Frequency (Hz)');ylabel('Phase component (dB re 1 rad)');legend(sprintf('Candidate %.3f km',z(bestZ)),sprintf('Reference %.3f km',z(refIndex)));title(sprintf('Actual-timestamp spectrum; peak %.2f Hz',peakHz));xline(targetHz,'--k','HandleVisibility','off');
saveas(fig,fullfile(outputDir,'pzt_analysis.png'));close(fig);
fprintf('PZT_ANALYSIS_COMPLETE %s\n',outputDir);
end
