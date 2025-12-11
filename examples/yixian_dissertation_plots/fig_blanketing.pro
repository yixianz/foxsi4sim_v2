Pro fig_blanketing
  ; Plotting FOXSI-4 blanketing transmission

  popen,'dissertation_plots/blanket_trans.ps', xsi=5, ysi=3.5, /port
  !p.multi=[0,1,1]
  !X.margin=4.
  !Y.margin=2.
  !X.thick = 2
  !Y.thick = 2
  !P.FONT = 0
  hsi_linecolors
  PLOTSYM, 0, /FILL
  
  ; optics side blanketing
  blanket_trans = foxsi4_blanketing(energy_arr = indgen(300)*0.1+0.1) 
  ; focal plane thin mylar (applicable to positions 3, 5, 6)
  fp_mylar_trans = get_material_transmission('material_data/mylar_att_len.txt', 6.35, energy_arr = indgen(300)*0.1+0.1)
  fp_al_trans = get_material_transmission('material_data/al_att_len.txt', 0.1, energy_arr = indgen(300)*0.1+0.1)

  plot, blanket_trans.energy_kev, blanket_trans.transmission, charsize = 1., charthick=1., xr=[0,30], thick=2.5, $
    xtitle = 'Energy (keV)', ytitle = 'Transmission fraction', title = 'FOXSI-4 blankets transmission'
  oplot,  fp_mylar_trans.energy_kev, fp_mylar_trans.transmission*fp_al_trans.transmission, thick=2.5, color=cgcolor("blue")
  
  al_legend, ['Optics-side (all Positions)', 'Detector-side (Pos. 3,5,6)'], $
    textcolors = 0, color=[0,cgcolor("blue")], linestyle = 0, $
    charsize = 1, linsize = 0.6, thick=2.5, /right,/bottom, spacing=1.3
  
  pclose
  cgPS2PDF, 'dissertation_plots/blanket_trans.ps',/delete_ps ;convert .ps to .pdf
  stop

End