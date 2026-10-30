"""Independent selected-position demodulation from append-only receiver IQ.

Output: 10 little-endian float64 values per accepted frame:
seq, tick, trigger, accepted ordinal, increment rad, AC phase rad,
spatial agreement, quality flags, center km, frame receive timestamp placeholder.
The last column is reserved (0); host time is in JSON publication metadata.
"""
from pathlib import Path
import argparse, json, time
import numpy as np
from rbs_selected_capture import publish_json
from rbs_continuous_phase import ContinuousPhase, LOW_AGREEMENT, TIME_GAP, NO_MEASUREMENT

def run(directory, seconds=0):
    root = Path(directory)
    raw = output = None
    session = None
    cursor = 0
    timer = time.monotonic()
    last_publish = 0
    last_batch = 0
    state = {}
    try:
        while not seconds or time.monotonic() - timer < seconds:
            if (root / 'SELECTED_STOP').exists() or (root / 'STOP').exists():
                break
            try:
                capture = json.loads((root / 'selected_capture.json').read_text())
            except (OSError, ValueError):
                time.sleep(.02)
                continue
            if capture['directory'] != session:
                if raw:
                    raw.close()
                    output.close()
                session = capture['directory']
                dest = Path(session)
                raw = (dest / 'selected_raw.bin').open('rb')
                # A worker restart creates a new complete replay, never truncates a prior result.
                name = 'waveform_' + str(time.time_ns()) + '.bin'
                output = (dest / name).open('wb', buffering=0)
                cursor = 0
                algorithm = ContinuousPhase(capture['centerBin'] - capture['firstBin'])
                state = dict(version=1, directory=session, file=name, recordDoubles=10, records=0,
                    centerKm=capture['centerKm'], receiverEpoch=capture['receiverEpoch'],
                    startedUnix=time.time(), running=True, timeGapFrames=0, sequenceGapFrames=0,
                    invalidPhaseFrames=0, lowAgreementFrames=0, interpolatedFrames=0,
                    cutoffHz=algorithm.cutoff, method='Measured spatial phase; causal stateful integration with 5 Hz high-pass and 225 Hz low-pass',
                    qualityDefinition='20m pair flags: 1 endpoint amplitude below gate, 2 time/accepted-frame gap, 4 no measurement, 8 initial reference, 16 near pi')
                last_sequence = None
            size = (Path(session) / 'selected_raw.bin').stat().st_size
            available = size // capture['recordBytes']
            count = min(512, available - cursor)
            if count <= 0 or (count < 32 and time.monotonic()-last_batch < .02):
                time.sleep(.005)
                continue
            payload = raw.read(count * capture['recordBytes'])
            count = len(payload) // capture['recordBytes']
            if not count:
                continue
            records = np.frombuffer(payload, dtype=np.uint8).reshape(count, capture['recordBytes'])
            seq = records[:, :8].copy().view('<u8').ravel()
            tail = records[:, -8:].copy().view('<u8').ravel()
            if not np.array_equal(seq, tail):
                raw.seek(cursor * capture['recordBytes'])
                time.sleep(.005)
                continue  # Append may still be in progress; retry, never skip a record.
            h = records[:, 8:56].copy().view('<u4').reshape(count, 12)
            samples = records[:, 56:-8].copy().view('<i2').reshape(count, capture['bins'], 2)
            iq = (samples[:, :, 0].astype(float) + 1j * samples[:, :, 1]) / capture['iqScale']
            ticks = h[:, 8].astype(np.int64) + (h[:, 9].astype(np.int64) << 32)
            ordinal = (h[:, 1].astype(np.int64) - h[:, 7].astype(np.int64)) & 0xffffffff
            inc, phase, agreement, flags = algorithm.process(iq, ticks, ordinal)
            steps = np.diff(np.r_[seq[0] - np.uint64(1) if last_sequence is None else last_sequence, seq].astype(np.int64))
            state['sequenceGapFrames'] += int(np.maximum(steps - 1, 0).sum())
            last_sequence = int(seq[-1])
            rows = np.column_stack((seq, ticks, h[:, 1], ordinal, inc, phase, agreement, flags,
                                    np.full(count, capture['centerKm']), np.zeros(count))).astype('<f8')
            if output.write(rows.tobytes()) != rows.nbytes:
                raise OSError('Incomplete waveform archive write')
            cursor += count
            last_batch = time.monotonic()
            state['timeGapFrames'] += int(np.sum((flags & TIME_GAP) != 0))
            state['invalidPhaseFrames'] += int(np.sum((flags & NO_MEASUREMENT) != 0))
            state['lowAgreementFrames'] += int(np.sum((flags & LOW_AGREEMENT) != 0))
            state.update(records=cursor, lastSequence=int(seq[-1]), lastTicks=int(ticks[-1]),
                         lastTrigger=int(h[-1, 1]), updatedUnix=time.time(),
                         pendingRawFrames=max(0, available - cursor),
                         receiverLastFrameUnix=capture.get('lastFrameUnix'),
                         receiverLastTicks=capture.get('lastTicks'))
            if time.monotonic()-last_publish >= .05:
                publish_json(root / 'selected_stream_status.json', state)
                publish_json(Path(session) / 'waveform_status.json', state)
                last_publish = time.monotonic()
    finally:
        if raw:
            raw.close()
            output.close()
        if state:
            state.update(running=False, updatedUnix=time.time())
            publish_json(root / 'selected_stream_status.json', state)

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--directory', required=True)
    ap.add_argument('--seconds', type=float, default=0)
    args = ap.parse_args()
    run(args.directory, args.seconds)
