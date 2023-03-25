# vosimosc_bela_csound

A [Csound](https://csound.com) implementation of a vocal simulation with formant characteristics for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

3 vosim oscillators playing in unison, with detune.
Control over formant frequency, pulse count and pulse factor, all of which can be modulated by the global envelope

Analog Inputs - always active:

  0. V/Oct - quantized to midi notes  
  1. Gate

Analog Inputs page 0:  

  2. Formant freq 
  3. Decay
  4. Pulse count
  5. Pulse factor
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
  1. Formant mod enable
  2. Pulse count mod enable
  3. Pulse factor mod enable

Buttons page 1:  
  1. Exponential envelope
  2. Invert the envelope
  3. Portamento enable

Controls:  

![controls](https://github.com/jazamatronic/bela_pepper_patches/blob/main/vosimosc_bela_csound/vosimosc.png)
