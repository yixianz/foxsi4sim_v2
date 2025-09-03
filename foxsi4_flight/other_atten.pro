energy_arr = indgen(40)*0.4+4.2

; Position 2
al_p2_trans = foxsi4_attenuator(al_um = 0.015*25400, energy_arr = energy_arr)
al_p2_new1 = foxsi4_attenuator(al_um = 0.012*25400, energy_arr = energy_arr)
al_p2_new2 = foxsi4_attenuator(al_um = 0.010*25400, energy_arr = energy_arr)
al_p2_new3 = foxsi4_attenuator(al_um = 0.008*25400, energy_arr = energy_arr)
plot, al_p2_trans.energy_kev, al_p2_trans.transmission,charsize = 1., charthick=1., xr=[0,30], thick=2, yr=[1e-4,1],/ylog,$
  xtitle = 'Energy (keV)', ytitle = 'Transmission fraction'
oplot, al_p2_new1.energy_kev, al_p2_new1.transmission, thick=2, color=cgcolor("blue")
oplot, al_p2_new2.energy_kev, al_p2_new2.transmission, thick=2, color=cgcolor("orange")
oplot, al_p2_new3.energy_kev, al_p2_new3.transmission, thick=2, color=cgcolor("green")

;plot, al_p2_trans.energy_kev, al_p2_trans.transmission/al_p2_new1.transmission,/ylog

write_csv, '/Users/zyx/Desktop/Lab/foxsi4/root_quicklook_ipynb/Flight_data_analysis/att.csv',$
  al_p2_trans.energy_kev,al_p2_trans.transmission/al_p2_new1.transmission, al_p2_trans.transmission/al_p2_new2.transmission,$
  al_p2_trans.transmission/al_p2_new3.transmission,$
  header=['energy (keV)','ratio (0.012"/0.015")','ratio (0.010"/0.015")','ratio (0.008"/0.015")']
  
al_p4_trans = foxsi4_attenuator(al_um = 0.005*25400, energy_arr = energy_arr)
  