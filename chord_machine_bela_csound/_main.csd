<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

prealloc 2, 8
prealloc 3, 1
maxalloc 2, 8

giexp0		= 0.001
giparamthresh	= 0.05
gioscamp	= 0.2
gimaxat		= 2
gimaxdt 	= 4
gimaxdrift	= 1/12
gimindriftfreq	= 0.5
gimaxdriftfreq	= 5
giphasefc	= 5500
giminphsfreq	= 0.05
gimaxphsfreq 	= 5
gimaxphsfb	= 0.95
giminphsfb 	= -gimaxphsfb
gigatethresh	= 0.1
gimidimin	= 15
givoct		= 118

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

giled_page    = 6
giled_wf1     = 7
giled_wf0     = 10
giled_oct     = 2
giled_sus     = 3
giled_expenv  = 0
giled_id0     = 8
giled_id1     = 5
giled_id2     = 4
giled_id3     = 1

ginextfree vco2init 27, 1, 0, 4096

gimaj  ftgen 0, 0, 4, -2, 0, 4, 7, 12
gimin  ftgen 0, 0, 4, -2, 0, 3, 7, 12
gidim  ftgen 0, 0, 4, -2, 0, 3, 6, 12
giaug  ftgen 0, 0, 4, -2, 0, 4, 8, 12
gimaj6 ftgen 0, 0, 4, -2, 0, 4, 7, 9
gimaj7 ftgen 0, 0, 4, -2, 0, 4, 7, 11
gidom7 ftgen 0, 0, 4, -2, 0, 4, 7, 10
gimin7 ftgen 0, 0, 4, -2, 0, 3, 7, 10
gisus4 ftgen 0, 0, 4, -2, 0, 5, 7, 12
gisus2 ftgen 0, 0, 4, -2, 0, 2, 7, 12

gimaj1st  ftgen 0, 0, 4, -2, 4, 7, 12, 16
gimin1st  ftgen 0, 0, 4, -2, 3, 7, 12, 15
gidim1st  ftgen 0, 0, 4, -2, 3, 6, 12, 15
giaug1st  ftgen 0, 0, 4, -2, 4, 8, 12, 16
gimaj61st ftgen 0, 0, 4, -2, 4, 7, 9 , 16
gimaj71st ftgen 0, 0, 4, -2, 4, 7, 11, 16
gidom71st ftgen 0, 0, 4, -2, 4, 7, 10, 16
gimin71st ftgen 0, 0, 4, -2, 3, 7, 10, 15
gisus41st ftgen 0, 0, 4, -2, 5, 7, 12, 17
gisus21st ftgen 0, 0, 4, -2, 2, 7, 12, 14

gimaj2nd  ftgen 0, 0, 4, -2, 7, 12, 16, 19
gimin2nd  ftgen 0, 0, 4, -2, 7, 12, 15, 19
gidim2nd  ftgen 0, 0, 4, -2, 6, 12, 15, 18
giaug2nd  ftgen 0, 0, 4, -2, 8, 12, 16, 20
gimaj62nd ftgen 0, 0, 4, -2, 7, 9 , 16, 19
gimaj72nd ftgen 0, 0, 4, -2, 7, 11, 16, 19
gidom72nd ftgen 0, 0, 4, -2, 7, 10, 16, 19
gimin72nd ftgen 0, 0, 4, -2, 7, 10, 15, 19
gisus42nd ftgen 0, 0, 4, -2, 7, 12, 17, 19
gisus22nd ftgen 0, 0, 4, -2, 7, 12, 14, 19


gichords  ftgen 0, 0, 10, -2, gimaj, gimin, gidim, giaug, gimaj6, gimaj7, gidom7, gimin7, gisus4, gisus2
gi1sts	  ftgen 0, 0, 10, -2, gimaj1st, gimin1st, gidim1st, giaug1st, gimaj61st, gimaj71st, gidom71st, gimin71st, gisus41st, gisus21st
gi2nds	  ftgen 0, 0, 10, -2, gimaj2nd, gimin2nd, gidim2nd, giaug2nd, gimaj62nd, gimaj72nd, gidom72nd, gimin72nd, gisus42nd, gisus22nd

