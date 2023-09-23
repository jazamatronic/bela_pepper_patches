; Originally from:
; TR-808.csd - http://iainmccurdy.org/CsoundRealtimeExamples/Cabbage/Instruments/DrumMachines/TR-808.csd
; Written by Iain McCurdy, 2012 with the following license:
;
;Attribution-NonCommercial-ShareAlike 4.0 International
;Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
;NonCommercial - You may not use the material for commercial purposes.
;ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
;https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
;
; Modified for Bela Pepper by Jared Anderson, 2023

<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

giexp0 		= 0.0001
giparamport 	= 0.01
giparamthresh	= 0.05
gigatethresh	= 0.1
gimaxdec	= 2
gichdec 	= 0.2
gimaxtune	= 2
gimaxbend	= 12

/*
 * From https://github.com/BelaPlatform/bela-pepper/wiki/Pin-numbering
 *
 * LED output pins are as follows from left to right:
 * PD: 17, 18, 21, 13, 14, 11, 12, 15, 16, 19
 * C++: 6, 7, 10, 2, 3, 0, 1, 4, 5, 8
 * 
 * Buttons input pins:
 * PD: 26, 25, 24, 23
 * CPP: 15. 14. 13. 12
 * 
 * Trigger input pins when configured on the back (shared with the buttons):
 * PD: 26, 25, 24, 23
 * CPP: 15, 14, 13, 12
 */

gibtn0 = 15
gibtn1 = 14
gibtn2 = 13
gibtn3 = 12

giled_page2   = 6
giled_page1   = 7
giled_page0   = 10
giled_pan     = 2
giled_btn2    = 3
giled_btn3    = 0
giled_id0     = 8
giled_id1     = 5
giled_id2     = 4
giled_id3     = 1

gisine	ftgen 0, 0, 1024, 10, 1

gicos	ftgen 0, 0, 4096, 9, 1, 1, 90

ginextfree vco2init 8; do it here so it doesn't cause trouble with the instruments?
 
; try and avoid overloading Bela by only allowing a single instance of each instrument
prealloc 2, 1
prealloc 3, 1
prealloc 4, 1
prealloc 5, 1
maxalloc 2, 1
maxalloc 3, 1
maxalloc 4, 1
maxalloc 5, 1


#include "../udos/pages_buttons_params.udo"

; multi pages

; Buttons:
;   1. Page
;   2. Pan (Center or BD L, SN R)
;   3. On performance page adjust distortion
;   4. Trigger voice 
;
; Page zero Kick params:
;   two: Decay	three: Tuning
;   four: Bend	five: Attack and Body mix
;   six: Vol 	seven: Distortion
;
; Page one Snare params:
;   two: Decay	three: Tuning
;   four: Bend	five: Noise and Body mix
;   six: Vol 	seven: Distortion
;
; Page two Open Hi Hat params:
;   two: Decay	three: Tuning
;   four: OscPW five: Noise and Body mix
;   six: Vol 	seven: Distortion
;   
; Page three Closed Hi Hat params:
;   two: Decay	three: Tuning
;   four: OscPW	five: Noise and Body mix
;   six: Vol 	seven: Distortion
;   
; Page four performance
;   zero: BD trig one: SN trig
;   two:  OH trig three: CH trig
;   four: BD Dec  five: SN Dec
;   six:  OH Dec  seven: CH Dec
;
; or with btn 3 depressed
;
;   four: BD Dist  five: SN Dist
;   six:  OH Dist  seven: CH Dist
;
;
; IO trigger
instr 1

  digiOutBela 0, giled_id0
  digiOutBela 0, giled_id1
  digiOutBela 0, giled_id2
  digiOutBela 1, giled_id3

  kpage	     init     0
  
; bela buttons
  kpagebtn  digiInBela gibtn0

  kpage	    page_incr_count_wrap kpagebtn, 5

  kbtn1	    digiInBela gibtn1
  gkbdpan   toggle_buttonk, kbtn1

  kbtn2	    digiInBela gibtn2
  kbtn3	    digiInBela gibtn3

  if (kbtn2 == 1 && kpage == 4) then
    kpage += 1
  endif

  digiOutBela kpage & 4,  giled_page2
  digiOutBela kpage & 2,  giled_page1
  digiOutBela kpage & 1,  giled_page0
  digiOutBela gkbdpan,	  giled_pan  
  digiOutBela kbtn2,	  giled_btn2  
  digiOutBela kbtn3,	  giled_btn3  

