Pro fig_cdte_eff

popen,'fig_cdte_eff', xsi=6, ysi=4.2, /port

; average across whole detector
eff = foxsi4_deteff(energy_arr = indgen(3000)*0.01+1.0, cdte = 1)
plot, eff.energy_keV, eff.efficiency, thick = 3, charth=1.3, xth=3, yth=3, xtitle = 'Energy (keV)', ytitle = 'Efficiency', $
  chars = 1.2, xr = [0,30]

; finest pitch region
eff = foxsi4_deteff(energy_arr = indgen(3000)*0.01+1.0, cdte = 1, elec_coverage = 0.5)
oplot, eff.energy_keV, eff.efficiency, thick = 3, linestyle = 0, color = cgcolor('orange_red')

; medium pitch region
eff = foxsi4_deteff(energy_arr = indgen(3000)*0.01+1.0, cdte = 1, elec_coverage = 0.375)
oplot, eff.energy_keV, eff.efficiency, thick = 3, linestyle = 0, color = cgcolor('lime_green')

; coarsest pitch region
eff = foxsi4_deteff(energy_arr = indgen(3000)*0.01+1.0, cdte = 1, elec_coverage = 0.3)
oplot, eff.energy_keV, eff.efficiency, thick = 3, linestyle = 0, color = cgcolor('dodger_blue')

; overplot average again so the line stands out
eff = foxsi4_deteff(energy_arr = indgen(3000)*0.01+1.0, cdte = 1)
oplot, eff.energy_keV, eff.efficiency, thick = 3

al_legend, ['average', 'finest pitch region', 'medium pitch region', 'coarsest pitch region'], linestyle = [0,0,0,0], $
  linsize = 0.3, thick = 3, color = [0,cgcolor('orange_red'),cgcolor('lime_green'),cgcolor('dodger_blue')], $
  chars = 1, charth=1., position = [15.8, 0.28]

pclose
cgPS2PDF, 'fig_cdte_eff.ps', /delete_ps

End