giinvs ftgen 0, 0, 3, -2, gichords, gi1sts, gi2nds

;python can be helpful
;
;import itertools
;perms = itertools.permutations([0, 1, 2, 3])
;
;j = 0
;tables = [] 
;for i in list(perms):
;    print("ginoteord{:d} ftgen 0, 0, 4, -2, {}, {}, {}, {}".format(j, *i))
;    tables.append('ginoteord{:d}'.format(j))
;    j+=1
;print(tables) 

ginoteord0  ftgen 0, 0, 4, -2, 0, 1, 2, 3
ginoteord1  ftgen 0, 0, 4, -2, 0, 1, 3, 2
ginoteord2  ftgen 0, 0, 4, -2, 0, 2, 1, 3
ginoteord3  ftgen 0, 0, 4, -2, 0, 2, 3, 1
ginoteord4  ftgen 0, 0, 4, -2, 0, 3, 1, 2
ginoteord5  ftgen 0, 0, 4, -2, 0, 3, 2, 1
ginoteord6  ftgen 0, 0, 4, -2, 1, 0, 2, 3
ginoteord7  ftgen 0, 0, 4, -2, 1, 0, 3, 2
ginoteord8  ftgen 0, 0, 4, -2, 1, 2, 0, 3
ginoteord9  ftgen 0, 0, 4, -2, 1, 2, 3, 0
ginoteord10 ftgen 0, 0, 4, -2, 1, 3, 0, 2
ginoteord11 ftgen 0, 0, 4, -2, 1, 3, 2, 0
ginoteord12 ftgen 0, 0, 4, -2, 2, 0, 1, 3
ginoteord13 ftgen 0, 0, 4, -2, 2, 0, 3, 1
ginoteord14 ftgen 0, 0, 4, -2, 2, 1, 0, 3
ginoteord15 ftgen 0, 0, 4, -2, 2, 1, 3, 0
ginoteord16 ftgen 0, 0, 4, -2, 2, 3, 0, 1
ginoteord17 ftgen 0, 0, 4, -2, 2, 3, 1, 0
ginoteord18 ftgen 0, 0, 4, -2, 3, 0, 1, 2
ginoteord19 ftgen 0, 0, 4, -2, 3, 0, 2, 1
ginoteord20 ftgen 0, 0, 4, -2, 3, 1, 0, 2
ginoteord21 ftgen 0, 0, 4, -2, 3, 1, 2, 0
ginoteord22 ftgen 0, 0, 4, -2, 3, 2, 0, 1
ginoteord23 ftgen 0, 0, 4, -2, 3, 2, 1, 0

ginoteords ftgen 0, 0, 23, -2, ginoteord0, ginoteord1, ginoteord2, ginoteord3, ginoteord4, ginoteord5, ginoteord6, ginoteord7, ginoteord8, ginoteord9, ginoteord10, ginoteord11, ginoteord12, ginoteord13, ginoteord14, ginoteord15, ginoteord16, ginoteord17, ginoteord18, ginoteord19, ginoteord20, ginoteord21, ginoteord22, ginoteord23

; inverted half-sine, used for modulating phaser1 frequency
gisin ftgen 0, 0, 16384, 9, .5, -1, 0

gares init 0

#include "../udos/pages_buttons_params.udo"

; multi pages
;
; Inputs zero and one on all pages - the V/Oct and Gate
;
; btn0 = cycle page button
; btn1 = cycle waveform (square/saw/half cosine thing)
;
; Page zero:
;   CV:
;     two:  Chord CV	  three: Inversion CV
;     four: Note order CV five: Note Delay
;     six:  Delay Decay	  seven: PW
;
;   Buttons:
;     Octave, Sustain
;   
; Page one:
;   CV:
;     two:  A	      three: D
;     four: Drift Amt five:  Drift Frq
;     six: Phaser Frq seven: Phaser FB
;
;   Buttons:
;     exp env, Phase stages cycle
;   

