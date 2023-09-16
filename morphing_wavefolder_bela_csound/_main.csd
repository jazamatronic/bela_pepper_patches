<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16 
nchnls = 2
0dbfs = 1
;starting from the gen13.csd example by Russell Pinkston - Univ. of Texas  
;added morphing between multiple waves, param driven folding, and morphing between shaping tables
;3-osc with detune and drift plus a phase_sync facility to reset phasor accumulators.
;l/r channel delay for subtle phasing and stereo field enhancement
;right channel phase inversion if you don't care about mono mixes
;sine sub-osc

gisine	ftgen 0, 0, 16384, 10, 1  ;sine wave

;TRIANGLE WAVE (ODD HARMONICS AT A STRENGTH OF 1/HARMONIC
;NUMBER WITH INVERTED PHASE FOR EVERY OTHER HARMONIC):
gitri ftgen 0, 0, 16384, 9, 1, 1, 0, 3, .333, 180, 5, .2, 0, 7, .143, 180, 9, .111, 0

gisaw ftgen 0, 0, 16384, 10, .5, .333, .25, .2, .166, .142, .125, .111, .1, .09, .083, .076, .071, .066, .062

;PULSE (TRUMPET?)
gipulse ftgen 0, 0, 16384, 10,  .8, .9, .95, .96, 1, .91, .8, .75, .6, .42, .5, .4, .33, .28, .2, .15


ginumwaves   = 3
ginumshapers = 8
gimaxdel     = 20
giparamport  = 0.01
gimaxdetune  = 1 / 24
gidriftfreq1 = 0.3
gidriftfreq2 = 0.31
gidriftfreq3 = 0.29
gimaxdrift   = 1/24
gimidimin    = 15
givoct	     = 118

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

gisub_osc = 15
giphase_sync = 14
gidrone = 13
giinv_r_phase = 12
giled_so = 6
giled_sync = 7
giled_drone = 10
giled_phase = 2
giled_id0 = 8
giled_id1 = 5
giled_id2 = 4

; simple toggle detector
; may need to add some debounce mechanism on real hardware but seems to work 
; on a non-latching button widget
opcode toggle_button, k, i
  iindex xin
  kout init 0
  ktoggle digiInBela iindex
  kchanged changed ktoggle
  kriseedge = kchanged * ktoggle
  if (kriseedge == 1) then
    if (kout == 0) then
    	kout = 1
    else
    	kout = 0
    endif
  endif
  xout kout
endop

