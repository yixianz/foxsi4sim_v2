Pro foxsi4_ospex_fit_example

; Description:
; Example script demonstrating how to use OSPEX to reconstruct photon spectrum from FOXSI-4 data (simulated):
; (a) simulate count spectrum for the M3.5 flare from Simoes and Kontar (2013)
; (b) calculate the 2d response matrix to put into OSPEX
; (c) try spectral fitting in OSPEX and compare fit parameters with the input parameters
; 
; History:
; Oct 2023, Y.Zhang

pos = 5    ; position number
att_wheel = 0    ; attenuator wheel is not inserted
int_time = 10.   ; integration time
energy_bin = 0.5    ; energy bin size for spectrum
counting_stat = 1    ; add counting statistics to count spectrum

; Generate photon spectrum for a real M3.5 flare
phspec = real_m3flare_phspec(footpoint=1)
; Simulate count spectrum
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, att_wheel=att_wheel, int_time = int_time, energy_bin = energy_bin, $
  counting_stat = counting_stat, plot = 1)
emean = ctspec.energy_kev

; Generate 2d response matrix
resp = foxsi4_resp_2d(pos = pos, att_wheel = att_wheel, energy_arr = emean)

; Create livetime array
livetime_array = fltarr(n_elements(emean))
livetime_array[*] = int_time

energy_bin = mean(get_edges(emean,/width))
e_edges = transpose([[emean-0.5*energy_bin],[emean+0.5*energy_bin]])

; Run ospex for spectral analysis
o = ospex()
o -> set, spex_data_source = 'SPEX_USER_DATA'
o -> set, spectrum = ctspec.count_flux*energy_bin*int_time, spex_ct_edges = e_edges, errors = sqrt(ctspec.count_flux*energy_bin*int_time),livetime=livetime_array
o -> set, spex_respinfo = resp.eff_area_cm2/energy_bin/1.
o -> set, spex_area = 1.
o-> set, fit_function= 'vth+thick2'  
o-> set, fit_comp_params= [0.1, 1.0, 1.00000,2.,5.,33000,0.00,20.0,32000]
o-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]    ; low energy cutoff is fixed because it's not well-constrained
o-> set, fit_comp_spectrum= ['full', '']
o-> set, fit_comp_model= ['chianti', '']
o-> set, spex_erange = [6.,18.]
o-> dofit

fit_params = o -> get(/fit_comp_params) 

print, 'Input parameters: ', phspec.parameters
print, 'Fit parameters: ', fit_params

stop
End