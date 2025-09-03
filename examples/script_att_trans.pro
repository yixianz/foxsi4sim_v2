;-------------------------- fixed uniform attenuators --------------------------
att_trans_p2_fixed = foxsi4_attenuator(al_um = 0.015*25400, energy_arr = energy_arr)
att_trans_p2_fixed_lb = foxsi4_attenuator(al_um = 0.015*1.05*25400, energy_arr = energy_arr)
att_trans_p2_fixed_ub = foxsi4_attenuator(al_um = 0.015*0.95*25400, energy_arr = energy_arr)
write_csv, 'unif_att_p2_theoretical.csv', att_trans_p2_fixed.energy_keV,  att_trans_p2_fixed.transmission, $
  att_trans_p2_fixed_lb.transmission, att_trans_p2_fixed_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']

att_trans_p4_fixed = foxsi4_attenuator(al_um = 0.005*25400, energy_arr = energy_arr)
att_trans_p4_fixed_lb = foxsi4_attenuator(al_um = 0.005*1.05*25400, energy_arr = energy_arr)
att_trans_p4_fixed_ub = foxsi4_attenuator(al_um = 0.005*0.95*25400, energy_arr = energy_arr)
write_csv, 'unif_att_p4_theoretical.csv', att_trans_p4_fixed.energy_keV,  att_trans_p4_fixed.transmission, $
  att_trans_p4_fixed_lb.transmission, att_trans_p4_fixed_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']

;-------------------------- Attenuator wheel --------------------------
att_trans_p2_wheel = foxsi4_attenuator(al_um = 0.015*25400, energy_arr = energy_arr)
att_trans_p2_wheel_lb = foxsi4_attenuator(al_um = 0.015*1.05*25400, energy_arr = energy_arr)
att_trans_p2_wheel_ub = foxsi4_attenuator(al_um = 0.015*0.95*25400, energy_arr = energy_arr)
write_csv, 'att_wheel_p2_theoretical.csv', att_trans_p2_wheel.energy_keV,  att_trans_p2_wheel.transmission, $
  att_trans_p2_wheel_lb.transmission, att_trans_p2_wheel_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']
  
att_trans_p3_wheel = foxsi4_attenuator(al_um = 0.006*25400, energy_arr = energy_arr)
att_trans_p3_wheel_lb = foxsi4_attenuator(al_um = 0.006*1.05*25400, energy_arr = energy_arr)
att_trans_p3_wheel_ub = foxsi4_attenuator(al_um = 0.006*0.95*25400, energy_arr = energy_arr)
write_csv, 'att_wheel_p3_theoretical.csv', att_trans_p3_wheel.energy_keV,  att_trans_p3_wheel.transmission, $
  att_trans_p3_wheel_lb.transmission, att_trans_p3_wheel_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']

att_trans_p4_wheel = foxsi4_attenuator(al_um = 0.007*25400, energy_arr = energy_arr)
att_trans_p4_wheel_lb = foxsi4_attenuator(al_um = 0.007*1.05*25400, energy_arr = energy_arr)
att_trans_p4_wheel_ub = foxsi4_attenuator(al_um = 0.007*0.95*25400, energy_arr = energy_arr)
write_csv, 'att_wheel_p4_theoretical.csv', att_trans_p4_wheel.energy_keV,  att_trans_p4_wheel.transmission, $
  att_trans_p4_wheel_lb.transmission, att_trans_p4_wheel_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']

att_trans_p5_wheel = foxsi4_attenuator(al_um = 0.013*25400, energy_arr = energy_arr)
att_trans_p5_wheel_lb = foxsi4_attenuator(al_um = 0.013*1.05*25400, energy_arr = energy_arr)
att_trans_p5_wheel_ub = foxsi4_attenuator(al_um = 0.013*0.95*25400, energy_arr = energy_arr)
write_csv, 'att_wheel_p5_theoretical.csv', att_trans_p5_wheel.energy_keV,  att_trans_p5_wheel.transmission, $
  att_trans_p5_wheel_lb.transmission, att_trans_p5_wheel_ub.transmission, $
  header=['energy[keV]','transmission', 'transmission_lb', 'transmission_ub']

;-------------------------- FP thin mylar (.25mil mylar + 2*1000A Al) --------------------------
fp_mylar_mylar_trans = get_material_transmission('material_data/mylar_att_len.txt', 6.35, energy_arr = energy_arr)
fp_mylar_al_trans = get_material_transmission('material_data/al_att_len.txt', 0.2, energy_arr = energy_arr)
fp_mylar_transmission = fp_mylar_mylar_trans.transmission * fp_mylar_al_trans.transmission
write_csv, 'thin_mylar_p3_p5_theoretical.csv', fp_mylar_mylar_trans.energy_keV,  fp_mylar_transmission, $
  header=['energy[keV]','transmission']

