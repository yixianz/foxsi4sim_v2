Function foxsi4_optics_effarea, energy_arr = energy_arr, heritage = heritage, msfc_hi_res =  msfc_hi_res, nagoya_hxr = nagoya_hxr, $
  nagoya_sxr = nagoya_sxr, plot = plot

; Purpose:
; Get FOXSI-4 optics effective area from previouly saved data file
;
; Note: 
; For heritage 10-shell optics, uses data from FOXSI-2 Module X-6.
; For Marshall high-resolution optics, use theoretical values for the innermost and the 3rd innermost shells (S10 and S08).
; For Nagoya optics of the HXR telescope: 
;   use simulation data that contains responses from mirror + housing 
; For Nagoya optics of the SXR telescope: 
;   use simulation data that contains responses from mirror + housing + collimator (40% transmission) + optic filter (5um polymide C22H10N2O5 + 150 nm Al) 
;
; Keywords:
; energy_arr: 1d array of enegy bin centers in keV
; heritage: set this to 1 to get effective area for heritage 10-shell optics
; msfc_hi_res: set this to 1 to get effective area for Marshall high-resolution optics
; nagoya_hxr: set this to 1 to get effective area for Nagoya optics of the HXR telescope
; nagoya_sxr: set this to 1 to get effective area for Nagoya optics of the SXR telescope
; plot: set this to 1 to plot the effective area vs energy
;
; Outputs:
; Data structure that consists of energies in keV and effective areas in cm^2
;
; Examples:
; effective_area = foxsi4_optics_effarea(heritage = 1, plot = 1)
; effective_area = foxsi4_optics_effarea(msfc_hi_res = 1, plot = 1)
; effective_area = foxsi4_optics_effarea(nagoya_sxr = 1, energy_arr = indgen(200)*0.2+1, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang

Default, energy_arr, indgen(300)*0.1+1.
Default, heritage, 0
Default, msfc_hi_res, 0
Default, nagoya_hxr, 0
Default, nagoya_sxr, 0

If total(heritage+msfc_hi_res+nagoya_hxr+nagoya_sxr) ne 1 then begin
  print, 'Error: please choose 1 optics module - set (only) one of below keywords: heritage, msfc_hi_res, nagoya_hxr, nagoya_sxr'
  return, 0
Endif

; Effective area for heritage 10-shell optics
If heritage eq 1 then begin
  ;filename = './optics_data/FOXSI2_Module_X-6_EA_pan.txt'
  filename = './optics_data/FOXSI3_Module_X-7_EA_pan.txt'
  energy = [4.5,  5.5,  6.5,  7.5,  8.5,  9.5, 11. , 13. , 15. , 17. , 19. , 22.5, 27.5]; all effarea use same energy bins
  data = read_ascii(filename, DATA_START=4, DELIMITER=",") 
  eff_area = data.field01[5,*]
  eff_area = interpol(eff_area, energy, energy_arr)
Endif

; Effective area for Marshall high-resolution optics (roughness of 14\AA with EPDL model)
If msfc_hi_res eq 1 then begin
  filename = './optics_data/3Inner_EA_EPDL97_14AA.csv' 
  ;filename = './optics_data/3Inner_EA_Windt_15AA.csv' ; roughness of 15\AA with Windt model 
  data = read_csv(filename)
  energy = data.field2 ; in kev
  eff_area = data.field5 + data.field3 ; in cm2 ; we use the innermost and the 3rd innermost shells (S10 and S08)
  eff_area = interpol(eff_area, energy, energy_arr)
Endif

; Effective area for Nagoya optics (HXR/SXR)
If nagoya_hxr eq 1 or nagoya_sxr eq 1 then begin
  if nagoya_hxr eq 1 then filename = 'optics_data/effective-area_raytracing_hard-xray-optic_on-axis.txt' $
    else filename = 'optics_data/effective-area_raytracing_soft-xray-optic_on-axis.txt'
  data = read_ascii(filename, DATA_START=1)
  energy = data.field1[0,*] ; in kev
  eff_area = data.field1[1,*] / 100  ;covert from mm2 to cm2
  eff_area = interpol(eff_area, energy, energy_arr)  
Endif

eff_area = eff_area > 0. ; There might be small negative values due to interpolation - set them all to 0.
If keyword_set(plot) then begin
  plot, energy_arr, eff_area, xtitle = 'energy (keV)', ytitle = 'effective area (cm2)',charsize = 1.5
Endif

effective_area = create_struct("energy_kev", energy_arr, "eff_area_cm2", eff_area)
return, effective_area

End