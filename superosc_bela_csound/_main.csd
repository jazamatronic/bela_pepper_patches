<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

; 4 arate channels
; 0 = filt in
; 1 = filt out
; 2 = dist in
; 3 = dist out
; 4+ slots for 12 oscs
zakinit 16, 1

giexp0 		= 0.001
gimaxt 		= 5
gimaxoscs	= 13
gimaxfc 	= 22050
gimaxq 		= 10
giparamthresh	= 0.05
gizakvcostart	= 4
gioscgain	= 0.7
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
giled_fcmod   = 7
giled_order   = 10
giled_sync    = 2
giled_exp_env = 3
giled_env_inv = 0
giled_port    = 1
giled_id0     = 8
giled_id1     = 5
giled_id2     = 4

gaso1 init 0 ; global sync

; exponential for ADSR controls
giexp  ftgen	0, 0, 256, 5, giexp0, 256, 1, 0

givcotable_start vco2init 31, giexp+1, 0, 128, 2^16

#include "../udos/pages_buttons_params.udo"

; outputs: 	k = detuned freq
; inputs:	k = freq to be detuned
;		k = detune amount between 0 and 1
;		k = detune multiplier, use to spread dtns up and down
;
; Detune for super osc
; Takes an input freq and detunes it either up or down up to an octave
opcode detune, k, kkk
  kfreq, kdtn, km xin
  kdtn = 1 + (km * kdtn)
  kdtn min 2, kdtn
  kdtn max 0.5, kdtn
  kfreq_dtn = kfreq * kdtn
    xout kfreq_dtn
endop

; Global Control Instrument
;
; multi pages
;
; Inputs zero and one on all pages - the V/Oct and Gate
;
; btn0 = cycle page button
;
; Page zero:
;   two:  Fc	    three: Q
;   four: Num Oscs  five: Osc shape 
;   six:  dtn	    seven: dist
;
;   Buttons:
;     fcmod order sync
;   
; Page one:
;   two:  A	  three: D
;   four: S	  five:  R
;   six:  port	  seven: mix
;   
;   Buttons:
;     exp_env env_inv portamento

; adsr trigger
instr 1

  digiOutBela 0, giled_id0
  digiOutBela 0, giled_id1
  digiOutBela 1, giled_id2
  

  kpage	     init     0
  gkenv      init     0
  gkenvo     init     0
  
; bela buttons
  kpagebtn  digiInBela gibtn0

  kpage	    page_incr_count_wrap kpagebtn, 2

  kbtn1	    digiInBela gibtn1
  kbtn2	    digiInBela gibtn2
  kbtn3	    digiInBela gibtn3

  if (kpage == 0) then 
    gkfcmod   toggle_buttonk, kbtn1
    gkorder   toggle_buttonk, kbtn2
    gksync    toggle_buttonk, kbtn3
  else
    gkexp_env toggle_buttonk, kbtn1
    gkenv_inv toggle_buttonk, kbtn2
    gkport    toggle_buttonk, kbtn3
  endif

  digiOutBela kpage,	  giled_page
  digiOutBela gkfcmod,	  giled_fcmod  
  digiOutBela gkorder, 	  giled_order  
  digiOutBela gksync,  	  giled_sync   
  digiOutBela gkexp_env,  giled_exp_env
  digiOutBela gkenv_inv,  giled_env_inv
  digiOutBela gkport,     giled_port   

; bela CV inputs
  amidinote chnget "analogIn0"
  ;This works with my 61SL MkIII
  gkmidinote = gimidimin + k(amidinote) * givoct

  akgate    chnget  "analogIn1"
  gkgate = k(akgate)

  acv2       chnget  "analogIn2"
  acv3       chnget  "analogIn3"
  acv4       chnget  "analogIn4"
  acv5       chnget  "analogIn5"
  acv6       chnget  "analogIn6"
  acv7       chnget  "analogIn7"

  kcv2 = k(acv2)
  kcv3 = k(acv3)
  kcv4 = k(acv4)
  kcv5 = k(acv5)
  kcv6 = k(acv6)
  kcv7 = k(acv7)

  gkfc	  locked_param kcv2, 0.5, 0, kpage, giparamthresh
  gkq	  locked_param kcv3, 0,	  0, kpage, giparamthresh
  knoscs  locked_param kcv4, 0,	  0, kpage, giparamthresh
  kshape  locked_param kcv5, 0,	  0, kpage, giparamthresh
  kdtn	  locked_param kcv6, 0,	  0, kpage, giparamthresh
  gkdist  locked_param kcv7, 0,	  0, kpage, giparamthresh

  kat     locked_param kcv2,	0.1,	1, kpage, giparamthresh
  kdt     locked_param kcv3,	0.1,	1, kpage, giparamthresh
  ksl     locked_param kcv4,	0.8,	1, kpage, giparamthresh
  krt     locked_param kcv5,	0.1,	1, kpage, giparamthresh
  gkptim  locked_param kcv6,	0,	1, kpage, giparamthresh
  gkmix	  locked_param kcv7,	1,	1, kpage, giparamthresh

  khertzi = cpsmidinn(int(gkmidinote))
  if (gkport == 1) then
    gkhertz portk khertzi, gkptim
  else
    gkhertz = khertzi
  endif
	
  kfnshape = int(kshape * 4.99)
  if (kfnshape == 0) then
    gkfn  vco2ft gkhertz, 0 ; saw
  elseif (kfnshape == 1) then
    gkfn  vco2ft gkhertz, 3 ; square
  elseif (kfnshape == 2) then
    gkfn  vco2ft gkhertz, 4 ; tri
  elseif (kfnshape == 3) then
    gkfn  vco2ft gkhertz, 1 ; integrated saw
  elseif (kfnshape == 4) then
    gkfn  vco2ft gkhertz, 2 ; ouch, ever heard of Nyquist?
  endif
				  
  gknoscs scale knoscs, gimaxoscs, 1
  gknoscs = int(gknoscs)
  
  gkdtn  scale kdtn, 0.5, 0
		  
  ktrig trigger gkgate, gigatethresh, 2
  if (ktrig == 1) then
    if (gkgate > gigatethresh) then
      ; adsr changes only count when we've got an event to create
      katc changed kat
      kdtc changed kdt
      kslc changed ksl
      krtc changed krt

      if (katc == 1) then
        gkat tablei kat, giexp, 1
        gkat =      gkat * gimaxt
      endif

      if (kdtc == 1) then
        gkdt tablei kdt, giexp, 1
        gkdt =      gkdt * gimaxt
      endif

      if (kslc == 1) then
        gksl scale ksl, 1, giexp0
      endif

      if (krtc == 1) then
        gkrt tablei krt, giexp, 1
        gkrt =      gkrt * gimaxt
      endif

      event "i", 2, 0, -1
    else
      turnoff2 2, 0, 1
    endif
  endif
  
  if (gkenv_inv == 1) then
    gkenvo = 1 - gkenv
  else
    gkenvo = gkenv
  endif
