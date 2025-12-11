Pro fig_atten_filter
  ; Plotting FOXSI-4 attenuator/pre-filter transmission

  popen,'dissertation_plots/atten_filter_trans.ps', xsi=5, ysi=3.5, /port
  !p.multi=[0,1,1]
  !X.margin=4.
  !Y.margin=2.
  !X.thick = 2
  !Y.thick = 2
  !P.FONT = 0
  hsi_linecolors
  PLOTSYM, 0, /FILL

  energy_arr = indgen(300)*0.1+0.1
  mpa_trans = foxsi4_attenuator(pixelated_att = 1, energy_arr = energy_arr)
  al_p2_trans = foxsi4_attenuator(al_um = 0.015*25400, energy_arr = energy_arr)
  al_p4_trans = foxsi4_attenuator(al_um = 0.005*25400, energy_arr = energy_arr)
  prefilter_p0_trans = foxsi4_cmos_prefilter(cmos_pos = 0, energy_arr = energy_arr)
  prefilter_p1_trans = foxsi4_cmos_prefilter(cmos_pos = 1, energy_arr = energy_arr)
 
  plot, mpa_trans.energy_kev, mpa_trans.transmission, charsize = 1., charthick=1., xr=[0,30], thick=2, yr=[1e-5,1],/ylog,$
    xtitle = 'Energy (keV)', ytitle = 'Transmission fraction', title = 'FOXSI-4 attenuation filter transmission'
  oplot, prefilter_p0_trans.energy_kev, prefilter_p0_trans.transmission, thick=3, color=cgcolor("dodger blue")
  oplot, prefilter_p1_trans.energy_kev, prefilter_p1_trans.transmission, thick=3, color=cgcolor("orange")
  oplot, al_p2_trans.energy_kev, al_p2_trans.transmission, thick=3, color=cgcolor("hot pink")
  oplot, al_p4_trans.energy_kev, al_p4_trans.transmission, thick=3, color=cgcolor("sea green")
  oplot, mpa_trans.energy_kev, mpa_trans.transmission, thick=3, color=cgcolor("brown")

  al_legend, ['Pre-filter (Pos 0)','Pre-filter (Pos 1)', 'Uniform Al (Pos 2)', 'Uniform Al (Pos 4)', 'MPA (Pos 3, 5)'], $
    textcolors = 0, color=[cgcolor("dodger blue"),cgcolor("orange"),cgcolor("hot pink"),cgcolor("sea green"),cgcolor("brown")], linestyle = 0, $
    charsize = 1, linsize = 0.6, thick=2.5, /right,/bottom, spacing=1.3

  pclose
  cgPS2PDF, 'dissertation_plots/atten_filter_trans.ps',/delete_ps ;convert .ps to .pdf
  stop

End