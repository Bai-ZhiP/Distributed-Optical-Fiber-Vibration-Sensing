function result = matlab_rbs_live(durationSeconds, dataDir)
% Real external-triggered AD1_B RBS data; compatible with MATLAB R2019a.
% 80 MHz heterodyne envelope and wrapped differential phase; no strain calibration.
if nargin<1, durationSeconds=Inf; end
if nargin<2, dataDir=fullfile(fileparts(mfilename('fullpath')),'rbs_live'); end
viewerCleanup=onCleanup(@() removeViewerHeartbeat(dataDir)); %#ok<NASGU>
initialStatus=jsondecode(fileread(fullfile(dataDir,'status.json')));
n=initialStatus.sampleCount;origin=0;if isfield(initialStatus,'firstSampleIndex'),origin=initialStatus.firstSampleIndex;end
fs=2.5e8; ng=1.468; bin=10;if mod(n,bin),bin=8;end;assert(mod(n,bin)==0);nx=n/bin;
z=(origin+(0:nx-1)*bin+(bin-1)/2)*299792458/(2*ng*fs*1000);
dt=.02; rows=250; histMap=nan(rows,nx,'single'); histVar=histMap;
binTimes=nan(rows,1); base=[]; lastSeq=0; lastTick=NaN; prevTrigger=NaN; rates=[];
pulseWidthNs=200;matchedSamples=round(pulseWidthNs*fs/1e9);
cfg=struct('sampleRate',fs,'beatHz',80e6,'bandwidthHz',fs/(2*matchedSamples),'matchedPulseNs',pulseWidthNs,'gaugeMeters',20,'displayBin',bin,'minIqAmplitudeCounts',6);
cfg.firstSampleIndex=origin;
seen=0; firstTick=NaN; lastStatus=[]; lastRaw=[]; lastEnv=[];
receiverStarted=NaN; traceRates=[]; lastFrameSeq=0;
lastValidFraction=0;
displayRangeKm=65;
ui=rbs_dashboard_layout();fig=ui.fig;
ax1=ui.left(1);trace=plot(ax1,z,nan(1,nx));xlim(ax1,[0 65]);grid(ax1,'on');ylabel(ax1,'Envelope (ADC counts)');
title(ax1,'Waiting for genuine FPGA data');
ax2=ui.left(2);im=imagesc(ax2,z,[-5 0],histMap);axis(ax2,'xy');xlim(ax2,[0 65]);colorbar(ax2);ylabel(ax2,'Time relative to latest trigger (s)');title(ax2,'RBS envelope space-time map | last 5 seconds');
ax3=ui.left(3);iv=imagesc(ax3,z,[-5 0],histVar);axis(ax3,'xy');xlim(ax3,[0 65]);colorbar(ax3);ylabel(ax3,'Time relative to latest trigger (s)');xlabel(ax3,'Distance (km); zero delay not calibrated');title(ax3,'Phase change | 20 m gauge | waiting for data');
set(im,'AlphaData',isfinite(histMap));set(iv,'AlphaData',isfinite(histVar));set([ax2 ax3],'Color',[.8 .8 .8]);
colormap(fig,parula(256)); started=tic;lastPlot=0;lastSave=0;
zoomMask=z>=20 & z<=22;zoomZ=z(zoomMask);
% Maps and PZT axes share one figure; no additional popup windows.
zoomFig=[];
rbs_pzt_live_panel('init',dataDir,cfg,fig,ui.right);pztCleanup=onCleanup(@() rbs_pzt_live_panel('close')); %#ok<NASGU>
set([ax1 ax2 ax3],'XLim',[max(20,z(1)) min(22,z(end))]);
for axisHandle=[ui.left ui.right],set(get(axisHandle,'Title'),'FontSize',10);end
while isgraphics(fig) && toc(started)<durationSeconds
 if exist(fullfile(dataDir,'VIEWER_STOP'),'file'),break;end
 try
  stat=jsondecode(fileread(fullfile(dataDir,'status.json')));
 catch
  pause(.1);drawnow;continue;
 end
 lastStatus=stat;
 if stat.sampleCount~=n || (isfield(stat,'firstSampleIndex') && stat.firstSampleIndex~=origin)
  title(ax1,sprintf('Frame format mismatch: viewer expects %d, receiver reports %d samples',n,stat.sampleCount));
  pause(.2);drawnow;continue;
 end
 if stat.startedUnix~=receiverStarted
  receiverStarted=stat.startedUnix;lastSeq=0;lastFrameSeq=0;
  firstTick=NaN;lastTick=NaN;prevTrigger=NaN;rates=[];traceRates=[];
  base=[];seen=0;lastRaw=[];lastEnv=[];histMap(:)=NaN;histVar(:)=NaN;binTimes(:)=NaN;
  rbs_pzt_live_panel('reset');
  set(trace,'YData',nan(1,nx));set(im,'CData',histMap);set(iv,'CData',histVar);
  if isgraphics(zoomFig),set(zoomEnvelope,'CData',histMap(:,zoomMask),'AlphaData',zeros(rows,sum(zoomMask)));set(zoomPhase,'CData',histVar(:,zoomMask),'AlphaData',zeros(rows,sum(zoomMask)));end
 end
 if stat.complete>lastSeq
  file=fopen(fullfile(dataDir,'frames.ring'),'rb','ieee-le');
  if file<0,pause(.1);continue;end
  guard=onCleanup(@() fclose(file));
  for seq=max(lastSeq+1,stat.complete-stat.slots+1):stat.complete
   fseek(file,mod(seq-1,stat.slots)*stat.recordBytes,'bof');
   s1=fread(file,1,'uint64=>double'); h=fread(file,12,'uint32=>double');raw=fread(file,n,'int16=>double');s2=fread(file,1,'uint64=>double');
   if isempty(s1)||isempty(s2)||s1~=seq||s2~=seq||numel(raw)~=n||numel(h)~=12||h(1)~=hex2dec('32534252')||h(7)~=n||h(5)~=fs,continue;end
   if any(raw< -2048 | raw>2047),warning('RBS:InvalidADC','Out-of-range ADC codes');continue;end
   tick=h(9)+h(10)*2^32;
   if ~isnan(lastTick)&&tick<=lastTick,continue;end
   if isnan(firstTick),firstTick=tick;end
   if ~isnan(lastTick)
    rates(end+1)=(h(2)-prevTrigger)*fs/(tick-lastTick);rates=rates(max(1,end-99):end); %#ok<AGROW>
    traceRates(end+1)=(seq-lastFrameSeq)*fs/(tick-lastTick);traceRates=traceRates(max(1,end-99):end); %#ok<AGROW>
   end
   lastTick=tick;prevTrigger=h(2);lastFrameSeq=seq;seen=seen+1;
   rbs_pzt_live_panel('sample',raw,tick);
   % Only the last complete trace in a 20 ms display bin is needed for FFT.
   % Receive/store every trace in Python; avoid spending MATLAB CPU on rows
   % that would immediately be overwritten in the space-time display.
   if seq<stat.complete
    fseek(file,mod(seq,stat.slots)*stat.recordBytes,'bof');
    nextSeq=fread(file,1,'uint64=>double');nextHeader=fread(file,12,'uint32=>double');
    if ~isempty(nextSeq)&&nextSeq==seq+1&&numel(nextHeader)==12&&nextHeader(1)==hex2dec('32534252')
     nextTick=nextHeader(9)+nextHeader(10)*2^32;
     if floor((nextTick-firstTick)/fs/dt)==floor((tick-firstTick)/fs/dt),continue;end
    end
   end
   [profile,phase,valid]=rbs_demodulate(raw,cfg);
   lastValidFraction=mean(valid);
   if isempty(base),base=nan(size(phase));end
   new=valid & isnan(base);base(new)=phase(new);
   variation=angle(exp(1i*(phase-base)));variation(~valid)=NaN;
   t=(tick-firstTick)/fs; b=floor(t/dt);slot=mod(b,rows)+1;
   histMap(slot,:)=single(profile);histVar(slot,:)=single(variation);binTimes(slot)=b;
   lastRaw=raw;lastEnv=profile;
  end
  clear guard; lastSeq=stat.complete;
 end
 if toc(started)-lastPlot>.2
  if seen>0 && ~isempty(lastEnv)
   b=floor((lastTick-firstTick)/fs/dt);wanted=b-rows+1:b;order=mod(wanted,rows)+1;
   a=histMap(order,:);v=histVar(order,:);missing=binTimes(order)~=wanted';a(missing,:)=NaN;v(missing,:)=NaN;
   set(trace,'YData',lastEnv);set(im,'CData',a,'AlphaData',~isnan(a));set(iv,'CData',v,'AlphaData',~isnan(v));
   % Keep the useful echo visible after a fiber-length change; capture stays full length.
   echoMask=movmean(double(lastEnv>max(15,.005*max(lastEnv))),9)>.8;
   lastEcho=find(echoMask,1,'last');
   if ~isempty(lastEcho)
    newRange=min(65,max(25,5*ceil((z(lastEcho)+1)/5)));
    if newRange~=displayRangeKm
     displayRangeKm=newRange;xlim(ax1,[0 newRange]);xlim(ax2,[0 newRange]);xlim(ax3,[0 newRange]);
    end
   end
   if origin>0,set([ax1 ax2 ax3],'XLim',[max(20,z(1)) min(22,z(end))]);end
   set(ax2,'Color',[.8 .8 .8]);set(ax3,'Color',[.8 .8 .8]);
   scale=sort(lastEnv);top=scale(max(1,round(.99*numel(scale))));caxis(ax2,[0 max(1,top)]);
   phaseScale=abs(v(1:5:end,1:4:end));phaseScale=sort(phaseScale(isfinite(phaseScale)));
   phaseLimit=pi;
   if ~isempty(phaseScale),phaseLimit=max(.05,min(pi,phaseScale(max(1,round(.99*numel(phaseScale))))));end
   caxis(ax3,[-phaseLimit phaseLimit]);
   prf=NaN;if ~isempty(rates),prf=median(rates);end
   receivedHz=NaN;if ~isempty(traceRates),receivedHz=median(traceRates);end
   title(ax1,'RBS envelope | 80 MHz heterodyne');
   set(ui.status,'String',sprintf('LIVE  |  %.1f traces/s  |  TRIG %.1f Hz  |  Pulse %.0f ns  |  Last trigger %u  |  Total %u traces',receivedHz,prf,pulseWidthNs,stat.lastTrigger,stat.complete));
   if isfield(stat,'acceptedFrameGapCount') && stat.acceptedFrameGapCount>0
    title(ax1,sprintf('AD1_B | trigger %.2f Hz | received %.1f traces/s | RX whole-frame gap indications: %d',prf,receivedHz,stat.acceptedFrameGapCount));
   end
   if lastValidFraction==0
    title(ax3,'NO USABLE RBS SIGNAL: all differential phase points below amplitude threshold');
   else
    title(ax3,sprintf('Phase change | %.0f m gauge | usable %.1f%%',cfg.gaugeMeters,100*lastValidFraction));
   end
   age=posixtime(datetime('now','TimeZone','UTC'))-stat.lastFrameUnix;
   if age>2,set(ui.status,'String',sprintf('NO NEW DATA for %.1f s | check FPGA power, ETH1 and TRIG | last trigger %u',age,stat.lastTrigger));end
   if isgraphics(zoomFig)
    za=a(:,zoomMask);zv=v(:,zoomMask);
    set(zoomEnvelope,'CData',za,'AlphaData',isfinite(za));set(zoomPhase,'CData',zv,'AlphaData',isfinite(zv));
    ze=sort(za(isfinite(za)));if ~isempty(ze),caxis(zoomAx1,[0 max(1,ze(max(1,round(.99*numel(ze)))))]);end
    zp=sort(abs(zv(isfinite(zv))));zl=pi;if ~isempty(zp),zl=max(.05,min(pi,zp(max(1,round(.99*numel(zp))))));end
    caxis(zoomAx2,[-zl zl]);
    title(zoomAx1,sprintf('20-22 km RBS envelope (ADC counts) | pulse %.0f ns | trigger %u | %.1f traces/s',pulseWidthNs,stat.lastTrigger,receivedHz));
    title(zoomAx2,sprintf('Wrapped phase change (rad), %.0f m gauge | same live data as overview',cfg.gaugeMeters));
    if age>2,title(zoomAx1,sprintf('NO NEW DATA for %.1f s | 20-22 km | last trigger %u',age,stat.lastTrigger));end
   end
  else
   title(ax1,'RBS envelope | waiting for data');
   set(ui.status,'String',sprintf('WAITING FOR FPGA  |  UDP packets %d  |  Check FPGA power, ETH1 and TRIG',stat.datagrams));
  end
  if isfield(stat,'displayMode'),set(ui.status,'String',stat.displayMode);end
  rbs_pzt_live_panel('draw',stat);drawnow;lastPlot=toc(started);
  heartbeat=fopen(fullfile(dataDir,'viewer.heartbeat'),'w');
  if heartbeat>=0,fprintf(heartbeat,'%.3f',posixtime(datetime('now','TimeZone','UTC')));fclose(heartbeat);end
  if seen>0 && ~isempty(lastEnv) && toc(started)-lastSave>15
   saveas(fig,fullfile(dataDir,'matlab_rbs_display.png'));
   saveas(fig,fullfile(dataDir,'DAS_dashboard.png'));
   if isgraphics(zoomFig),saveas(zoomFig,fullfile(dataDir,'matlab_rbs_zoom20_22.png'));end
   lastSave=toc(started);
  end
 end
 pause(.03);
end
result=struct('received',seen,'lastStatus',lastStatus,'lastRaw',lastRaw,'lastEnvelope',lastEnv,'distanceKm',z,'envelopeMap',histMap,'wrappedDifferentialPhaseMap',histVar,'timeBins',binTimes,'timeBinSeconds',dt,'firstTick',firstTick,'lastTick',lastTick,'measuredPrf',rates,'fiberIndex',ng,'distanceZeroCalibrated',false,'phaseProcessingEnabled',true,'lastValidPhaseFraction',lastValidFraction,'demodulationConfig',cfg);
save(fullfile(dataDir,'matlab_rbs_last.mat'),'result','-v7.3');
if isgraphics(fig),saveas(fig,fullfile(dataDir,'matlab_rbs_display.png'));
   saveas(fig,fullfile(dataDir,'DAS_dashboard.png'));end
if isgraphics(zoomFig),saveas(zoomFig,fullfile(dataDir,'matlab_rbs_zoom20_22.png'));end
if isgraphics(fig),close(fig);end
end

function closeZoom(fig)
if isgraphics(fig),close(fig);end
end

function removeViewerHeartbeat(dataDir)
path=fullfile(dataDir,'viewer.heartbeat');
if exist(path,'file'),delete(path);end
end
