Pro fig_phspec_reconst
  ; Plotting example count spectra and fit results for the energy resolution simulation
  ; These results were produced using foxsi4_simulation_ospex_singledet in foxsi4sim:
  ;    foxsi4_simulation_ospex_singledet, fp=1, nonthermal=1
  ; Energy resolution was 0.8 keV

  popen,'dissertation_plots/example_phspec_reconst.ps', xsi=7.7, ysi=3.6, /port
  !p.multi=[0,2,1]
  !X.margin=5.
  !Y.margin=2.
  !X.thick = 1.6
  !Y.thick = 1.6
  !P.FONT = 0
  hsi_linecolors
  
  result = spex_read_fit_results('dissertation_plots/ospex_results_19_feb_2025.fits')
  area = result.spex_summ_area
  en_edges = result.spex_summ_energy
  en_width = get_edges(result.spex_summ_energy,/width)
  en_mean = get_edges(en_edges,/mean)
  ct_flux = result.spex_summ_ct_rate  / area / en_width
  ct_flux_err = result.spex_summ_ct_error / area / en_width
 
  conv_fact = result.spex_summ_conv
  ph_flux = ct_flux / conv_fact
  ph_flux_err = ct_flux_err/ conv_fact
  
  param = result.spex_summ_params
  param_sigma = result.spex_summ_sigmas
  flux_th =  f_vth(en_edges,param[0:2])
  flux_nonth = f_thick2(en_edges,param[3:-1])
  valid_ind = where(ct_flux>0)
  
  plot, en_mean,ct_flux,psym=10,/xlog,/ylog,xr=[5,20],yr= [0.1,1e3], /xst, /yst,ytickunits='scientific', $
    xtitle = 'Energy (keV)', ytitle = 'counts s!U-1!N keV!U-1!N cm!U-2!N', thick=1.6, title = 'Simulated count spectrum'
  errplot, en_mean[valid_ind],ct_flux[valid_ind]-ct_flux_err[valid_ind]>0.1, ct_flux[valid_ind]+ct_flux_err[valid_ind]
  
  plot, en_mean,ph_flux,psym=10,/xlog,/ylog,xr=[5,20],yr= [1,1e6], /xst, /yst, $
    xtitle = 'Energy (keV)', ytitle = 'photons s!U-1!N keV!U-1!N cm!U-2!N', thick=1.6, title = 'Reconstructed photon spectrum'
  errplot, en_mean[valid_ind],ph_flux[valid_ind]-ph_flux_err[valid_ind]>1, ph_flux[valid_ind]+ph_flux_err[valid_ind]
  oplot, en_mean, flux_th+flux_nonth, color=cgcolor("red"), thick=2.5
  oplot, en_mean, flux_th, color=cgcolor("blue"), thick=2.5
  oplot, en_mean, flux_nonth, color=cgcolor("forest green"), thick=2.5
  oplot, [6,6],[1,1e6],linestyle = 1
  oplot, [18,18],[1,1e6],linestyle = 1
  
;  xyouts, 0.76, 0.64, 'EM = '+string(param[0],format='(F5.3)')+' +/- '+string(param_sigma[0],format='(F5.3)'), /normal,$
;    charsize = 0.8, color=cgcolor("red")
;  xyouts, 0.76, 0.595, 'kT = '+string(param[1],format='(F5.3)')+' +/- '+string(param_sigma[1],format='(F5.3)'), /normal,$
;    charsize = 0.8, color=cgcolor("red")
;  xyouts, 0.76, 0.55, 'f!De!N = '+string(param[3],format='(F5.2)')+' +/-'+string(param_sigma[3],format='(F5.2)'), /normal,$
;    charsize = 0.8, color=cgcolor("red")
;  xyouts, 0.76, 0.505, 'delta = '+string(param[4],format='(F5.2)')+' +/-'+string(param_sigma[4],format='(F5.2)'), /normal,$
;    charsize = 0.8, color=cgcolor("red")
;    
  al_legend, ['vth+thick2', 'vth', 'thick2'], $
    textcolors = 0, color=[cgcolor("red"),cgcolor("blue"),cgcolor("Forest Green")], linestyle = 0, $
    charsize = 0.8, linsize = 0.5, thick=2.5, /right

  
  pclose
  cgPS2PDF, 'dissertation_plots/example_phspec_reconst.ps',/delete_ps ;convert .ps to .pdf

  stop
End