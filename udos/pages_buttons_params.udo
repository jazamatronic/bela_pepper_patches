; outputs: 	k = current page
; intputs: 	k = button input, one or zero - will be transformed into a trigger
; 		i = number of pages 
; Everytime there is a posedge on channel, increment current page
; and wrap around to zero when we hit the number of pages
opcode page_incr_count_wrap, k, ki
	kpage init 0
	kpagebtn, inum xin
	kchantrig changed kpagebtn
	if (kchantrig == 1 && kpagebtn == 1) then
		kpage = kpage + 1
		if (kpage == inum) then
			kpage = 0
		endif
	endif
	xout kpage
endop

; outputs:	k = a parameter that has been locked
; intputs:	k = the input value of the param source
;		  This should be between 0 and 1
;		i = init value
;		i = The page number the parameter is found on
;		k = The current page
;		i = The threshold
; Output a lockable parameter - as soon as the current page is not equal
;	to the specified page number, the parameter is locked and will continue
; to output its previous value.
; To unlock, the current page should equal the page number and the value
; from the channel should be within threshold of the previous value
; 
opcode locked_param, k, kiiki
	kin, iinit, ipage, kcurpage, ithresh xin
	kparam init iinit
	klocked init 1
	if (kcurpage == ipage) then
		if (klocked == 1) then
			if (abs(kin - kparam) < ithresh) then
				klocked = 0
				kparam = kin
			endif
		else
			kparam = kin
		endif
	else
		klocked = 1
	endif
	xout kparam
endop

; outputs:	k = a variable that toggles between zero and one on each rising edge of the input
; intputs:	i = switch signal that's either zero or one, like from a momentary switch
; simple toggle detector
; may need to add some debounce mechanism on real hardware but seems to work 
; on a non-latching button widget
opcode toggle_button, k, i
  iindex xin
  kout init 0
  ktoggle digiInBela iindex
  kchanged changed ktoggle
  if (kchanged == 1 && ktoggle == 1) then
    if (kout == 0) then
    	kout = 1
    else
    	kout = 0
    endif
  endif
  xout kout
endop

; outputs:	k = a variable that toggles between zero and one on each rising edge of the input
; intputs:	k = switch signal that's either zero or one, like from a momentary switch
; simple toggle detector
; may need to add some debounce mechanism on real hardware but seems to work 
; on a non-latching button widget
opcode toggle_buttonk, k, k
  ktoggle xin
  kout init 0
  kchanged changed ktoggle
  if (kchanged == 1 && ktoggle == 1) then
    if (kout == 0) then
    	kout = 1
    else
    	kout = 0
    endif
  endif
  xout kout
endop

