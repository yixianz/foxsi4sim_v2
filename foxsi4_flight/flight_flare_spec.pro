; FOXSI-4 flight flare spectroscopy
; 
; Predicted count spectrum from Fermi thermal fit parameters
en_edges = indgen(300)*0.1+1
emean  = get_edges( en_edges, /mean )
phflux_fermi1 = f_vth( en_edges, [0.0997, 1.05, 1.] )  
;phflux_fermi2 = f_vth( en_edges, [0.0443, 1.11, 1.] )  
phflux_fermi2 = f_vth( en_edges, [0.0418, 1.11, 1.] ) ;22:14:45-22:18:15 UT, nai_03
pos = 2
ctspec1 = foxsi4_ct_spec(emean, phflux_fermi1, pos = pos, att_wheel = 0)
ctspec2 = foxsi4_ct_spec(emean, phflux_fermi2, pos = pos, att_wheel = 0, erange=[4,30],energy_resolution=2)
plot, ctspec1.energy_kev, ctspec1.count_flux, psym=10, xtitle = 'Energy (keV)', ytitle = 'counts/s/keV', xr=[0,20], charsize = 1.6, $
  background=255, color = 0
oplot, ctspec2.energy_kev, ctspec2.count_flux, psym=10, color = cgcolor("blue")
al_legend,['thermal params 1','thermal params 2'], textcolor = [0,cgcolor("blue")], charsize = 1.6, box=0, /right
;plot, ctspec.energy_kev, ctspec.count_flux, /xlog, /ylog, psym=10, yr=[0.01,1e2], charsize = 1.5, $
;  title = "Count spectrum, Position " + strtrim(pos,2), xtitle = 'Energy (keV)', ytitle = 'counts/s/keV'

;write_csv, 'foxsi4_flight/foxsi_spec_predicted_pos2.csv', ctspec2.energy_kev, ctspec2.count_flux, header=['Energy', 'Count flux']

; Spectral fitting
; CdTe 4, Position 2 
pos = 2    ; position number
att_wheel = 0    ; attenuator wheel is not inserted

pt_count_arr = [ 0.,   0.,  42.,  69.,  62.,$
  122., 146., 223., 303., 464., 607., 717., 690., 755., 586., 567.,$
  438., 297., 167., 100.,  61.,  36.,  24.,  14.,   7.,   4.,   3.,$
  5.,   0.,   0.,   0.,   0.,   0.,   2.]
al_count_arr = [ 0.,   0.,  16.,  12.,  32.,$
  50., 106., 191., 336., 517., 641., 787., 747., 814., 694., 549.,$
  416., 250., 159.,  71.,  41.,  28.,  18.,  16.,   5.,   7.,   3.,$
  0.,   2.,   0.,   0.,   1.,   2.,   0.]
en_bin = [ 3. ,  3.5,  4. ,  4.5,  5. , $
  5.5,  6. ,  6.5,  7. ,  7.5,  8. ,  8.5,  9. ,  9.5, 10. , 10.5, $
  11. , 11.5, 12. , 12.5, 13. , 13.5, 14. , 14.5, 15. , 15.5, 16. , $
  16.5, 17. , 17.5, 18. , 18.5, 19. , 19.5, 20. ]
livetime = 51.55704834 ; in seconds

; Generate 2d response matrix
emean = get_edges(en_bin,/mean)
resp = foxsi4_resp_2d(pos = pos, att_wheel = att_wheel, energy_arr = emean)
energy_bin = 0.5

livetime_array = fltarr(n_elements(emean))
livetime_array[*] = livetime
e_edges = [transpose(en_bin[0:-2]),transpose(en_bin[1:-1])]

o = ospex()
o -> set, spex_data_source = 'SPEX_USER_DATA'
o -> set, spectrum = pt_count_arr, spex_ct_edges = e_edges, errors = sqrt(pt_count_arr),livetime=livetime_array
o -> set, spex_respinfo = resp.eff_area_cm2/energy_bin/1.
o -> set, spex_area = 1.
o-> set, fit_function= 'vth+thick2'
o-> set, fit_comp_params= [0.1, 1.0, 1.00000,2.,5.,33000,0.00,20.0,32000]
o-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]    ; low energy cutoff is fixed because it's not well-constrained
o-> set, fit_comp_spectrum= ['full', '']
o-> set, fit_comp_model= ['chianti', '']
o-> set, spex_erange = [6.,16.]
o-> dofit

