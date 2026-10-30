function rbs_fast_iq_live(durationSeconds,dataDir)
% Fast selected-position path. Full-fiber FFT runs in another process.
if nargin<1,durationSeconds=Inf;end
try,maxNumCompThreads(2);catch,end
ui=rbs_dashboard_layout();fig=ui.fig;guard=onCleanup(@() finish(dataDir,fig)); %#ok<NASGU>
set(fig,'Name','DAS Auto | space-time, vibration locations, waveform and FFT');
set(ui.heading,'String','DAS | Continuous recorded waveform and FFT search');
set(ui.footer,'String','Both FFT halves >10 dB | strongest confirmed point | continuous measured AC phase');
autoButton=annotation(fig,'textbox',[.655 .949 .10 .033],'String','AUTO TRACK','FontSize',10,...
 'HorizontalAlignment','center','EdgeColor',[.2 .45 .7],'BackgroundColor',[.83 .93 1],'ButtonDownFcn',@(s,e) resumeAutomatic(fig));
inspectButton=annotation(fig,'textbox',[.765 .949 .085 .033],'String','INSPECT','FontSize',10,...
 'HorizontalAlignment','center','EdgeColor',[.5 .6 .7],'ButtonDownFcn',@(s,e) enableInspection(fig));
ax=ui.left;ar=ui.right;zPower=((0:3199)*25+12)*299792458/(2*1.468*250e6*1000);zSearch=((10:1:3189)*25+12)*299792458/(2*1.468*250e6*1000);
echoLine=plot(ax(1),zPower,nan(size(zPower)),':','Color',[.75 .49 .17]);hold(ax(1),'on');
snrLine=plot(ax(1),zSearch,nan(size(zSearch)),'Color',[.08 .34 .78],'LineWidth',1.1,'Marker','.','MarkerSize',3);
yline(ax(1),10,'--r','FFT gate 10 dB');marker=plot(ax(1),NaN,NaN,'ro','MarkerFaceColor','r');hold(ax(1),'off');
for clickable={ax(1),snrLine,echoLine,marker},set(clickable{1},'ButtonDownFcn',@(s,e) selectDistance(fig,ax(1)));end
legend(ax(1),[snrLine echoLine],{'FFT peak SNR','Echo reference'},'FontSize',8,'Location','northeast');ylabel(ax(1),'SNR (dB)');grid(ax(1),'on');ylim(ax(1),[-12 50]);title(ax(1),'Waiting for independent full-fiber search');
noiseNote=annotation(fig,'textbox',[.055 .655 .50 .027],'EdgeColor','none','FontSize',9,'String','Tail noise reference: 31.5-32.5 km','Color',[.35 .4 .48]);
im=imagesc(ax(2),zPower,[-5 0],nan(250,3200));axis(ax(2),'xy');set(im,'AlphaData',zeros(250,3200));set(ax(2),'Color',[.82 .84 .86]);colorbar(ax(2));caxis(ax(2),[-5 40]);ylabel(ax(2),'Time (s)');
pm=imagesc(ax(3),zSearch,[-5 0],nan(250,numel(zSearch)));axis(ax(3),'xy');set(pm,'AlphaData',zeros(250,numel(zSearch)));set(ax(3),'Color',[.82 .84 .86]);colorbar(ax(3));caxis(ax(3),[-pi pi]);
title(ax(3),'Measured phase increments | 20 ms map rows');ylabel(ax(3),'Time (s)');xlabel(ax(3),'Distance (km)');set(ax,'XLim',[0 zPower(end)]);
set(ar(1),'Position',[.635 .665 .335 .19]);wave=plot(ar(1),NaN,NaN);grid(ar(1),'on');xlabel(ar(1),'Time relative to latest processed trace (s)');ylabel(ar(1),'AC phase (rad)');title(ar(1),'Waiting for a qualified location');
set(ar(2),'Position',[.635 .376 .335 .19]);sp=plot(ar(2),NaN,NaN);grid(ar(2),'on');xlabel(ar(2),'Frequency (Hz)');ylabel(ar(2),'Amplitude (dB re rad)');xlim(ar(2),[0 225]);
set(ar(3),'Position',[.615 .075 .36 .225]);axis(ar(3),'off');
text(ar(3),0,1,'FFT peak SNR > 10 dB | click row to track','FontSize',11,'FontWeight','bold');
modeNote=text(ar(3),0,1.13,'AUTO TRACK | INSPECT enables distance selection','FontSize',8,'Color',[.1 .3 .55]);
text(ar(3),0,.88,'    km        Hz      FFT dB    Valid %','FontName','Consolas','FontSize',10);
candidateText=gobjects(12,1);for k=1:12,candidateText(k)=text(ar(3),0,.81-(k-1)*.065,'','FontName','Consolas','FontSize',10,'ButtonDownFcn',@(s,e) selectCandidate(fig,k));end
setappdata(fig,'manualDistanceKm',[]);setappdata(fig,'inspectionEnabled',false);setappdata(fig,'candidateRequest',[]);
setappdata(fig,'dataDirectory',dataDir);
try
 saved=jsondecode(fileread(fullfile(dataDir,'inspection_position.json')));
 if saved.enabled&&isfinite(saved.distanceKm),setappdata(fig,'manualDistanceKm',saved.distanceKm);setappdata(fig,'inspectionEnabled',true);end
