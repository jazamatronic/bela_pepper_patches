# fbmcfm_bela_csound

A [Csound](https://csound.com) implementation of a Feedback Multi Carrier FM oscillator for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

A modulating oscillator has feedback, the amount of which is controlled by the beta parameter and the global env.  
Two detunable carriers are modulated by the fb osc with envelopped mod index i   
The sum of all three oscillators are output  
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
  4. Beta
  5. Modulation Index
  6. Detune
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
  3. Oscillator Sync

Buttons page 1:  
  1. Exponential envelope
  2. Invert the envelope
  3. Portamento enable

Controls:  

![controls](https://github.com/jazamatronic/bela_pepper_patches/blob/main/fbmcfm_bela_csound/fbmcfm.png)
