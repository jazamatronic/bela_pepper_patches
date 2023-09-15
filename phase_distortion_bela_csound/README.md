# phase_distortion_bela_csound

A [Csound](https://csound.com) implementation of a Phase Distortion oscillator for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

Two flavours of phase distortion synthesis using pdhalf and pdhalfy

There are 12 waveforms to distort:
  * half sine
  * sine
  * square
  * sawtooth
  * even harmonics
  * cosine partials
  * double half sine
  * half sine + sine
  * half sine + square
  * half sine + saw
  * half sine + even harms
  * half sine + cosine partials

Includes detune, routed into distortion then filter 
       	oscs -> dist -> filt -> clip -> out
Fc can be modulated

Analog Inputs - always active:

  0. V/Oct - quantized to midi notes  
  1. Gate

Analog Inputs page 0:  

  2. Fc 
  3. Q
  4. Phase Distortion Amount
  5. Waveform
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
  2. Phase Distortion Style
  3. Oscillator Sync

Buttons page 1:  
  1. Exponential envelope
  2. Invert the envelope
  3. Portamento enable

Controls:  

![controls](https://github.com/jazamatronic/bela_pepper_patches/blob/main/phase_distortion_bela_csound/pd.png)
