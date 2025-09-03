PRO Making_blanket_transmission_fits

;+
; Purpose  
;		Creates fits file for the thermal response of FOXSI 4
; 		
; 		Helpful links for making fits files in IDL: 
;		FX* libary: https://asd.gsfc.nasa.gov/archive/idlastro/contents.html
;		Example of making fits files: https://www.sdss3.org/dr10/software/goddard_doc.php
;
; Outputs		Read using: ta = mrdfits('FOXSI4_thermal_blanket_transmission.fits',0,header) 
;		A fits file. 
; 		Primary extension (HDU0) contains information on the materials in the thermal blanket
; 		Extension 1 (HDU0) contains a binary table of the energy and theoretical transmission
;
;
; Files required: 
;		foxsi_resp_fxbh.pro
;		foxsi_resp_fxbw.pro
;		foxsi4_theoretical_blanket_transmission.pro
;
;Version: 1.0 
; Nov25 2024
;

blanket_trans = foxsi4_theoretical_blanket_transmission(plot = 0)   ; Obtain theoretical transmission

data_for_fits = {energy:blanket_trans.energy_kev, theo_trans: blanket_trans.transmission}  ; Put data in a structure

; ================================================
; ================================================
; Making the initial fits file

filename = 'FOXSI4_thermal_blanket_transmission.fits'

fxhmake, header, /extend, /initialize,/date	;create basic fits primary header
fxwrite, filename, header		;write a fits file

; Modifying the Primary Header
name = ['NMYLAR','WMYLAR','TWMYLAR','NKAPTON','WKAPTON','TWKAPTON','NDRACON','WDRACON','TWDRACON','NVDA','WVDA','TWVDA']  ; N instead of L
value = [10, 6.35,63.5,2,50.8,101.6,11,30,330,22,0.1,2.2]
comment = [' ','[um]','[um]',' ','[um]','[um]',' ','[um]','[um]',' ','[um]','[um]']

for i = 0, n_elements(name) -1 do begin
	tli = comment[i]
	strpi = strpos(tli,':')
	tli1 = strtrim(strmid(tli, strpi[0]+1),2)
	FXHMODIFY, FILENAME, NAME[i], VALUE[i], tli
endfor

; ================================================
; ================================================
; Making the binary table in Extension 1 

nrows = N_ELEMENTS(data_for_fits) ;number of rows in the table
ncolumns = N_ELEMENTS(tag_names(data_for_fits)) ;number of columns in the table
print, nrows, ncolumns

fxbhmake, h0, 1

tag_labels = ['ENERGY','Theoretical Transmission']
title = strupcase(tag_names(data_for_fits,/struct))
tags = tag_names(data_for_fits)	


tli = tag_labels[0]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 1, h0, data_for_fits.energy, tags[0], tli1

tli = tag_labels[1]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 2, h0, data_for_fits.theo_trans, tags[1], tli1

fxbcreate, unit, filename, h0


temp = data_for_fits.energy
fxbwrite, unit, temp, 1, 1


temp = data_for_fits.Theo_trans
fxbwrite, unit, temp, 2, 1


fxbfinish, unit

; ================================================
; ================================================
; Modifying the header for the binary table

name_bt = ['TUNIT1']
value_bt = ['[keV]']
for i = 0, n_elements(name_bt) -1 do begin
	FXHMODIFY, FILENAME, NAME_bt[i], VALUE_bt[i], extension = 1
endfor

; ================================================
; ================================================

end




