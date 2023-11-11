# chord_machine_bela_csound

A [Csound](https://csound.com) implementation of a chord machine for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

A set of up to 8 virtual analog VCOs are triggered.  
The notes selected depend on the midi input root note, the chord style and the inversion selected via the CVs.  

There are 10 chords to select from:
  * major	  
  * minor 	  
  * diminished   
  * augmented	  
  * major_sixth  
  * major_seventh
  * dom_seventh  
  * minor_seventh
  * sus4	  
  * sus2	  

Pick one of three inversions.  
Note order can also be CV selected.  

Analog Inputs - always active:

  0. V/Oct - quantized to midi notes  
  1. Gate

Analog Inputs page 0:  

  2. Chord
  3. Inversion
  4. Note Order
  5. Note Delay
  6. Delay Decay
  7. Osc PW

Analog Inputs page 1:  

  2. Attack 
  3. Decay
  4. Drift Amount
  5. Drift Frequency
  6. Phaser Frequency
  7. Phaser Amount


Buttons:
  
  0. Page
  1. Cycle Waveform (square/saw/half cosine thing)

Buttons page 0:  
  2. Add an Octave
  3. Gate or Trigger mode

Buttons page 1:  
  2. Exponential envelope
  3. Cycle number of Phaser stages

Controls:  

![controls](https://github.com/jazamatronic/bela_pepper_patches/blob/main/chord_machine_bela_csound/chord_machine.png)
