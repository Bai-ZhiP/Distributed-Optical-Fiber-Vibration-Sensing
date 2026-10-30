function rbs_auto_iq_live(durationSeconds,dataDir)
% Full returned-fiber automatic search, fed by board-side IQ transport.
if nargin<1,durationSeconds=Inf;end
if nargin<2,dataDir=fullfile(fileparts(mfilename('fullpath')),'rbs_iq_live');end
stat=jsondecode(fileread(fullfile(dataDir,'status.json')));
assert(strcmp(stat.format,'IQ16')&&stat.iqDecimation==25&&stat.matchedPulseNs==100);
n=stat.sampleCount;bins=n/2;fs=250e6;
z=((0:bins-1)*25+12)*299792458/(2*1.468*fs*1000);
[~,~,searchZ]=rbs_iq_features(complex(zeros(bins,1)),0,true);nc=numel(searchZ);
cap=3500;times=nan(cap,1);increments=nan(cap,nc,'single');count=0;
strictIncrements=nan(cap,nc,'single');
powerHistory=nan(cap,bins,'single');diagnosticIncrements=nan(cap,nc,'single');echo=struct('ready',false);
rows=250;envMap=nan(rows,bins,'single');phaseMap=nan(rows,nc,'single');timeBins=nan(rows,1);
ui=rbs_dashboard_layout();fig=ui.fig;cleanup=onCleanup(@() finish(dataDir,fig)); %#ok<NASGU>
set(fig,'Name','DAS Auto | space-time, vibration locations, waveform and FFT');
set(ui.heading,'String','DAS  |  FFT peak SNR and vibration location');
autoButton=annotation(fig,'textbox',[.655 .949 .10 .033],'String','AUTO TRACK','FontSize',10,...
 'HorizontalAlignment','center','EdgeColor',[.2 .45 .7],'BackgroundColor',[.83 .93 1],...
 'ButtonDownFcn',@(s,e) resumeAutomatic(fig));
inspectButton=annotation(fig,'textbox',[.765 .949 .085 .033],'String','INSPECT','FontSize',10,...
 'HorizontalAlignment','center','EdgeColor',[.5 .6 .7],'ButtonDownFcn',@(s,e) enableInspection(fig));
set(ui.footer,'String','Acquire: FFT peak SNR >10 dB in both halves; spatial agreement valid >=95% | AC phase 5-200 Hz; no sine fit | spatial span ~280 m; distance uncalibrated');
ax=ui.left;ar=ui.right;
echoLine=plot(ax(1),z,nan(size(z)),':','Color',[.75 .49 .17]);hold(ax(1),'on');
snrLine=plot(ax(1),searchZ,nan(size(searchZ)),'Color',[.08 .34 .78],'LineWidth',1.1);
yline(ax(1),10,'--r','FFT gate 10 dB');marker=plot(ax(1),NaN,NaN,'ro','MarkerFaceColor','r');hold(ax(1),'off');
for clickable={ax(1),snrLine,echoLine,marker},set(clickable{1},'ButtonDownFcn',@(s,e) selectDistance(fig,ax(1)));end
legend(ax(1),[snrLine echoLine],{'FFT peak SNR','Echo reference'},'FontSize',8,'Location','northeast');
ylabel(ax(1),'SNR (dB)');title(ax(1),'Highest FFT peak at each distance | collecting at least 4 s');grid(ax(1),'on');ylim(ax(1),[-10 50]);
noiseNote=annotation(fig,'textbox',[.055 .655 .50 .027],'EdgeColor','none','FontSize',9,...
 'String','Noise reference: 31.5-32.5 km, assumed beyond fiber | display floor -10 dB','Color',[.35 .4 .48]);
