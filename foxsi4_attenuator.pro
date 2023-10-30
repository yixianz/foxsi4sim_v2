Function foxsi4_attenuator, energy_arr = energy_arr, al_um = al_um, pixelated_att = pixelated_att, plot = plot

; Purpose:
; Get FOXSI-4 attenuator transmission as a function of energy
;
; Notes:
; Two types of attenuators: uniform Al attenuator or microfabricated pixelated attenuator
; Can choose one of them or use both 
;
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
; al_um: thickness of the uniform Al attenuator (default is 200)
; pixelated_att: set this to 1 to get transmission from microfabricated pixelated attenuator
; plot: set this to 1 to plot transmission vs energy
; 
; Outputs:
; Data structure that consists of energies in keV and transmission
; 
; Examples:
; att_trans = foxsi4_attenuator(al_um = 300, pixelated_att = 0, plot = 1)
; att_trans = foxsi4_attenuator(al_um = 0, pixelated_att = 1, plot = 1)
; att_trans = foxsi4_attenuator(energy_arr = findgen(40)+1, al_um = 120, pixelated_att = 1, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang


Default, al_um, 0
Default, pixelated_att, 0
Default, energy_arr, findgen(300)*0.1+1.0

att_trans = fltarr(n_elements(energy_arr)) + 1    ;set transmission array to 1 when there is no attenuator

; uniform Al attenuator
If al_um gt 0 then begin
  result = get_material_transmission('material_data/al_att_len.txt', al_um, energy_arr = energy_arr)
  att_trans = att_trans*result.transmission
Endif

; pixelated attenuator
If pixelated_att eq 1 then begin
  file =  'material_data/foxsi4_perforated_attenuator_em2_transmission.csv'
  opt = read_csv(file)
  en = opt.field1
  factor = opt.field2
  IF keyword_set(energy_arr) THEN BEGIN
    factor = interpol(factor, en, energy_arr)
  Endif
  att_trans = att_trans*factor
Endif

If keyword_set(plot) then plot, energy_arr, att_trans, xtitle = 'Energy (keV)', ytitle = 'Transmission', charsize = 1.4
result = create_struct("energy_keV", energy_arr, "transmission", att_trans)  

RETURN, result

End