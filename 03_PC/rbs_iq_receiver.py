"""Receive genuine RBS2 FPGA datagrams into a bounded ring for MATLAB.
No synthetic data is generated. Run with --seconds for a finite verification.
"""
import argparse, socket, struct, time, json, os, collections
from pathlib import Path
from rbs_selected_capture import SelectedCapture

MAGIC=0x33425149
N=6400
SLOTS=8192
RECORD=8+48+2*N+8

def board_restarted(previous_tick, previous_trigger, tick, trigger, sample_rate):
    # Hardware ticks reset on boot. Allow small UDP reordering and trigger wrap.
    return (previous_tick is not None and previous_trigger is not None
            and tick + sample_rate < previous_tick
            and trigger < previous_trigger and trigger < 60000)

def run():
    global N,SLOTS,RECORD
    ap=argparse.ArgumentParser();ap.add_argument('--directory',default=str(Path(__file__).parent/'rbs_iq_live'))
    ap.add_argument('--seconds',type=float,default=0)
    ap.add_argument('--samples',type=int,default=N);ap.add_argument('--first-sample',type=int,default=0)
    ap.add_argument('--slots',type=int,default=SLOTS);ap.add_argument('--data-port',type=int,default=50005);ap.add_argument('--status-port',type=int,default=50006)
    args=ap.parse_args();N=args.samples;SLOTS=args.slots;RECORD=8+48+2*N+8
    assert 0<N<=160000 and args.first_sample>=0 and args.first_sample+N<=160000 and SLOTS>=2
    dest=Path(args.directory);dest.mkdir(parents=True,exist_ok=True)
    status={'version':2,'sampleCount':N,'slots':SLOTS,'recordBytes':RECORD,'complete':0,'datagrams':0,'malformed':0,'incomplete':0,'duplicates':0,'acceptedFrameGapCount':0,'outOfOrderCompleteFrames':0,'boardStatus':'','running':True}
    status['startedUnix']=time.time()
    status['selectedArchiveEnabled']=True
    selected=SelectedCapture(dest)
    status['firstSampleIndex']=args.first_sample
    status.update(format='IQ16',iqDecimation=25,iqScale=8,captureSamples=80000,connector='AD2_B',board='AX7350B + FL9613',matchedPulseNs=100,beatHz=80000000)
    parts=collections.OrderedDict();done=collections.deque();done_ids=set()
    data=socket.socket(socket.AF_INET,socket.SOCK_DGRAM);data.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,64*1024*1024)
    data.bind(('172.18.9.10',args.data_port));data.settimeout(.05)
    stat=socket.socket(socket.AF_INET,socket.SOCK_DGRAM);stat.bind(('172.18.9.10',args.status_port));stat.setblocking(False)
    status['receiveBufferBytes']=data.getsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF)
    def publish():
        status['updatedUnix']=time.time()
        temp=dest/'status.tmp';temp.write_text(json.dumps(status),encoding='utf-8')
        try:
            os.replace(temp,dest/'status.json')
        except PermissionError:
            # Windows readers can briefly prevent replacing an open status file.
            # Keep receiving; the next publication carries all accumulated counts.
            pass
    start=time.monotonic();lastpub=0;last_accepted_ordinal=None
    with (dest/'frames.ring').open('w+b',buffering=0) as out:
        out.truncate(SLOTS*RECORD);publish()
        try:
            while not args.seconds or time.monotonic()-start<args.seconds:
                # Keep filesystem and status-socket work out of the packet hot path.
                # At 125 traces/s the data socket delivers about 27,000 packets/s.
                if time.monotonic()-lastpub>.2:
                    if (dest/'STOP').exists():break
                    selected.refresh(status)
                    try:
                        while True:
                            d,peer=stat.recvfrom(2048)
                            if peer[0]=='172.18.9.11':status['boardStatus']=d.decode('ascii',errors='replace')
                    except BlockingIOError:pass
                    publish();lastpub=time.monotonic()
                try:d,peer=data.recvfrom(65535)
                except socket.timeout:d=b''
                if d:
                    status['datagrams']+=1
                    if len(d)<48 or peer[0]!='172.18.9.11':status['malformed']+=1;continue
                    h=struct.unpack_from('<12I',d);magic,fid,off,n,fs,flags,total,skip,lo,hi,prf,res=h
                    if magic!=MAGIC or total!=N or res!=25 or fs!=250000000 or flags&~15 or (flags&12)!=12 or n<1 or n>600 or off+n>N or off%600 or n!=min(600,N-off) or len(d)!=48+2*n or bool(flags&1)!=(off==0) or bool(flags&2)!=(off+n==N):
                        status['malformed']+=1;continue
                    if fid in done_ids:status['duplicates']+=1;continue
                    meta=(fid,fs,total,skip,lo,hi,prf)
                    if fid not in parts:
                        if len(parts)>=16:parts.popitem(last=False);status['incomplete']+=1
                        parts[fid]=[meta,bytearray(2*N),set(),d[:48]]
                    item=parts[fid]
                    if item[0]!=meta:status['malformed']+=1;continue
                    if off in item[2]:
                        status['duplicates']+=1
                        if item[1][2*off:2*(off+n)]!=d[48:]:status['malformed']+=1
                        continue
                    item[1][2*off:2*(off+n)]=d[48:];item[2].add(off)
                    if len(item[2])==(N+599)//600:
                        if board_restarted(status.get('lastTicks'),status.get('lastTrigger'),
                                           (hi<<32)|lo,fid,fs):
                            status.update(startedUnix=time.time(),complete=0,
                                          boardRestarts=status.get('boardRestarts',0)+1)
                            last_accepted_ordinal=None
                            done.clear();done_ids.clear()
                            parts.clear();parts[fid]=item
                        # Header ID minus skipped-trigger count advances once per
                        # accepted capture. This also exposes a missing entire UDP
                        # frame, which cannot enter the partial-packet timeout path.
                        ordinal=(fid-skip)&0xffffffff
                        if last_accepted_ordinal is not None:
                            step=(ordinal-last_accepted_ordinal)&0xffffffff
                            if 0<step<0x80000000:
                                status['acceptedFrameGapCount']+=step-1
                                last_accepted_ordinal=ordinal
                            else:
                                status['outOfOrderCompleteFrames']+=1
                        else:last_accepted_ordinal=ordinal
                        seq=status['complete']+1;pos=((seq-1)%SLOTS)*RECORD
                        out.seek(pos);out.write(struct.pack('<Q',0));out.write(item[3]);out.write(item[1]);out.write(struct.pack('<Q',seq))
                        out.seek(pos);out.write(struct.pack('<Q',seq))
                        status.update(complete=seq,lastTrigger=fid,skippedTriggers=skip,lastTicks=(hi<<32)|lo,lastFrameUnix=time.time())
                        selected.append(seq,item[3],item[1],(hi<<32)|lo,status['lastFrameUnix'])
                        if seq==1:
                            (dest/'first_frame.bin').write_bytes(item[3]+item[1])
                        done.append(fid);done_ids.add(fid)
                        if len(done)>256:done_ids.remove(done.popleft())
                        del parts[fid]
        finally:
            selected.close()
            status['running']=False;publish();data.close();stat.close()
    print(json.dumps(status),flush=True)
if __name__=='__main__':run()
