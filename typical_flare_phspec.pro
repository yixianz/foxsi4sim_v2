Function typical_flare_phspec, fgoes = fgoes, en_edges = en_edges, plot = plot

; Purpose:
; Generate typical hard X-ray spectrum for flares using scaling laws described in Battaglia et al (2005).
; 
; Note:
; Battaglia et al (2005) did a statistical study on 85 B1-M6 flares observed by RHESSI and found correlations between different 
; parameters, such as GOES flux (fgoes), temperature (T), emission measure (EM), non-thermal flux at 35 keV (f35), and
; power-law spectral index (delta). Here for a given GOES flux, the spectrum is generated through following steps: 
;   a. Calculate f35 based on Eq.(8) from the paper: 
;             fgoes = 1.8*10^(-5)*f35^0.83
;   b. Calculate T, EM, and delta from f35 based on Eqs.(9), (10), and (4): 
;             T = 1.46*ln(f35) + 21.57
;             EM = 5*10^48*f35^0.91
;             delta = 3.0*f35^(-0.13)
;   c. Calculate photon spectrum using an isothermal + broken power-law model (fixed spectral index of 1.5 below 9 keV) 
; 
; Keywords:
; fgoes: GOES flux (W m^-2)
; en_edges: 1d array of enegy bin edges in keV (default is [1.00,1.01,1.02,...,41.00])
; plot: set this to 1 to plot the photon spectrum
; 
; Outputs:
; Data structure that consists of:
;   parameters (EM_49, T_kev, f35, delta): flare parameters
;   energy_keV: energy array
;   phflux: total photon fluxes at above energies (photons/cm2/s/keV)
;   phflux_th: thermal photon fluxes (photons/cm2/s/keV)
;   phflux_nonth: non-thermal photon fluxes (photons/cm2/s/keV)
; 
; Example:
; phspec = typical_flare_phspec(fgoes = 1e-6, plot = 1)    ; C1 class flare
; phspec = typical_flare_phspec(fgoes = 5e-5, en_edges = indgen(200)*0.2+1, plot = 1)    ; M5 class flare 
;
; History:
; Oct 2023, created by Y. Zhang

Default, en_edges, indgen(4000)*0.01+1
Default, plot, 0

emean = get_edges( en_edges, /mean )

; Calculate flare parameters based on scaling laws
f35 = (fgoes/1.8d-5)^(1/0.83)
T_kev = (1.46*alog(f35) + 21.57)/11.6  ;temperature in keV
EM_49 = 5d48*f35^0.91/1.d49 ;emission measure in 10^49 cm^-3
delta = 3.0*f35^(-0.13)

; Compute thermal component
phflux_th = f_vth( en_edges, [EM_49,T_kev,1.] )  
; Compute nonthermal component
ebreak = 9
delta_below_break = 1.5
phflux_nonth = f35*bpow( emean, [delta_below_break,ebreak,delta] )/bpow( 35, [delta_below_break,ebreak,delta] )

phflux = phflux_th + phflux_nonth

If keyword_set(plot) then begin
  plot, emean, phflux, /xlog, /ylog, xtitle = 'Energy (keV)', ytitle = 'photons/cm2/s/keV', charsize = 1.4, title = 'Typical flare photon spectrum'
  oplot, emean, phflux_th, linestyle = 2
  oplot, emean, phflux_nonth, linestyle = 1
  al_legend, ['total','thermal','non-thermal'], textcolors = 255,color=255, linestyle = [0,2,1], charsize = 1.5, linsize = 0.4, /right
Endif

parameters = create_struct("EM_49", EM_49, "T_kev", T_kev, "f35", f35, "delta", delta)
phspec = create_struct("parameters", parameters, "energy_keV", emean, "phflux", phflux, "phflux_th", phflux_th, "phflux_nonth", phflux_nonth)
return, phspec

End