; adsr trigger
;
; Generates chords or note sequences
instr 1

  digiOutBela 1, giled_id0
  digiOutBela 0, giled_id1
  digiOutBela 0, giled_id2
  digiOutBela 1, giled_id3

  kpage	  init	0
  kchord  init	0
  kinv	  init	0
  kzero	  init	0
  gkphase init  0
  
; bela buttons
  kpagebtn  digiInBela gibtn0
  
  kpage page_incr_count_wrap kpagebtn, 2
  
  kbtn1	digiInBela gibtn1
  kbtn2	digiInBela gibtn2
  kbtn3	digiInBela gibtn3	
  
  kshape page_incr_count_wrap kbtn1, 3


  if (kpage == 0) then 
    koct  toggle_buttonk, kbtn2
    ksus  toggle_buttonk, kbtn3
  else
    gkexpenv  toggle_buttonk, kbtn2
    gkphase   page_incr_count_wrap kbtn3, 6
  endif

  digiOutBela kpage,	  giled_page
  digiOutBela kshape & 1, giled_wf0  
  digiOutBela kshape & 2, giled_wf1  
  digiOutBela koct,	  giled_oct  
  digiOutBela ksus,	  giled_sus  
  digiOutBela gkexpenv,	  giled_expenv  

; bela CV inputs
  amidinote chnget "analogIn0"
  ;This works with my 61SL MkIII
  kmidinote = gimidimin + k(amidinote) * givoct

  akgate     chnget  "analogIn1"
  gkgate = k(akgate)

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

  kchrd	  locked_param kcv2, 0,	  0, kpage, giparamthresh
  kinv	  locked_param kcv3, 0,	  0, kpage, giparamthresh
  kord	  locked_param kcv4, 0,   0, kpage, giparamthresh
  kdelay  locked_param kcv5, 0,   0, kpage, giparamthresh
  kdeldc  locked_param kcv6, 0.5, 0, kpage, giparamthresh
  kpw	  locked_param kcv7, 0,	  0, kpage, giparamthresh
  
  kat	    locked_param kcv2, 0.1, 1, kpage, giparamthresh
  kdt	    locked_param kcv3, 0.1, 1, kpage, giparamthresh
  gkdrftamt locked_param kcv4, 0,   1, kpage, giparamthresh
  gkdrftfrq locked_param kcv5, 0,   1, kpage, giparamthresh
  kphsfrq   locked_param kcv6, 0,   1, kpage, giparamthresh
  kfb	    locked_param kcv7, 0.5, 1, kpage, giparamthresh
  
  kdel	    scale kdelay, 0.3, 0
  gkpw 	    scale kpw, 0.99, 0.1
  kat	    scale kat, gimaxat, 0
  kdt 	    scale kdt, gimaxdt, 0
  kdeldcs   scale kdeldc, 2, 0.25
  gkphsfrq  scale kphsfrq, gimaxphsfreq, giminphsfreq
  gkfb	    scale kfb, gimaxphsfb, giminphsfb
  
  kwf = 2 << kshape
  
  ktrig trigger gkgate, gigatethresh, 2 ; triggers on both edges
  if (ktrig == 1) then
    if (gkgate > gigatethresh) then
      ; select inversion
      kinvs  tab kinv, giinvs, 1
      ; select chord
      kchord tablekt kchrd, kinvs, 1
      
      ; select note order
      knoteord tab kord, ginoteords, 1
      kn1 tablekt 0, knoteord
      kn2 tablekt 1, knoteord
      kn3 tablekt 2, knoteord
      kn4 tablekt 3, knoteord
      
      ; assign notes									
      kone    tablekt kn1, kchord
      ktwo    tablekt kn2, kchord
      kthree  tablekt kn3, kchord
      kfour   tablekt kn4, kchord
      
      if (koct == 1) then
      	kamp = gioscamp * 0.75
      else
      	kamp = gioscamp
      endif			
      
      if (ksus == 1) then
      	kdur = -1
      else
      	kdur = kat + kdt
      endif
      knotedel = 0
      kthisdeldc = kdeldcs
      event "i", 2.0, knotedel,	kdur, kamp, kwf, cpsmidinn(kmidinote + kone), kat, kdt
      kthisdeldc *= kdeldcs
      knotedel += kdel * kthisdeldc
      event "i", 2.1, knotedel,	kdur, kamp, kwf, cpsmidinn(kmidinote + ktwo), kat, kdt
      kthisdeldc *= kdeldcs
      knotedel += kdel * kthisdeldc
      event "i", 2.2, knotedel, kdur, kamp, kwf, cpsmidinn(kmidinote + kthree), kat, kdt
      kthisdeldc *= kdeldcs
      knotedel += kdel * kthisdeldc
      event "i", 2.3, knotedel, kdur, kamp, kwf, cpsmidinn(kmidinote + kfour), kat, kdt
      if (koct == 1) then
      	kmidinote += 12
	kthisdeldc *= kdeldcs
      	knotedel += kdel * kthisdeldc
      	event "i", 2.0, knotedel,	kdur, kamp, kwf, cpsmidinn(kmidinote + kone), kat, kdt
	kthisdeldc *= kdeldcs
      	knotedel += kdel * kthisdeldc
      	event "i", 2.1, knotedel,	kdur, kamp, kwf, cpsmidinn(kmidinote + ktwo), kat, kdt
	kthisdeldc *= kdeldcs
      	knotedel += kdel * kthisdeldc
      	event "i", 2.2, knotedel, kdur, kamp, kwf, cpsmidinn(kmidinote + kthree), kat, kdt
	kthisdeldc *= kdeldcs
      	knotedel += kdel * kthisdeldc
      	event "i", 2.3, knotedel, kdur, kamp, kwf, cpsmidinn(kmidinote + kfour), kat, kdt
      endif
    else
      ;need this turnoff dance if we release before all events are triggered
      if (ksus == 1) then
      	event "i", 3, 0, -1
      	schedulek 3, knotedel + kat + kdt, -1
      endif
    endif
  endif
