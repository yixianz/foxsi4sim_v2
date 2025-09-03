Function foxsi4_obf, energy_arr = energy_arr, plot = plot
  ; Purpose:
  ; Generate transmission profiles for the optics blocking filter (OBF) in SXR telescopes
  ;
  ; Notes:
  ; Materials: 5um polymide C22H10N2O5 + 150 nm Al
  ; 
  ; Keywords:
  ; energy_arr: 1d array of enegy bin centers in keV
  ; plot: set this to 1 to plot energy vs blanketing transmission
  ;
  ; Outputs:
  ; Data structure that consists of energies in keV and transmission.
  ;
  ; Examples:
  ; obf_trans = foxsi4_obf(energy_arr = indgen(30)+1.0, plot = 1)
  ;
  ; History:
  ; Feb 2025, created by Y. Zhang
  
  Default, energy_arr, indgen(300)*0.1+1.0
  Default, plot, 0

  poly_trans = get_material_transmission('material_data/polymide_att_len.txt', 5., energy_arr = energy_arr)
  al_trans = get_material_transmission('material_data/al_att_len.txt', 0.15, energy_arr = energy_arr)
  obf_trans = poly_trans.transmission * al_trans.transmission
 
  If keyword_set(plot) then plot, energy_arr, obf_trans,  xtitle = 'Energy (keV)', ytitle = 'Transmission', charsize = 1.4

  result = create_struct('energy_keV', energy_arr, 'transmission', obf_trans)
  return, result

End