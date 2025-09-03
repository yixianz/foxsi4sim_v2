Pro proposal_m3_flare_2

  pos = 2
  counting_stat = 0
  int_time = 60.

  popen,'fig_m3_flare_pos2', xsi=8, ysi=2.6, /port
  !p.multi = [0,3,1]
  !X.margin = 5.5

  hsi_linecolors

  ; spatially integrated
  phspec = real_m3flare_phspec()
  ; total
  ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, counting_stat = counting_stat, int_time = int_time)
  plot, ctspec.energy_kev, ctspec.count_flux, chars=1.1, thick=2.5, charth=1.4, xth=2.5, yth=2.5, background=1, psym = 10, /ylog, /xlog, $
    xrange = [4, 25], yrange = [1,10000], /xsty, /ysty, xtitle = "Energy (keV)", ytitle = "Count flux (counts/s/ keV)", $
    title = "Spatially integrated"
  ; thermal
  ctspec_th = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_th, pos=pos, counting_stat = counting_stat, int_time = int_time)
  oplot, ctspec_th.energy_kev, ctspec_th.count_flux, color = 7, thick=2.5
  ; non-thermal
  ctspec_nonth = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_nonth, pos=pos, counting_stat = counting_stat, int_time = int_time)
  oplot, ctspec_nonth.energy_kev, ctspec_nonth.count_flux, color = 8,  thick=2.5
  al_legend, ['Total','Thermal','Non-thermal'],textcolors=[0,7,8], color=[0,7,8], chars=0.7, charth=0.5,$
    linestyle=[0,0,0], linsi=0.4,thick=2, /left, box=0, pos = [3.9,9000]


  ; footpoint
  phspec = real_m3flare_phspec(footpoint=1)
  ; total
  ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, counting_stat = counting_stat, int_time = int_time)
  plot, ctspec.energy_kev, ctspec.count_flux, chars=1.1, thick=2.5, charth=1.4, xth=2.5, yth=2.5, background=1, psym = 10, /ylog, /xlog, $
    xrange = [4, 25], yrange = [1,10000], /xsty, /ysty, xtitle = "Energy (keV)", title = "Footpoint"
  ; thermal
  ctspec_th = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_th, pos=pos, counting_stat = counting_stat, int_time = int_time)
  oplot, ctspec_th.energy_kev, ctspec_th.count_flux, color = 7, thick=2.5
  ; non-thermal
  ctspec_nonth = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_nonth, pos=pos, counting_stat = counting_stat, int_time = int_time)
  oplot, ctspec_nonth.energy_kev, ctspec_nonth.count_flux, color = 8,  thick=2.5
  al_legend, ['Total','Thermal','Non-thermal'],textcolors=[0,7,8], color=[0,7,8], chars=0.7, charth=0.6,$
    linestyle=[0,0,0], linsi=0.4,thick=2, /left, box=0, pos = [3.9,9000]

  resp = foxsi4_resp_diag(pos = pos)
  plot, resp.energy_keV, resp.eff_area_cm2, chars=1.1, thick=2.5, charth=1.4, xth=2.5, yth=2.5, background=1, psym = 10, /ylog, /xlog, $
    xrange = [4, 25], yrange = [0.001,100], /xsty, /ysty,xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!E2!N)'


  pclose
  cgPS2PDF, 'fig_m3_flare_pos2.ps',/delete_ps


End

