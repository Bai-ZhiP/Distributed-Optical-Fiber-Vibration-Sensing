function track = rbs_track_location(track,det,t,x,z) %#ok<INUSD>
% Select the strongest confirmed FFT-SNR point, then apply switching hysteresis.
now=t(end);
if isempty(track)
 track=struct('active',false,'centerKm',NaN,'regionKm',NaN,'lastQualifiedTime',NaN,...
  'seed',[],'pendingKm',NaN,'pendingCount',0,'missingWindows',0,'snrDb',NaN,'reason','Waiting for confirmed FFT peak');
end
if ~det.ready,return;end
candidate=det.candidates;
if isempty(candidate)
 if track.active,track.missingWindows=track.missingWindows+1;track.reason='Monitoring last location; no peak passes both halves';end
 return;
end
[~,order]=sort([candidate.snrDb],'descend');candidate=candidate(order);best=candidate(1);
if ~track.active,track=accept(track,best,now);return;end
[~,j]=min(abs(z-track.centerKm));currentConfirmed=det.qualified(j);
if currentConfirmed
 track.lastQualifiedTime=now;track.missingWindows=0;track.snrDb=det.snrDb(j);
else
 track.missingWindows=track.missingWindows+1;
end
if abs(best.distanceKm-track.centerKm)<.001
 track=accept(track,best,now);return;
end
% A persistent point at least 3 dB stronger may replace the current point.
% If the old point is unqualified, require two agreeing search windows.
stronger=~currentConfirmed||best.snrDb>=det.snrDb(j)+3;
if ~stronger,track.pendingCount=0;track.reason='Holding confirmed point within 3 dB of strongest';return;end
if abs(best.distanceKm-track.pendingKm)<.001,track.pendingCount=track.pendingCount+1;
else,track.pendingKm=best.distanceKm;track.pendingCount=1;end
track.reason='Confirming stronger location across consecutive windows';
if track.pendingCount>=2,track=accept(track,best,now);end
end
function track=accept(track,c,now)
track.active=true;track.centerKm=c.distanceKm;track.regionKm=c.distanceKm;track.seed=c;
track.lastQualifiedTime=now;track.snrDb=c.snrDb;track.pendingCount=0;track.pendingKm=NaN;track.missingWindows=0;
track.reason='Strongest confirmed measured FFT-SNR location';
end
