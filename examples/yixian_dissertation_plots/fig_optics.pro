Pro fig_optics
  ; Plotting effective area for different types of optics

  popen,'dissertation_plots/optics_effarea.ps', xsi=8, ysi=2.6, /port
  !p.multi=[0,3,1]
  !X.margin=4.
  !Y.margin=2.
  !X.thick = 1.6
  !Y.thick = 1.6
  !P.FONT = 0
  hsi_linecolors
  PLOTSYM, 0, /FILL 
  
  ;---------------------10-shell optics---------------------
  energy = [4.5,  5.5,  6.5,  7.5,  8.5,  9.5, 11. , 13. , 15. , 17. , 19. , 22.5, 27.5]
  heri_optics_x7 = foxsi4_optics_effarea(energy_arr = energy, heritage = 1, heri_module = 7)
  heri_optics_x8 = foxsi4_optics_effarea(energy_arr = energy, heritage = 1, heri_module = 8)
  plot, heri_optics_x7.energy_kev, heri_optics_x7.eff_area_cm2,psym=8,symsize=0.1,charsize = 1.5, charthick=1., $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!U2!N)', title = 'Heritage 10-shell optics'
  oplot, heri_optics_x7.energy_kev, heri_optics_x7.eff_area_cm2, psym=8, symsize=0.5, color = cgcolor("Dodger Blue")
  oplot, heri_optics_x7.energy_kev, heri_optics_x7.eff_area_cm2, thick=3, color = cgcolor("Dodger Blue")
  oplot, heri_optics_x8.energy_kev, heri_optics_x8.eff_area_cm2, psym=8, symsize=0.5, color = cgcolor("Orange")
  oplot, heri_optics_x8.energy_kev, heri_optics_x8.eff_area_cm2, thick=3, color = cgcolor("Orange")
  
  al_legend, ['Module X7 (lab)', 'Module X8 (lab)'], $
    textcolors = 0, color=[cgcolor("Dodger Blue"),cgcolor("Orange")], linestyle = 0, $
    charsize = 0.7, linsize = 0.6, thick=3, /right

  ;---------------------MSFC high-resolution optics---------------------
  msfc_hires_hxr = foxsi4_optics_effarea(energy_arr = indgen(350)*0.1+1, msfc_hi_res = 1, msfc_hires_mdl='EPDL') 
  colli_trans = 0.42 ; pre-collimator transmission
  obf = foxsi4_obf(energy_arr = indgen(350)*0.1+1)    ; OBF transmission
  msfc_hires_sxr_ea = msfc_hires_hxr.eff_area_cm2 * obf.transmission * colli_trans
  
  plot, msfc_hires_hxr.energy_kev, msfc_hires_hxr.eff_area_cm2, charsize = 1.5, charthick=1., xr=[0,30], thick=2.5, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!U2!N)', title = 'MSFC high-resolution optics'
  oplot, msfc_hires_hxr.energy_kev, msfc_hires_sxr_ea, thick=3, color = cgcolor("red")
  
  al_legend, ['HXR telescope', 'SXR telescope'], $
    textcolors = 0, color=[0,cgcolor("red")], linestyle = 0, $
    charsize = 0.7, linsize = 0.6, thick=3, /right

  ;---------------------Nagoya high-resolution optics---------------------
  nagoya_hxr = foxsi4_optics_effarea(energy_arr = indgen(350)*0.1+0.1, nagoya_hxr = 1) 
  nagoya_sxr = foxsi4_optics_effarea(energy_arr = indgen(350)*0.1+0.1, nagoya_sxr = 1)
  plot, nagoya_hxr.energy_kev, nagoya_hxr.eff_area_cm2, charsize = 1.5, charthick=1., xr=[0,30], thick=2.5, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!U2!N)', title = 'Nagoya high-resolution optics'
  oplot, nagoya_sxr.energy_kev, nagoya_sxr.eff_area_cm2, thick=3, color = cgcolor("red")

  al_legend, ['HXR telescope', 'SXR telescope'], $
    textcolors = 0, color=[0,cgcolor("red")], linestyle = 0, $
    charsize = 0.7, linsize = 0.6, thick=3, /right
  
  pclose
  cgPS2PDF, 'dissertation_plots/optics_effarea.ps',/delete_ps ;convert .ps to .pdf

End