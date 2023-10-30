Function real_m3flare_phspec, en_edges = en_edges, footpoint = footpoint, looptop = looptop, plot = plot

; Purpose:
; Simulate photon spectra for a real M3.5 RHESSI flare
; 
; Notes:
; This is flare C from Simoes and Kontar 2013 (https://www.aanda.org/articles/aa/full_html/2013/03/aa20304-12/aa20304-12.html)
; Parameters are read from OSPEX .fits files. Use f_vth + thick2 model. 
; Default is to simulate for the whole flare region. Set keywords to simulate for the footpoint/looptop region only.
; 
; Keywords:
; en_edges: 1d array of enegy bin edges in keV
; footpoint: set this to 1 to calculate for the footpoint region
; looptop: set this to 1 to calculate for the looptop region
; plot: set this to 1 to plot all spectra
; 
; Outputs:
; Data structure that consists of:
;   parameters: flare parameters for f_vth + thick2 model
;   energy_keV: energy array
;   phflux: total photon fluxes at above energies (photons/cm2/s/keV)
;   phflux_th: thermal photon fluxes (photons/cm2/s/keV)
;   phflux_nonth: non-thermal photon fluxes (photons/cm2/s/keV)
;
; Examples:
; phspec = real_m3flare_phspec(plot = 1)
; phspec = real_m3flare_phspec(footpoint = 1, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang

Default, en_edges, indgen(4000)*0.01+1

emean = get_edges( en_edges, /mean )
data_dir = 'flare_data/Simoes2013_flare20110224/'

; Read parameters from .fits file
If not keyword_set(footpoint) and not keyword_set(looptop) then begin   ; default is to read parameters for the whole flare region
  res = spex_read_fit_results(data_dir + 'ospex_results_FULL.fits')
  title_str = 'spatially integrated'
Endif
If keyword_set(footpoint) then begin
  res = spex_read_fit_results(data_dir + 'ospex_results_FP.fits')
  title_str = 'footpoint'
Endif
If keyword_set(looptop) then begin
  res = spex_read_fit_results(data_dir + 'ospex_results_LT.fits')
  title_str = 'looptop'
Endif
param = res.SPEX_SUMM_PARAMS

; Use isothermal + thick-target model
phflux_th = f_vth(en_edges, param[0:2])    ; thermal
phflux_nonth = f_thick2(emean, param[3:-1])    ; non-thermal
phflux = phflux_th + phflux_nonth    ; total = thermal + non-thermal

If keyword_set(plot) then begin
  plot, emean, phflux, /xlog, /ylog, charsize = 1.5, xtitle = 'Energy (keV)', ytitle = 'photons/cm2/s/keV', $
    title = 'M3.5 flare '+title_str+' photon spectrum'
  oplot, emean, phflux_th, linestyle = 2
  oplot, emean, phflux_nonth, linestyle = 1
  al_legend, ['total','thermal','non-thermal'], textcolors = 255,color=255, linestyle = [0,2,1], charsize = 1.5, linsize = 0.4, /right
Endif

phspec = create_struct('parameters', param, 'energy_keV', emean, 'phflux', phflux, 'phflux_th', phflux_th, 'phflux_nonth', phflux_nonth)
return, phspec

End