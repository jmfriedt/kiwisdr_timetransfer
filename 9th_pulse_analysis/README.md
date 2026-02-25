According to SAE9990/2 (see below), the 9th pulse starts 1000 us after the 8th
pulse and is positioned 0 to 160 us to encode the 32 possible bit values.

<img src="2026-02-25-190717_2704x1050_scrot.png">

When sampling at 12 kHz, 1 ms lasts 12 samples, so the 9th pulse position starts
12 samples after the 9th.

When sampling at 12 kHz, the sampling period is 83.33 us so that two delay values
are included in each subsequent sample, bit values 0 to 15 (delays 0 to 60 us) in
sample 13, and delay 100 us to 160 us in sample 14. The delay $\tau$ is detected
as a phase $\varphi$ through $\varphi=2\pi\cdot f\cdot\tau$ with $f$ the carrier
frequency 100 kHz.

Hence, each delay increment of 1.25 us is a phase increment of 45 degrees, and
the 0 to 7 bit values span 0 to 315 degrees. The second bit sequence separated by 
50.525 us starts at mod(50.625,10)=0.625 us which is a phase of 22.5 degrees and
the second set of bit values from 8 to 15 are detected as phase values separated
by 45 degrees but interleaved with the first set.

Finally, 101.25 on sample 14 is detected again as 45 degrees and same for the
last bit sequence.

The challenge in phase identification is that now the phases are only separated
by 22.5 degrees instead of the 36 degrees of the Eurofix.

The <a href="plot_9pulse_histo.m">plot_9pulse_histo.m</a> script simulates the 
expected phase distribution as a function of bit value.
