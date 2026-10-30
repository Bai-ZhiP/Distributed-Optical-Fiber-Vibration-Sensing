"""Measured spatial phase and a causal stateful band-limited AC phase integrator.

Quality flags accompany every accepted frame. No interpolation, target tone,
window re-integration, or deletion of low-agreement measured estimates.
"""
import numpy as np

LOW_AGREEMENT = 1
TIME_GAP = 2
NO_MEASUREMENT = 4
INITIAL_REFERENCE = 8
NEAR_PI = 16

def spatial_estimates(iq, previous, center):
    # Local 20.42 m pair. No spatial mixing across the return edge.
    prior = np.vstack((previous[None, :], iq[:-1]))
    left, right = center-1, center+1
    value = np.angle((iq[:,right]*prior[:,right].conj())
                     * (iq[:,left]*prior[:,left].conj()).conj())
    amplitude_ok = ((abs(iq[:,left])>=6)&(abs(iq[:,right])>=6)
                    &(abs(prior[:,left])>=6)&(abs(prior[:,right])>=6))
    no_measurement = ((abs(iq[:,left])==0)|(abs(iq[:,right])==0)
                      |(abs(prior[:,left])==0)|(abs(prior[:,right])==0))
    value[no_measurement] = np.nan
    return value, amplitude_ok.astype(float), (~no_measurement).astype(int)

class ContinuousPhase:
    def __init__(self, center_bin_in_roi=30, cutoff_hz=5.0, sample_rate_hz=1000.0):
        self.center = center_bin_in_roi
        self.cutoff = cutoff_hz
        self.previous = None
        self.last_tick = None
        self.last_ordinal = None
        self.y = 0.0
        self.initialized = False
        self.filters = []
        self.sample_rate = sample_rate_hz
        for j, q in enumerate((0.541196100146197, 1.306562964876377)):
            k = np.tan(np.pi * cutoff_hz / sample_rate_hz)
            norm = 1 / (1 + k / q + k*k)
            # First high-pass section cancels the integrator's (1-z^-1)
            # analytically, avoiding an unbounded numerical accumulator.
            b = np.array([1, -1, 0] if j == 0 else [1, -2, 1]) * norm
            a = np.array([2*(k*k-1)*norm, (1-k/q+k*k)*norm])
            self.filters.append([b, a, np.zeros(2)])
        k = np.tan(np.pi * min(225,.45*sample_rate_hz) / sample_rate_hz);q = 1/np.sqrt(2);norm = 1/(1+k/q+k*k)
        self.filters.append([np.array([1,2,1])*k*k*norm,
                             np.array([2*(k*k-1)*norm,(1-k/q+k*k)*norm]),np.zeros(2)])

    def filter_increment(self, value):
        for b, a, state in self.filters:
            y = b[0] * value + state[0]
            state[0] = b[1] * value - a[0] * y + state[1]
            state[1] = b[2] * value - a[1] * y
            value = y
        return value

    def reset_filters(self):
        for _, _, state in self.filters:
            state[:] = 0

    def process(self, iq, ticks, ordinals):
        iq = np.asarray(iq, dtype=np.complex128)
        ticks = np.asarray(ticks, dtype=np.int64)
        ordinals = np.asarray(ordinals, dtype=np.int64)
        first = self.previous is None
        inc, agreement, contributors = spatial_estimates(iq, iq[0] if first else self.previous, self.center)
        flags = np.zeros(len(ticks), dtype=np.uint32)
        flags[(agreement < .9) | (contributors < 1)] |= LOW_AGREEMENT
        flags[abs(inc) >= .8 * np.pi] |= NEAR_PI
        phase = np.empty(len(ticks))
        for k in range(len(ticks)):
            if first and k == 0:
                # Differential phase has an arbitrary initial reference, not a lost frame.
                inc[k], phase[k], self.y = 0.0, 0.0, 0.0
                flags[k] |= INITIAL_REFERENCE
                self.initialized = True
            else:
                delta = (int(ticks[k]) - self.last_tick) / 250e6
                step = (int(ordinals[k]) - self.last_ordinal) & 0xffffffff
                if delta <= 0 or delta >= 1.5/self.sample_rate or step != 1:
                    flags[k] |= TIME_GAP
                if not np.isfinite(inc[k]) or flags[k] & TIME_GAP:
                    phase[k] = np.nan
                    flags[k] |= NO_MEASUREMENT
                    self.initialized = False
                else:
                    if not self.initialized:
                        self.y = 0.0
                        self.reset_filters()
                        flags[k] |= INITIAL_REFERENCE
                        self.initialized = True
                    # Causal integration combined with a 4th-order 5 Hz high-pass
                    # and 2nd-order 225 Hz low-pass, preserving state across chunks.
                    self.y = self.filter_increment(inc[k])
                    phase[k] = self.y
            if not np.isfinite(inc[k]):
                flags[k] |= NO_MEASUREMENT
                phase[k] = np.nan
            self.last_tick, self.last_ordinal = int(ticks[k]), int(ordinals[k])
        self.previous = iq[-1].copy()
        return inc, phase, agreement, flags