im=imagesc(ax(2),z,[-5 0],envMap);axis(ax(2),'xy');set(im,'AlphaData',zeros(size(envMap)));set(ax(2),'Color',[.82 .84 .86]);colorbar(ax(2));
title(ax(2),'RBS power / tail noise (dB) | 100 ns | last 5 s');ylabel(ax(2),'Time (s)');caxis(ax(2),[-5 40]);
pm=imagesc(ax(3),searchZ,[-5 0],phaseMap);axis(ax(3),'xy');set(pm,'AlphaData',zeros(size(phaseMap)));set(ax(3),'Color',[.82 .84 .86]);colorbar(ax(3));caxis(ax(3),[-pi pi]);
title(ax(3),'Measured phase increments | weak signal masked');ylabel(ax(3),'Time (s)');xlabel(ax(3),'Distance (km)');
set(ax,'XLim',[0 z(end)]);
set(ar(1),'Position',[.635 .665 .335 .19]);wave=plot(ar(1),NaN,NaN);grid(ar(1),'on');xlabel(ar(1),'Time relative to latest trace (s)');ylabel(ar(1),'Phase increment (rad/trace)');title(ar(1),'No qualified location yet');
set(ar(2),'Position',[.635 .376 .335 .19]);sp=plot(ar(2),NaN,NaN);grid(ar(2),'on');xlabel(ar(2),'Frequency (Hz)');ylabel(ar(2),'Amplitude (dB re rad/trace)');title(ar(2),'Frequency spectrum at selected location');
set(ar(3),'Position',[.615 .075 .36 .225]);axis(ar(3),'off');
text(ar(3),0,1,'FFT peak SNR > 10 dB | click row to select','FontSize',11,'FontWeight','bold');
modeNote=text(ar(3),0,1.13,'AUTO: click a candidate row to track; use INSPECT to select any distance','FontSize',8,'Color',[.1 .3 .55]);
text(ar(3),0,.88,'    km        Hz      FFT dB    Valid %','FontName','Consolas','FontSize',10);
candidateText=gobjects(12,1);
for k=1:12,candidateText(k)=text(ar(3),0,.81-(k-1)*.065,'','FontName','Consolas','FontSize',10,'ButtonDownFcn',@(s,e) selectCandidate(fig,k));end
setappdata(fig,'candidateSelection',1);setappdata(fig,'manualDistanceKm',[]);setappdata(fig,'candidateRequest',[]);setappdata(fig,'inspectionEnabled',false);
lastSeq=0;epoch=NaN;lastTick=NaN;firstTick=NaN;lost=0;
timer=tic;lastPlot=-1;lastSearch=-10;lastSave=0;track=[];det=struct('ready',false,'reason','Collecting data','candidates',[]);
while isgraphics(fig)&&toc(timer)<durationSeconds
 if exist(fullfile(dataDir,'VIEWER_STOP'),'file'),break;end
 try,stat=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,pause(.05);continue;end
 if stat.startedUnix~=epoch
  epoch=stat.startedUnix;lastSeq=max(0,stat.complete-min(stat.slots,2200));count=0;lastTick=NaN;firstTick=NaN;lost=0;
  times(:)=NaN;increments(:)=NaN;strictIncrements(:)=NaN;diagnosticIncrements(:)=NaN;powerHistory(:)=NaN;envMap(:)=NaN;phaseMap(:)=NaN;timeBins(:)=NaN;echo=struct('ready',false);
  set(snrLine,'YData',nan(size(searchZ)));set(echoLine,'YData',nan(size(z)));
  rbs_iq_features(complex(zeros(bins,1)),0,true);track=[];det=struct('ready',false,'reason','Collecting data','candidates',[]);
 end
 if stat.complete>lastSeq
  begin=max(lastSeq+1,stat.complete-stat.slots+1);lost=lost+max(0,begin-lastSeq-1);
  f=fopen(fullfile(dataDir,'frames.ring'),'rb','ieee-le');if f<0,pause(.05);continue;end
  guard=onCleanup(@() fclose(f));
  for seq=begin:stat.complete
   fseek(f,mod(seq-1,stat.slots)*stat.recordBytes,'bof');a=fread(f,1,'uint64=>double');h=fread(f,12,'uint32=>double');raw=fread(f,n,'int16=>double');b=fread(f,1,'uint64=>double');
   if isempty(a)||isempty(b)||a~=seq||b~=seq||numel(raw)~=n||numel(h)~=12||h(1)~=hex2dec('33425149')||h(7)~=n||h(12)~=25,lost=lost+1;continue;end
   tick=h(9)+h(10)*2^32;if ~isnan(lastTick)&&tick<=lastTick,continue;end
   if isnan(firstTick),firstTick=tick;end
   iq=complex(raw(1:2:end),raw(2:2:end))/stat.iqScale;
   [amp,strictInc,~,~,diagnosticInc]=rbs_iq_features(iq,tick,false);lastTick=tick;
   count=count+1;k=mod(count-1,cap)+1;times(k)=tick/fs;strictIncrements(k,:)=strictInc;diagnosticIncrements(k,:)=diagnosticInc;powerHistory(k,:)=single(amp.^2);
   tb=floor((tick-firstTick)/fs/.02);m=mod(tb,rows)+1;envMap(m,:)=single(amp);phaseMap(m,:)=diagnosticInc;timeBins(m)=tb;
  end
  clear guard;lastSeq=stat.complete;
 end
 if toc(timer)-lastPlot>.5
  if count>5
   ix=mod((max(1,count-cap+1):count)-1,cap)+1;
   tt=times(ix);xx=[];rate=1/median(diff(tt));
   freshStat=latestStatus(dataDir,stat);age=posixtime(datetime('now','TimeZone','UTC'))-freshStat.lastFrameUnix;
   tb=floor((lastTick-firstTick)/fs/.02);wanted=tb-rows+1:tb;order=mod(wanted,rows)+1;
   em=envMap(order,:);ph=rbs_spatial_increments(phaseMap(order,:));missing=timeBins(order)~=wanted';em(missing,:)=NaN;ph(missing,:)=NaN;
   set(pm,'CData',ph,'AlphaData',isfinite(ph));
   if toc(timer)-lastSearch>3&&age<2
    usePower=ix(tt>=tt(end)-4.2);
    echo=rbs_echo_snr(mean(powerHistory(usePower,:),1),z,[31.5 32.5]);
    xx=rbs_spatial_increments(diagnosticIncrements(ix,:));
    det=rbs_auto_snr(tt,xx,searchZ,diagnosticIncrements(ix,:));lastSearch=toc(timer);
    track=rbs_track_location(track,det,tt,diagnosticIncrements(ix,:),searchZ);
    if echo.ready
     displaySnr=echo.snrDb;displaySnr(~isfinite(displaySnr)|displaySnr<-10)=-10;
     set(echoLine,'YData',displaySnr);
     set(noiseNote,'String',sprintf('Tail noise: %.2f ADC counts^2 (31.5-32.5 km, assumed beyond fiber) | floor -10 dB',echo.noisePowerAdcCountsSquared));
    end
    if det.ready
     displayFftSnr=det.snrDb;missingFft=~isfinite(displayFftSnr);
     displayFftSnr(missingFft)=det.diagnosticSnrDb(missingFft);displayFftSnr(displayFftSnr<-10)=-10;
     set(snrLine,'YData',displayFftSnr);set(candidateText,'String','');
     for k=1:numel(det.candidates),c=det.candidates(k);set(candidateText(k),'String',sprintf('%8.3f %9.2f %9.1f %9.1f',c.distanceKm,c.frequencyHz,c.snrDb,100*c.validFraction));end
     if isempty(det.candidates)
      title(ax(1),'No valid location passes FFT peak SNR >10 dB in both halves');set(marker,'XData',NaN,'YData',NaN);set(candidateText(1),'String','No qualified candidate');
     else
      title(ax(1),sprintf('%d separated candidate regions | FFT peak SNR >10 dB',numel(det.candidates)));
     end
    else,title(ax(1),det.reason);set(candidateText,'String','');set(marker,'XData',NaN,'YData',NaN);end
   end
   freshStat=latestStatus(dataDir,stat);age=posixtime(datetime('now','TimeZone','UTC'))-freshStat.lastFrameUnix;
   analysisDelay=max(0,(freshStat.lastTicks-lastTick)/fs);
   set(ui.status,'String',sprintf('LIVE | %.1f traces/s | search 5-%.1f Hz | 0-%.2f km | pulse 100 ns | missed %d | view delay %.1f s',rate,min(450,.45*rate),z(end),lost,analysisDelay));
   if age>2,set(ui.status,'String',sprintf('NO NEW DATA for %.1f s | showing last measured data',age));end
   request=getappdata(fig,'candidateRequest');
   if det.ready&&~isempty(request)&&request<=numel(det.candidates)
    chosen=det;chosen.candidates=det.candidates(request);track=rbs_track_location([],chosen,tt,diagnosticIncrements(ix,:),searchZ);setappdata(fig,'candidateRequest',[]);
   end
   manual=getappdata(fig,'manualDistanceKm');hasTrack=~isempty(track)&&track.active;
   interactionMode='automatic';modeLabel='AUTO TRACK';
   set(autoButton,'BackgroundColor',[.83 .93 1]);set(inspectButton,'BackgroundColor',[.96 .97 .985]);
   set(modeNote,'String','AUTO: click a candidate row to track; use INSPECT to select any distance','Color',[.1 .3 .55]);
   if getappdata(fig,'inspectionEnabled')
    interactionMode='inspection_armed';modeLabel='INSPECT: click SNR curve to choose a distance';
    if ~isempty(manual),interactionMode='manual_inspection';modeLabel='MANUAL INSPECT: click AUTO TRACK to resume';end
    set(autoButton,'BackgroundColor',[.96 .97 .985]);set(inspectButton,'BackgroundColor',[1 .90 .68]);
    set(modeNote,'String',modeLabel,'Color',[.65 .32 .02]);
   end
   set(ui.status,'String',[get(ui.status,'String') ' | ' modeLabel]);
   hasSelection=det.ready&&(hasTrack||~isempty(manual));waveInfo=struct('available',false);plottedPhase=nan(size(tt));
   if hasSelection
    set(candidateText,'Color',[.2 .2 .2]);isDiagnostic=false;selectionMode='tracked_region';
    if isempty(manual)
     [~,j]=min(abs(searchZ-track.centerKm));c=track.seed;c.index=j;c.distanceKm=searchZ(j);
     c.snrDb=det.snrDb(j);c.frequencyHz=det.peakHz(j);
     if ~isfinite(c.snrDb),c.snrDb=det.diagnosticSnrDb(j);c.frequencyHz=det.diagnosticPeakHz(j);end
     [y,fusion]=rbs_fuse_increments(diagnosticIncrements(ix,:),searchZ,track.centerKm,3);c.validFraction=fusion.validFraction;
     c.strictCenterValidFraction=mean(isfinite(strictIncrements(ix,j)));
     c.waveformPhaseSource='Measured phase estimates including low amplitude samples; >=3 neighboring estimates must agree >=0.9';
     c.currentlySearchQualified=~isempty(det.candidates)&&any(abs([det.candidates.distanceKm]-track.centerKm)<=.25);
     selectionLabel='TRACK';if ~c.currentlySearchQualified,selectionLabel='MONITOR';end
     c.lastQualifiedSecondsAgo=tt(end)-track.lastQualifiedTime;
     if ~isempty(det.candidates)
      [d,selection]=min(abs([det.candidates.distanceKm]-track.centerKm));if d<=.25,set(candidateText(selection),'Color',[.0 .35 .8]);end
     end
    else
     [~,j]=min(abs(searchZ-manual));isDiagnostic=det.validFraction(j)<.95;
     c=struct('index',j,'distanceKm',searchZ(j),'frequencyHz',det.peakHz(j),'snrDb',det.snrDb(j),'validFraction',det.validFraction(j));
     selectionMode='manual_usable';selectionLabel='MANUAL';
     if isDiagnostic
      c.frequencyHz=det.diagnosticPeakHz(j);c.snrDb=det.diagnosticSnrDb(j);selectionMode='manual_diagnostic';selectionLabel='LOW CONFIDENCE';
     end
     y=rbs_fuse_increments(diagnosticIncrements(ix,:),searchZ,searchZ(j),3);if isDiagnostic,y=double(diagnosticIncrements(ix,j));end
    end
    set(marker,'XData',c.distanceKm,'YData',c.snrDb);
    x=tt-tt(end);unit='Measured increment (rad/trace)';
    if ~isDiagnostic
     [plottedPhase,waveInfo]=rbs_recover_ac_phase(tt,y);
     if waveInfo.available,y=plottedPhase;unit=sprintf('AC phase (rad), 5-%.0f Hz',waveInfo.bandHz(2));end
    end
    endpoint=find(isfinite(y),1,'last');endTime=0;if ~isempty(endpoint),endTime=x(endpoint);end
    show=x>=endTime-.6&x<=endTime;set(wave,'XData',x(show),'YData',y(show));xlim(ar(1),[endTime-.6 endTime]);ylabel(ar(1),unit);
    waveTitle=sprintf('%s | %.3f km | FFT SNR %.1f dB',selectionLabel,c.distanceKm,c.snrDb);
    if ~isempty(manual)&&(~isfinite(c.snrDb)||c.snrDb<=10),waveTitle=[waveTitle ' | BELOW 10 dB'];end
    title(ar(1),waveTitle);
    spectrum=rbs_wave_spectrum(tt,y);set(sp,'XData',spectrum.frequencyHz,'YData',20*log10(max(spectrum.amplitude,1e-7)));xlim(ar(2),[0 min(225,.45*rate)]);
    if waveInfo.available
     title(ar(2),sprintf('AC phase FFT | peak %.2f Hz | filled %d samples',spectrum.peakHz,waveInfo.filledSamples));ylabel(ar(2),'Amplitude (dB re rad)');
    else
     title(ar(2),sprintf('Increment FFT | peak %.2f Hz | phase quality limited',spectrum.peakHz));ylabel(ar(2),'Amplitude (dB re rad/trace)');
    end
    if age>2,title(ar(1),sprintf('STALE %.1f s | last measured %.3f km',age,c.distanceKm));end
   else
    set(wave,'XData',NaN,'YData',NaN);set(sp,'XData',NaN,'YData',NaN);title(ar(1),'No current qualified vibration location');
    if age>2,set(candidateText,'String','');set(candidateText(1),'String','No live data');set(marker,'XData',NaN,'YData',NaN);end
   end
   if echo.ready
    set(im,'CData',10*log10(max(em.^2,eps)/echo.noisePowerAdcCountsSquared),'AlphaData',isfinite(em));
   end
   info=det;for field={'power','displayPower'},if isfield(info,field{1}),info=rmfield(info,field{1});end;end
   info.echo=echo;info.phaseQualityRule='>=3 neighboring measured phase estimates and circular agreement >=0.9 at each trace; >=95% valid in both search halves';
   info.updatedUnix=posixtime(datetime('now','TimeZone','UTC'));info.lastTrigger=stat.lastTrigger;info.viewerMissed=lost;info.dataAgeSeconds=age;info.analysisDelaySeconds=analysisDelay;
   info.pulseWidthNs=100;info.searchRangeKm=[z(1) z(end)];info.distanceZeroCalibrated=false;info.liveDataFresh=age<2;info.pztResponseConfirmed=false;
   info.interactionMode=interactionMode;
   if hasSelection
    info.selected=c;info.continuousPhaseQualified=false;info.acPhaseRecovered=waveInfo.available;info.waveformUnits=unit;info.selectionMode=selectionMode;
    info.waveformSpectrumPeakHz=spectrum.peakHz;info.waveformEndDelaySeconds=analysisDelay-endTime;info.phaseRecovery=waveInfo;
   end
   fo=fopen(fullfile(dataDir,'auto_detection.json'),'w');if fo>=0,fprintf(fo,'%s',jsonencode(info));fclose(fo);end
  else,set(ui.status,'String','WAITING FOR IQ DATA | check FPGA power, ETH1 and TRIG');end
  if isfield(stat,'displayMode'),set(ui.status,'String',stat.displayMode);end
  drawnow;lastPlot=toc(timer);
  fo=fopen(fullfile(dataDir,'viewer.heartbeat'),'w');if fo>=0,fprintf(fo,'%.3f',posixtime(datetime('now','TimeZone','UTC')));fclose(fo);end
  if count>0&&toc(timer)-lastSave>20
   saveas(fig,fullfile(dataDir,'DAS_auto_dashboard.png'));
   if isempty(xx),xx=rbs_spatial_increments(diagnosticIncrements(ix,:));end
   measured=struct('timeSeconds',tt,'incrementsRadians',xx,'strictIncrementsRadians',strictIncrements(ix,:),'diagnosticIncrementsRadians',diagnosticIncrements(ix,:),...
    'distanceKm',searchZ,'echo',echo,'detection',info,'receiver',stat,'recoveredAcPhaseRadians',plottedPhase); %#ok<NASGU>
   save(fullfile(dataDir,'auto_latest.mat'),'measured','-v7.3');lastSave=toc(timer);
  end
 end
 pause(.02);
end
end

function finish(dataDir,fig)
p=fullfile(dataDir,'viewer.heartbeat');if exist(p,'file'),delete(p);end
if isgraphics(fig),close(fig);end
end

function selectDistance(fig,ax)
if ~getappdata(fig,'inspectionEnabled'),return;end
p=get(ax,'CurrentPoint');limits=xlim(ax);
if p(1,1)>=limits(1)&&p(1,1)<=limits(2),setappdata(fig,'manualDistanceKm',p(1,1));end
end

function selectCandidate(fig,k)
resumeAutomatic(fig);setappdata(fig,'candidateSelection',k);setappdata(fig,'candidateRequest',k);
end

function resumeAutomatic(fig)
setappdata(fig,'inspectionEnabled',false);setappdata(fig,'manualDistanceKm',[]);setappdata(fig,'candidateRequest',[]);
end

function enableInspection(fig)
setappdata(fig,'inspectionEnabled',true);
end

function stat=latestStatus(dataDir,fallback)
stat=fallback;try,stat=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,end
end
