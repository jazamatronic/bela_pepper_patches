# ks_bela_csound

A [Csound](https://csound.com) implementation of a Karplus-Strong plucked string for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

A user configurable mix of left input and noise is enveloped and fed into a feed-forward comb filter.
The output of the comb filter is then combined with the feedback signal and
input to a damping filter after passing through a dcblocker
The damped signal is fed into a variable delay who's length depends on freq

Signal path is configurable between 
      	oscs -> dist -> filt -> clip -> out
      	oscs -> filt -> dist -> clip -> out
Fc can be modulated

Analog Inputs - always active:

  0. V/Oct - quantized to midi notes  
  1. Gate

Analog Inputs page 0:  

  2. Fc 
  3. Q
  4. G - delay feedback gain
  5. Del1 - comb filter delay
  6. Damping
  7. Distortion

Analog Inputs page 1:  

  2. Attack 
  3. Decay
  4. Sustain
  5. Release
  6. Portamento
  7. Mix


Buttons:
  
  0. Page

Buttons page 0:  
  1. Fc mod enable
  2. Effect order toggle
  3. Invert the feedback gain G

Buttons page 1:  
  1. Exponential envelope
  2. Invert the envelope
  3. Portamento enable

