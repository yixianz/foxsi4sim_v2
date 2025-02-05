Function foxsi4_resp_diag, pos = pos, energy_arr = energy_arr, att_wheel = att_wheel, plot = plot, let_file = let_file

; Purpose:
; Calculate FOXSI-4 instrument response (1D diagonol elements) as a function of energy for each telescope (Units: cm^2)
; 
; Note:
; Include response from optics, blanketing material, prefilters, attenuators, and detectors. 
; Position 0: MSFC high-resolution optics + CMOS
; Position 1: Nagoya high-resolution optics + CMOS
; Position 2: 10-shell optics + CdTe
; Position 3: MSFC high-resolution optics + pixelated attenuator + CdTe
; Position 4: Nagoya high-resolution optics + CdTe
; Position 5: 10-shell optics + pixelated attenuator + CdTe
; Position 6: MSFC high-resolution optics + Timepix
; Detector energy resolution not considered here (considered in foxsi4_resp_2d.pro and foxsi4_ct_spec.pro). 
; 
; Keywords:
; pos: position number (must be from 0 to 6)
; energy_arr: 1d energy array in keV (default is [1.00,1.01,1.02,...,41.00])
; att_wheel: set this to 1 to insert the attenutor wheel (only have effects on CdTe strip detectors)
; plot: set this to 1 to plot total effective area vs energy
; let_file: energy vs efficiency file for different CdTe detector low energy thresholds
;
; Outputs:
; Data structure that consists of energy array (keV) and effective area (cm2)
;
; Examples:
; resp = foxsi4_resp_diag(pos = 2, energy_arr = findgen(100)*0.2+1, plot = 1)
; resp = foxsi4_resp_diag(pos = 4, att_wheel = 1, plot = 1)
; resp = foxsi4_resp_diag(pos = 6, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang
; Apr 8 2024, add options for CdTe let efficiency file

Default, energy_arr, findgen(4000)*0.01+1
Default, att_wheel, 0
Default, plot, 0

; thickness of the uniform Al attenuator attached to the detector (only needed for Position 2 and 4)
;al_thickness = [0,0,380,0,113,0,0]
al_thickness = [0,0,0.015,0,0.005,0,0]*25400
; thicknesses of the Al attenuator on the insertable wheel (only needed for CdTe strip detectors)
;al_att_wheel = [0,0,390,145,190,335,0]
al_att_wheel = [0,0,0.015,0.006,0.007,0.013,0]*25400

If total(pos eq findgen(7)) ne 1 then begin
  print, "Error: position must be an integer between 0 and 6"
  return,0
Endif

;-------------------------------------------------------------------------------------
; Position 0: MSFC high-resolution optics + CMOS
If pos eq 0 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area 
  colli_trans = 0.4 ; optics collimator
  ; optics filter: 5um polymide C22H10N2O5 + 150 nm Al
  optf_poly = get_material_transmission('material_data/polymide_att_len.txt', 5., energy_arr = energy_arr)
  optf_al = get_material_transmission('material_data/al_att_len.txt', 0.15, energy_arr = energy_arr)
  optf_trans = optf_poly.transmission * optf_al.transmission
  optics.eff_area_cm2 = optics.eff_area_cm2 * colli_trans * optf_trans
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  ;blanketing= foxsi4_blanketing(energy_arr = energy_arr, kapton_um = 50.8) 
  atten = foxsi4_cmos_prefilter(energy_arr = energy_arr,cmos_pos = 0)    ; prefilter transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cmos = 1)      ; detector efficiency
Endif

; Position 1: Nagoya high-resolution optics + CMOS
If pos eq 1 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, nagoya_sxr = 1)     ; optics effective area (this already includes collimator and optics filters)
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  ;blanketing= foxsi4_blanketing(energy_arr = energy_arr, kapton_um = 50.8) 
  atten = foxsi4_cmos_prefilter(energy_arr = energy_arr,cmos_pos = 1)     ; prefilter transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cmos = 1)      ; detector efficiency
Endif

; Position 2: 10-shell optics + blanketing + uniform Al attenuator + CdTe
If pos eq 2 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, heritage = 1)     ; optics effective area
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  al_um = al_thickness[pos]
  If att_wheel eq 1 then al_um = al_um + al_att_wheel[pos]
  atten = foxsi4_attenuator(energy_arr = energy_arr, al_um = al_um, pixelated_att = 0)      ; attenuator transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1, let_file = let_file)      ; detector efficiency
Endif

; Position 3: MSFC high-resolution optics + blanketing + pixelated attenuator + CdTe
If pos eq 3 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  al_um = al_thickness[pos]
  If att_wheel eq 1 then al_um = al_um + al_att_wheel[pos]
  atten = foxsi4_attenuator(energy_arr = energy_arr, al_um = al_um, pixelated_att = 1)      ; attenuator transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1, let_file = let_file)      ; detector efficiency
Endif

; Position 4: Nagoya optics + blanketing + uniform Al attenuator + CdTe
If pos eq 4 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, nagoya_hxr = 1)     ; optics effective area
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  al_um = al_thickness[pos]
  If att_wheel eq 1 then al_um = al_um + al_att_wheel[pos]
  atten = foxsi4_attenuator(energy_arr = energy_arr, al_um = al_um, pixelated_att = 0)      ; attenuator transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1, let_file = let_file)      ; detector efficiency
Endif

; Position 5: 10-shell optics + blanketing + pixelated attenuator + CdTe
If pos eq 5 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, heritage = 1)     ; optics effective area
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  al_um = al_thickness[pos]
  If att_wheel eq 1 then al_um = al_um + al_att_wheel[pos]
  atten = foxsi4_attenuator(energy_arr = energy_arr, al_um = al_um, pixelated_att = 1)      ; attenuator transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1, let_file = let_file)      ; detector efficiency
Endif

; Position 6: MSFC high-resolution optics + blanketing + Timepix
If pos eq 6 then begin
  optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area
  blanketing= foxsi4_blanketing(energy_arr = energy_arr)      ; blanketing transmission
  al_um = al_thickness[pos]
  If att_wheel eq 1 then al_um = al_um + al_att_wheel[pos]
  atten = foxsi4_attenuator(energy_arr = energy_arr, al_um = al_um, pixelated_att = 0)      ; attenuator transmission
  detector = foxsi4_deteff(energy_arr = energy_arr, timepix = 1)      ; detector efficiency
Endif

; Final effective area
effarea = optics.eff_area_cm2 * blanketing.transmission * atten.transmission * detector.efficiency

If keyword_set(plot) then plot, energy_arr, effarea, xtitle = 'Energy (keV)', ytitle = 'Effective area (cm2)', $
  charsize = 1.4,  xr = [4,40], yr = [0.01,5], /xlog, /ylog, /xst, /yst

resp = create_struct("energy_keV", energy_arr, "eff_area_cm2", effarea)
return, resp

End
