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
zakinit 4, 1

giexp0 		= 0.001
gimaxt 		= 5
gimaxfc 	= 22050
gimaxq 		= 10
giparamthresh	= 0.01
gimaxdel	= 2048 / sr
gigatethresh	= 0.1
gimidimin	= 14
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
giled_invg    = 2
giled_exp_env = 3
giled_env_inv = 0
giled_port    = 1
giled_id0 = 8
giled_id1 = 5
giled_id2 = 4

; exponential for ADSR controls
giexp  ftgen	0, 0, 256, 5, giexp0, 256, 1, 0

#include "../udos/pages_buttons_params.udo"

opcode damp_filter, a, ak
  ain, ks xin
  adel delay1 ain
  aout = ain * ks + adel * (1 - ks)
    xout aout
endop

opcode hertz_to_del, k, k
  khz xin
  knumsamps = sr / khz
  kadj = knumsamps - 0.5
    xout kadj / sr
endop

opcode ff_comb, a, akkki
  ain, kdel, kb0, kbm, imaxdel xin
  ad delayr imaxdel
  adel deltapi kdel
  delayw ain
    xout ain * kb0 + adel * kbm
endop
	

; multi pages
;
; Inputs zero and one on all pages - the V/Oct and Gate
;
; Page zero:
;   two:  Fc	  three: Q
;   four: g	  five:  del1
;   six:  damp	  seven: dist
;   
;   Buttons:
;     fcmod order invg
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

  digiOutBela 1, giled_id0
  digiOutBela 0, giled_id1
  digiOutBela 1, giled_id2

  kpage	  init	0
  gkenv   init	0
  gkenvo  init	0
  gkdist  init	0
  
; bela buttons
  kpagebtn  digiInBela gibtn0

  kpage	page_incr_count_wrap kpagebtn, 2

  kbtn1	    digiInBela gibtn1
  kbtn2	    digiInBela gibtn2
  kbtn3	    digiInBela gibtn3

  if (kpage == 0) then 
    gkfcmod   toggle_buttonk, kbtn1
    gkorder   toggle_buttonk, kbtn2
    gkinvg    toggle_buttonk, kbtn3
  else
    gkexp_env toggle_buttonk, kbtn1
    gkenv_inv toggle_buttonk, kbtn2
    gkport    toggle_buttonk, kbtn3
  endif

  digiOutBela kpage,	  giled_page
  digiOutBela gkfcmod,	  giled_fcmod  
  digiOutBela gkorder, 	  giled_order  
  digiOutBela gkinvg,  	  giled_invg   
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


  gkfc	 locked_param kcv2, 0.5,  0, kpage, giparamthresh
  gkq	 locked_param kcv3, 0,	  0, kpage, giparamthresh
  gkg	 locked_param kcv4, 0.5,  0, kpage, giparamthresh
  gkdel1 locked_param kcv5, 0.5,  0, kpage, giparamthresh
  gkdamp locked_param kcv6, 0.5,  0, kpage, giparamthresh
  gkdist locked_param kcv7, 0,	  0, kpage, giparamthresh

  kat    locked_param kcv2, 0.1,    1, kpage, giparamthresh
  kdt    locked_param kcv3, 0.25,   1, kpage, giparamthresh
  ksl    locked_param kcv4, giexp0, 1, kpage, giparamthresh
  krt    locked_param kcv5, giexp0, 1, kpage, giparamthresh
  gkptim locked_param kcv6, 0,	    1, kpage, giparamthresh
  gkmix	 locked_param kcv7, 1,	    1, kpage, giparamthresh

  khertzi = cpsmidinn(int(gkmidinote))
  if (gkport == 1) then
    gkhertz portk khertzi, gkptim
  else
    gkhertz = khertzi
  endif
  
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

  ; some weird precision thing going on here so this isn't getting triggered
  ; gkenv = 0.0010000000000000002376571162088 
  ; giexp0 = 0.0010000000000000000208166817117
  ; 
  ;  if (gkgate == 0 && gkenv <= giexp0) then
  ;  		printks "foo\n", 0.5
  ;    gkenv = 0
  ;  endif
  ;  outvalue "display", gkenv
  ;  printks "gkenv = %32.31f (%32.31f)\n", 0.5, gkenv, giexp0
  
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
    ; due to the string model we can't close the filter or it doesn't ring
    ; so let's do it slightly differently
    kfce = kfce + (gimaxfc - kfce) * gkenvo
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

; Karplus-Strong plucked string
;
; A user configurable mix of left input and noise is enveloped and fed into
; a feed-forward comb filter.
; The output of the comb filter is then combined with the feedback signal and
; input to a damping filter after passing through a dcblocker
; The damped signal is fed into a variable delay who's length depends on freq
;
; Signal path is configurable between 
;		oscs -> dist -> filt -> clip -> out
;		oscs -> filt -> dist -> clip -> out
; Fc can be modulated
instr 5
  afb init 0
  
  kdel hertz_to_del gkhertz
  kdel1 scale gkdel1, kdel / 2, giexp0
  kdamp scale gkdamp, 0.5, 0
  kg scale gkg, 1.0, 0.5
  if (gkinvg == 1) then
    kg = 0 - kg
  endif
  
  ainl, ainr ins
  
  anoise rand 0.7
  astim = anoise * gkmix + (1 - gkmix) * ainl
  aenvstim = astim * gkenvo
  affcomb ff_comb aenvstim, kdel1, 1, -1, gimaxdel
  adcblock dcblock2 (affcomb + afb)
  adamp damp_filter adcblock, kdamp
  adel	delayr gimaxdel
  adelo deltapi kdel
  delayw adamp
  afb = adelo * kg
  
  if (gkorder == 1) then
    ; filter drives distortion
    zaw adelo, 0
    afx zar, 1
    zaw afx, 2
    aeo zar, 3		
  else 
    ; distortion drives filter
    zaw adelo, 2
    afx zar, 3
    zaw afx, 0
    aeo zar, 1
  endif
  
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
i 5     0.1    -1     


e
</CsScore>
</CsoundSynthesizer>