catch
end
timer=tic;lastDraw=-1;lastFft=-1;lastGeneration=-1;epoch=NaN;roiCenter=NaN;roiState=[];lastSeq=0;lost=0;bad=0;requestedCenter=[];
lastTick=NaN;lastTrigger=NaN;waveformSpan=1.0;rows=zeros(0,10);streamCursor=0;streamKey='';lastShownTick=NaN;lockedCenter=NaN;
snap=[];det=struct('ready',false,'candidates',[]);spectrum=struct('frequencyHz',[],'amplitude',[],'peakHz',NaN);lastSpectrumTick=NaN;
while isgraphics(fig)&&toc(timer)<durationSeconds
 if exist(fullfile(dataDir,'VIEWER_STOP'),'file'),break;end
 try,stat=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,pause(.02);continue;end
 if stat.startedUnix~=epoch,epoch=stat.startedUnix;roiCenter=NaN;snap=[];lastGeneration=-1;streamKey='';rows=zeros(0,10);lastShownTick=NaN;lockedCenter=NaN;end
 try
  pointer=jsondecode(fileread(fullfile(dataDir,'processor_snapshot.json')));
  if pointer.receiverEpoch==epoch&&pointer.generation~=lastGeneration
   loaded=load(fullfile(dataDir,pointer.file),'snapshot');snap=loaded.snapshot;det=snap.detection;lastGeneration=pointer.generation;
   curve=det.snrDb;missing=~isfinite(curve);curve(missing)=det.diagnosticSnrDb(missing);curve(curve<-10)=-10;set(snrLine,'YData',curve);
   echo=snap.echo;if echo.ready
    e=echo.snrDb;e(~isfinite(e)|e<-10)=-10;set(echoLine,'YData',e);
    set(noiseNote,'String',sprintf('Noise %.2f counts^2 | all-point FFT; both halves >10 dB to track | floor -10 dB',echo.noisePowerAdcCountsSquared));
    powerDb=10*log10(max(snap.powerMap,eps)/echo.noisePowerAdcCountsSquared);set(im,'CData',powerDb,'AlphaData',isfinite(powerDb));
   end
   set(pm,'CData',snap.phaseMap,'AlphaData',isfinite(snap.phaseMap));set(candidateText,'String','');
   for k=1:numel(det.candidates),c=det.candidates(k);set(candidateText(k),'String',sprintf('%8.3f %9.2f %9.1f %9.1f',c.distanceKm,c.frequencyHz,c.snrDb,100*c.validFraction));end
   title(ax(1),sprintf('%d candidate regions | 4.2 s search windows',numel(det.candidates)));
  end
 catch
  % A missing/in-use snapshot does not block the selected waveform path.
 end
 if isempty(snap),set(ui.status,'String','WAITING FOR BACKGROUND SEARCH | receiver remains active');drawnow;pause(.05);continue;end
 request=getappdata(fig,'candidateRequest');
 if ~isempty(request)&&request<=numel(det.candidates)
  requestedCenter=det.candidates(request).distanceKm;lockedCenter=NaN;setappdata(fig,'candidateRequest',[]);
  rbs_write_json(fullfile(dataDir,'selection_request.json'),struct('distanceKm',requestedCenter,'updatedUnix',posixtime(datetime('now','TimeZone','UTC'))));
 end
 manual=getappdata(fig,'manualDistanceKm');center=[];selectionMode='tracked_region';label='TRACK';mode='automatic';
 if snap.track.active,center=snap.track.centerKm;end
 if ~isempty(requestedCenter)
  if snap.track.active&&abs(snap.track.regionKm-requestedCenter)<.25,requestedCenter=[];else,center=requestedCenter;end
 end
 if getappdata(fig,'inspectionEnabled'),mode='inspection_armed';end
 if ~isempty(manual),center=manual;selectionMode='manual_usable';label='MANUAL';mode='manual_inspection';end
 if isempty(center),set(ui.status,'String','SEARCHING | no qualified location yet');drawnow;pause(.05);continue;end
 % Switching hysteresis belongs to the processor. Follow its exact point,
 % including refinements within the same 250 m region.
 [~,j]=min(abs(zSearch-center));center=zSearch(j);
 if ~isfinite(roiCenter)||abs(center-roiCenter)>1e-6
  roiCenter=center;streamCursor=0;streamKey='';rows=zeros(0,10);lastShownTick=NaN;lastFft=-Inf;
  rbs_write_json(fullfile(dataDir,'selected_stream_request.json'),struct('distanceKm',roiCenter,'updatedUnix',posixtime(datetime('now','TimeZone','UTC'))));
 end
 if toc(timer)-lastDraw<.15,pause(.005);continue;end
 try
  stream=jsondecode(fileread(fullfile(dataDir,'selected_stream_status.json')));
  if stream.receiverEpoch~=epoch||abs(stream.centerKm-roiCenter)>1e-6,error('Selected stream is switching');end
  [rows,streamCursor,streamKey]=rbs_read_selected_wave(stream,streamCursor,streamKey,rows);
 catch
  set(ui.status,'String','WAITING FOR CONTINUOUS SELECTED STREAM | check selected_stream.err');drawnow;pause(.05);continue;
 end
 if size(rows,1)<200,pause(.01);continue;end
 drawStart=tic;tt=rows(:,2)/250e6;rate=1/median(diff(tt));lastTick=rows(end,2);lastTrigger=rows(end,3);lastSeq=rows(end,1);
 increments=rows(:,5);phase=rows(:,6);flags=uint32(rows(:,8));qualified=bitand(flags,uint32(7))==0;
 recovery=struct('available',all(isfinite(phase(max(1,numel(phase)-499):end))),'originalValidFraction',mean(qualified),...
  'filledSamples',0,'edgeDiscardSeconds',0,'causal',true,'lowAgreementSamples',sum(bitand(flags,uint32(1))~=0),...
  'invalidSamples',sum(~isfinite(phase)),'cutoffHz',5,'reason','Continuous measured phase; quality flags retained; no interpolation');
 y=phase;unit='AC phase (rad), causal';
 c=struct('index',j,'distanceKm',roiCenter,'frequencyHz',det.peakHz(j),'snrDb',det.snrDb(j),'validFraction',mean(qualified));
 if ~isfinite(c.snrDb),c.snrDb=det.diagnosticSnrDb(j);c.frequencyHz=det.diagnosticPeakHz(j);end
 c.amplitudeValidFraction=mean(qualified);c.validFraction=det.validFraction(j);
 c.currentlySearchQualified=det.qualified(j);
 if isempty(manual)&&~c.currentlySearchQualified,label='MONITOR';end
 c.waveformPhaseSource='Measured 20 m differential pair; amplitude quality flagged, no interpolation';
 endTime=0;startTick=lastTick-waveformSpan*250e6;
 if isfinite(lastShownTick),startTick=min(startTick,lastShownTick-.02*250e6);end
 x=tt-tt(end);show=rows(:,2)>=startTick;shownSpan=max(waveformSpan,(lastTick-startTick)/250e6);
 set(wave,'XData',x(show),'YData',y(show));xlim(ar(1),[-shownSpan 0]);ylabel(ar(1),unit);
 textTitle=sprintf('%s | %.3f km | FFT SNR %.1f dB',label,roiCenter,c.snrDb);if ~isempty(manual)&&(~isfinite(c.snrDb)||c.snrDb<=10),textTitle=[textTitle ' | BELOW 10 dB'];elseif ~c.currentlySearchQualified,textTitle=[textTitle ' | QUALITY GATE'];end;title(ar(1),textTitle);
 set(marker,'XData',roiCenter,'YData',c.snrDb);
 if toc(timer)-lastFft>.5
  specKeep=tt>=tt(end)-7;spectrum=rbs_wave_spectrum(tt(specKeep),y(specKeep));lastSpectrumTick=lastTick;lastFft=toc(timer);set(sp,'XData',spectrum.frequencyHz,'YData',20*log10(max(spectrum.amplitude,1e-7)));
  title(ar(2),sprintf('FFT of continuous waveform | %.2f Hz | no interpolation',spectrum.peakHz));
 end
 set(autoButton,'BackgroundColor',[.83 .93 1]);set(inspectButton,'BackgroundColor',[.96 .97 .985]);modeLabel='AUTO TRACK';
 if ~strcmp(mode,'automatic'),set(autoButton,'BackgroundColor',[.96 .97 .985]);set(inspectButton,'BackgroundColor',[1 .90 .68]);modeLabel='INSPECT: click AUTO TRACK to resume';end
 set(modeNote,'String',modeLabel);fresh=stat;try,fresh=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,end
 age=posixtime(datetime('now','TimeZone','UTC'))-fresh.lastFrameUnix;lag=max(0,(fresh.lastTicks-lastTick)/250e6);searchAge=max(0,fresh.lastTicks/250e6-det.searchEndHardwareSeconds);
 title(ax(2),sprintf('RBS power / tail noise | map age %.1f s',max(0,fresh.lastTicks/250e6-snap.mapEndHardwareSeconds)));
 set(ui.status,'String',sprintf('LIVE %.1f traces/s | waveform age ~%.2f s | saved %d | gaps %d | amplitude flags %.1f%%',rate,max(0,lag+age),stream.records,stream.timeGapFrames,100*(1-mean(qualified))));
 if searchAge>6.2,set(ui.status,'String',[get(ui.status,'String') ' | SEARCH LAG: detection may be delayed']);end
 if age>2,set(ui.status,'String',sprintf('NO NEW DATA %.1f s | displaying the last measured waveform',age));end
 if det.searchCoverageGapSeconds>0||det.processorMissed>0,set(ui.footer,'String',sprintf('SEARCH GAP %.3f s | processor missed %d | inspect processor_status.json',det.searchCoverageGapSeconds,det.processorMissed));end
 drawnow;lastDraw=toc(timer);lastShownTick=lastTick;
 fresh=stat;try,fresh=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,end
 lag=max(0,(fresh.lastTicks-lastTick)/250e6);now=posixtime(datetime('now','TimeZone','UTC'));
 info=det;info.updatedUnix=now;info.lastTrigger=lastTrigger;info.lastProcessedTicks=lastTick;info.latestReceiverTicksAtDraw=fresh.lastTicks;
 info.snrCurveDisplay=struct('measuredPositions',sum(isfinite(curve)),'missingPositions',sum(~isfinite(curve)),...
  'displayOnlyPositions',sum(~det.qualified&isfinite(curve)),'floorDb',-10,'interpolatedPositions',0);
 info.viewerMissed=stream.sequenceGapFrames;info.viewerRejected=0;info.dataAgeSeconds=now-fresh.lastFrameUnix;info.analysisDelaySeconds=lag;
 info.waveformEndDelaySeconds=lag;info.waveformEndTicks=lastTick;info.waveformWindowSeconds=shownSpan;info.drawSeconds=toc(drawStart);
 info.waveformStartTicks=rows(find(show,1),2);info.displayedSampleCount=sum(show);info.displayedInvalidSamples=sum(~isfinite(y(show)));
 info.continuousWaveform=stream;info.lastProcessedSequence=lastSeq;
 info.waveformAgeEstimateSeconds=max(0,info.waveformEndDelaySeconds+info.dataAgeSeconds);
 info.latencyDefinition='Age estimated from received hardware timestamps and host receive time; includes publication age and draw, excludes unmeasured constant optical/board/network and monitor-scanout delay';
 info.interactionMode=mode;info.selectionMode=selectionMode;info.selected=c;info.acPhaseRecovered=recovery.available;info.phaseRecovery=recovery;info.waveformUnits=unit;
 info.waveformSpectrumPeakHz=spectrum.peakHz;info.spectrumEndTicks=lastSpectrumTick;info.searchAgeSeconds=searchAge;info.pulseWidthNs=100;info.distanceZeroCalibrated=false;info.pztResponseConfirmed=false;
 info.phaseQualityRule='Measured phase coverage >=95%; FFT peak SNR >10 dB in both independent halves; amplitude flags reported, not a fixed candidate veto';info.liveDataFresh=info.dataAgeSeconds<2;
 rbs_write_json(fullfile(dataDir,'auto_detection.json'),info);
 f=fopen(fullfile(dataDir,'viewer.heartbeat'),'w');if f>=0,fprintf(f,'%.3f',now);fclose(f);end
 requestPath=fullfile(dataDir,'VIEWER_SNAPSHOT');
 if exist(requestPath,'file')
  delete(requestPath);saveas(fig,fullfile(dataDir,'DAS_auto_dashboard.png'));
  measured=struct('timeSeconds',tt,'incrementsRadians',increments,'recoveredAcPhaseRadians',phase,'detection',info,'receiver',fresh); %#ok<NASGU>
  save(fullfile(dataDir,'auto_latest.mat'),'measured','-v6');
 end
 pause(.005);
