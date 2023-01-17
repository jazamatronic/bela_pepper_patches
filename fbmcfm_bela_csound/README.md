# fbmcfm_bela_csound

A [Csound](https://csound.com) implementation of a feedback multi carrier FM oscillator for [Bela Pepper](https://learn.bela.io/products/modular/pepper/) .  

The modulating oscillator has feedback, the amount is controlled by the beta parameter and the global envelope.  
Two detunable carriers are modulated by the fb osc with mod index i.  

The global envelope can be either linear or exponential. By default it controls beta and the output amplitude.   

The sum of all three oscillators are fed into a filter/distortion chain and then to the output.  
Will also pass through audio from the left in channel.  The osc/in mix can be controlled.

Signal path is configurable between   
      	oscs/in mix -> dist -> filt -> clip -> out  
      	oscs/in mix -> filt -> dist -> clip -> out  

Filter cutoff and Q can be modulated via the CV ins.  

There are two pages of params, cycle the page with the leftmost button on Pepper.  The first led indicates the page.

Analog Inputs availble on both pages:  
  0. V/Oct - quantized to midi notes  
  1. Gate signal  

Analog Inputs on page 1:  
  2. Filter cutoff  
  3. Filter Q  
  4. fm feedback parameter beta  
  5. fm modulation index i  
  6. Detune  
  7. Distortion  

Buttons on page 1:  
  1. Enable filter cutoff modulation by the internal envelope  
  2. Swap Filter/Distortion order  
  3. Lock Osc Phase (resets detune)  

Analog Inputs on page 2:  
  2. Attack time  
  3. Decay time  
  4. Sustain level  
  5. Release time  
  6. Portamento time  
  7. Input/Osc mix  

Buttons on page 2:  
  1. Toggle between linear and exponential envelopes  
  2. Invert the envelope  
  3. Enable portamento  


