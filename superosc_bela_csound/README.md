# superosc_bela_csound

A [Csound](https://csound.com) implementation of a super saw oscillator for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

Up to 13 band-limited oscillator using pre-calculated wavetable oscillators playing in unison with detune.
Select between saw, square, tri, or pulse like waveforms

Analog Inputs - always active:

  0. V/Oct - quantized to midi notes  
  1. Gate

Analog Inputs page 0:  

  2. Fc 
  3. Q
  4. Number of oscillators 1 to 13
  5. Oscillator shape
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

![controls](https://github.com/jazamatronic/bela_pepper_patches/blob/main/superosc_bela_csound/superosc.png)
