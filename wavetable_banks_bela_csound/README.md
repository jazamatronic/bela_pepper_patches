# wavetable_banks_bela_csound

A [Csound](https://csound.com) implementation of a wavetable synth for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .

Heavily inspired by Synthesis Technology's [WaveEdit](https://github.com/AndrewBelt/WaveEdit) .  The Wavetable format is the same as WaveEdit, in fact you can use the tables supplied with it directly in this implementation .

I've not included any banks here but you can find a lot of them on the web - start with Adventure Kid's [AKWF](https://github.com/KristofferKarlAxelEkstrand/AKWF-FREE/tree/master/AKWF--Synthesis-Technology/Wavetables) tables .  Put them in the same directory as _main.csd and rename them sequentially starting from 1.wav.  Be sure to adjust ```gimaxbank``` parameter accordingly .  

Analog Inputs:  
  0. V/Oct - quantized to midi notes
  1. VCA CV input 
  2. X or Z CV, depending on mode
  3. Y or Z mod freq CV, depending on mode
  4. LP filter cutoff CV
  5. LP Q CV
  6. Sub Osc volume
  7. L/R phase delay CV

Buttons:  
  0. Toggle interpolation between tables - LED 1 on means interpolation is on
  1. Bank Select Down
  2. Bank Select UP
  3. Toggles Z or XY mode - LED 4 on means it's in XY mode