; bela CV inputs
  acv0   chnget  "analogIn0"
  acv1   chnget  "analogIn1"
  acv2   chnget  "analogIn2"
  acv3   chnget  "analogIn3"
  acv4   chnget  "analogIn4"
  acv5   chnget  "analogIn5"
  acv6   chnget  "analogIn6"
  acv7   chnget  "analogIn7"

  kcv2 = k(acv2)
  kcv3 = k(acv3)
  kcv4 = k(acv4)
  kcv5 = k(acv5)
  kcv6 = k(acv6)
  kcv7 = k(acv7)

  kdecp1    locked_param kcv2, 0.75,  0, kpage, giparamthresh
  gktune1   locked_param kcv3, 0.25,  0, kpage, giparamthresh
  kbend1    locked_param kcv4, 0.5,   0, kpage, giparamthresh
  gkmix1    locked_param kcv5, 0.75,  0, kpage, giparamthresh
  kvol1	    locked_param kcv6, 0.75,  0, kpage, giparamthresh
  kdistp1   locked_param kcv7, 0,     0, kpage, giparamthresh
  
  kdecp2    locked_param kcv2, 0.75,  1, kpage, giparamthresh
  gktune2   locked_param kcv3, 0.25,  1, kpage, giparamthresh
  kbend2    locked_param kcv4, 0.5,   1, kpage, giparamthresh
  gkmix2    locked_param kcv5, 0.5,   1, kpage, giparamthresh
  kvol2	    locked_param kcv6, 0.75,  1, kpage, giparamthresh
  kdistp2   locked_param kcv7, 0,     1, kpage, giparamthresh

  kdecp3    locked_param kcv2, 0.25,  2, kpage, giparamthresh
  gktune3   locked_param kcv3, 0.25,  2, kpage, giparamthresh
  gkpw3	    locked_param kcv4, 0.5,   2, kpage, giparamthresh
  gkmix3    locked_param kcv5, 0.5,   2, kpage, giparamthresh
  kvol3	    locked_param kcv6, 0.75,  2, kpage, giparamthresh
  kdistp3   locked_param kcv7, 0,     2, kpage, giparamthresh

  kdecp4    locked_param kcv2, 0.25,  3, kpage, giparamthresh
  gktune4   locked_param kcv3, 0.25,  3, kpage, giparamthresh
  gkpw4	    locked_param kcv4, 0.5,   3, kpage, giparamthresh
  gkmix4    locked_param kcv5, 0.5,   3, kpage, giparamthresh
  kvol4	    locked_param kcv6, 0.75,  3, kpage, giparamthresh
  kdistp4   locked_param kcv7, 0,     3, kpage, giparamthresh
  
  kdeca1    locked_param kcv4, 0.75,  4, kpage, giparamthresh
  kdeca2    locked_param kcv5, 0.75,  4, kpage, giparamthresh
  kdeca3    locked_param kcv6, 0.25,  4, kpage, giparamthresh
  kdeca4    locked_param kcv7, 0.25,  4, kpage, giparamthresh

  kdista1   locked_param kcv4, 0,     5, kpage, giparamthresh
  kdista2   locked_param kcv5, 0,     5, kpage, giparamthresh
  kdista3   locked_param kcv6, 0,     5, kpage, giparamthresh
  kdista4   locked_param kcv7, 0,     5, kpage, giparamthresh

  kdec1 = kdecp1
  kdec2 = kdecp2
  kdec3 = kdecp3
  kdec4 = kdecp4
  gkdist1 = kdistp1
  gkdist2 = kdistp2
  gkdist3 = kdistp3
  gkdist4 = kdistp4
  if (kpage == 0) then
    ktrigbtn1 trigger kbtn3, gigatethresh, 0
  elseif (kpage == 1) then 
    ktrigbtn2 trigger kbtn3, gigatethresh, 0
  elseif (kpage == 2) then 
    ktrigbtn3 trigger kbtn3, gigatethresh, 0
  elseif (kpage == 3) then 
    ktrigbtn4 trigger kbtn3, gigatethresh, 0
  else
    kgate1 = k(acv0)
    kgate2 = k(acv1)
    kgate3 = k(acv2)
    kgate4 = k(acv3)
    kdec1 = kdeca1
    kdec2 = kdeca2
    kdec3 = kdeca3
    kdec4 = kdeca4
    gkdist1 = kdista1
    gkdist2 = kdista2
    gkdist3 = kdista3
    gkdist4 = kdista4
  endif


  ;BD trigger
  ktrig1 trigger kgate1, gigatethresh, 0
  if (ktrig1 == 1 || ktrigbtn1 == 1) then
    turnoff2 2, 0, 0 ; can only smack it once
    event "i", 2, 0, kdec1, kvol1, kbend1
  endif
  
  ;SN trigger
  ktrig2 trigger kgate2, gigatethresh, 0
  if (ktrig2 == 1 || ktrigbtn2 == 1) then
    turnoff2 3, 0, 0 ; can only smack it once
    event "i", 3, 0, kdec2, kvol2, kbend2
  endif

  ;OH trigger
  ktrig3 trigger kgate3, gigatethresh, 0
  if (ktrig3 == 1 || ktrigbtn3 == 1) then
    turnoff2 4, 0, 0 ; can only smack it once
    turnoff2 5, 0, 0 ; mute group for hats
    event "i", 4, 0, kdec3, kvol3
  endif
  
  ;CH trigger
  ktrig4 trigger kgate4, gigatethresh, 0
  if (ktrig4 == 1 || ktrigbtn4 == 1) then
    turnoff2 5, 0, 0 ; can only smack it once
    turnoff2 4, 0, 0 ; mute group for hats
    event "i", 5, 0, kdec4, kvol4
  endif
  
