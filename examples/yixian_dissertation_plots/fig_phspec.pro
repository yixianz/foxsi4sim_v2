Pro fig_phspec
; Plotting photon spectra for real M3.5 flare, real C2.6 flare, and typical flares from scaling laws

popen,'dissertation_plots/flare_phspec.ps', xsi=8, ysi=3.2, /port
!p.multi=[0,3,1]
!X.margin=4.
!Y.margin=2.
!X.thick = 1.6
!Y.thick = 1.6
!P.FONT = 0
hsi_linecolors

;---------------------------------------------------------------------------------------------------
; M3.5 flare
m3_full = real_m3flare_phspec()
m3_footpoint = real_m3flare_phspec(footpoint = 1)
m3_looptop = real_m3flare_phspec(looptop = 1)

plot, m3_footpoint.energy_keV, m3_footpoint.phflux,/xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', $
  charsize = 1.5, charthick=1., thick=1.8, yr = [0.01,1e9], xr=[1,30], /xst, /yst, title = 'M3.5 real flare photon spectrum'
oplot, m3_footpoint.energy_keV, m3_footpoint.phflux_th, thick=1.8, linestyle = 2
oplot, m3_footpoint.energy_keV, m3_footpoint.phflux_nonth, thick=1.8, linestyle = 1

oplot, m3_looptop.energy_keV, m3_looptop.phflux, color=8, thick=1.8
oplot, m3_looptop.energy_keV, m3_looptop.phflux_th, color=8, thick=1.8, linestyle = 2
oplot, m3_looptop.energy_keV, m3_looptop.phflux_nonth, color=8, thick=1.8, linestyle = 1

al_legend, ['footpoint, summed','footpoint, thermal','footpoint, nonthermal', 'looptop, summed','looptop, thermal', 'looptop, nonthermal'], $ 
  textcolors = 0, color=[0,0,0,8,8,8], linestyle = [0,2,1,0,2,1], $
  charsize = 0.62, linsize = 1.5, thick=2.2, /right, spacing=0.7

;---------------------------------------------------------------------------------------------------
; C2.6 flare
c3_full = real_c3flare_phspec()
c3_footpoint1 = real_c3flare_phspec(footpoint1 = 1)
c3_footpoint2 = real_c3flare_phspec(footpoint2 = 1)
c3_looptop = real_c3flare_phspec(looptop = 1)

plot, c3_footpoint1.energy_keV, c3_footpoint1.phflux, /xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', $
  charsize = 1.5, charthick=1., thick=1.8, yr = [0.01,1e9], xr=[1,30], /xst, /yst, title = 'C2.6 real flare photon spectrum'
oplot, c3_footpoint1.energy_keV, c3_footpoint1.phflux_th, thick=1.8, linestyle = 2
oplot, c3_footpoint1.energy_keV, c3_footpoint1.phflux_nonth, thick=1.8, linestyle = 1

oplot, c3_looptop.energy_keV, c3_looptop.phflux, color=8, thick=1.8
oplot, c3_looptop.energy_keV, c3_looptop.phflux_th, color=8, thick=1.8, linestyle = 2
oplot, c3_looptop.energy_keV, c3_looptop.phflux_nonth, color=8, thick=1.8, linestyle = 1

al_legend, ['footpoint, summed','footpoint, thermal','footpoint, nonthermal', 'looptop, summed','looptop, thermal', 'looptop, nonthermal'], $ 
  textcolors = 0, color=[0,0,0,8,8,8], linestyle = [0,2,1,0,2,1], $
  charsize = 0.62, linsize = 1.5, thick=2.2, /right, spacing=0.7

;---------------------------------------------------------------------------------------------------
; Typical flares
typical_x1 = typical_flare_phspec(fgoes = 1e-4)
typical_m5 = typical_flare_phspec(fgoes = 5e-5)
typical_m1 = typical_flare_phspec(fgoes = 1e-5)
typical_c5 = typical_flare_phspec(fgoes = 5e-6)
typical_c1 = typical_flare_phspec(fgoes = 1e-6)

plot, typical_x1.energy_keV, typical_x1.phflux, thick=1.8, $
  /xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', $
  charsize = 1.5, charthick=1., yr = [0.01,1e9], xr=[1,30], /xst, /yst, title = 'Typical flare photon spectrum'
oplot,  typical_x1.energy_keV, typical_x1.phflux, thick=1.8, color=cgcolor("Dodger Blue")
oplot,  typical_m5.energy_keV, typical_m5.phflux, thick=1.8, color=cgcolor("Crimson")
oplot,  typical_m1.energy_keV, typical_m1.phflux, thick=1.8, color=cgcolor("Forest Green")
oplot,  typical_c5.energy_keV, typical_c5.phflux, thick=1.8, color=cgcolor("Orange")
oplot,  typical_c1.energy_keV, typical_c1.phflux, thick=1.8, color=cgcolor("Hot pink")

al_legend, ['X1', 'M5', 'M1', 'C5', 'C1'], $
  textcolors = 0, color=[cgcolor("Dodger Blue"),cgcolor("Crimson"),cgcolor("Forest Green"),cgcolor("Orange"),cgcolor("Hot pink")], linestyle = 0, $
  charsize = 0.65, linsize = 1.2, thick=2.2, /right
  
pclose
cgPS2PDF, 'dissertation_plots/flare_phspec.ps',/delete_ps ;convert .ps to .pdf

stop

typical_m3 = typical_flare_phspec(fgoes = 3.5e-5, en_edges = indgen(4000)*0.01+0.995) ; typical M3.5 flare
m3_full = real_m3flare_phspec(en_edges = indgen(4000)*0.01+0.995) ; real M3.5 flare
print, 'Typical M3.5 flare flux at', typical_m3.energy_keV[900], 'keV:  ', typical_m3.phflux[900]
print, 'Real M3.5 flare flux at', m3_full.energy_keV[900], 'keV:  ', m3_full.phflux[900]

;popen,'test.ps', xsi=6, ysi=6, /port
;!X.thick = 3
;!Y.thick = 3
;!P.FONT = 0
;phspec = real_m3flare_phspec(footpoint = 1, en_edges = indgen(500)*0.2+1)
;plot, phspec.energy_kev, phspec.phflux, /xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', charsize = 1.5, background=255, color=1,thick=3, charthick=2, xr=[1,100]
;oplot, phspec.ENERGY_KEV, phspec.PHFLUX_TH,thick=3, color=cgcolor("blue")
;oplot, phspec.ENERGY_KEV, phspec.PHFLUX_nonth,thick=3, color=cgcolor("orangered")
;al_legend, ['total','thermal','nonthermal'], textcolors=[0,cgcolor("blue"),cgcolor("orangered")], color=[0,cgcolor("blue"),cgcolor("orangered")],charsize=1.4,linsize = 0.3, thick=3, linestyle = 0,/right
;pclose
;cgPS2PDF, 'test.ps',/delete_ps


End