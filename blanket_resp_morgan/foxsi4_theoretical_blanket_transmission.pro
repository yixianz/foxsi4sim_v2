Function foxsi4_theoretical_blanket_transmission, energy_arr = energy_arr, mylar_um = mylar_um, al_um = al_um, kapton_um = kapton_um, dracon_um, plot = plot


; Purpose:
; Get FOXSI-4 blanketing transmission as a function of energy
;
; Notes:
; FOXSI-1 Values: mylar - 139.7 um, al - 4.8 um, kapton - 203.2 um
; FOXSI-2 Values: mylar - 76.2 um, al - 2.5 um, kapton - 50.8 um
; FOXSI-3 Values: mylar - 76.2 um, al - 2.4 um, kapton - 0.0 um
; FOXSI4 - Values: mylar_um = 63.5, al_um = 2.2, kapton_um = 101.6, dracon = 330
; 
; Default is to use FOXSI-3 values
; 
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
; mylar_um: total thickness of Mylar in microns
; al_um: total thickness of Al in microns
; kapton_um: total thickness of Kapton (polymide) in microns
; dracon_um: total thickness of Dracon (mesh material) in microns
; plot: set this to 1 to plot energy vs blanketing transmission
; 
; Outputs:
; Data structure that consists of energy array (keV) and transmission
; 
; Examples:
; blanket_trans = ms_foxsi4_blanket_transmission(plot = 1)
; blanket_trans = ms_foxsi4_blanketing(mylar_um = 139.7, al_um = 4.8, kapton_um = 203.2, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang
; Version 2.0 Nov 2024 edited by M. Stores
; 		Added dracon thickness and updated default values.

Default, mylar_um, 63.5
Default, al_um, 2.2
Default, kapton_um, 101.6
Default, dracon_um, 330
Default, energy_arr, indgen(300)*0.1+1.0
Default, plot, 0

thickness = [mylar_um, al_um, kapton_um,dracon_um]
path = './Material Attenutor Lengths/'
files = path + [ 'mylar_att_len.txt', 'al_att_len.txt', 'polymide_att_len.txt','dracon_att_len.txt']

blanket_trans = fltarr(n_elements(energy_arr)) + 1. ;set transmission array to 1 when there is no material

For i = 0, n_elements(files)-1 do begin

  If thickness[i] ne 0 then begin
    ; get the transmission profile for each layer of material
    result = get_material_transmission(files[i], thickness[i], energy_arr = energy_arr)
    	
    	if i EQ 3 then begin  ; Transmission in the dracon mesh layer
    		result.transmission = (result.transmission*0.3+0.7)
    		blanket_trans = blanket_trans*result.transmission
    	
    	endif else blanket_trans = blanket_trans*result.transmission
  Endif  
Endfor

If keyword_set(plot) then plot, energy_arr, blanket_trans,  xtitle = 'Energy (keV)', ytitle = 'Transmission', charsize = 1.4

result = create_struct('energy_keV', energy_arr, 'transmission', blanket_trans)
return, result

End