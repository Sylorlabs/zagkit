# Experimental motion contract

Zagkit motion is driven by an explicit monotonic clock. Platform callbacks do
not define animation progress, so the same clock and event sequence must
produce the same track state and evidence on every backend.

## Units and ownership

- Values use signed 26.6 logical units; 64 units equal one density-independent
  logical pixel. Velocity uses those fixed-point units per second.
- Time uses monotonic microseconds supplied by the host or deterministic replay.
- A `MotionScheduler` owns every `MotionTrack`, copied keyframe, and retained
  `MotionEvent`. `motion_scheduler_free` releases that complete ownership tree.
- Stable positive track IDs reject duplicates before allocation.

## Scheduling truth

The scheduler records its active refresh rate and integer frame interval for
24 through 480 Hz. Refresh changes emit `refresh_rate_change`. A running track
causes `motion_needs_frame` and `MotionTickResult.request_next_frame` to return
true. When every track settles, later ticks perform no work, append no event,
and request no frame.

Clock regression and individual clock jumps over one second fail before time or
track mutation. Once motion is running, callers must advance time through
`motion_tick`; `motion_set_clock` cannot silently skip evaluation.

Every evaluated active frame emits an ordered `tick` reason. Starts,
interruptions, reversals, resize retargeting, gesture handoff, reduced-motion
substitution, and refresh changes retain their own reason and exact track state.

## Springs

Springs use deterministic integer semi-implicit integration in fixed one
millisecond steps. Sub-unit velocity and position remainders are retained so a
spring cannot stall because of integer truncation. Grouping identical elapsed
time into 60 Hz, 120 Hz, or irregular callbacks produces identical position
and velocity.

Retargeting preserves visible position and incoming velocity. Interruption,
reversal, and resize are semantic reasons for the same continuity operation.
Gesture handoff replaces position and velocity with the recognizer's exact
sample and continues toward the supplied target. When configured position and
velocity tolerances are both reached, the track snaps exactly to its target,
zeros velocity, and becomes idle.

## Keyframes

A keyframe timeline starts at zero microseconds, contains strictly increasing
times, and is copied into scheduler ownership. Linear interpolation reports
exact constant velocity within each segment and settles exactly on the final
value. Schedulers and timelines are each bounded to 4,096 tracks or samples,
and a timeline is bounded to 60 seconds; malformed order,
unsafe values, and unsafe segment velocity fail before ownership transfer.

Additional easing curves, keyframe interruption into a replacement timeline,
and spline velocity matching remain open.

## Reduced motion

Reduced motion is an explicit semantic substitution:

- spatial springs use `snap_to_end`;
- components may supply a separate `opacity_fade` keyframe timeline;
- an opacity substitute is limited to values from zero through one logical
  unit and a maximum duration of 250 milliseconds.

Zagkit does not multiply every duration by a global factor. A spatial spring
cannot be mislabeled as an opacity fade. Component-level substitutions and
their semantic equivalence still require conformance coverage before
`G3-REDUCED-MOTION` can be completed.

## Current boundary

This slice proves the deterministic headless kernel. It does not yet provide
layout or shared-transition orchestration, gesture recognition, platform vsync
adapters, bounded long-running event retention, easing families, visual
goldens, p99 frame evidence, 120 Hz device certification, or ten-minute stall
traces. Those remain required by the master goal and release gates.
