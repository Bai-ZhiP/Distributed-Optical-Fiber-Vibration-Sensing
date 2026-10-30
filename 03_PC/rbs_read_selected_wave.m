function [rows,cursor,key] = rbs_read_selected_wave(status,cursor,key,rows)
% Read every newly committed output sample; complete history stays on disk.
newKey=fullfile(status.directory,status.file);
if ~strcmp(key,newKey)
 if ~strcmp(fileparts(key),status.directory),cursor=max(0,status.records-3500);rows=zeros(0,10);end
 key=newKey;
end
count=status.records-cursor;if count<=0,return;end
f=fopen(key,'rb','ieee-le');assert(f>=0,'Selected waveform archive cannot be opened');guard=onCleanup(@() fclose(f)); %#ok<NASGU>
fseek(f,cursor*80,'bof');a=fread(f,[10 count],'double=>double')';
assert(size(a,1)==count,'Incomplete selected waveform publication');
rows=[rows;a];cursor=cursor+count;
keep=max(3500,count+500);if size(rows,1)>keep,rows=rows(end-keep+1:end,:);end
end