endin

instr 2    ;BASS DRUM

  idur	    = p3 * gimaxdec
  ibendur   = idur * 0.2
  ibendmult = p5 * gimaxbend
  ktune	    = gktune1 * gimaxtune

  ;SUSTAIN AND BODY OF THE SOUND
  kmul	transeg 0.2, idur*0.5, -15, 0.01, idur*0.5, 0, 0  ;PARTIAL STRENGTHS MULTIPLIER USED BY GBUZZ. DECAYS FROM A SOUND WITH OVERTONES TO A SINE TONE.                   
  kbend transeg 1, ibendur, -1, 0			  ;SLIGHT PITCH BEND AT THE START OF THE NOTE 
  abody gbuzz   0.75, 40 * octave(ktune) * semitone(ibendmult * kbend), 20, 1, kmul, gicos        ;GBUZZ TONE
  
  aenv1 expsega	giexp0, 0.004, 1, (idur - 0.004), giexp0
  aenv1 = aenv1 - giexp0
  
  abody = abody * aenv1

  ;HARD, SHORT ATTACK OF THE SOUND
  aenv linseg  1, 0.07, 0                            ;AMPLITUDE ENVELOPE (FAST DECAY)                        
  acps expsega 400, 0.07, giexp0, 1, giexp0          ;FREQUENCY OF THE ATTACK SOUND. QUICKLY GLISSES FROM 400 Hz TO SUB-AUDIO
  aimp oscili  aenv, acps * octave(ktune * 0.25), gisine                ;CREATE ATTACK SOUND

  abd = ((gkmix1 * abody) + ((1 - gkmix1) * aimp))
  kdist scale, gkdist1, 0.99, 0		
  adist powershape abd, 1 - kdist   
  amix = adist * p4

  if (gkbdpan == 1) then
    kpan = 0
  else
    kpan = 0.5
  endif
  aL,aR pan2 amix,kpan ;PAN THE MONOPHONIC SOUND
  outs    aL,aR        ;SEND AUDIO TO OUTPUTS
endin

