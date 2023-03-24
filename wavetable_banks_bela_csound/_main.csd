<CsoundSynthesizer>
<CsOptions>
-m0d
</CsOptions>
<CsInstruments>

; some ideas
; lofi CV out from scanning wavetables and writing them to one of the CV out ports
; have xy/z modes run in parallel, one to l, the other to r

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

ginumwaves   = 7   ; Actually 8 but we add 1 to get upper bounds for interpolation
giparamport  = 0.01
gimaxdel     = 20
gimaxmod     = 10
gimaxbank    = 79 
giwavetn     = 200
gimaxfc      = 22050
gimaxq       = 10
gSbank       = "./1.wav"
gimidimin    = 14
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

giinterp = 15
gibankdn = 14
gibankup = 13
gixy_mode = 12 
giled_interp = 6
giled_up = 10
giled_dn = 7
giled_xy_mode = 2
giled_id0 = 8
giled_id1 = 5
giled_id2 = 4

gisine ftgen 0, 0, 256, 10, 1 ; for sub_osc

giexp  ftgen 0, 0, 256, 5, 0.001, 256, 1, 0 ; for exponential z-morph control

gi00 ftgen 0, 0, 256, 10, 1
gi10 ftgen 0, 0, 256, 10, 1
gi20 ftgen 0, 0, 256, 10, 1
gi30 ftgen 0, 0, 256, 10, 1
gi40 ftgen 0, 0, 256, 10, 1
gi50 ftgen 0, 0, 256, 10, 1
gi60 ftgen 0, 0, 256, 10, 1
gi70 ftgen 0, 0, 256, 10, 1
gi01 ftgen 0, 0, 256, 10, 1
gi11 ftgen 0, 0, 256, 10, 1
gi21 ftgen 0, 0, 256, 10, 1
gi31 ftgen 0, 0, 256, 10, 1
gi41 ftgen 0, 0, 256, 10, 1
gi51 ftgen 0, 0, 256, 10, 1
gi61 ftgen 0, 0, 256, 10, 1
gi71 ftgen 0, 0, 256, 10, 1
gi02 ftgen 0, 0, 256, 10, 1
gi12 ftgen 0, 0, 256, 10, 1
gi22 ftgen 0, 0, 256, 10, 1
gi32 ftgen 0, 0, 256, 10, 1
gi42 ftgen 0, 0, 256, 10, 1
gi52 ftgen 0, 0, 256, 10, 1
gi62 ftgen 0, 0, 256, 10, 1
gi72 ftgen 0, 0, 256, 10, 1
gi03 ftgen 0, 0, 256, 10, 1
gi13 ftgen 0, 0, 256, 10, 1
gi23 ftgen 0, 0, 256, 10, 1
gi33 ftgen 0, 0, 256, 10, 1
gi43 ftgen 0, 0, 256, 10, 1
gi53 ftgen 0, 0, 256, 10, 1
gi63 ftgen 0, 0, 256, 10, 1
gi73 ftgen 0, 0, 256, 10, 1
gi04 ftgen 0, 0, 256, 10, 1
gi14 ftgen 0, 0, 256, 10, 1
gi24 ftgen 0, 0, 256, 10, 1
gi34 ftgen 0, 0, 256, 10, 1
gi44 ftgen 0, 0, 256, 10, 1
gi54 ftgen 0, 0, 256, 10, 1
gi64 ftgen 0, 0, 256, 10, 1
gi74 ftgen 0, 0, 256, 10, 1
gi05 ftgen 0, 0, 256, 10, 1
gi15 ftgen 0, 0, 256, 10, 1
gi25 ftgen 0, 0, 256, 10, 1
gi35 ftgen 0, 0, 256, 10, 1
gi45 ftgen 0, 0, 256, 10, 1
gi55 ftgen 0, 0, 256, 10, 1
gi65 ftgen 0, 0, 256, 10, 1
gi75 ftgen 0, 0, 256, 10, 1
gi06 ftgen 0, 0, 256, 10, 1
gi16 ftgen 0, 0, 256, 10, 1
gi26 ftgen 0, 0, 256, 10, 1
gi36 ftgen 0, 0, 256, 10, 1
gi46 ftgen 0, 0, 256, 10, 1
gi56 ftgen 0, 0, 256, 10, 1
gi66 ftgen 0, 0, 256, 10, 1
gi76 ftgen 0, 0, 256, 10, 1
gi07 ftgen 0, 0, 256, 10, 1
gi17 ftgen 0, 0, 256, 10, 1
gi27 ftgen 0, 0, 256, 10, 1
gi37 ftgen 0, 0, 256, 10, 1
gi47 ftgen 0, 0, 256, 10, 1
gi57 ftgen 0, 0, 256, 10, 1
gi67 ftgen 0, 0, 256, 10, 1
gi77 ftgen 0, 0, 256, 10, 1

