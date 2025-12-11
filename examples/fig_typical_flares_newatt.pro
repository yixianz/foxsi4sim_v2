Pro fig_typical_flares_newatt, pos = pos

; Flare peak spectrum simulation for new attenuator thicknesses for FOXSI-5
; Simulate for C5 and M1 class typical flares
; Compare spectra with FOXSI-4 attenuator thicknesses and new thicknesses
; Only relevant for Postion 2 and 4 (those with a uniform Al attenuator)

Default, pos, 2

!p.multi = 0
popen,'fig_typical_flares_newatt', xsi=6.6, ysi=6., /port

hsi_linecolors,/pastel
colorcode = [0,8,7,2]

energy_bin = 0.4

phspec_c5 = typical_flare_phspec(fgoes = 5e-6) 
phspec_m1 = typical_flare_phspec(fgoes = 1e-5) 

ctspec_c5 = foxsi4_ct_spec(phspec_c5.energy_keV, phspec_c5.phflux, pos = pos, new_att = 0, energy_bin=energy_bin)
ctspec_c5_newatt = foxsi4_ct_spec(phspec_c5.energy_keV, phspec_c5.phflux, pos = pos, new_att = 1, energy_bin=energy_bin)
ctspec_m1 = foxsi4_ct_spec(phspec_m1.energy_keV, phspec_m1.phflux, pos = pos, new_att = 0, energy_bin=energy_bin)
ctspec_m1_newatt = foxsi4_ct_spec(phspec_m1.energy_keV, phspec_m1.phflux, pos = pos, new_att = 1, energy_bin=energy_bin)

plot, ctspec_m1_newatt.energy_kev, ctspec_m1_newatt.count_flux, chars=1.4, thick=4, charth=1.3, xth=4, yth=4, background=1, color=0, $
  /xlog, /ylog, psym=10, xtitle='Energy (keV)', ytitle='Count flux (counts/s/keV)', $
  yr=[1.,3d5], xr=[4.,25.], /xsty, /ysty
  
oplot, ctspec_m1_newatt.energy_kev, ctspec_m1_newatt.count_flux, psym=10, color=7, thick=4
oplot, ctspec_c5_newatt.energy_kev, ctspec_c5_newatt.count_flux, psym=10, color=2,thick=4
oplot, ctspec_m1.energy_kev, ctspec_m1.count_flux, psym=10, color=12,thick=4
oplot, ctspec_c5.energy_kev, ctspec_c5.count_flux, psym=10, color=8,thick=4

al_legend, ['M1 (new): '+strtrim(string(round(ctspec_m1_newatt.count_rate_tot)),2)+' cts/s',$
  'C5 (new): '+strtrim(string(round(ctspec_c5_newatt.count_rate_tot)),2)+' cts/s',$
  'M1 (FOXSI-4): '+strtrim(string(round(ctspec_m1.count_rate_tot)),2)+' cts/s',$
  'C5 (FOXSI-4): '+strtrim(string(round(ctspec_c5.count_rate_tot)),2)+' cts/s'], $
  textcolors=[7,2,12,8],color=[7,2,12,8], linestyle = 0, spacing=1.6, box = 0, /right, $
  chars=1.2, charth=2, thick=4, linsize = 0.2, pos=[25.2,2.5e5]

pclose
cgPS2PDF, 'fig_typical_flares_newatt.ps',/delete_ps
stop

End