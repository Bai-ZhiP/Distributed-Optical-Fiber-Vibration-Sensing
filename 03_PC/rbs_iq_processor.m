function rbs_iq_processor(durationSeconds,dataDir)
% Independent full-fiber analysis process. Search windows advance in order.
if nargin<1,durationSeconds=Inf;end
try,maxNumCompThreads(2);catch,end
cap=6000;hopSeconds=4;epoch=NaN;count=0;lastSeq=0;state=[];lost=0;bad=0;track=[];lastEnd=NaN;searchGap=0;windows=0;generation=0;
processorEpoch=posixtime(datetime('now','TimeZone','UTC'));timer=tic;lastRequest=0;
logPath=fullfile(dataDir,sprintf('search_timing_%.0f.jsonl',processorEpoch));
while toc(timer)<durationSeconds
 if exist(fullfile(dataDir,'PROCESSOR_STOP'),'file'),break;end
 try,s=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,pause(.02);continue;end
 if s.startedUnix~=epoch
  epoch=s.startedUnix;lastSeq=s.complete;count=0;state=[];track=[];lastEnd=NaN;
  [~,~,~,~,z]=rbs_iq_batch(complex(zeros(3200,1)),0,[]);nc=numel(z);zPower=((0:3199)*25+12)*299792458/(2*1.468*250e6*1000);
  times=nan(1,cap);qualityHistory=false(nc,cap);measuredHistory=nan(nc,cap,'single');powerHistory=nan(3200,cap,'single');
  envMap=nan(3200,250,'single');phaseMap=nan(nc,250,'single');mapTime=nan(1,250);nextSearch=4201;
 end
 begin=max(lastSeq+1,s.complete-s.slots+1);
 if begin>lastSeq+1,lost=lost+begin-lastSeq-1;state=[];end
 finish=min([s.complete begin+511 begin+nextSearch-count-1]);
 if finish<begin,pause(.005);continue;end
 [iq,h,seq,rejected]=rbs_read_iq_ring(dataDir,s,begin,finish);bad=bad+rejected;lastSeq=finish;
 if isempty(seq),continue;end
 ticks=h(9,:)+h(10,:)*2^32;[power,~,diag,state,~,measured]=rbs_iq_batch(iq,ticks,state);
 cols=mod(count+(0:numel(seq)-1),cap)+1;times(cols)=ticks/250e6;qualityHistory(:,cols)=isfinite(diag);measuredHistory(:,cols)=measured;powerHistory(:,cols)=power;count=count+numel(seq);
 bins=floor(ticks/250e6/.02);[~,keep]=unique(bins,'last');m=mod(bins(keep),250)+1;envMap(:,m)=power(:,keep);phaseMap(:,m)=diag(:,keep);mapTime(m)=bins(keep);
 if count<nextSearch,continue;end
 phaseStart=tic;ix=mod((max(1,count-4201+1):count)-1,cap)+1;tt=times(ix)';dx=measuredHistory(:,ix)';dx(~qualityHistory(:,ix)')=NaN;
 rate=1/median(diff(tt));use=tt>=tt(end)-4.2;xx=rbs_spatial_increments(dx(use,:));
 det=rbs_auto_snr(tt(use),xx,z,measuredHistory(:,ix(use))');
 requested=false;
 try
  request=jsondecode(fileread(fullfile(dataDir,'selection_request.json')));
  if request.updatedUnix>max(lastRequest,processorEpoch)&&~isempty(det.candidates)
   lastRequest=request.updatedUnix;[distance,k]=min(abs([det.candidates.distanceKm]-request.distanceKm));
   if distance<.25,chosen=det;chosen.candidates=det.candidates(k);track=rbs_track_location([],chosen,tt,dx,z);requested=true;end
  end
 catch
 end
 if ~requested,track=rbs_track_location(track,det,tt,dx,z);end
 startTime=tt(find(use,1));if isfinite(lastEnd),searchGap=searchGap+max(0,startTime-lastEnd);end;lastEnd=tt(end);windows=windows+1;
 echo=rbs_echo_snr(mean(powerHistory(:,ix(use)),2),zPower,[31.5 32.5]);
 for field={'power','displayPower'},if isfield(det,field{1}),det=rmfield(det,field{1});end;end
 det.searchStartHardwareSeconds=startTime;det.searchEndHardwareSeconds=tt(end);det.searchWindows=windows;det.searchCoverageGapSeconds=searchGap;
 det.searchHopSeconds=hopSeconds;det.processorMissed=lost;det.processorRejected=bad;det.processorEpoch=processorEpoch;det.receiverEpoch=epoch;
 det.searchComputeSeconds=toc(phaseStart);det.updatedUnix=posixtime(datetime('now','TimeZone','UTC'));
 wanted=bins(end)-249:bins(end);order=mod(wanted,250)+1;powerMap=envMap(:,order)';incrementsMap=rbs_spatial_increments(phaseMap(:,order)');
 missing=mapTime(order)~=wanted;powerMap(missing,:)=NaN;incrementsMap(missing,:)=NaN;
 snapshot=struct('detection',det,'track',track,'echo',echo,'powerMap',powerMap,'phaseMap',incrementsMap,...
  'searchDistanceKm',z,'powerDistanceKm',zPower,'mapEndHardwareSeconds',ticks(end)/250e6,'lastTrigger',h(2,end)); %#ok<NASGU>
 generation=generation+1;slot=mod(generation,3);name=sprintf('processor_snapshot_%d.mat',slot);temp=fullfile(dataDir,'processor_snapshot.tmp.mat');
 save(temp,'snapshot','-v6');[published,~]=movefile(temp,fullfile(dataDir,name),'f');
 if published
  pointer=struct('file',name,'generation',generation,'receiverEpoch',epoch,'processorEpoch',processorEpoch,'updatedUnix',posixtime(datetime('now','TimeZone','UTC')));
  rbs_write_json(fullfile(dataDir,'processor_snapshot.json'),pointer);
 end
 fresh=s;try,fresh=jsondecode(fileread(fullfile(dataDir,'status.json')));catch,end
 timing=struct('updatedUnix',posixtime(datetime('now','TimeZone','UTC')),'startHardwareSeconds',startTime,'endHardwareSeconds',tt(end),...
  'computeSeconds',det.searchComputeSeconds,'processorDelaySeconds',max(0,fresh.lastTicks/250e6-tt(end)),...
  'coverageGapSeconds',searchGap,'missed',lost,'rejected',bad,'windows',windows,'ready',det.ready);
 log=fopen(logPath,'a');if log>=0,fprintf(log,'%s\n',jsonencode(timing));fclose(log);end
 rbs_write_json(fullfile(dataDir,'processor_status.json'),timing);
 nextSearch=nextSearch+max(1,round(hopSeconds*rate));
end
end
