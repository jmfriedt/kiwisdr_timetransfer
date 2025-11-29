## eLORAN digital payload decoding

# Recoring: ``command.sh``

A 15-min long record was collected from the KiwiSDR station G0GHK 
whose coordinates are documented in <a href="G0GHK.txt">G0GHK.txt</a>,
close enough to Anthorn to provide excellent SNR. The record
is 20251014T122009Z_100000_G0GHK_iq.wav.

# Pulse detection: ``process_eloran.m``

The pulses are alternating Master and Secondary. We observe that all Master
pulses exhibit 0 or 90 degree phases, i.e. no +/- 1 us shift indicating 
digital payload content. Only secondary pulses include +/-36 degrees phase
shift since +/-1 us at 100 kHz carrier is +/- 36 degrees phase shift.
Attributing +/- 36 phase shift to +/-1 bit state leads to two possible
schemes, and accumulating the bits left to right or right to left to
another 2, hence 4 resulting files.

# CRC detection: ``crc_eloran.m``

As known from RDS analysis, a continuous stream of bit requires 
synchronization, and sliding CRC calculation untile a match
is detected is one way of detecting the beginning of sentences
in the absence of a synchronization word. Again many degrees of
freedom in swapping the polynomial coefficients, bit order or
remainder order.

At the end, many more matches than expected are provided with
``crc_eloran.m``, but few enough are 210 bits apart. The
result is the file <a href="crc_eloran.txt">crc_eloran.txt</a>
where sentences not 210 bits from their neigbours have been 
deleted.
