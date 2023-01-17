# morphing_wavefolder_bela_csound

A [Csound](https://csound.com) implementation of a morphing waveshaper for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

3 wavetable oscillators playing in unison, with detune and drift parameters
Morph between sine, tri, saw or pulse like waveforms
Each oscillator is fed into a morphable wave shaping table
A sine wave sub oscillator is optionally included

Analog Inputs:  
  0. V/Oct - quantized to midi notes  
  1. VCA CV input when not in drone mode  
  2. Waveshaping amount CV
  3. Wave shape selection CV
  4. Wavefolding table selection CV
  5. Detune CV
  6. Drift CV
  7. L/R phase delay CV

Buttons:  
  0. Toggle Sub Osc
  1. Lock Osc Phase (resets detune/drift)
  2. Drone
  3. Invert the R output phase