instr 3    ;SNARE DRUM
    
  ;SOUND CONSISTS OF TWO SINE TONES, AN OCTAVE APART AND A NOISE SIGNAL
  ifrq	    = 171		    ;FREQUENCY OF THE TONES
  idur	    = p3 * gimaxdec
  iNseDur   = idur * 0.6	    ;DURATION OF THE NOISE COMPONENT
  iPchDur   = idur * 0.2	    ;DURATION OF THE SINE TONES COMPONENT
  ibendur   = idur * 0.1
  ktune	    = octave(gktune2 * gimaxtune)
  ibendmult = p5 * gimaxbend

  ;SINE TONES COMPONENT
  aenv1	expseg 1, iPchDur, giexp0, iNseDur - iPchDur, giexp0 ;AMPLITUDE ENVELOPE
  aenv1 = aenv1 - giexp0
  
  kbend	transeg	1, ibendur, -1, 0 ;SLIGHT PITCH BEND AT THE START OF THE NOTE 
  kbend = kbend * ibendmult
  apitch1 oscili 1, ifrq * ktune * semitone(kbend), gisine          ;SINE TONE 1
  apitch2 oscili 0.25, ifrq * 0.5 * ktune * semitone(kbend), gisine ;SINE TONE 2 (AN OCTAVE LOWER)
  apitch = (apitch1 + apitch2) * 0.75					    ;MIX THE TWO SINE TONES
  asn = apitch * aenv1
  
  ;NOISE COMPONENT
  aenv2 expon 1, iNseDur, giexp0 ;AMPLITUDE ENVELOPE
  aenv2 = aenv2 - giexp0
  
  anoise noise 0.75, 0				      ;CREATE SOME NOISE
  anoise butbp anoise, 10000 * ktune, 10000   ;BANDPASS FILTER THE NOISE SIGNAL
  anoise buthp anoise, 1000			      ;HIGHPASS FILTER THE NOISE SIGNAL
  kcf expseg 5000, 0.1, 3000, iNseDur - 0.2, 3000     ;CUTOFF FREQUENCY FOR A LOWPASS FILTER
  anoise butlp anoise, kcf			      ;LOWPASS FILTER THE NOISE SIGNAL
  ans = anoise * aenv2
    
  asnare = (gkmix2 * asn) + ((1 - gkmix2) * ans)
  kdist scale, gkdist2, 0.99, 0		
  adist powershape asnare, 1 - kdist   
    
  amix = adist * p4
  if (gkbdpan == 1) then
    kpan = 1
  else
    kpan = 0.5
  endif

  aL,aR pan2 amix, kpan  ;PAN THE MONOPHONIC AUDIO SIGNAL
  outs aL,aR             ;SEND AUDIO TO OUTPUTS
endin

instr 4    ;OPEN HIGH HAT

  idur  = p3 * gimaxdec
  
  ktune = octave(gktune3 * gimaxtune)
  kFrq1 = 296 * ktune 	;FREQUENCIES OF THE 6 OSCILLATORS
  kFrq2 = 285 * ktune 	
  kFrq3 = 365 * ktune 	
  kFrq4 = 348 * ktune 	
  kFrq5 = 420 * ktune 	
  kFrq6 = 835 * ktune 	
  
  
  ;SOUND CONSISTS OF 6 PULSE OSCILLATORS MIXED WITH A NOISE COMPONENT
  ;PITCHED ELEMENT
  aenv	linseg	1, idur - 0.05, 0.1, 0.05, 0		;AMPLITUDE ENVELOPE FOR THE PULSE OSCILLATORS
  
  kpw scale gkpw3, 0.5, 0
  
  a1	vco2	0.5, kFrq1, 2, kpw			;PULSE OSCILLATORS...
  a2	vco2	0.5, kFrq2, 2, kpw
  a3	vco2	0.5, kFrq3, 2, kpw
  a4	vco2	0.5, kFrq4, 2, kpw
  a5	vco2	0.5, kFrq5, 2, kpw
  a6	vco2	0.5, kFrq6, 2, kpw
  amix	sum	a1, a2, a3, a4, a5, a6			;MIX THE PULSE OSCILLATORS
  amix	reson	amix, 5000 * ktune, 5000, 1	;BANDPASS FILTER THE MIXTURE
  amix	buthp	amix, 5000				;HIGHPASS FILTER THE SOUND...
  amix	buthp	amix, 5000				;...AND AGAIN
  
  ;NOISE ELEMENT
  anoise	noise	0.8, 0				;GENERATE SOME WHITE NOISE
  kcf	expseg	20000, 0.1, 9000, idur - 0.1, 9000	;CREATE A CUTOFF FREQ. ENVELOPE
  anoise	butlp	anoise, kcf			;LOWPASS FILTER THE NOISE SIGNAL
  anoise	buthp	anoise, 8000			;HIGHPASS FILTER THE NOISE SIGNAL
  
  ;MIX PULSE OSCILLATOR AND NOISE COMPONENTS
  aoh = ((gkmix3 * amix) + ((1 - gkmix3) * anoise)) * aenv
  kdist scale, gkdist3, 0.99, 0		
  adist powershape aoh, 1 - kdist   
    
  amix = adist * p4
  if (gkbdpan == 1) then
    kpan = 1
  else
    kpan = 0.5
  endif

  aL,aR	pan2	amix,kpan		;PAN MONOPHONIC SIGNAL
  outs	aL,aR				;SEND TO OUTPUTS
