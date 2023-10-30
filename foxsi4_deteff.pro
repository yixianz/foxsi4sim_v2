Function foxsi4_deteff, energy_arr = energy_arr, cdte = cdte, cmos = cmos, timepix = timepix, elec_coverage = elec_coverage, plot = plot

; Purpose:
; Get FOXSI-4 detector efficiency
; 
; Notes:
; Efficiency is theoretical based on materials and their thicknesses.
; For CdTe:
;    Detector thickness, electrodes thickness and coverage, and the efficiency curve at low energy threshold are taken into account.
;    The electrode coverage is not uniform accross the detector (0.5 for finest pitch, 0.375 for the second finest pitch, and 0.3
;    for the coarsest pitch); here 0.5 is used - differences when using 0.3 are very small. The low energy threshold 
;    efficiency curve is generated based on Fe-55 threshold scan data measured by Nagasawa san (see Ishikawa et al 2016
;    for method https://arxiv.org/abs/1606.03887).
; For CMOS,
;    Use FOXSI-3 prefilter design. Need to update.
; For Timepix,
;    This is a rough estimate based on Timepix thickness but with FOXSI-3 CdTe detector electrodes. 
;    Low energy threshold efficiency not implemented.
;    Need to update.
;
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
; cdte: set this to 1 to get efficiency for the CdTe strip detector
; cmos: set this to 1 to get efficiency for the CMOS detector
; timepix: set this to 1 to get efficiency for the Timepix3 detector
; elec_coverage: electrode coverage (fraction). If not set, use 0.5 for CdTe and Timepix. Ignored for CMOS.
; plot: set this to 1 to efficiency vs energy
; 
; Outputs:
; Data structure that consists of energies in keV and efficiency.
; 
; Examples:
; deteff = foxsi4_deteff(energy_arr = indgen(30)+1.0, cdte = 1, plot = 1)
; deteff = foxsi4_deteff(cmos = 1, plot = 1)
; deteff = foxsi4_deteff(timepix = 1, elec_coverage = 0.4, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang

Default, energy_arr, indgen(300)*0.1+1.0
Default, cdte, 0
Default, cmos, 0
Default, timepix, 0
Default, plot, 0

db_dir = 'material_data/'

If total(cdte+cmos+timepix) ne 1 then begin
  print, 'Error: please choose 1 detector - set (only) one of below keywords: cdte, cmos, timepix'
  return, 0
Endif

; -----------------------------------------------------------------------------------------------------------------------------------
; CdTe detector
If cdte eq 1 then begin
  
  ; transmission of the electrodes: Pt(~30nm) + Au(30nm) + Ni(1000nm) + Au(50nm)
  pt_thick_um = 0.03
  au_thick_um = 0.08
  ni_thick_um = 1.
  If not keyword_set(elec_coverage) then elec_coverage = 0.5   ; electrode coverage
  pt_trans = get_material_transmission(db_dir + 'pt_att_len.txt', pt_thick_um, energy_arr = energy_arr)
  au_trans = get_material_transmission(db_dir + 'au_att_len.txt', au_thick_um, energy_arr = energy_arr)
  ni_trans = get_material_transmission(db_dir + 'ni_att_len.txt', pt_thick_um, energy_arr = energy_arr)
  elec_trans = pt_trans.transmission * au_trans.transmission * ni_trans.transmission * elec_coverage + (1 - elec_coverage)
  
  ; absorption of CdTe
  cdte_thick_um = 750 
  cdte_trans = get_material_transmission(db_dir + 'cdte_att_len.txt', cdte_thick_um, energy_arr = energy_arr)
  cdte_absor = 1 - cdte_trans.transmission
  
  ; low energy threshold 
  ; see Ishikawa et al 2016 for method (https://arxiv.org/abs/1606.03887)
  ; using data and fit parameters from Nagasawa san
  let = 0.5*(erf((energy_arr/0.732-5)/sqrt(2)/2.769)+1)

  det_eff = elec_trans * cdte_absor * let

Endif

; -----------------------------------------------------------------------------------------------------------------------------------
; CMOS detector
If cmos eq 1 then begin
  
  ; transmission of pre-filter
  prefilter_al = 0.45
  prefilter_poly = 2
  al_trans = get_material_transmission(db_dir + 'al_att_len.txt', prefilter_al, energy_arr = energy_arr)
  poly_trans = get_material_transmission(db_dir + 'polymide_att_len.txt', prefilter_poly, energy_arr = energy_arr)
  prefilter_trans = al_trans.transmission * poly_trans.transmission
  
  ; absorption of Si
  si_thick_um = 25
  si_trans = get_material_transmission(db_dir + 'si_att_len.txt', si_thick_um, energy_arr = energy_arr)
  si_absor = 1 - si_trans.transmission
  
  det_eff = prefilter_trans*si_absor
  
Endif

; -----------------------------------------------------------------------------------------------------------------------------------
; Timepix detector
; This is temporary using cdte strip electrodes and LET. (Need to update!)
If timepix eq 1 then begin
  
  ; transmission of the electrodes
  au_thick_um = 0.1
  pt_thick_um = 0.05
  If not keyword_set(elec_coverage) then elec_coverage = 0.3
  au_trans = get_material_transmission(db_dir + 'au_att_len.txt', au_thick_um, energy_arr = energy_arr)
  pt_trans = get_material_transmission(db_dir + 'pt_att_len.txt', pt_thick_um, energy_arr = energy_arr)
  elec_trans = au_trans.transmission * pt_trans.transmission * elec_coverage + (1 - elec_coverage)
  
  ; absorption of CdTe
  cdte_thick_um = 1000
  cdte_trans = get_material_transmission(db_dir + 'cdte_att_len.txt', cdte_thick_um, energy_arr = energy_arr)
  cdte_absor = 1 - cdte_trans.transmission

  ; low energy threshold efficiency (to be implemented)
  let = 1.
  det_eff = elec_trans * cdte_absor * let

Endif

If keyword_set(plot) then plot, energy_arr, det_eff, xtitle = 'Energy (keV)', ytitle = 'Efficiency', charsize = 1.4
eff = create_struct("energy_keV", energy_arr, "efficiency", det_eff)
return, eff

End