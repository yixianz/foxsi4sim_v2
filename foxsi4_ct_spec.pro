Function foxsi4_ct_spec, energy_arr, ph_flux, pos = pos, energy_bin = energy_bin, energy_resolution = energy_resolution, $
  erange = erange, att_wheel = att_wheel, counting_stat = counting_stat, int_time = int_time, plot = plot, let_file = let_file
  
; Purpose: generate FOXSI-4 count spectrum for a given photon spectrum
; 
; Description:
; For any given photon spectrum and position number, the count spectrum is calculated as follows:
; (a) calculate count flux from photon flux and (1d) instrument response
; (b) convolve with Gaussian to account for detector energy resolution
; (c) rebin and set energy range to make the count spectrum more realistic
; (d) if needed, add counting statistics by randomly adjusting count fluxes according to Possion distribution
;
; Inputs:
; energy_arr: 1d energy array in keV (bin centers)
; ph_flux: photon fluxes at above energies in photons/cm2/s/keV
;
; Keywords:
; pos: position number (choose from 0-6, see foxsi4_resp_diag.pro for more details)
; energy_bin: energy bin size for count spectrum
; energy_resolution: energy resolution of the detector (if not set, use 0.2 keV for CMOS, 1 keV for CdTe, 5.4 keV for Timepix)
; erange: 2d array of [energy_min, energy_max]
; att_wheel: set this to 1 to insert the attenutor wheel
; counting_stat: set this to 1 to add counting statistics
; int_time: integration time in seconds (only used when counting_stat is set)
; plot: set this to 1 to plot count flux vs energy
; let_file:
; 
; Outputs:
; Data structure that consists of energy array (keV), count fluxes (counts/s/keV), and total count rate (counts/s)
; 
; Example 1:
; phspec = typical_flare_phspec(fgoes = 1e-5)  ; M1 class
; ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=2, plot = 1)
; Example 2:
; phspec = typical_flare_phspec(fgoes = 5e-5)  ; M5 class
; ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=3, att_wheel=1, counting_stat = 1, int_time = 30.,  plot = 1)
; 
; History:
; Oct 2023, created by Y. Zhang
; Apr 8 2024, added CdTe let file option


Default, energy_bin, 0.8
Default, erange, [3,30]
Default, att_wheel, 0
Default, counting_stat, 0
Default, int_time, 60
Default, plot, 0

; Detector energy resolution
If keyword_set(energy_resolution) eq 0 then begin
  If pos eq 0 or 1 then energy_resolution = 0.2   ;cmos
  If pos eq 2 or pos eq 3 or pos eq 4 or pos eq 5 then energy_resolution = 1.  ;cdte
  If pos eq 6 then energy_resolution = 5.4    ;timepix
Endif

If pos eq 0 then print, "Calculating count spectrum for position 0: MSFC hi-res optics + CMOS ..." else $
  if pos eq 1 then print, "Calculating count spectrum for position 1: Nagoya hi-res optics + CMOS ..." else $
  if pos eq 2 then print, "Calculating count spectrum for position 2: 10-shell optics + CdTe ..." else $
  if pos eq 3 then print, "Calculating count spectrum for position 3: MSFC high-resolution optics + pixelated attenuator + CdTe ..." else $
  if pos eq 4 then print, "Calculating count spectrum for position 4: Nagoya high-resolution optics + CdTe ..." else $
  if pos eq 5 then print, "Calculating count spectrum for position 5: 10-shell optics + pixelated attenuator + CdTe ..." else $
  if pos eq 6 then print, "Calculating count spectrum for position 6: MSFC high-resolution optics + Timepix ..." 

print, "Detector energy resolution:", energy_resolution, " keV"

; Calculate count flux
resp = foxsi4_resp_diag(pos = pos, energy_arr = energy_arr, att_wheel = att_wheel, let_file = let_file)
ct_flux = ph_flux * resp.eff_area_cm2
;plot, energy_arr, ct_flux,/xlog,/ylog, xr = [3,30], yr = [1,1e5]

; Convolve with Gaussian to account for energy resolution
bin_width = mean(get_edges(energy_arr,/width))
sigma = energy_resolution/(2.*sqrt(2*alog(2)))
ct_flux = GAUSS_SMOOTH(ct_flux, sigma/bin_width, kernel=kernel, /edge_truncate)

; Rebin in selected energy range (note: done by interpolation)
n_ebin = fix((erange[1] - erange[0])/energy_bin)
en_edges_new = erange[0] + findgen(n_ebin+1)*energy_bin
energy_new = get_edges(en_edges_new, /mean)
ct_flux_new = interpol(ct_flux, energy_arr, energy_new) ;counts/s/keV
ct_flux_new = ct_flux_new > 0

; Add Possion noise if counting_stat is set to 1
If counting_stat eq 1 then begin
  ct_flux_tot = fltarr(n_elements(ct_flux_new))
  For k=0, n_elements(ct_flux_new)-1 do begin
    If ct_flux_new[k] gt 0 then begin
      ct_flux_tot[k] = randomu(seed, 1, poisson = ct_flux_new[k]*int_time, /double)
      seed = !null
    Endif
  Endfor
  ct_flux_new = ct_flux_tot/int_time
Endif

; calculate count rate
ct_rate = total(ct_flux_new * energy_bin)
print, "Total count rate:", ct_rate, " counts/s"

If keyword_set(plot) then plot, energy_new, ct_flux_new, /xlog, /ylog, psym=10, yr=[1,1e4], charsize = 1.5, $
  title = "Count spectrum, Position " + strtrim(pos,2), xtitle = 'Energy (keV)', ytitle = 'counts/s/keV'

ctspec = create_struct("energy_keV", energy_new, "count_flux", ct_flux_new, "count_rate_tot", ct_rate)

return, ctspec

End