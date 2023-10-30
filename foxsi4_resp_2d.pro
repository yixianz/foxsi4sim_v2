Function foxsi4_resp_2d, pos = pos, energy_arr = energy_arr,  att_wheel = att_wheel, energy_resolution = energy_resolution, $
  plot = plot

; Purpose:
; Generate FOXSI-4 2D instrument response matrix that can be put into OSPEX for photon spectrum reconstruction
; 
; Notes:
; Units: cm^2
; Off-diagonol elements only come from detector energy resolution so far.
; 1D diagonol response from foxsi4_resp_diag.pro convolved with Gaussian.
;
; Keywords:
; pos: position number (must be from 0 to 6)
; energy_arr: 1d energy array in keV (must be uniform bin size)
; att_wheel: set this to 1 to insert the attenutor wheel (only have effects on CdTe strip detectors)
; energy_resolution: energy resolution of the detector (if not set, use 0.2 keV for CMOS, 1 keV for CdTe, 5.4 keV for Timepix)
; plot: set this to 1 to plot the 2d response
; 
; Examples:
; resp = foxsi4_resp_2d(pos = 2, energy_arr = findgen(300)*0.1+1, plot = 1)
; 
; History:
; Oct 2023, created by Y. Zhang


Default, energy_arr, findgen(40)*0.8+1
Default, att_wheel, 0
Default, plot, 0

If keyword_set(energy_resolution) eq 0 then begin
  If pos eq 0 or 1 then energy_resolution = 0.2   ;cmos
  If pos eq 2 or 3 or 4 or 5 then energy_resolution = 1.   ;cdte
  If pos eq 6 then energy_resolution = 5.4    ;timepix
Endif

; Get diagonal response
resp_diag = foxsi4_resp_diag(pos = pos, energy_arr = energy_arr, att_wheel = att_wheel) 
resp_1d = resp_diag.eff_area_cm2
ndiag = n_elements(resp_1d)
resp_2d = fltarr(ndiag,ndiag)

; Convolve with Gaussian to get 2d response matrix
energy_bin = mean(get_edges(energy_arr, /width))
sigma = energy_resolution/(2.*sqrt(2*alog(2)))     ; covert energy resolution (FWHM) to sigma
For j = 0, ndiag-1 do begin
  resp_2d[j,j] = resp_1d[j]
  resp_2d[*,j] = GAUSS_SMOOTH(resp_2d[*,j], sigma/energy_bin, kernel=kernel, /edge_truncate)
Endfor

If keyword_set(plot) then begin
  loadct,5
  plot_image, resp_2d, scale=energy_bin, xtitle='Input photon energy (keV)', ytitle='Output photon energy (keV)', charsize=1.6
Endif

result = create_struct("energy_arr", energy_arr, "eff_area_cm2", resp_2d)
return, result

End