endin

; adsr gen
instr 2
  if (gkexp_env == 1) then
    kadsenv  expsegr giexp0, i(gkat), 1, i(gkdt), i(gksl), i(gkrt), giexp0
    if (gkgate == 0) then
    	 ; there is some precision errors when release is finished so we do some tricks to make it definitely off.
      kadsenv -= giexp0
    endif
  else 
    kadsenv  linsegr 0, i(gkat), 1, i(gkdt), i(gksl), i(gkrt), 0
  endif
  gkenv = kadsenv
endin

; filter instrument
; input is zak channel 0
; output is zak channel 1
instr 3
  kfce	tablei gkfc, giexp, 1
  kfce	= kfce * gimaxfc
  if (gkfcmod == 1) then
  	kfce = kfce * gkenvo
  endif
  
  kq = gkq * gimaxq
  	  	
  afilti zar, 0  		  	
  afilto K35_lpf afilti, kfce, kq
  zaw afilto, 1
endin

; distortion instrument
; intput is zak channel 2
; output is zak channel 3
instr 4
  adisti zar, 2
  kdist scale, gkdist, 0.99, 0
  adisto powershape adisti, 1 - kdist
  zaw adisto, 3
endin

; detunable osc
instr 5
  ii = p4 ; detune number and direction, -1, +1 etc.
  islot = p5 ; zak slot
  khertzdtn detune gkhertz, gkdtn, ii
  aphasedtn, aso2 syncphasor khertzdtn, gaso1
  avcodtn tableikt	aphasedtn, gkfn, 1, 0, 1
  zaw (avcodtn * gioscgain), gizakvcostart + islot
endin

; osc + variable sum of other osc insts
; Signal path is configurable between 
;		oscs -> dist -> filt -> clip -> out
;		oscs -> filt -> dist -> clip -> out
; Fc can be modulated
instr 6
  ainl, ainr ins
  
  asi init 0
  
  aphase, gaso1 syncphasor gkhertz, asi
  gaso1 = gaso1 * gksync
  avco	tableikt aphase, gkfn, 1, 0, 1
  avco	= avco * gioscgain
  avcomix = avco
  
  ; this instrument already has one vco so we count up to gknoscs - 1
  kloop = 0
  while (kloop < (gknoscs - 1)) do
    amix zar gizakvcostart + kloop
    avcomix += amix
    kloop += 1
  od
  
  abalance balance avcomix, avco 
  apre = (gkmix * abalance) + ((1 - gkmix) * ainl)
  
  if (gkorder == 1) then
    ; filter drives distortion
    zaw apre, 0
    afx zar, 1
    zaw afx, 2
    aenvin zar, 3		
  else 
    ; distortion drives filter
    zaw apre, 2
    afx zar, 3
    zaw afx, 0
    aenvin zar, 1
  endif
  
  aeo = aenvin * gkenvo	
  aout clip aeo, 0, 1, 0.8
    outs aout, aout
endin


</CsInstruments>
<CsScore>
f0 z ; needed for -ve duration - i.e. hold note on

;	      st	   dur	   amp
i 1     0.1    -1     
i 3     0.1    -1     
i 4     0.1    -1
; 12 detune oscs
i 5.0  0.1 -1 -1      0
i 5.1  0.1 -1  2      1
i 5.2  0.1 -1 -1.02   2
i 5.3  0.1 -1  2.04   3
i 5.4  0.1 -1 -1.03   4
i 5.5  0.1 -1  2.06   5
i 5.6  0.1 -1 -1.05   6
i 5.7  0.1 -1  2.1    7
i 5.8  0.1 -1 -1.07   8
i 5.9  0.1 -1  2.14   9
i 5.11 0.1 -1 -1.11  10
i 5.12 0.1 -1  2.22  11
; one summing osc
i 6     0.1    -1     

e
</CsScore>
</CsoundSynthesizer>
