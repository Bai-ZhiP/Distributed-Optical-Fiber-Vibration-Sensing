"""Append every selected-position IQ frame before the receiver ring can wrap."""
from pathlib import Path
import json, os, struct, time

SCALE = 299792458 / (2 * 1.468 * 250e6 * 1000)

def publish_json(path, value):
    path = Path(path)
    temp = path.with_suffix('.tmp')
    temp.write_text(json.dumps(value, allow_nan=False), encoding='utf-8')
    try:
        os.replace(temp, path)
    except PermissionError:
        pass  # A brief Windows reader lock must not block packet reception.

class SelectedCapture:
    def __init__(self, directory):
        self.root = Path(directory)
        self.file = None
        self.meta = None
        self.center = None
        self.epoch = None
        self.count = 0

    def refresh(self, receiver):
        try:
            request = json.loads((self.root / 'selected_stream_request.json').read_text())
            center = float(request['distanceKm'])
            if not 0.15 <= center <= 32.5:
                return
        except (OSError, ValueError, KeyError, TypeError):
            return
        center_bin = round((center / SCALE - 12) / 25)
        center = (center_bin * 25 + 12) * SCALE
        if self.file is None or center != self.center or receiver['startedUnix'] != self.epoch:
            self.close()
            session = self.root / 'tracked_waveforms' / time.strftime('%Y%m%d_%H%M%S')
            session = session.with_name(session.name + '_' + str(time.time_ns() % 1000000000))
            session.mkdir(parents=True, exist_ok=False)
            first = max(0, min(3139, center_bin - 30))
            self.center, self.epoch, self.count = center, receiver['startedUnix'], 0
            self.meta = dict(version=1, directory=str(session), receiverEpoch=self.epoch,
                centerKm=center, centerBin=center_bin, firstBin=first, bins=61,
                recordBytes=8 + 48 + 4 * 61 + 8, iqScale=8, sampleClockHz=250000000,
                startedUnix=time.time(), firstSequence=None, records=0, running=True,
                persistence='Append-only selected raw IQ; OS write cache, no power-failure guarantee')
            self.file = (session / 'selected_raw.bin').open('ab', buffering=0)
            publish_json(session / 'metadata.json', self.meta)
        self.publish()

    def append(self, sequence, header, iq_bytes, tick, received_unix):
        if self.file is None:
            return
        lo = 4 * self.meta['firstBin']
        record = struct.pack('<Q', sequence) + header + iq_bytes[lo:lo + 244] + struct.pack('<Q', sequence)
        written = self.file.write(record)
        if written != len(record):
            raise OSError('Incomplete selected IQ archive write')
        self.count += 1
        if self.meta['firstSequence'] is None:
            self.meta['firstSequence'] = sequence
        self.meta.update(records=self.count, lastSequence=sequence, lastTicks=tick,
                         lastFrameUnix=received_unix)

    def publish(self):
        if self.meta:
            self.meta['updatedUnix'] = time.time()
            publish_json(Path(self.meta['directory']) / 'metadata.json', self.meta)
            publish_json(self.root / 'selected_capture.json', self.meta)

    def close(self):
        if self.file:
            self.file.close()
            self.file = None
            self.meta['running'] = False
            self.publish()