endin

instr	5    ;CLOSED HIGH HAT
  idur	= p3 * gichdec
  
  ktune	= octave(gktune4 * gimaxtune)
  kFrq1	= 296 * ktune 	;FREQUENCIES OF THE 6 OSCILLATORS
  kFrq2	= 285 * ktune 	
  kFrq3	= 365 * ktune 	
  kFrq4	= 348 * ktune 	
  kFrq5	= 420 * ktune 	
  kFrq6	= 835 * ktune 	
  
  ;PITCHED ELEMENT
  aenv	expsega	1, idur, 0.001		;AMPLITUDE ENVELOPE FOR THE PULSE OSCILLATORS
  
  kpw scale gkpw4, 0.5, 0
  a1	vco2	0.5, kFrq1, 2, kpw			;PULSE OSCILLATORS...			
  a2	vco2	0.5, kFrq2, 2, kpw
  a3	vco2	0.5, kFrq3, 2, kpw
  a4	vco2	0.5, kFrq4, 2, kpw
  a5	vco2	0.5, kFrq5, 2, kpw
  a6	vco2	0.5, kFrq6, 2, kpw
  amix	sum	a1, a2, a3, a4, a5, a6			;MIX THE PULSE OSCILLATORS
  amix	reson	amix, 5000 * ktune, 5000, 1	;BANDPASS FILTER THE MIXTURE
  amix	buthp	amix, 5000				;HIGHPASS FILTER THE SOUND...
  amix	buthp	amix, 5000				;...AND AGAIN
  
  ;NOISE ELEMENT
  anoise	noise	0.8, 0				;GENERATE SOME WHITE NOISE
  kcf	expseg	20000, 0.1, 9000, idur - 0.1, 9000	;CREATE A CUTOFF FREQ. ENVELOPE
  anoise	butlp	anoise, kcf			;LOWPASS FILTER THE NOISE SIGNAL
  anoise	buthp	anoise, 8000			;HIGHPASS FILTER THE NOISE SIGNAL
  
  ;MIX PULSE OSCILLATOR AND NOISE COMPONENTS
  ach = ((gkmix4 * amix) + ((1 - gkmix4) * anoise)) * aenv
  kdist scale, gkdist4, 0.99, 0		
  adist powershape ach, 1 - kdist   
    
  amix = adist * p4
  if (gkbdpan == 1) then
    kpan = 1
  else
    kpan = 0.5
  endif

  aL,aR	pan2	amix,kpan			;PAN MONOPHONIC SIGNAL
  	outs	aL,aR				;SEND TO OUTPUTS
endin

</CsInstruments>
<CsScore>
f0 z ; needed for -ve duration - i.e. hold note on

;	st	dur
i 1     0.1    -1     

e
</CsScore>
</CsoundSynthesizer>

