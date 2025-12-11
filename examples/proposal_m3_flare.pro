Pro proposal_m3_flare

pos = 3
counting_stat = 0
int_time = 60.

popen,'fig_m3_flare', xsi=7.6, ysi=3., /port
!p.multi = [0,3,1]
!X.margin = 2.7

hsi_linecolors

; spatially integrated
phspec = real_m3flare_phspec()
; total
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, counting_stat = counting_stat, int_time = int_time)
plot, ctspec.energy_kev, ctspec.count_flux, chars=1.7, thick=3, charth=2., xth=3, yth=3, background=1, psym = 10, /ylog, /xlog, $
  xrange = [3, 25], yrange = [1,1000], /xsty, /ysty, xtitle = "Energy (keV)", ytitle = "Count flux (counts/s/ keV)", $
  title = "Spatially integrated"
; thermal
ctspec_th = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_th, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_th.energy_kev, ctspec_th.count_flux, color = 7, thick=3
; non-thermal
ctspec_nonth = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_nonth, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_nonth.energy_kev, ctspec_nonth.count_flux, color = 8,  thick=3
al_legend, ['Total','Thermal','Non-thermal'],textcolors=[0,7,8], color=[0,7,8], chars=0.75, charth=0.6,$
  linestyle=[0,0,0], linsi=0.4,thick=3, /right, box=0, pos = [25.2,830]


; footpoint
phspec = real_m3flare_phspec(footpoint=1)
; total
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, counting_stat = counting_stat, int_time = int_time)
plot, ctspec.energy_kev, ctspec.count_flux, chars=1.7, thick=3, charth=2, xth=3, yth=3, background=1, psym = 10, /ylog, /xlog, $
  xrange = [3, 25], yrange = [1,1000], /xsty, /ysty, xtitle = "Energy (keV)", title = "Footpoint"
; thermal
ctspec_th = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_th, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_th.energy_kev, ctspec_th.count_flux, color = 7, thick=3
; non-thermal
ctspec_nonth = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_nonth, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_nonth.energy_kev, ctspec_nonth.count_flux, color = 8,  thick=3
al_legend, ['Total','Thermal','Non-thermal'],textcolors=[0,7,8], color=[0,7,8], chars=0.75, charth=0.6,$
  linestyle=[0,0,0], linsi=0.4,thick=3, /right, box=0, pos = [25.2,830]


; looptop
phspec = real_m3flare_phspec(looptop=1)
; total
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, counting_stat = counting_stat, int_time = int_time)
plot, ctspec.energy_kev, ctspec.count_flux, chars=1.7, thick=3, charth=2, xth=3, yth=3, background=1, psym = 10, /ylog, /xlog, $
  xrange = [3, 25], yrange = [1,1000], /xsty, /ysty, xtitle = "Energy (keV)", title = "Looptop"
; thermal
ctspec_th = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_th, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_th.energy_kev, ctspec_th.count_flux, color = 7, thick=3
; non-thermal
ctspec_nonth = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux_nonth, pos=pos, counting_stat = counting_stat, int_time = int_time)
oplot, ctspec_nonth.energy_kev, ctspec_nonth.count_flux, color = 8,  thick=3
al_legend, ['Total','Thermal','Non-thermal'],textcolors=[0,7,8], color=[0,7,8], chars=0.75, charth=0.6,$
  linestyle=[0,0,0], linsi=0.4,thick=3, /right, box=0, pos = [25.2,830]


pclose
cgPS2PDF, 'fig_m3_flare.ps',/delete_ps


End
