pro flare_ph_spec_example

popen,'dissertation_plots/flare_ph_spec_example.ps', xsi=6, ysi=6, /port
!X.thick = 3
!Y.thick = 3
!P.FONT = 0

phspec = typical_flare_phspec(fgoes = 1e-5, en_edges = indgen(500)*0.2+1) 
plot, phspec.energy_keV, phspec.phflux, thick=4, $
  /xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', $
  charsize = 1.5, charthick=1., xr=[1,100], /xst
oplot, phspec.energy_keV, phspec.phflux_th, thick=4, color= cgcolor("blue")
oplot, phspec.energy_keV, phspec.phflux_nonth, thick=4, color= cgcolor("orange")
al_legend, ['total','thermal','non-thermal'], textcolors = [0,cgcolor("blue"),cgcolor("orange")],$
  color = [0,cgcolor("blue"),cgcolor("orange")], linestyle=0, charsize = 1.3, linsize = 0.4, thick=4, /right

pclose
cgPS2PDF, 'dissertation_plots/flare_ph_spec_example.ps',/delete_ps ;convert .ps to .pdf

End
