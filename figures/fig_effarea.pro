Pro fig_effarea

popen,'fig_effarea2', xsi=6.7, ysi=5.5, /port
colorlist = [cgcolor('orange_red'), cgcolor('gold'), cgcolor('peru'),  cgcolor('lime_green'), cgcolor('teal'), cgcolor('dodger_blue'), $
  cgcolor('purple')]

resp = foxsi4_resp_diag(pos = 0)
plot, resp.energy_keV, resp.eff_area_cm2, /ylog, yrange = [0.001,20], xr = [1,23], /xsty, /ysty, thick = 4, charth=1.5, xth=4, yth=4, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!E2!N)', chars = 1.4

For i = 0, 6 do begin
    resp = foxsi4_resp_diag(pos = i)
    oplot, resp.energy_keV, resp.eff_area_cm2, color = colorlist[i], thick = 4
Endfor

al_legend, ['Position 0', 'Position 1', 'Position 2', 'Position 3', 'Position 4', 'Position 5', 'Position 6'], color = colorlist, textcolors = colorlist, $
  chars = 1.2, charth=1.5, box = 0, /right, position = [23, 17.]

pclose
cgPS2PDF, 'fig_effarea2.ps', /delete_ps


End