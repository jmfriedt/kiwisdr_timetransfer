# eLORAN digital payload decoding

## Recording: ``command.sh``

A 15-min long record was collected from the KiwiSDR station G0GHK 
whose coordinates are documented in <a href="G0GHK.txt">G0GHK.txt</a>,
close enough to Anthorn to provide excellent SNR. The record
is 20251014T122009Z_100000_G0GHK_iq.wav.

## Pulse detection: ``process_eloran.m``

The pulses are alternating Master and Secondary. We observe that all Master
pulses exhibit 0 or 90 degree phases, i.e. no +/- 1 us shift indicating 
digital payload content. Only secondary pulses include +/-36 degrees phase
shift since +/-1 us at 100 kHz carrier is +/- 36 degrees phase shift.
Attributing +/- 36 phase shift to +/-1 bit state leads to two possible
schemes, and accumulating the bits left to right or right to left to
another 2, hence 4 resulting files.

## Preliminary analysis: bit organization ``imagescall.m``

Some reasonable pattern appears when mapping bit states 
reorganized as matrices with 210 elements (sentence length 
including payload, CRC and FEC):

<img src="maps1.png">
<img src="maps2.png">

Each message is 210 bit long, each GRI (67.31 ms for Anthorn) broadcasts 
7 bits so the duration between each sentence is $67.31*(210/7)=2.02$ s

## CRC detection: ``crc_eloran.m``

As known from RDS [1] analysis, a continuous stream of bit requires 
synchronization, and sliding CRC calculation until a match
is detected is one way of detecting the beginning of sentences
in the absence of a synchronization word. Again many degrees of
freedom in swapping the polynomial coefficients, bit order or
remainder order.

At the end, many more matches than expected are provided with
``crc_eloran.m``, but few enough are 210 bits apart. The
result is the file <a href="crc_eloran.txt">crc_eloran.txt</a>
where sentences *not* 210 bits from their neigbours have been 
deleted.

## Payload analysis

According to <a href="https://www.reelektronika.nl/manuals/reelektronika_Differential_eLoran_Manual_v1.0.pdf">the reelektronika manual</a> on page 46, the sentence 
0110 is LORAN UTC message, whos <a href="https://www.reelektronika.nl/manuals/reelektronika_LORADD_UTC_Manual_v1.21.pdf">format is described in this manual</a> or these <a href="https://www.loran.org/proceedings/Meeting2005/Session%204%20-%20Timing,%20Differential%20Loran/Helwig-Implementation%20of%20a%20UTC%20Service%20on%20the%20NELS.pdf">slides</a> and reproduced below. 

Thanks to this information, the bitstreams

```
01100100111000100110111111110011100000000000011011000000
01101001100111101101110100001011100001110110101101001100
01100100001101010000000110001011100000000000011011000000
01101001011110111010001001001011100001110110101101001100
``` 

is analyzed as
* 0110: LORAN UTC (must be 0110)
* 01: message subtype (must be 01 or 10)
* 00111000100110111111110011100: time at master/secondary in hours (in 10 us
  unit): ``bin2dec(fliplr("00001101010000000110001011100"))*1e-5`` 
  indicates 1216.2486 and then 1220.2872, consistent with 2.02 seconds/message
  (16.24 to 20.28 after 2 sentences) and with minutes around 20 in the hour (see 
  .wav filename)
* 00000000001101: hour of year (13): ``bin2dec(fliplr("00000000001101"))`` indicates
  11264 hours (should be 6902 for october 14 at 14 UTC ???)
* 100000: year 1 ???
* 0: spare

or for message subtype 2:
* 0110: LORAN UTC
* 10: message subtype
* 01100111101101110100001011100: time at master/secondary in hours (in 10 us
  unit): ``bin2dec(fliplr("01100111101101110100001011100"))*1e-5=1218.2679``
  consistent with the previous value
* 0011101101: precise time in 10 ns units (``bin2dec(fliplr("0011101101"))*0.01=7.32`` us)
* 011010011: leap seconds (-54) (should be 37 ???)
* 00: leap second change

<img src="utc.png">

Message 13 is described in https://www.telecom-sync.com/files/pdfs/itsf/2014/Day1/1430-charles_curry2.pdf

**TODO: hour of year, year and leap second fields are incorrectly decoded**

**TODO: add FEC correction**

[1] p.14 of <a href="http://jmfriedt.free.fr/EN50067_RDS_Standard.pdf">
Specification of the radio data system (RDS) for VHF/FM sound broadcasting
in the frequency range from 87,5 to 108,0 MHz</a> states: "The beginnings
and ends of the data blocks may be recognized in the receiver decoder by
using the fact that the error-checking decoder will, with a high level of
confidence, detect block synchronisation slip as well as additive errors.
This system of block synchronisation is made reliable by the addition of
the offset words (which also serve to identify the blocks within the group)."
