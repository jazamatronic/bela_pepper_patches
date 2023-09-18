<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

sr     = 44100
ksmps  = 16
nchnls = 2
0dbfs = 1

giexp0 		= 0.001
gimaxt 		= 5
giparamport 	= 0.1
giparamthresh	= 0.01
givosimamp	= 0.233
gigatethresh	= 0.1
gimidimin	= 15
givoct		= 118
gimidimax	= 127

gibtn0 = 15
gibtn1 = 14
gibtn2 = 13
gibtn3 = 12

giled_page    = 6
giled_fmod    = 7
giled_fpcmod  = 10
giled_fpfmod  = 2
giled_exp_env = 3
giled_env_inv = 0
giled_port    = 1
giled_id0     = 8
giled_id1     = 5
giled_id2     = 4

; exponential for ADSR controls
giexp  ftgen 0, 0, 256, 5, giexp0, 256, 1, 0
;a rising sigmoid for detune
gisig ftgen 0, 0, 256, 19, 0.5, 0.5, 270, 0.5

#include "../udos/pages_buttons_params.udo"

;#################################################
; By Rasmus Ekman 2008

; Square each point in table #p4. This should only be run once in the performance.
instr 10
  index tableng p4
  index = index - 1  ; start from last point
loop:
  ival table index, p4
  ival = ival * ival
  tableiw ival, index, p4
  index = index - 1
  if index < 0 igoto endloop
    igoto loop
endloop: 
endin

;#################################################

; multi pages
;
; Inputs zero and one on all pages - the V/Oct and Gate
;
; Page zero:
;   two:  Formant	three: Decay
;   four: pulse count	five:  pulse factor
;   six:  dtn		seven: dist
;   
;   Buttons:
;     fmod pcmod pfmod
;   
; Page one:
;   two:  A	  three: D
;   four: S	  five:  R
;   six:  port	  seven: mix
;   
;   Buttons:
;     exp_env env_inv portamento


instr 1

  digiOutBela 0, giled_id0
  digiOutBela 1, giled_id1
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
    gkfmod    toggle_buttonk, kbtn1
    gkpcmod   toggle_buttonk, kbtn2
    gkpfmod   toggle_buttonk, kbtn3
  else
    gkexp_env toggle_buttonk, kbtn1
    gkenv_inv toggle_buttonk, kbtn2
    gkport    toggle_buttonk, kbtn3
  endif

  digiOutBela kpage,	  giled_page
  digiOutBela gkfmod,	  giled_fmod  
  digiOutBela gkpcmod, 	  giled_fpcmod  
  digiOutBela gkpfmod,    giled_fpfmod  
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

  kform	  locked_param kcv2, 0.5, 0, kpage, giparamthresh
  kdecay  locked_param kcv3, 0.1, 0, kpage, giparamthresh
  kpc	  locked_param kcv4, 0.5, 0, kpage, giparamthresh
  kpf	  locked_param kcv5, 0.5, 0, kpage, giparamthresh
  kdtn	  locked_param kcv6, 0,	  0, kpage, giparamthresh
  gkdist  locked_param kcv7, 0,	  0, kpage, giparamthresh

  kat     locked_param kcv2, 0.1, 1, kpage, giparamthresh
  kdt     locked_param kcv3, 0.1, 1, kpage, giparamthresh
  ksl     locked_param kcv4, 0.8, 1, kpage, giparamthresh
  krt     locked_param kcv5, 0.1, 1, kpage, giparamthresh
  gkptim  locked_param kcv6, 0,	  1, kpage, giparamthresh
  gkmix	  locked_param kcv7, 1,	  1, kpage, giparamthresh
	  
  khertzi = cpsmidinn(int(gkmidinote))
  if (gkport == 1) then
    gkhertz portk khertzi, gkptim
  else
    gkhertz = khertzi
  endif
	
  ktrig trigger gkgate, gigatethresh, 2 ; triggers on both edges
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
  ; pass the envelope through a filter to turn it into an audio rate signal and avoid zipper noise
  gaenvo tone a(gkenvo), 500

  kdtns  tablei kdtn, gisig, 1
  gkdtn  scale kdtns, 0.5, 0
  ;gkdtn  scale kdtn, 0.5, 0
  
  if (gkfmod == 1) then
    kformnote scale (kform * gaenvo), gimidimax, gkmidinote
  else
    kformnote scale kform, gimidimax, gkmidinote
  endif
  kformh = cpsmidinn(int(kformnote))
  gkformhp port kformh, giparamport
  
  
  ;some range checking and adjustments to the params below here to avoid clipping	
  kmaxcnt = ceil(gkformhp / gkhertz)

  kmaxscale = givosimamp / kmaxcnt
  kdecay init 0
  gkdecay scale kdecay, kmaxscale, 0
  
  if (gkpcmod == 1) then
    kpc = kpc * gaenvo
  endif
  kpcs scale kpc, kmaxcnt, 1
  gkpcp port kpcs, giparamport
  
  if (gkpfmod == 1) then
    kpf = kpf * gaenvo
  endif
  kpfs scale, kpf, 2, 0.1
  gkpfp port kpfs, giparamport

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

instr 5
  kdtnform init 1
  
  ainl, ainr ins
  
  kdtndn = 1 - gkdtn
  kdtnup = 1 + (gkdtn * 2)
  
  if (kdtnform == 1) then
    khertzdn = gkhertz
    khertzup = gkhertz
    kformhpdn = gkformhp * kdtndn
    kformhpdn max gkhertz, kformhpdn
    kformhpup = gkformhp * kdtnup
  else
    khertzdn = gkhertz * kdtndn
    khertzup = gkhertz * kdtnup	
    kformhpdn = gkformhp
    kformhpup = gkformhp
  endif
  
  al 	vosim givosimamp, gkhertz, gkformhp, gkdecay, gkpcp, gkpfp, 17
  aldn	vosim givosimamp, khertzdn, kformhpdn, gkdecay, gkpcp, gkpfp, 17
  alup	vosim givosimamp, khertzup, kformhpup, gkdecay, gkpcp, gkpfp, 17
  
  adisti = gkmix * (al + aldn + alup) + (1 - gkmix) * ainl
  ;adcblock dcblock2 adisti
  ;adisti = adcblock * gkenvo
  adisti = adisti * gaenvo
  kdist scale, gkdist, 0.99, 0
  adisto powershape adisti, 1 - kdist
  aout clip adisto, 0, 1, 0.8
  outs aout, aout
endin


</CsInstruments>
<CsScore>
f0 z ; needed for -ve duration - i.e. hold note on


f1       0  32768    9  1    1  0   ; sine wave
f17      0  32768    9  0.5  1  0   ; half sine wave
i10 0 0 17 ; init run only, square table 17

;	      st	   dur	   amp
i 1     0.1    -1     
i 2     0.1    -1     
i 5     0.1    -1     

e

</CsScore>
</CsoundSynthesizer>
