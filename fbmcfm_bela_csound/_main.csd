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

giexp0 			= 0.001
gimaxt 			= 5
gibetamax		= 2
gimodimax		= 20
gimidimax		= 84  ; C6
gimidimin		= 24  ; C1
gimaxfc 		= 22050
gimaxq 			= 10
giparamthresh		= 0.05

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

; sine wave for oscillators
gisin ftgen 0, 0, 4096, 10, 1
; exponential for ADSR controls
giexp ftgen 0, 0, 256, 5, giexp0, 256, 1, 0

#include "../udos/pages_buttons_params.udo"

; multi pages
;
; Inputs zero and one on all pages - the V/Oct and Gate
;
; btn0 = cycle page button
;
; Page zero:
;   CV:
;     two:  Fc	  three: Q
;     four: beta  five:  modi
;     six:  dtn	  seven: dist
;
;   Buttons:
;     fcmod order sync 
;   
; Page one:
;   CV:
;     two:  A	  three: D
;     four: S	  five:  R
;     six:  port  seven: mix
;
;   Buttons:
;     exp_env env_inv portamento
;   

; adsr trigger
instr 1

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
    gkfcmod   toggle_button, kbtn1
    gkorder   toggle_button, kbtn2
    gksync    toggle_button, kbtn3
  else
    gkexp_env toggle_button, kbtn1
    gkenv_inv toggle_button, kbtn2
    gkport    toggle_button, kbtn3
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
  gkmidinote = 14 + k(amidinote) * 120

  akgate     chnget  "analogIn1"
  gkate = k(akgate)

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

  gkfc	  locked_param kcv2, 1,	    0, kpage, giparamthresh
  gkq	  locked_param kcv3, 0,	    0, kpage, giparamthresh
  gkbeta  locked_param kcv4, 0.15,  0, kpage, giparamthresh
  gkmodi  locked_param kcv5, 0,	    0, kpage, giparamthresh
  gkdtn	  locked_param kcv6, 0,	    0, kpage, giparamthresh
  gkdist  locked_param kcv7, 0,	    0, kpage, giparamthresh
  
  kat     locked_param kcv2, 0.1, 1, kpage, giparamthresh
  kdt     locked_param kcv3, 0.1, 1, kpage, giparamthresh
  ksl     locked_param kcv4, 1,	  1, kpage, giparamthresh
  krt     locked_param kcv5, 0.1, 1, kpage, giparamthresh
  gkptim  locked_param kcv6, 0,	  1, kpage, giparamthresh
  gkmix	  locked_param kcv7, 1,	  1, kpage, giparamthresh
	  
  
  ktrig trigger gkgate, 0.1, 2 ; triggers on both edges
  if (ktrig == 1) then
    if (gkgate == 1) then
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
    if (gkgate == 0 && kadsenv == giexp0) then
      kadsenv = 0
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
  kfce tablei gkfc, giexp, 1
  kfce = kfce * gimaxfc
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
  kdist scale, gkdist, 0.99, 0 ; make sure the power param to powershape is never 0
  adisto powershape adisti, 1 - kdist
  zaw adisto, 3
endin

; feedback multi carrier fm
; The modulating oscillator has feedback, amount controlled by beta and the global env
; Two detunable carriers are modulated by the fb osc with mod index i 
; The sum of all three oscillators are output
; Signal path is configurable between 
;		oscs -> dist -> filt -> clip -> out
;		oscs -> filt -> dist -> clip -> out
; Fc can be modulated
instr 5
  afb init 0
  
  ainl, ainr ins
  
  kbeta tablei	gkbeta, giexp, 1
  kbeta =	kbeta * gibetamax
  kmodi = 	gkmodi * gimodimax
  kdtn  scale	gkdtn, 0.5, 0
  
  
  kmidinote scale gkmidinote, gimidimax, gimidimin
  khertzi cpsmidinn int(kmidinote)
  if (gkport == 1) then
    khertz portk khertzi, gkptim
  else
    khertz = khertzi
  endif
  
  kdtndn = 1 - kdtn
  kdtnup = 1 + (kdtn * 2)
  khertzdn = khertz * kdtndn
  khertzup = khertz * kdtnup
  
  asi init 0
  
  aphase,   aso1 syncphasor khertz, asi
  aphaseup, aso2 syncphasor khertzup, aso1 * gksync
  aphasedn, aso3 syncphasor khertzdn, aso1 * gksync

  afm	tablei aphase + (kbeta * afb),	      gisin, 1, 0, 1
  afcup	tablei aphaseup * (1 + kmodi * afm),  gisin, 1, 0, 1
  afcdn	tablei aphasedn * (1 + kmodi * afm),  gisin, 1, 0, 1

  afb  = afm * gkenvo
  apre = gkmix * ((afm + afcup + afcdn) / 3)
  apre = apre + (1 - gkmix) * ainl
  
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
  aout clip aeo, 0, 1, 0.8 ; prevent any nonsense
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