endin

; Virtual Analog VCO with linear or exponential envelopes
instr 2

  idur	  = p3
  iamp	  = p4
  ishape  = p5
  kfreq	  = p6
  iat 	  = p7
  idt 	  = p8

  kdriftfreq scale gkdrftfrq, gimaxdriftfreq, gimindriftfreq
  kdrift randh gimaxdrift, kdriftfreq
  kdriftp portk kdrift, 1/kdriftfreq
  kfreqdrift = kfreq + (kdriftp * gkdrftamt * kfreq)

  if (idur < 0) then
    ; sustained notes use r env gens
    if (gkexpenv == 1) then
      kenv expsegr giexp0, iat, iamp, idt, giexp0
    else 
      kenv linenr iamp, iat, idt, 0.01
    endif
    
  else

    if (gkexpenv == 1) then
      kenv expseg giexp0, iat, iamp, idt, giexp0
    else 
      kenv linen iamp, iat, idur, idt
    endif

  endif

  ares vco2 kenv, kfreqdrift, ishape, gkpw
  gares += ares

endin

instr 3
  turnoff2 2, 0, 1
  turnoff
endin

; phaser -> cycle through 0, 2, 4, 8, 10 and 12 stages
; includes rate and feedback controls
instr 4
  kordch changed gkphase
  if (kordch == 1) then
    kord = 2 * gkphase
    reinit rephase
  endif
  
rephase:  
  
  if (gkphase > 0) then
    kfreq oscili giphasefc, gkphsfrq, gisin
    apha phaser1 gares, kfreq, kord, gkfb
    asig = (gares + apha) * 0.4
  else
    asig = gares
  endif
  
  aout clip asig, 0, 1, 0.9
  outs aout, aout
  
  gares = 0
endin

</CsInstruments>
<CsScore>
f0 z ; needed for -ve duration - i.e. hold note on

i 1     0.1    -1     
i 4     0.1    -1     


e
</CsScore>
</CsoundSynthesizer>
