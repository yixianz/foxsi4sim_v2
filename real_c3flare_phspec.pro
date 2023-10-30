Function real_c3flare_phspec, en_edges = en_edges, footpoint1 = footpoint1, footpoint2 = footpoint2, looptop = looptop, plot = plot

; Purpose:
; Simulate photon spectra for a real C2.6 RHESSI flare
; 
; Notes:
; This is the flare from Simoes et al 2015 (https://www.aanda.org/articles/aa/abs/2015/05/aa24795-14/aa24795-14.html)
; Use f_vth + thick2 model. 
; Default is to calculate for the whole flare region. Set keywords to calculated for one of the footpoints or looptop region only.
;
; Keywords:
; en_edges: 1d array of enegy bin edges
; footpoint1: set this to 1 to calculate for the first footpoint (east ribbon)
; footpoint2: set this to 1 to calculate for the second footpoint (west ribbon)
; looptop: set this to 1 to calculate for the looptop region
; plot: set this to 1 to plot all spectra
;
; Outputs:
; Data structure that consists of:
;   parameters: flare parameters for f_vth + thick2 model
;   energy_keV: energy array
;   phflux: total photon fluxes at above energies (photons/cm2/s/keV)
;   phflux_th: thermal photon fluxes
;   phflux_nonth: non-thermal photon fluxes
;
; Examples:
; phspec = real_c3flare_phspec(plot = 1)
; phspec = real_c3flare_phspec(footpoint2 = 1, plot = 1)
;
; History:
; Oct 2023, created by Y. Zhang

Default, en_edges, indgen(4000)*0.01+1

emean = get_edges( en_edges, /mean )
data_dir = 'flare_data/Simoes2013_flare20110224/'

; Set up parameters
If not keyword_set(footpoint1) and not keyword_set(footpoint2) and not keyword_set(looptop) then begin
  param = [0.0133, 11.81/11.6, 1.00, 2.84, 5.6, 33000, 0.00, 10.0, 32000]
  title_str = 'spatially integrated'
Endif
If keyword_set(footpoint1) then begin
  param = [0.0096, 10.19/11.6, 1.00, 1.02, 5.7, 33000, 0.00, 10.0, 32000]
  title_str = 'east footpoint'
Endif
If keyword_set(footpoint2) then begin
  param = [0.0099, 10.01/11.6, 1.00, 0.51, 4.9, 33000, 0.00, 10.0, 32000]
  title_str = 'west footpoint'
Endif
If keyword_set(looptop) then begin
  param = [0.0060, 11.81/11.6, 1.00, 0.73, 5.2, 33000, 0.00, 10.0, 32000]
  title_str = 'looptop'
Endif

; Use isothermal + thick-target model
phflux_th = f_vth(en_edges, param[0:2])    ; thermal
phflux_nonth = f_thick2(emean, param[3:-1])    ; non-thermal
phflux = phflux_th + phflux_nonth    ; total = thermal + non-thermal

If keyword_set(plot) then begin
  plot, emean, phflux, /xlog, /ylog, charsize = 1.5, xtitle = 'Energy (keV)', ytitle = 'photons/cm2/s/keV', $
    title = 'C2.6 flare '+title_str+' photon spectrum'
  oplot, emean, phflux_th, linestyle = 2
  oplot, emean, phflux_nonth, linestyle = 1
  al_legend, ['total','thermal','non-thermal'], textcolors = 255,color=255, linestyle = [0,2,1], charsize = 1.5, linsize = 0.4, /right
Endif

phspec = create_struct('parameters', param, 'energy_keV', emean, 'phflux', phflux, 'phflux_th', phflux_th, 'phflux_nonth', phflux_nonth)
return, phspec

End