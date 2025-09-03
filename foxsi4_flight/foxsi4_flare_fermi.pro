Pro foxsi4_flare_fermi
; This script is to generate Fermi-predicted FOXSI-4 flare spectra 
; Has been used for SPHERE poster, AGU talk slides, and dissertation

; -----------Spectral fitting----------------------
specfile = 'foxsi4_flight/glg_cspec_n3_240417_v00.pha'
respfile = 'foxsi4_flight/glg_cspec_n3_bn240417_2200_917_v00.rsp2'

obj = ospex()
obj -> set, spex_specfile = specfile
obj -> set, spex_drmfile  = respfile
obj-> set, spex_erange= [6D, 20D]
obj-> set, spex_bk_time_interval=['17-Apr-2024 21:51:18.918', '17-Apr-2024 21:53:17.704']

obj-> set, spex_fit_time_interval= '17-Apr-2024 22:' + ['14:45','18:19']
obj-> set, fit_function= 'vth'
obj-> set, fit_comp_params= [10., 1.5, 1.]
obj-> set, fit_comp_minima= [1.e-20, 0.5, 0.01]
obj-> set, fit_comp_maxima= [1.e+20, 8. , 10.0]
obj-> set, fit_comp_free_mask= [1B, 1B, 0B]
obj-> set, fit_comp_spectrum= ['full']
obj-> set, fit_comp_model= ['chianti']
obj-> set, spex_autoplot_units= 'Flux'
obj-> set, spex_fitcomp_plot_bk= 1
;obj-> set, spex_eband= [[4.50000, 15.0000], [15.0000, 25.0000], [25.0000, 50.0000], $
;  [50.0000, 100.000], [100.000, 300.000], [300.000, 600.000], [600.000, 2000.00]]
obj-> set, spex_fit_manual=0
obj -> dofit, /all

;; try adding a nonthermal component - turns out that component is very faint if it exists
;obj-> set, fit_function= 'vth+bpow'
;obj-> set, fit_comp_params= [10., 1.5, 1., 0.602953, 1.7, 10., 5.]
;obj-> set, fit_comp_minima= [1.e-20, 0.5, 0.01, 1.e-10, 1.7, 5.,  1.7]
;obj-> set, fit_comp_maxima= [1.e+20, 8. , 10.0, 1.e+10, 10., 400., 10.]
;obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 0B, 1B, 1B]
;obj-> set, fit_comp_spectrum= ['full', '']
;obj-> set, fit_comp_model= ['chianti', '']
;obj -> dofit, /all

stop

; ----------get Fermi original (i.e. data with bk) and background count spectra----------------------
data_fit = obj -> getdata(class='spex_fitint', spex_units='flux')
obs = data_fit.obsdata ; data with bkg
bkg = data_fit.bkdata ; bkg
data = data_fit.data ; data-bkg
ct_en = obj -> getaxis(/ct_energy, /mean)
plot,ct_en,obs,/xlog,/ylog,psym=10,xr = [3,100],yr=[1e-2,10],/xst,xtitle = 'Energy (keV)', ytitle = 'counts/s/keV'
oplot,ct_en,bkg, psym=10, color=cgcolor("orange")
oplot,ct_en,data, psym=10, color=cgcolor("blue")
;write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/fermi_spec_thesis.csv', ct_en, obs, bkg, data, header=['Energy', 'data with bkg (ct flux)', 'bkg (flux)', 'data-bkg (flux)']
;;write_csv, 'foxsi4_flight/fermi_spec.csv', ct_en, obs, bkg, data, header=['Energy', 'data with bkg (ct flux)', 'bkg (flux)', 'data-bkg (flux)'] # AGU version

stop

;---------Extract photon-space spectra (data and/or model)------------------
results = obj -> get(/spex_summ)
en = results.spex_summ_energy
en_width = get_edges(en,/width)
en_mean = get_edges(en,/mean)
conv_fact = results.spex_summ_conv
ct_rate = results.spex_summ_ct_rate
ph_flux = ct_rate/conv_fact/en_width/results.spex_summ_area
ph_model= results.spex_summ_ph_model

fit_params = results.spex_summ_params
ph_model2 =  f_vth(en,fit_params)

plot,en_mean,ph_flux,/ylog,/xlog,xr=[4,50],yr=[1e-8,1e4]
oplot,en_mean,ph_model,color=cgcolor("red")
;oplot,en_mean,ph_model2,color=cgcolor("blue")
;write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/mflare_phspec.csv', en_mean, ph_flux, ph_model, header=['Energy', 'photon flux (data)', 'photon flux (model)']

stop

; -----------Predict FOXSI count spectra from fit parameters----------------------
; Best-fit detector (NAI_03)
en_edges2 = indgen(3000)*0.01+1
en2  = get_edges( en_edges2, /mean )
ph_model2 =  f_vth(en_edges2,fit_params)

