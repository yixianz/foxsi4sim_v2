Function foxsi4_deteff, energy_arr = energy_arr, cdte = cdte, cmos = cmos, timepix = timepix, elec_coverage = elec_coverage, plot = plot, $
            let_file = let_file

; Purpose:
; Get FOXSI-4 detector efficiency
; 
; Notes:
; Efficiency is theoretical based on materials and their thicknesses.
; For CdTe:
;    Detector thickness, electrodes thickness and coverage, and the efficiency curve at low energy threshold are taken into account.
;    The electrode coverage is not uniform accross the detector (0.5 for finest pitch, 0.375 for the second finest pitch, and 0.3
;    for the coarsest pitch); here the average value of 0.36 is used for default - differences when using 0.5 are very small. The low energy threshold 
;    efficiency curve is generated based on Fe-55 threshold scan data measured by Nagasawa san (see Ishikawa et al 2016
;    for method https://arxiv.org/abs/1606.03887). Results from 2025 UMN measurements are NOT implemented!!
; For CMOS:
;    Only consider photoabsorption of Si.
; For Timepix:
;    This is a rough estimate based on Timepix thickness assuming a similar low energy threshold efficiency as the CdTe strip detectors.
;    Electrode attenuation not implemented. This needs to be updated in the future.
;
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
; cdte: set this to 1 to get efficiency for the CdTe strip detector
; cmos: set this to 1 to get efficiency for the CMOS detector
; timepix: set this to 1 to get efficiency for the Timepix3 detector
; elec_coverage: electrode coverage (fraction). If not set, use 0.36 (average value) for CdTe. Ignored for CMOS and Timepix.
; plot: set this to 1 to efficiency vs energy
; let_file: energy vs efficiency file for different low energy thresholds
; 
; Outputs:
; Data structure that consists of energies in keV and efficiency.
; 
; Examples:
; deteff = foxsi4_deteff(energy_arr = indgen(150)*0.2+1.0, cdte = 1, plot = 1)
; deteff = foxsi4_deteff(cmos = 1, plot = 1)
; deteff = foxsi4_deteff(timepix = 1, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang
; Apr 2024, updated by Y. Zhang, added effiency files for different low energy thresholds for CdTe
; Feb 2025, updated by Y. Zhang, fixed typos; modified Timepix efficiency but this is still guesstimated

Default, energy_arr, indgen(300)*0.1+1.0
Default, cdte, 0
Default, cmos, 0
Default, timepix, 0
Default, plot, 0
Default, let_file, 'vth_5.csv'

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
  If not keyword_set(elec_coverage) then elec_coverage = 0.36   ; electrode coverage
  pt_trans = get_material_transmission(db_dir + 'pt_att_len.txt', pt_thick_um, energy_arr = energy_arr)
  au_trans = get_material_transmission(db_dir + 'au_att_len.txt', au_thick_um, energy_arr = energy_arr)
  ni_trans = get_material_transmission(db_dir + 'ni_att_len.txt', ni_thick_um, energy_arr = energy_arr)
  elec_trans = pt_trans.transmission * au_trans.transmission * ni_trans.transmission * elec_coverage + (1 - elec_coverage)
  
  ; absorption of CdTe
  cdte_thick_um = 750 
  cdte_trans = get_material_transmission(db_dir + 'cdte_att_len.txt', cdte_thick_um, energy_arr = energy_arr)
  cdte_absor = 1 - cdte_trans.transmission
  
  ; low energy threshold 
  ; see Ishikawa et al 2016 for method (https://arxiv.org/abs/1606.03887)
  ; using data and fit parameters from Nagasawa san
  ;let = 0.5*(erf((energy_arr/0.6865-5)/sqrt(2)/2.769)+1)  ; Note: this has been updated, see below!!
  
  ; load the low energy threshold efficiency file
  path = '/Users/zyx/Documents/foxsi/foxsi4sim_v2/cdte_let_eff/'
  filename = path + let_file
  data = read_csv(filename) 
  let = interpol(data.field2, data.field1, energy_arr)

  det_eff = elec_trans * cdte_absor * let

Endif

; -----------------------------------------------------------------------------------------------------------------------------------
; CMOS detector
If cmos eq 1 then begin
    
  ; absorption of Si
  si_thick_um = 25
  si_trans = get_material_transmission(db_dir + 'si_att_len.txt', si_thick_um, energy_arr = energy_arr)
  si_absor = 1 - si_trans.transmission
  
  det_eff = si_absor

Endif

; -----------------------------------------------------------------------------------------------------------------------------------
; Timepix detector
; This is temporary using cdte strip electrodes and LET. (Need to update!)
If timepix eq 1 then begin
  
  ; transmission of the electrodes (to be implemented)
  elec_trans = 1
  
  ; absorption of CdTe
  cdte_thick_um = 1000
  cdte_trans = get_material_transmission(db_dir + 'cdte_att_len.txt', cdte_thick_um, energy_arr = energy_arr)
  cdte_absor = 1 - cdte_trans.transmission

  ; low energy threshold efficiency (to be updated)
  path = '/Users/zyx/Documents/foxsi/foxsi4sim_v2/cdte_let_eff/'
  filename = path + let_file
  data = read_csv(filename)
  let = interpol(data.field2, data.field1, energy_arr)
  det_eff = elec_trans * cdte_absor * let

Endif

If keyword_set(plot) then plot, energy_arr, det_eff, xtitle = 'Energy (keV)', ytitle = 'Efficiency', charsize = 1.4
eff = create_struct("energy_keV", energy_arr, "efficiency", det_eff)

return, eff

End