instr   1

  digiOutBela 1, giled_id0
  digiOutBela 0, giled_id1
  digiOutBela 0, giled_id2
  
  amidinote chnget "analogIn0"
  ;This works with my 61SL MkIII
  gkmidinote = gimidimin + k(amidinote) * givoct
  khertz = cpsmidinn(int(gkmidinote))

  ipkamp = p4/3
  
  kdrone toggle_button gidrone
  digiOutBela kdrone, giled_drone
  if (kdrone == 1) kthen
  	gagate = 1
  else
  	gagate chnget "analogIn1"
	gkgate = k(gagate)
	if (gkgate < 0.05) then
	  gagate = 0
	endif
  endif
  
  actrl chnget "analogIn2"              ;waveshaping index control
  kctrlp port k(actrl) + 0.01, giparamport         ;port is used to smooth k-rate params
  kctrlp_on_two = kctrlp / 2
  
  amorphm chnget "analogIn3"       ;wave osc selection
  kmorphmp port k(amorphm), giparamport
  kmorphmps = kmorphmp * ginumwaves
  kmorpht = int(kmorphmps)
  kmorphf = frac(kmorphmps - kmorpht)
  
  ashape chnget "analogIn4"              ;waveshaper table selection
  kshapep port k(ashape), giparamport
  kshapeps = kshapep * ginumshapers
  kshapet = int(kshapeps)
  kshapef = frac(kshapeps - kshapet)
  kshapet = kshapet + 1
  knormt  = kshapet + ginumshapers + 1

  adetune chnget "analogIn5"
  kdetunep port k(adetune), giparamport
  kdetunes scale kdetunep, gimaxdetune, 0
  kdtndn = 1 - kdetunes
  kdtnup = 1 + (kdetunes * 2)
  khertzdn = khertz * kdtndn
  khertzup = khertz * kdtnup
  
  adrift chnget "analogIn6"
  kdriftp port k(adrift), giparamport
  kdriftps = kdriftp * gimaxdrift
  
  kd1 randh kdriftps, gidriftfreq1
  kd2 randh kdriftps, gidriftfreq2
  kd3 randh kdriftps, gidriftfreq3
  kd1p port kd1, 1/gidriftfreq1
  kd2p port kd2, 1/gidriftfreq2
  kd3p port kd3, 1/gidriftfreq3
  
  ksync toggle_button giphase_sync
  digiOutBela ksync, giled_sync
  asyncin init 0
  
  ; two tableikt's driven by a phasor to allow wave morphing
  aosc1, aosc1so  syncphasor khertz + (khertz * kd1p), asyncin
  aosc1soks = aosc1so * ksync
  aosc2, aosc2so  syncphasor khertzup + (khertz * kd2p), aosc1soks
  aosc3, aosc3so  syncphasor khertzdn + (khertz * kd3p), aosc1soks
  
  aindex1 tableikt aosc1, 101 + kmorpht, 1
  aindex2 tableikt aosc1, 101 + kmorpht + 1, 1
  aindex01  = ((1 - kmorphf) * (aindex1 * kctrlp_on_two)) + (kmorphf * (aindex2 * kctrlp_on_two))
  
  aindex3 tableikt aosc2, 101 + kmorpht, 1
  aindex4 tableikt aosc2, 101 + kmorpht + 1, 1
  aindex02  = ((1 - kmorphf) * (aindex3 * kctrlp_on_two)) + (kmorphf * (aindex4 * kctrlp_on_two))
  
  aindex5 tableikt aosc3, 101 + kmorpht, 1
  aindex6 tableikt aosc3, 101 + kmorpht + 1, 1
  aindex03  = ((1 - kmorphf) * (aindex5 * kctrlp_on_two)) + (kmorphf * (aindex6 * kctrlp_on_two))
  
  asignal1 tableikt .5+aindex01, kshapet, 1			;waveshaping
  asignal2 tableikt .5+aindex01, kshapet + 1, 1			;waveshaping
  knormal1 tableikt kctrlp, knormt, 1				;amplitude normalization
  knormal2 tableikt kctrlp, knormt + 1, 1			;amplitude normalization
  asignal01 = ((1 - kshapef) * (asignal1 * knormal1)) + (kshapef * (asignal2 * knormal2))
  
  asignal3 tableikt .5+aindex02, kshapet, 1	
  asignal4 tableikt .5+aindex02, kshapet + 1, 1
  asignal02 = ((1 - kshapef) * (asignal3 * knormal1)) + (kshapef * (asignal4 * knormal2))
  
  asignal5 tableikt .5+aindex03, kshapet, 1
  asignal6 tableikt .5+aindex03, kshapet + 1, 1	
  asignal03 = ((1 - kshapef) * (asignal5 * knormal1)) + (kshapef * (asignal6 * knormal2))
  
  
  kphase toggle_button giinv_r_phase
  digiOutBela kphase, giled_phase
  adel chnget "analogIn7"
  kdel port k(adel), giparamport
  gkdel = kdel * gimaxdel
  
  adel interp gkdel
  asigl = (asignal01 + asignal02 + asignal03)*ipkamp*gagate
  asigr vdelay asigl, adel, gimaxdel
  gkphasem pow -1, kphase
  asigr = asigr * gkphasem
    outs   asigl, asigr
endin