#include "../udos/pages_buttons_params.udo"

instr 1

  digiOutBela 0, giled_id0
  digiOutBela 1, giled_id1
  digiOutBela 0, giled_id2
  
  ;Some banks:
  ; "/data/AKWF/AKWF--Synthesis-Technology/Wavetables/AK01.wav"
  ; "/data/WaveEdit/banks/ROM C.wav"
  ; see also https://waveeditonline.com/

  kbank init 1
  
  kup digiInBela gibankup
  digiOutBela, kup, giled_up
  kupc changed kup
  if (kupc == 1 && kup == 1) then
    kbank = kbank + 1
  endif
  
  kdn digiInBela gibankdn
  digiOutBela, kdn, giled_dn  
  kdnc changed kdn
  if (kdnc == 1 && kdn == 1) then
    kbank = kbank - 1
  endif
  
  if (kbank == 0) then
    kbank = gimaxbank
  elseif (kbank > gimaxbank) then
    kbank = 1
  endif
  
  kchanged changed kbank
  if (kchanged == 1) then
    gSbank sprintfk "./%d.wav", kbank  

reinit wave
wave:
  giwave ftgentmp giwavetn, 0, 16384, 1, gSbank, 0, 0, 0

  ftslicei giwave, gi00, 0, 256
  ftslicei giwave, gi10, 256, 512
  ftslicei giwave, gi20, 512, 768
  ftslicei giwave, gi30, 768, 1024
  ftslicei giwave, gi40, 1024, 1280
  ftslicei giwave, gi50, 1280, 1536
  ftslicei giwave, gi60, 1536, 1792
  ftslicei giwave, gi70, 1792, 2048
  ftslicei giwave, gi01, 2048, 2304
  ftslicei giwave, gi11, 2304, 2560
  ftslicei giwave, gi21, 2560, 2816
  ftslicei giwave, gi31, 2816, 3072
  ftslicei giwave, gi41, 3072, 3328
  ftslicei giwave, gi51, 3328, 3584
  ftslicei giwave, gi61, 3584, 3840
  ftslicei giwave, gi71, 3840, 4096
  ftslicei giwave, gi02, 4096, 4352
  ftslicei giwave, gi12, 4352, 4608
  ftslicei giwave, gi22, 4608, 4864
  ftslicei giwave, gi32, 4864, 5120
  ftslicei giwave, gi42, 5120, 5376
  ftslicei giwave, gi52, 5376, 5632
  ftslicei giwave, gi62, 5632, 5888
  ftslicei giwave, gi72, 5888, 6144
  ftslicei giwave, gi03, 6144, 6400
  ftslicei giwave, gi13, 6400, 6656
  ftslicei giwave, gi23, 6656, 6912
  ftslicei giwave, gi33, 6912, 7168
  ftslicei giwave, gi43, 7168, 7424
  ftslicei giwave, gi53, 7424, 7680
  ftslicei giwave, gi63, 7680, 7936
  ftslicei giwave, gi73, 7936, 8192
  ftslicei giwave, gi04, 8192, 8448
  ftslicei giwave, gi14, 8448, 8704
  ftslicei giwave, gi24, 8704, 8960
  ftslicei giwave, gi34, 8960, 9216
  ftslicei giwave, gi44, 9216, 9472
  ftslicei giwave, gi54, 9472, 9728
  ftslicei giwave, gi64, 9728, 9984
  ftslicei giwave, gi74, 9984, 10240
  ftslicei giwave, gi05, 10240, 10496
  ftslicei giwave, gi15, 10496, 10752
  ftslicei giwave, gi25, 10752, 11008
  ftslicei giwave, gi35, 11008, 11264
  ftslicei giwave, gi45, 11264, 11520
  ftslicei giwave, gi55, 11520, 11776
  ftslicei giwave, gi65, 11776, 12032
  ftslicei giwave, gi75, 12032, 12288
  ftslicei giwave, gi06, 12288, 12544
  ftslicei giwave, gi16, 12544, 12800
  ftslicei giwave, gi26, 12800, 13056
  ftslicei giwave, gi36, 13056, 13312
  ftslicei giwave, gi46, 13312, 13568
  ftslicei giwave, gi56, 13568, 13824
  ftslicei giwave, gi66, 13824, 14080
  ftslicei giwave, gi76, 14080, 14336
  ftslicei giwave, gi07, 14336, 14592
  ftslicei giwave, gi17, 14592, 14848
  ftslicei giwave, gi27, 14848, 15104
  ftslicei giwave, gi37, 15104, 15360
  ftslicei giwave, gi47, 15360, 15616
  ftslicei giwave, gi57, 15616, 15872
  ftslicei giwave, gi67, 15872, 16128
  ftslicei giwave, gi77, 16128, 16384
  rireturn
  endif
endin

