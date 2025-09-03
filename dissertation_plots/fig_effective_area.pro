Pro fig_effective_area
  ; Plotting FOXSI-4 effective area

  popen,'dissertation_plots/foxsi4_eff_area.ps', xsi=5.5, ysi=4, /port
  !p.multi=[0,1,1]
  !X.margin=4.
  !Y.margin=2.
  !X.thick = 3
  !Y.thick = 3
  !P.FONT = 0
  hsi_linecolors
  PLOTSYM, 0, /FILL

  ea_p0 = foxsi4_resp_diag(pos = 0, energy_arr = energy_arr)
  ea_p1 = foxsi4_resp_diag(pos = 1, energy_arr = energy_arr)
  ea_p2 = foxsi4_resp_diag(pos = 2, energy_arr = energy_arr)
  ea_p3 = foxsi4_resp_diag(pos = 3, energy_arr = energy_arr)
  ea_p4 = foxsi4_resp_diag(pos = 4, energy_arr = energy_arr)
  ea_p5 = foxsi4_resp_diag(pos = 5, energy_arr = energy_arr)
  ea_p6 = foxsi4_resp_diag(pos = 6, energy_arr = energy_arr)
  
  plot, ea_p0.energy_kev, ea_p0.eff_area_cm2, thick=4, $
    charsize = 1., charthick=1., xr=[0,25], yr = [0.001,10], /ylog, /xst, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!U2!N)', title = 'FOXSI-4 telescope effective area'
  oplot, ea_p0.energy_kev, ea_p0.eff_area_cm2, thick=4, color = cgcolor("orange red")
  oplot, ea_p1.energy_kev, ea_p1.eff_area_cm2, thick=4, color = cgcolor("gold")
  oplot, ea_p2.energy_kev, ea_p2.eff_area_cm2, thick=4, color = cgcolor("peru")
  oplot, ea_p3.energy_kev, ea_p3.eff_area_cm2, thick=4, color = cgcolor("lime green")
  oplot, ea_p4.energy_kev, ea_p4.eff_area_cm2, thick=4, color = cgcolor("dodger blue")
  oplot, ea_p5.energy_kev, ea_p5.eff_area_cm2, thick=4, color = cgcolor("teal")
  oplot, ea_p6.energy_kev, ea_p6.eff_area_cm2, thick=4, color = cgcolor("purple")

  al_legend, ['Pos 0', 'Pos 1', 'Pos 2', 'Pos 3', 'Pos 4', 'Pos 5', 'Pos 6'], $
    textcolor = [cgcolor("orange red"),cgcolor("gold"),cgcolor("peru"),cgcolor("lime green"),cgcolor("dodger blue"),cgcolor("teal"),cgcolor("purple")], $
    chars = 1.1, charth=1.5, box = 0, /right, position = [4, 9.2]

  pclose
  cgPS2PDF, 'dissertation_plots/foxsi4_eff_area.ps',/delete_ps ;convert .ps to .pdf
  stop

End