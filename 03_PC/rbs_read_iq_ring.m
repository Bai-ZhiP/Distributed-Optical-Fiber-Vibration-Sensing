function [iq,h,seq,bad] = rbs_read_iq_ring(dataDir,stat,first,last,binIndices)
% Bulk read committed ring records; no change to the independent receiver.
if nargin<5,binIndices=1:stat.sampleCount/2;end
count=max(0,last-first+1);iq=complex(zeros(numel(binIndices),count));h=zeros(12,count);seq=first:last;bad=0;
if count==0,return;end
f=fopen(fullfile(dataDir,'frames.ring'),'rb','ieee-le');assert(f>=0,'Cannot open IQ ring');guard=onCleanup(@() fclose(f)); %#ok<NASGU>
words=stat.recordBytes/4;raw=zeros(words,count,'uint32');done=0;
while done<count
 slot=mod(first+done-1,stat.slots);take=min(count-done,stat.slots-slot);
 fseek(f,slot*stat.recordBytes,'bof');a=fread(f,[words take],'*uint32');
 assert(size(a,2)==take,'Short IQ ring read');raw(:,done+(1:take))=a;done=done+take;
end
head=double(raw(1,:))+double(raw(2,:))*2^32;tail=double(raw(end-1,:))+double(raw(end,:))*2^32;
h=double(raw(3:14,:));ok=head==seq&tail==seq&h(1,:)==hex2dec('33425149')&h(7,:)==stat.sampleCount&h(12,:)==25;
bad=sum(~ok);h=h(:,ok);seq=seq(ok);
samples=reshape(typecast(reshape(raw(15:end-2,ok),[],1),'int16'),stat.sampleCount,[]);
iq=complex(double(samples(2*binIndices-1,:)),double(samples(2*binIndices,:)))/stat.iqScale;
end