instr 2
  ilineinc = ginumwaves + 1
  inumtabs = ilineinc * ilineinc
  
  amidinote chnget "analogIn0"
  ;gkmidinote scale kmidinote, gimidimax, gimidimin
  ;This works with my 61SL MkIII
  gkmidinote = gimidimin + k(amidinote) * givoct
  khertz = cpsmidinn(int(gkmidinote))
  
  kmin = 165
  
  kxy_mode toggle_button gixy_mode
  digiOutBela, kxy_mode, giled_xy_mode
  kinterp  toggle_button giinterp
  digiOutBela, kinterp, giled_interp
  
  aphase phasor khertz
  
  if (kxy_mode == 1) then
    amorphx	chnget "analogIn4"       ;wave osc selection
    kmorphxmp 	port k(amorphx), giparamport
    kmorphxmps	= kmorphxmp * ginumwaves
    kmorphxt	= int(kmorphxmps)
    kmorphxf 	= frac(kmorphxmps - kmorphxt)
        
    amorphy	chnget "analogIn5"       ;wave osc selection
    kmorphymp	port k(amorphy), giparamport
    kmorphymps	= kmorphymp * ginumwaves
    kmorphyt	= int(kmorphymps)
    kmorphyf 	= frac(kmorphymps - kmorphyt)    
  
    if (kinterp == 0) then
      kmorphxf = round(kmorphxf)
      kmorphyf = round(kmorphyf)
    endif 

    klull min kmin, gi00 + kmorphxt + ilineinc * kmorphyt
    klulr min kmin, gi00 + kmorphxt + 1 + ilineinc * kmorphyt
    kluul min kmin, gi00 + kmorphxt + ilineinc * (kmorphyt + 1)
    kluur min kmin, gi00 + kmorphxt + 1 + ilineinc * (kmorphyt + 1)
    axll  tableikt aphase, klull, 1
    axlr  tableikt aphase, klulr, 1
    axul  tableikt aphase, kluul, 1
    axur  tableikt aphase, kluur, 1
    axl	  = ((1 - kmorphxf) * axll + kmorphxf * axlr)
    axu   = ((1 - kmorphxf) * axul + kmorphxf * axur)
    ax    = ((1 - kmorphyf) * axl  + kmorphyf * axu)
  else
    amorphz   chnget "analogIn4"
    kmorphzmp port k(amorphz), giparamport

    amodz chnget "analogIn5"
    ;kmodz = k(amodz)
    kmodz port k(amodz), giparamport
      
    if (kmodz < 0.05) then 
      kmorphzmps = kmorphzmp * inumtabs
    else
      kmodze tablei kmodz, giexp, 1
      kmodze = kmodze * gimaxmod
      amod  phasor kmodze
      kmorphzmps = amod * inumtabs
    endif
    
    kmorphzt = int(kmorphzmps)
    kmorphzf = frac(kmorphzmps - kmorphzt)

    if (kinterp == 0) then
      kmorphzf = round(kmorphzf)
    endif
    
    klul min kmin, gi00 + kmorphzt
    klur min kmin, gi00 + kmorphzt + 1
    axl  tableikt aphase, klul, 1
    axr  tableikt aphase, klur, 1
    ax	 = ((1 - kmorphzf) * axl  + kmorphzf * axr)

  endif

  gagate chnget "analogIn1"
  gkgate = k(gagate)
  if (gkgate < 0.05) then
    gagate = 0
  endif

  afc	chnget "analogIn2"
  kfce	tablei k(afc), giexp, 1
  kfce 	= kfce * gimaxfc
  aq	chnget "analogIn3"
  kaq = k(aq) * gimaxq
  al	K35_lpf (ax * p4 * 0.6 * gagate), kfce, kaq
	
  adel	chnget "analogIn7"
  kdel 	port k(adel), giparamport
  gkdel = kdel * gimaxdel
  
  adel	interp gkdel
  ar	vdelay al, adel, gimaxdel
	out al, ar
endin


instr 3 ; subosc
  asub_on   chnget "analogIn6"
  ksub_port port k(asub_on), giparamport                                     
  kgate     port k(gagate), giparamport                                      
  khertz    = cpsmidinn(int(gkmidinote) - 12)                                
  asubl     poscil ksub_port * p4 * 0.6 * kgate, khertz, gisine              
  adel      interp gkdel                                                     
  asubr     vdelay asubl, adel, gimaxdel                                     
            outs asubl, asubr                                                
endin                                                                        
  
;ftmorf!

</CsInstruments>
<CsScore>

;f200 0 0 1 "./1.wav" 0 0 0
f0 z ; needed for -ve duration - i.e. hold note on

;	      st	   dur	   amp
i 1     0.1    -1     
i 2     0.1    -1     1
i 3     0.1    -1     1


e
</CsScore>
</CsoundSynthesizer>
