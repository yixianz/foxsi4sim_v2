Pro fig_det_eff
  ; Plotting FOXSI-4 detector efficiency

  popen,'dissertation_plots/det_efficiency_all.ps', xsi=5, ysi=3.5, /port
  !p.multi=[0,1,1]
  !X.margin=4.
  !Y.margin=2.
  !X.thick = 2
  !Y.thick = 2
  !P.FONT = 0
  hsi_linecolors
  PLOTSYM, 0, /FILL

  ; optics side blanketing
  energy_arr = indgen(300)*0.1+0.1
  cdte_eff = foxsi4_deteff(energy_arr = energy_arr, cdte = 1) 
  cmos_eff = foxsi4_deteff(energy_arr = energy_arr, cmos = 1) 
  timepix_eff = foxsi4_deteff(energy_arr = energy_arr, timepix = 1)  
  
  plot, cdte_eff.energy_kev, cdte_eff.efficiency, charsize = 1., charthick=1., xr=[0,30], thick=3,$
    xtitle = 'Energy (keV)', ytitle = 'Efficiency', title = 'FOXSI-4 detector efficiency'
  oplot, cmos_eff.energy_kev, cmos_eff.efficiency, thick=3.5, color=cgcolor("dodger blue")
  oplot, timepix_eff.energy_kev, timepix_eff.efficiency, thick=3.5, color=cgcolor("orange")
  
  al_legend, ['CdTe strip','CMOS', 'Timepix'], $
    textcolors = 0, color=[0,cgcolor("dodger blue"),cgcolor("orange")], linestyle = 0, $
    charsize = 1, linsize = 0.6, thick=3, /right,/bottom, spacing=1.3

  pclose
  cgPS2PDF, 'dissertation_plots/det_efficiency_all.ps',/delete_ps ;convert .ps to .pdf
  stop

End