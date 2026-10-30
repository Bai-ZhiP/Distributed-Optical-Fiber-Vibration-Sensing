function [wave,metadata] = Read_DAS_Tracked_Waveform(sessionDirectory,lastSeconds)
% Read recorded full-rate waveform; defaults to latest session and last 60 s.
root=fileparts(mfilename('fullpath'));
if nargin<1||isempty(sessionDirectory)
 metadata=jsondecode(fileread(fullfile(root,'rbs_iq_live','selected_stream_status.json')));
else
 metadata=jsondecode(fileread(fullfile(sessionDirectory,'waveform_status.json')));
end
if nargin<2,lastSeconds=60;end
count=metadata.records;if isfinite(lastSeconds),count=min(count,max(1,ceil(lastSeconds*500)));end
f=fopen(fullfile(metadata.directory,metadata.file),'rb','ieee-le');assert(f>=0,'Cannot open stored waveform');guard=onCleanup(@() fclose(f)); %#ok<NASGU>
first=fread(f,[10 1],'double');fseek(f,(metadata.records-count)*80,'bof');a=fread(f,[10 count],'double')';
wave=struct('timeSeconds',(a(:,2)-first(2))/250e6,'hardwareTicks',a(:,2),...
 'receiverSequence',a(:,1),'trigger',a(:,3),'acceptedOrdinal',a(:,4),...
 'incrementRadians',a(:,5),'acPhaseRadians',a(:,6),'spatialAgreement',a(:,7),...
 'qualityFlags',uint32(a(:,8)),'distanceKm',a(:,9));
end