end
end

function selectDistance(fig,ax)
if ~getappdata(fig,'inspectionEnabled'),return;end;p=get(ax,'CurrentPoint');limits=xlim(ax);if p(1,1)>=limits(1)&&p(1,1)<=limits(2)
 setappdata(fig,'manualDistanceKm',p(1,1));
 rbs_write_json(fullfile(getappdata(fig,'dataDirectory'),'inspection_position.json'),struct('enabled',true,'distanceKm',p(1,1)));
end
end
function selectCandidate(fig,k)
resumeAutomatic(fig);setappdata(fig,'candidateRequest',k);
end
function resumeAutomatic(fig)
setappdata(fig,'manualDistanceKm',[]);setappdata(fig,'inspectionEnabled',false);setappdata(fig,'candidateRequest',[]);
rbs_write_json(fullfile(getappdata(fig,'dataDirectory'),'inspection_position.json'),struct('enabled',false,'distanceKm',0));
end
function enableInspection(fig)
setappdata(fig,'inspectionEnabled',true);
zoom(fig,'off');pan(fig,'off');
end
function finish(dataDir,fig)
p=fullfile(dataDir,'viewer.heartbeat');if exist(p,'file'),delete(p);end
f=fopen(fullfile(dataDir,'PROCESSOR_STOP'),'w');if f>=0,fprintf(f,'Viewer closed');fclose(f);end
if isgraphics(fig),close(fig);end
end
