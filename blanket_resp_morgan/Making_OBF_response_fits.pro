PRO Making_OBF_response_fits

; ================================================
; ================================================
; Making the initial fits file

filename = 'FOXSI4_OBF_response.fits'

fxhmake, header, /extend, /initialize,/date	;create basic fits primary header
fxwrite, filename, header		;write a fits file

; Modifying the Primary Header
name = ['COMMENT']  ; N instead of L
value = 'Design values: a 5-um-thick polyimide film coated with 0.15-um-thick Al'
comment = [' ']

tli = comment
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
FXHMODIFY, FILENAME, NAME, VALUE, tli


; ================================================
; ================================================
 ta = mrdfits('FOXSI4_OBF_RESPONSE.fits',0,header) 
 print, header
 
 END