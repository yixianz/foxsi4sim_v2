Pro proposal_figure_effarea

!p.multi = 0
popen,'fig_effarea', xsi=6.7, ysi=5.5, /port
colorlist = [cgcolor('orange_red'), cgcolor('gold'), cgcolor('peru'),  cgcolor('lime_green'), cgcolor('teal'), cgcolor('dodger_blue'), $
  cgcolor('purple')]

; Just effective area with optics + detector
energy_arr = findgen(4000)*0.01+1
; pos 0
optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cmos = 1)      ; detector efficiency
;optf_poly = get_material_transmission('material_data/polymide_att_len.txt', 5., energy_arr = energy_arr)
;optf_al = get_material_transmission('material_data/al_att_len.txt', 0.15, energy_arr = energy_arr)
;optf_trans = optf_poly.transmission * optf_al.transmission
;colli_trans = 0.4 ; optics collimator
;optics.eff_area_cm2 = optics.eff_area_cm2 * colli_trans * optf_trans
effarea = optics.eff_area_cm2 * detector.efficiency
plot, energy_arr, effarea, /ylog, yrange = [0.01,20], xr = [1,23], /xsty, /ysty, thick = 4, charth=1.5, xth=4, yth=4, $
      xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!E2!N)', chars = 1.4
oplot, energy_arr, effarea, color = colorlist[0], thick = 4
; pos 1
optics = foxsi4_optics_effarea(energy_arr = energy_arr, nagoya_hxr = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cmos = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[1], thick = 4
; pos 2
optics = foxsi4_optics_effarea(energy_arr = energy_arr, heritage = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[2], thick = 4
; pos 3
optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[3], thick = 4
; pos 4
optics = foxsi4_optics_effarea(energy_arr = energy_arr, nagoya_hxr = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[4], thick = 4
; pos 5
optics = foxsi4_optics_effarea(energy_arr = energy_arr, heritage = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, cdte = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[5], thick = 4
; pos 6
optics = foxsi4_optics_effarea(energy_arr = energy_arr, msfc_hi_res = 1)     ; optics effective area
detector = foxsi4_deteff(energy_arr = energy_arr, timepix = 1)      ; detector efficiency
effarea = optics.eff_area_cm2 * detector.efficiency
oplot, energy_arr, effarea, color = colorlist[6], thick = 4


For i = 0, 6 do begin
  resp = foxsi4_resp_diag(pos = i)
  oplot, resp.energy_keV, resp.eff_area_cm2, color = colorlist[i], thick = 5, linestyle = 1
Endfor


al_legend, ['Mod. 0', 'Mod. 1', 'Mod. 2', 'Mod. 3', 'Mod. 4', 'Mod. 5', 'Mod. 6'], color = colorlist, textcolors = colorlist, $
  chars = 1.2, charth=1.5, box = 0, /right, position = [23, 17.]

pclose
cgPS2PDF, 'fig_effarea.ps', /delete_ps
stop
End