ctspec_pos2 = foxsi4_ct_spec(en2, ph_model2, pos = 2, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos3 = foxsi4_ct_spec(en2, ph_model2, pos = 3, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos4 = foxsi4_ct_spec(en2, ph_model2, pos = 4, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos5 = foxsi4_ct_spec(en2, ph_model2, pos = 5, att_wheel = 0, erange=[4,30],energy_resolution=2)
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos2.csv', ctspec_pos2.energy_kev, ctspec_pos2.count_flux, header=['Energy', 'simulated count flux']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos3.csv', ctspec_pos3.energy_kev, ctspec_pos3.count_flux, header=['Energy', 'simulated count flux']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos4.csv', ctspec_pos4.energy_kev, ctspec_pos4.count_flux, header=['Energy', 'simulated count flux']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos5.csv', ctspec_pos5.energy_kev, ctspec_pos5.count_flux, header=['Energy', 'simulated count flux']

stop

; setting a range based on results from mutiple detectors (nai_01,nai_03,nai_05, those 3 have most counts)
params_n1 = [0.002834, 1.606, 1.000]
params_n3 = [0.04189, 1.105, 1.000]
params_n3_new_th = [0.0723, 1.05, 1.000]
params_n3_new_nonth = [0.0111, 2.0, 12.1, 3.62]
params_n5 = [0.1229, 1.014, 1.000]

sigma_n1= [8.899e-05, 0.009489, 0.000]
sigma_n3 = [0.002799, 0.009229, 0.000]
sigma_n5 = [0.006808, 0.006377, 0.000]

en_edges2 = indgen(3000)*0.01+1
en2  = get_edges( en_edges2, /mean )
ph_model_n1 =  f_vth(en_edges2,params_n1-sigma_n1)
ph_model_n3 =  f_vth(en_edges2,params_n3)
ph_model_n3_new =  f_vth(en_edges2,params_n3_new_th) + f_bpow(en_edges2,params_n3_new_nonth)
ph_model_n5 =  f_vth(en_edges2,params_n5+sigma_n5)
ph_model_l =  min([[ph_model_n1],[ph_model_n3],[ph_model_n5]], DIMENSION=2)
ph_model_h =  max([[ph_model_n1],[ph_model_n3],[ph_model_n5]], DIMENSION=2)

ctspec_pos2_l = foxsi4_ct_spec(en2, ph_model_l, pos = 2, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos3_l = foxsi4_ct_spec(en2, ph_model_l, pos = 3, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos4_l = foxsi4_ct_spec(en2, ph_model_l, pos = 4, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos5_l = foxsi4_ct_spec(en2, ph_model_l, pos = 5, att_wheel = 0, erange=[4,30],energy_resolution=2)

ctspec_pos2_h = foxsi4_ct_spec(en2, ph_model_h, pos = 2, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos3_h = foxsi4_ct_spec(en2, ph_model_h, pos = 3, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos4_h = foxsi4_ct_spec(en2, ph_model_h, pos = 4, att_wheel = 0, erange=[4,30],energy_resolution=1)
ctspec_pos5_h = foxsi4_ct_spec(en2, ph_model_h, pos = 5, att_wheel = 0, erange=[4,30],energy_resolution=2)

write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos2_range.csv', $
  ctspec_pos2_l.energy_kev, ctspec_pos2_l.count_flux, ctspec_pos2_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos3_range.csv', $
  ctspec_pos3_l.energy_kev, ctspec_pos3_l.count_flux, ctspec_pos3_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos4_range.csv', $
  ctspec_pos4_l.energy_kev, ctspec_pos4_l.count_flux, ctspec_pos4_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos5_range.csv', $
  ctspec_pos5_l.energy_kev, ctspec_pos5_l.count_flux, ctspec_pos5_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']


;  ctspec_pos2_l = foxsi4_ct_spec(en2, ph_model_l, pos = 2, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos3_l = foxsi4_ct_spec(en2, ph_model_l, pos = 3, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos4_l = foxsi4_ct_spec(en2, ph_model_l, pos = 4, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos5_l = foxsi4_ct_spec(en2, ph_model_l, pos = 5, att_wheel = 0, erange=[4.,20],energy_resolution=2,energy_bin=0.4)
;
;  ctspec_pos2_h = foxsi4_ct_spec(en2, ph_model_h, pos = 2, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos3_h = foxsi4_ct_spec(en2, ph_model_h, pos = 3, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos4_h = foxsi4_ct_spec(en2, ph_model_h, pos = 4, att_wheel = 0, erange=[4.,20],energy_resolution=1,energy_bin=0.4)
;  ctspec_pos5_h = foxsi4_ct_spec(en2, ph_model_h, pos = 5, att_wheel = 0, erange=[4.,20],energy_resolution=2,energy_bin=0.4)
;
;  write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos2_range2.csv', $
;    ctspec_pos2_l.energy_kev, ctspec_pos2_l.count_flux, ctspec_pos2_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
;  write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos3_range2.csv', $
;    ctspec_pos3_l.energy_kev, ctspec_pos3_l.count_flux, ctspec_pos3_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
;  write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos4_range2.csv', $
;    ctspec_pos4_l.energy_kev, ctspec_pos4_l.count_flux, ctspec_pos4_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']
;  write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/dissertation/flight_science/foxsi_spec_predicted_pos5_range2.csv', $
;    ctspec_pos5_l.energy_kev, ctspec_pos5_l.count_flux, ctspec_pos5_h.count_flux, header=['Energy', 'simulated count flux (low_bound)', 'simulated count flux (hi_bound)']


End

