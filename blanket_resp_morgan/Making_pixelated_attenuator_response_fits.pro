PRO Making_pixelated_attenuator_response_fits

;+
; Purpose  
;		Creates fits file for the thermal response of FOXSI 4
; 		
; 		Helpful links for making fits files in IDL: 
;		FX* libary: https://asd.gsfc.nasa.gov/archive/idlastro/contents.html
;		Example of making fits files: https://www.sdss3.org/dr10/software/goddard_doc.php
;
;		The data is located in the FOXSI google drive: 'FOXSI/FOXSI-4 Flight 36.370/Flight Science/Response work/Attenuator data analysis/gsfc_foxsi_attenuator_analysis/20240607_fosxi4_transmission.csv'
;
; Outputs		Read using: ta = mrdfits('FOXSI4_pixelated_attenuator_response.fits',0,header) 
;		A fits file. 
; 		Primary extension (HDU0) 
; 		Extension 1 (HDU0) contains a binary table of the energy and theoretical transmission
;		Extension 2 (HDU0) contains a binary table of the energy and modelled transmission
;
; Files required: 
;		foxsi_resp_fxbh.pro
;		foxsi_resp_fxbw.pro
;		foxsi4_theoretical_blanket_transmission.pro
;
; Version: 1.0 
; Nov27 2024
;

Result = READ_CSV( '20240607_fosxi4_transmission.csv',count = data, header = header) 

data_for_fits_extension1 = {energy:result.field1, theo_trans: result.field1}  ; Put data in a structure
data_for_fits_extension2 = {energy:result.field1, model_trans: result.field2} 
; ================================================
; ================================================
; Making the initial fits file

filename = 'FOXSI4_pixelated_attenuator_response.fits'

fxhmake, header, /extend, /initialize,/date	;create basic fits primary header
fxwrite, filename, header		;write a fits file

; Modifying the Primary Header
name = ['VERSION']  
value = [1]
comment = [' ']

for i = 0, n_elements(name) -1 do begin
	tli = comment[i]
	strpi = strpos(tli,':')
	tli1 = strtrim(strmid(tli, strpi[0]+1),2)
	FXHMODIFY, FILENAME, NAME[i], VALUE[i], tli
endfor

; ================================================
; ================================================
; Making the binary table in Extension 1 

nrows = N_ELEMENTS(data_for_fits_extension1) ;number of rows in the table
ncolumns = N_ELEMENTS(tag_names(data_for_fits_extension1)) ;number of columns in the table
print, nrows, ncolumns

fxbhmake, h0, 1

tag_labels = ['ENERGY','Theoretical Transmission']
title = strupcase(tag_names(data_for_fits_extension1,/struct))
tags = tag_names(data_for_fits_extension1)	


tli = tag_labels[0]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 1, h0, data_for_fits_extension1.energy, tags[0], tli1

tli = tag_labels[1]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 2, h0, data_for_fits_extension1.theo_trans, tags[1], tli1

fxbcreate, unit, filename, h0


temp = data_for_fits_extension1.energy
fxbwrite, unit, temp, 1, 1


temp = data_for_fits_extension1.Theo_trans
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

; ================================================
; ================================================
; Making the binary table in Extension 2

nrows = N_ELEMENTS(data_for_fits_extension2) ;number of rows in the table
ncolumns = N_ELEMENTS(tag_names(data_for_fits_extension2)) ;number of columns in the table
print, nrows, ncolumns

fxbhmake, h0, 1

tag_labels = ['ENERGY','Modelled Transmission']
title = strupcase(tag_names(data_for_fits_extension2,/struct))
tags = tag_names(data_for_fits_extension2)	


tli = tag_labels[0]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 1, h0, data_for_fits_extension2.energy, tags[0], tli1

tli = tag_labels[1]
strpi = strpos(tli,':')
tli1 = strtrim(strmid(tli, strpi[0]+1),2)
fxbaddcol, 2, h0, data_for_fits_extension2.model_trans, tags[1], tli1

fxbcreate, unit, filename, h0


temp = data_for_fits_extension2.energy
fxbwrite, unit, temp, 1, 1


temp = data_for_fits_extension2.model_trans
fxbwrite, unit, temp, 2, 1


fxbfinish, unit

; ================================================
; ================================================
; Modifying the header for the binary table

name_bt = ['TUNIT1']
value_bt = ['[keV]']
for i = 0, n_elements(name_bt) -1 do begin
	FXHMODIFY, FILENAME, NAME_bt[i], VALUE_bt[i], extension = 2
endfor

; ================================================
; ================================================
end