instr 2
  ksub_on toggle_button gisub_osc
  digiOutBela ksub_on, giled_so
  ksub_port port ksub_on, giparamport
  khertz = cpsmidinn(int(gkmidinote) - 12)
  asubl poscil ksub_port * p4 * 0.4 * gagate, khertz, gisine
  adel interp gkdel
  asubr vdelay asubl, adel, gimaxdel
  asubr = asubr * gkphasem
    outs asubl, asubr
endin
</CsInstruments>
<CsScore>
;a 0 0 140
; quasi triangle wave transfer function: 
;		 h0   h1   h2   h3   h4   h5   h6    h7   h8   h9   h10   h11 	h12   h13    h14    h15    h16    h17    h18    h19
f1 0 513 13 1 1  0   100   0  -11.11 0    4    0   -2.04  0   1.23  0   -.826	0    .59      0    -.444    0    .346     0   -.277	

f10 0 257 4 1 1	 ; normalizing function with midpoint bipolar offset

; quasi square wave transfer function: 
;		 h0   h1   h2   h3   h4   h5   h6    h7   h8   h9   h10   h11 	h12   h13    h14    h15    h16    h17    h18    h19
f2 0 513 13 1 1  0   100   0   -33   0    20   0   -14.2  0   11.1   0  -9.09	 0   7.69     0    -6.67    0    5.88     0    -5.26

f11 0 257 4 2 1	 ; normalizing function with midpoint bipolar offset

; quasi sawtooth transfer function: 
;		 h0   h1   h2   h3   h4   h5   h6    h7   h8   h9   h10   h11 	h12   h13    h14    h15    h16    h17    h18    h19    h20
f3 0 513 13 1 1  -65   100  -50  -33   25   20 -16.7 -14.2 12.5 11.1 -10  -9.09  8.333  7.69  -7.14  -6.67  6.25	  5.88	-5.55  -5.26    5		

f12 0 257 4 3 1	 ; normalizing function with midpoint bipolar offset

; transfer function1:  h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16
f4 0 513 13 1 1        0  1 -.8 0 .6  0  0  0 .4  0  0   0   0   .1 -.2 -.3  .5

f13 0 257 4 4 1	       ; normalizing function with midpoint bipolar offset

f5 0 513 7 -0.25 32 -1 32 -0.25 32 -1 32 -0.25 32 -1 192 1 32 0.25 32 1 32 0.25 32 1 32 0.25 

f14 0 257 4 5 1      ; normalizing function with midpoint bipolar offset

f6 0 513 7 0 32 -1 32 1 32 -1 32 1 32 -1 192 1 32 -1 32 1 32 -1 32 1 32 0 

f15 0 257 4 6 1      ; normalizing function with midpoint bipolar offset


;=========================================================================;
; This demonstrates the use of high partials, sometimes without a         ;
; fundamental, to get quasi-inharmonic spectra from waveshaping.          ;
;=========================================================================;
; transfer function2:  h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16
f7 0 513 13 1 1        0  0  0 -.1  0 .3  0 -.5 0 .7  0 -.9  0   1   0  -1   0

f16 0 257 4 7 1	       ; normalizing function with midpoint bipolar offset

; transfer function3: h0   h1   h2   h3   h4   h5   h6    h7   h8   h9   h10   h11 	h12   h13    h14    h15    h16    h17    h18    h19    h17   h18   h19   h20
f8 0 513 13 1 1      0    0    0    0    0    0    0     -1   0    1     0     0       -.1    0     .1      0     -.2    .3      0     -.7     0    .2     0    -.1                        

f17 0 257 4 8 1      ; normalizing function with midpoint bipolar offset

;=========================================================================;
; split a sinusoid into 3 odd-harmonic partials of relative strength 5:3:1
;=========================================================================;
; transfer function4: h0   h1   h2   h3   h4   h5
f9 0 513 13 1 1      0    5    0    3    0    1	

f18 0 257 4 9 1      ; normalizing function with midpoint bipolar offset

f0 z ; needed for -ve duration - i.e. hold note on

;	    st	   dur	   amp
i 1     0.1    -1     .7
i 2     0.1    -1     .7

e
</CsScore>
</CsoundSynthesizer>
