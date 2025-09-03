Function foxsi4_blanketing, energy_arr = energy_arr, mylar_um = mylar_um, al_um = al_um, kapton_um = kapton_um, $
  dacron_um = dacron_um, fp_mylar = fp_mylar, plot = plot


; Purpose:
; Get FOXSI-4 blanketing transmission as a function of energy
;
; Notes:
; FOXSI-1 Values: mylar - 139.7 um, al - 4.8 um, kapton - 203.2 um
; FOXSI-2 Values: mylar - 76.2 um, al - 2.5 um, kapton - 50.8 um
; FOXSI-3 Values: mylar - 76.2 um, al - 2.4 um, kapton - 0.0 um
; FOXSI-4 Values: mylar - 63.5 um, al - 2.2 um, kapton - 101.6 um, dacron - 330 um (70% open)
; 
; Default is to use FOXSI-4 values
; 
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
; mylar_um: total thickness of Mylar in microns
; al_um: total thickness of Al in microns
; kapton_um: total thickness of Kapton (polymide) in microns
; dracon_um: total thickness of Dracon (mesh material) in microns
; fp_mylar: set this to 1 to add the thin mylar piece (0.25mil mylar + 2000A Al) on the detector side
; plot: set this to 1 to plot energy vs blanketing transmission
; 
; Outputs:
; Data structure that consists of energy array (keV) and transmission
; 
; Examples:
; blanket_trans = foxsi4_blanketing(plot = 1)
; blanket_trans = foxsi4_blanketing(mylar_um = 139.7, al_um = 4.8, kapton_um = 203.2, dacron_um = 0, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang
; Feb 2025, updated with Morgan's routine (Added dracon thickness and updated default values)
; Feb 2025, Y. Zhang, added the thin mylar on the detector side, fixed typo
; Mar 2025, Y. Zhang, correct the Al layer thickness of the FP thin mylar (multiply by 2)

Default, mylar_um, 63.5
Default, al_um, 2.2
Default, kapton_um, 101.6
Default, dacron_um, 330
Default, energy_arr, indgen(300)*0.1+1.0
Default, fp_mylar, 0
Default, plot, 0

thickness = [mylar_um, al_um, kapton_um,dacron_um]
path = 'material_data/'
files = path + [ 'mylar_att_len.txt', 'al_att_len.txt', 'polymide_att_len.txt','dacron_att_len.txt']

blanket_trans = fltarr(n_elements(energy_arr)) + 1. ;set transmission array to 1 when there is no material

For i = 0, n_elements(files)-1 do begin

  If thickness[i] ne 0 then begin
    ; get the transmission profile for each layer of material
    result = get_material_transmission(files[i], thickness[i], energy_arr = energy_arr)
      
      if i EQ 3 then begin  ; Transmission in the dacron mesh layer
        result.transmission = (result.transmission*0.3+0.7)
        blanket_trans = blanket_trans*result.transmission
      
      endif else blanket_trans = blanket_trans*result.transmission
  Endif  
Endfor

If fp_mylar eq 1 then begin  ; focal-plane mylar piece
  fp_mylar_trans = get_material_transmission('material_data/mylar_att_len.txt', 6.35, energy_arr = energy_arr)
  fp_al_trans = get_material_transmission('material_data/al_att_len.txt', 0.2, energy_arr = energy_arr)
  blanket_trans = blanket_trans*fp_mylar_trans.transmission*fp_al_trans.transmission 
Endif

If keyword_set(plot) then plot, energy_arr, blanket_trans,  xtitle = 'Energy (keV)', ytitle = 'Transmission', charsize = 1.4

result = create_struct('energy_keV', energy_arr, 'transmission', blanket_trans)
return, result

End