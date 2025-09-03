;
; Script for Fermi GBM data analysis from Lindsay
;

; Note: nai_05 has the highest counts, but the spectrum fits best for nai_03.

specfile = 'fermi/glg_cspec_n3_240417_v00.pha'
respfile = 'fermi/glg_cspec_n3_bn240417_2200_917_v00.rsp2'

obj = ospex()
obj -> set, spex_specfile = specfile
obj -> set, spex_drmfile  = respfile 
obj-> set, spex_erange= [6.0854354D, 49.942291D]                                                                        
obj-> set, spex_bk_time_interval=['17-Apr-2024 21:51:18.918', '17-Apr-2024 21:53:17.704']                               

n=40
dur=30.
t_int = anytim( '17-Apr-2024 2200' ) + findgen(n+1)*dur
t_int = transpose([[t_int[0:n-1]],[t_int[1:n]]])
obj-> set, spex_fit_time_interval= anytim( t_int, /yo )

obj-> set, spex_fit_time_interval= '17-Apr-2024 22:' + ['15','17']

obj-> set, fit_function= 'vth+bpow'
obj-> set, fit_comp_params= [10., 1.5, 1., 0.602953, 1.7, 10., 5.]                                                                                                     
obj-> set, fit_comp_minima= [1.e-20, 0.5, 0.01, 1.e-10, 1.7, 5.,  1.7]
obj-> set, fit_comp_maxima= [1.e+20, 8. , 10.0, 1.e+10, 10., 400., 10.]                                                                                             
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 0B, 1B, 1B]                                      
obj-> set, fit_comp_spectrum= ['full', '']
obj-> set, fit_comp_model= ['chianti', '']
obj-> set, spex_autoplot_units= 'Flux'                                                                                  
obj-> set, spex_fitcomp_plot_bk= 1                                                                                      
obj-> set, spex_eband= [[4.50000, 15.0000], [15.0000, 25.0000], [25.0000, 50.0000], $                                   
 [50.0000, 100.000], [100.000, 300.000], [300.000, 600.000], [600.000, 2000.00]]                                        
obj-> set, spex_tband= [['17-Apr-2024 21:16:13.541', '17-Apr-2024 21:57:10.656'], $                                     
 ['17-Apr-2024 21:57:10.656', '17-Apr-2024 22:38:07.770'], ['17-Apr-2024 22:38:07.770', $                               
 '17-Apr-2024 23:19:04.884'], ['17-Apr-2024 23:19:04.884', '18-Apr-2024 00:00:01.999']] 

obj -> dofit, /all
 
                                 
obj -> restorefit, $                                                                                                    
 file='fermi/ospex_results_fermi_NAI_05.fits'                 
end          

 file='fermi/ospex_results_fermi_NAI_05.fits'

p0 = spex_read_fit_results(file)                                                                                                           
