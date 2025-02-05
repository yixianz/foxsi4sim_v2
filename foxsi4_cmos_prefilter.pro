Function foxsi4_cmos_prefilter, energy_arr = energy_arr, cmos_pos = cmos_pos, plot = plot

; Purpose:
; Get transmission profiles for the prefilters in front of the CMOS detectors
; 
; Notes:
; For Position 0 (paired with MSFC optics), filters are (150 nm Al + 5 um polymide) x 2
; For Position 1 (paired with Nagoya optics), filers are:
;   (150 nm Al + 5 um polymide) + (150 nm Al + 25 um polymide) + (150 nm Al + 50 um polymide)
;
; Keywords:
; energy_arr: 1d array of enegy bin centers in keV
; cmos_pos: position of the cmos detector (0 or 1)
;
; Outputs:
; Data structure that consists of energies in keV and transmission.
; 
; Examples:
; prefilter_trans = foxsi4_cmos_prefilter(cmos_pos = 0, plot = 1)
; prefilter_trans = foxsi4_cmos_prefilter(cmos_pos = 1, energy_arr = indgen(30)+1.0, plot = 1)
;
; History:
; Nov 2023, created by Y. Zhang

Default, energy_arr, indgen(300)*0.1+1.0
Default, plot, 0

If cmos_pos ne 0 and cmos_pos ne 1 then begin
  print, 'Error: CMOS position must be 0 or 1'
  return, 0
Endif

; Position 0 (paired with MSFC optics):
If cmos_pos eq 0 then begin
  al_tot_um = 0.15 * 2
  poly_tot_um = 5. * 2
Endif

; Position 1 (paired with Nagoya optics):
If cmos_pos eq 1 then begin
  al_tot_um = 0.15 * 3
  poly_tot_um = 5. + 25 + 50
Endif

al_trans = get_material_transmission('material_data/al_att_len.txt', al_tot_um, energy_arr = energy_arr)
poly_trans = get_material_transmission('material_data/polymide_att_len.txt', poly_tot_um, energy_arr = energy_arr)
prefilter_trans = al_trans.transmission * poly_trans.transmission

If keyword_set(plot) then plot, energy_arr, prefilter_trans, xtitle = 'Energy (keV)', ytitle = 'Transmission', charsize = 1.4
result = create_struct("energy_keV", energy_arr, "transmission", prefilter_trans)  

Return, result

End