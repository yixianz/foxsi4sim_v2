pos = 5
phspec = typical_flare_phspec(fgoes = 1e-5)  ; M1 class
ctspec_5 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1)
ctspec_7 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1, let_file = 'vth_7.csv')
ctspec_9 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1, let_file = 'vth_9.csv')
ctspec_11 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1, let_file = 'vth_11.csv')
ctspec_13 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1, let_file = 'vth_13.csv')
ctspec_15 = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, plot = 1, let_file = 'vth_15.csv')

colorcode = [0,cgcolor("red"),cgcolor("blue"),cgcolor("Forest Green"),cgcolor("Violet"),cgcolor("Sandy Brown")]

plot,ctspec_5.ENERGY_KEV,ctspec_5.COUNT_FLUX, /xlog,/ylog, psym=10, yr=[1,1e4], background = 255, color=colorcode[0], charsize = 1.6, xtitle = 'Energy (keV)', ytitle = 'counts/s/keV'
oplot,ctspec_7.ENERGY_KEV,ctspec_7.COUNT_FLUX, color = colorcode[1], psym=10
oplot,ctspec_9.ENERGY_KEV,ctspec_9.COUNT_FLUX, color = colorcode[2], psym=10
oplot,ctspec_11.ENERGY_KEV,ctspec_11.COUNT_FLUX, color = colorcode[3], psym=10
oplot,ctspec_13.ENERGY_KEV,ctspec_13.COUNT_FLUX, color = colorcode[4], psym=10
oplot,ctspec_15.ENERGY_KEV,ctspec_15.COUNT_FLUX, color = colorcode[5], psym=10

al_legend, ['vth = 5 (' + strtrim(string(round(ctspec_5.COUNT_RATE_TOT)),2) +' ct/s)',$
  'vth = 7 (' + strtrim(string(round(ctspec_7.COUNT_RATE_TOT)),2) +' ct/s)', $
  'vth = 9 (' + strtrim(string(round(ctspec_9.COUNT_RATE_TOT)),2) +' ct/s)', $
  'vth = 11 (' + strtrim(string(round(ctspec_11.COUNT_RATE_TOT)),2) +' ct/s)', $
  'vth = 13 (' + strtrim(string(round(ctspec_13.COUNT_RATE_TOT)),2) +' ct/s)', $
  'vth = 15 (' + strtrim(string(round(ctspec_15.COUNT_RATE_TOT)),2) +' ct/s)'], $
  chars=1.4, charth=1.4, box=0, color=colorcode, linestyle=[0,0,0,0,0,0], linsi=0.15, /right
