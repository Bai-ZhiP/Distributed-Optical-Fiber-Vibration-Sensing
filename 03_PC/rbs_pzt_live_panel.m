function rbs_pzt_live_panel(action,varargin)
% One waveform/spectrum figure fed by every received trace in the main viewer.
persistent s
switch action
 case 'init'
  if ~isempty(s)&&isfield(s,'fig')&&isgraphics(s.fig)&&s.ownsFigure,close(s.fig);end
  s=struct('dir',varargin{1},'cfg',varargin{2},'locationKm',20.147,'targetHz',20,'ticks',[],'phase',[],'amplitude',[],'lastDraw',tic,'lastSave',tic,'lastConfigText','');
  s.mode='point';s.increment=[];s.coherence=[];s.controlStatus='PZT control pending';
  configPath=fullfile(s.dir,'pzt_live_config.json');
  if exist(configPath,'file')
   c=jsondecode(fileread(configPath));
   assert(c.locationKm>=0 && c.locationKm<65 && c.gaugeMeters>=1 && c.gaugeMeters<=1000);
   s.locationKm=c.locationKm;s.cfg.gaugeMeters=c.gaugeMeters;s.targetHz=c.targetHz;
   if isfield(c,'mode'),s.mode=c.mode;end
   if isfield(c,'controlStatus'),s.controlStatus=c.controlStatus;end
   if isfield(c,'junctionGroupsKm'),s.cfg.junctionGroupsKm=c.junctionGroupsKm;end
   s.lastConfigText=fileread(configPath);
  end
  rbs_junction_phase([],s.cfg,0);
  s.ownsFigure=numel(varargin)<4;
  if s.ownsFigure
   s.fig=figure('Name','DAS PZT waveform and spectrum | measured data','NumberTitle','off','Color','w','Position',[300 50 1150 900]);
   panelAxes=gobjects(1,3);for k=1:3,panelAxes(k)=subplot(3,1,k,'Parent',s.fig);end
  else
   s.fig=varargin{3};panelAxes=varargin{4};
  end
  s.ax1=panelAxes(1);s.trace=plot(s.ax1,NaN,NaN,'.-');grid(s.ax1,'on');xlabel(s.ax1,'Time relative to latest trace (s)');ylabel(s.ax1,'Differential phase (rad)');xlim(s.ax1,[-2 0]);title(s.ax1,'Waiting for genuine traces');
  s.axHP=panelAxes(2);s.highpass=plot(s.axHP,NaN,NaN);grid(s.axHP,'on');xlim(s.axHP,[-2 0]);xlabel(s.axHP,'Time relative to latest trace (s)');ylabel(s.axHP,'Phase (rad)');title(s.axHP,'Broadband waveform | 0.25 s mean removed');
  s.ax2=panelAxes(3);s.spectrum=plot(s.ax2,NaN,NaN);grid(s.ax2,'on');xlim(s.ax2,[0 45]);xlabel(s.ax2,'Frequency (Hz) | actual sample times');ylabel(s.ax2,'Phase amplitude (dB re 1 rad)');xline(s.ax2,20,'--r','20 Hz','HandleVisibility','off');title(s.ax2,'Candidate location; PZT response not yet confirmed');
 case 'reset'
  if isempty(s),return;end
  s.ticks=[];s.phase=[];s.amplitude=[];
  s.increment=[];s.coherence=[];rbs_junction_phase([],s.cfg,0);
 case 'sample'
  if isempty(s)||~isgraphics(s.fig),return;end
  tick=varargin{2};if ~isempty(s.ticks)&&tick<=s.ticks(end),return;end
  if strcmp(s.mode,'junction')
   [p,a,z,coh,inc]=rbs_junction_phase(varargin{1},s.cfg,tick);
  else
   [p,a,z]=rbs_point_phase(varargin{1},s.cfg,s.locationKm);coh=NaN;inc=NaN;
  end
  s.actualKm=z;s.increment(end+1)=inc;s.coherence(end+1)=coh;
  s.ticks(end+1)=tick;s.phase(end+1)=p;s.amplitude(end+1)=a;
  keep=s.ticks>=tick-10*s.cfg.sampleRate;s.ticks=s.ticks(keep);s.phase=s.phase(keep);s.amplitude=s.amplitude(keep);
  s.increment=s.increment(keep);s.coherence=s.coherence(keep);
 case 'draw'
  if isempty(s)||~isgraphics(s.fig)||toc(s.lastDraw)<1,return;end
  s.lastDraw=tic;
  configPath=fullfile(s.dir,'pzt_live_config.json');
  if exist(configPath,'file')
   try
    txt=fileread(configPath);
    if ~strcmp(txt,s.lastConfigText)
     c=jsondecode(txt);assert(c.locationKm>=0 && c.locationKm<65 && c.gaugeMeters>=1 && c.gaugeMeters<=1000);
     s.locationKm=c.locationKm;s.cfg.gaugeMeters=c.gaugeMeters;s.targetHz=c.targetHz;s.lastConfigText=txt;
     s.mode='point';if isfield(c,'mode'),s.mode=c.mode;end
     s.controlStatus='PZT control pending';if isfield(c,'controlStatus'),s.controlStatus=c.controlStatus;end
     if isfield(c,'junctionGroupsKm'),s.cfg.junctionGroupsKm=c.junctionGroupsKm;end
     s.increment=[];s.coherence=[];rbs_junction_phase([],s.cfg,0);
     s.ticks=[];s.phase=[];s.amplitude=[];set(s.trace,'XData',NaN,'YData',NaN);set(s.spectrum,'XData',NaN,'YData',NaN);
    end
   catch
    % Preserve a valid current selection if a configuration write is in progress.
   end
  end
  if numel(s.ticks)<20,return;end
  t=(s.ticks-s.ticks(1))/s.cfg.sampleRate;p=s.phase;ok=isfinite(p);center=angle(sum(exp(1i*p(ok))));wave=angle(exp(1i*(p-center)));wave(~ok)=NaN;
  x=t-t(end);show=x>=-2;set(s.trace,'XData',x(show),'YData',wave(show));
  title(s.ax1,sprintf('Candidate %.5f km | %.0f m gauge | pulse %.0f ns | valid %.1f%%',s.actualKm,s.cfg.gaugeMeters,s.cfg.matchedPulseNs,100*mean(ok)));
  if strcmp(s.mode,'junction'),title(s.ax1,sprintf('Junction waveform | valid %.1f%%',100*mean(ok)));end
  spec=rbs_phase_spectrum(t,p,s.targetHz);
  unwrappedAvailable=~isempty(spec.unwrappedFrequencyHz);
  if unwrappedAvailable
   set(s.trace,'YData',spec.unwrappedPhase(show));set(s.highpass,'XData',x(show),'YData',spec.highpassPhase(show));
   ylabel(s.ax1,'Unwrapped phase, linear detrend (rad)');
   set(s.spectrum,'XData',spec.unwrappedFrequencyHz,'YData',20*log10(max(spec.unwrappedAmplitudeRadians,1e-6)));xlim(s.ax2,[0 max(spec.unwrappedFrequencyHz)]);
   ylabel(s.ax2,'Phase amplitude (dB re 1 rad)');
   title(s.ax2,sprintf('%.1f s | peak %.2f Hz | 20 Hz %.4f rad',spec.seconds,spec.unwrappedPeakHz,spec.unwrappedTargetRadians));
  elseif ~isempty(spec.frequencyHz)
   set(s.highpass,'XData',NaN,'YData',NaN);ylabel(s.ax1,'Wrapped differential phase (rad)');ylabel(s.ax2,'Unit-phasor modulation (dB)');xlim(s.ax2,[0 45]);
   set(s.spectrum,'XData',spec.frequencyHz,'YData',20*log10(max(spec.amplitude,1e-6)));
   title(s.ax2,sprintf('Latest %.1f s | strongest component %.1f Hz | %.0f Hz amplitude %.4f | not a calibrated strain FFT',spec.seconds,spec.peakHz,s.targetHz,spec.targetAmplitude));
  else
   set(s.highpass,'XData',NaN,'YData',NaN);
   set(s.spectrum,'XData',NaN,'YData',NaN);title(s.ax2,'Insufficient valid data for spectrum');
  end
  incrementSpec=struct;
  if strcmp(s.mode,'junction') && ~unwrappedAvailable
   incrementSpec=rbs_increment_spectrum(t,s.increment,s.targetHz);
   set(s.trace,'YData',s.increment(show));ylabel(s.ax1,'Wrapped phase increment (rad/trace)');
   set(s.highpass,'XData',NaN,'YData',NaN);title(s.axHP,'Phase unwrap unavailable: gaps or near-pi steps');
   if ~isempty(incrementSpec.frequencyHz)
    set(s.spectrum,'XData',incrementSpec.frequencyHz,'YData',20*log10(max(incrementSpec.amplitude,1e-7)));xlim(s.ax2,[0 max(incrementSpec.frequencyHz)]);
    ylabel(s.ax2,'Increment amplitude (dB re rad/trace)');title(s.ax2,sprintf('Increment spectrum | 20 Hz %.4f rad/trace',incrementSpec.targetAmplitude));
   end
  else
   title(s.axHP,'Broadband waveform | 0.25 s mean removed');
  end
  stat=varargin{1};age=posixtime(datetime('now','TimeZone','UTC'))-stat.lastFrameUnix;
  if age>2,title(s.ax1,sprintf('NO NEW DATA for %.1f s | candidate %.5f km',age,s.actualKm));end
  info=struct('updatedUnix',posixtime(datetime('now','TimeZone','UTC')),'lastTrigger',stat.lastTrigger,'locationKm',s.actualKm,'gaugeMeters',s.cfg.gaugeMeters,'pulseWidthNs',s.cfg.matchedPulseNs,'framesUsed',numel(t),'validFraction',mean(ok),'spectrumPeakHz',spec.peakHz,'targetHz',s.targetHz,'targetAmplitude',spec.targetAmplitude,'candidateOnly',true,'distanceZeroCalibrated',false);
  info.unwrappedAvailable=unwrappedAvailable;info.unwrappedPeakHz=spec.unwrappedPeakHz;info.unwrappedTargetRadians=spec.unwrappedTargetRadians;
  info.mode=s.mode;info.controlStatus=s.controlStatus;info.fractionIncrementsNearPi=mean(abs(s.increment)>.9*pi);info.incrementSpectrum=incrementSpec;
  f=fopen(fullfile(s.dir,'pzt_panel_status.json'),'w');if f>=0,fprintf(f,'%s',jsonencode(info));fclose(f);end
  if toc(s.lastSave)>15
   if s.ownsFigure,saveas(s.fig,fullfile(s.dir,'matlab_pzt_waveform_spectrum.png'));end
   waveform=struct('adcTicks',s.ticks,'timeSeconds',t,'wrappedPhaseRadians',p,'minimumIqCounts',s.amplitude,...
    'spectrum',spec,'configuration',s.cfg,'locationKm',s.actualKm,'status',info,'receiverStatus',stat,...
    'pztDriveStateConfirmedForThisWindow',false,'pztResponseConfirmed',false); %#ok<NASGU>
   waveform.wrappedIncrementRadians=s.increment;waveform.spatialIncrementCoherence=s.coherence;waveform.mode=s.mode;
   save(fullfile(s.dir,'pzt_waveform_latest.mat'),'waveform');
   s.lastSave=tic;
  end
 case 'close'
  if ~isempty(s)&&isfield(s,'fig')&&isgraphics(s.fig)&&s.ownsFigure,close(s.fig);end
  s=[];
end
end
