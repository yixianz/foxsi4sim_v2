Pro fig_effarea_fierce

  popen,'fig_fierce_effarea', xsi=7.5, ysi=2.2, /port
    
  !p.multi=[0,2,1]
  !X.margin=4.2
  !Y.margin=0.2

  fierce_fname = '/Users/zyx/Desktop/FIERCE_EA_options_70keV_20m_FL.csv'
    
  resp = foxsi4_optics_effarea(heritage = 1)
  plot, resp.energy_keV, resp.eff_area_cm2, xr = [0,80], yr=[0.1,40], /xsty, /ysty, thick = 4, charth=1.5, xth=4, yth=4, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!E2!N)', chars = 1.3,yminor=2, /ylog
  resp = foxsi4_optics_effarea(msfc_hi_res = 1)
  oplot, resp.energy_keV, resp.eff_area_cm2,thick = 4, color=cgcolor('orange_red')
  resp = foxsi4_optics_effarea(nagoya_hxr = 1)
  oplot, resp.energy_keV, resp.eff_area_cm2,thick = 4,color=cgcolor('dodger_blue')
  al_legend, ['10-shell optics','2-shell MSFC high-res','1-shell Nagoya high-res' ], color=[0,cgcolor('orange_red'),cgcolor('dodger_blue')], $
    linestyle=0,linsi=0.3,chars=1.05,charth=0.5,thick=4, pos=[11,35],box=0


  data = read_csv(fierce_fname)
  energy = data.field1 ; in kev
  eff_area = data.field2 ; in cm2
  plot, energy[0:-240],eff_area[0:-240],yrange = [5,100], xr = [0,80], /xsty, /ysty, thick = 4, charth=1.5, xth=4, yth=4, $
    xtitle = 'Energy (keV)', ytitle = 'Effective area (cm!E2!N)', chars = 1.3,/ylog

  
  pclose
  cgPS2PDF, 'fig_fierce_effarea.ps', /delete_ps

End