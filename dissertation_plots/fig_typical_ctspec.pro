Pro fig_typical_ctspec
  ; Plotting simulated CdTe strip detector count spectra for typical flares from scaling laws
  ; Generating 2 plots 
  ;   - one for C1, C5, M1, and M2 class flares (without attenuator wheel)
  ;   - one for M2, M5, M7, and X1 class flares (with attenuator wheel)

  !p.multi=[0,2,2]
  !X.margin=4.2
  !Y.margin=2.8
  !X.thick = 1.6
  !Y.thick = 1.6
  !P.FONT = 0
  colorcode = [cgcolor("Dodger blue"),cgcolor("Orange"),cgcolor("dark green"),cgcolor("hot pink")]

  ; ---------------- Baseline configuration (no attenuator wheel) ------------------------
  popen,'dissertation_plots/typical_ctspec_c_to_m2.ps', xsi=8, ysi=8, /port
  goesflux = [2e-5,1e-5,5e-6,1e-6]
  flareclass = ['M2','M1','C5','C1']
  
  For pos = 2, 5 do begin
    totcount = fltarr(n_elements(goesflux))
    pileup_frac = fltarr(n_elements(goesflux),2)
    For i = 0, n_elements(goesflux)-1 do begin
      phspec = typical_flare_phspec(fgoes = goesflux[i])    
      ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos = pos, energy_bin = 0.4, erange = [2,25], att_wheel = 0)  ; flare count spectrum
      totcount[i] = ctspec.count_rate_tot
      pileup_frac[i,*] = [1-exp(-totcount[i]/2*3.2e-6),1-exp(-totcount[i]/8*3.2e-6)]*100  ;pileup fraction assuming 2 or 8 strips
      if i eq 0 then begin
        plot, ctspec.energy_kev, ctspec.count_flux, chars=1.1, thick=3, charth=1.5, xth=3, yth=3, background=255, color=0, $
          /xlog, /ylog, title='Position '+strtrim(string(pos),2), psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', $
          yr=[1.,1d6], xr=[3.,30.], /xsty, /ysty
      endif
      oplot, ctspec.energy_kev, ctspec.count_flux, psym=10, color=colorcode[i], thick=3
    Endfor
    al_legend, [flareclass[0]+': '+strtrim(string(round(totcount[0])),2)+' cts/s,  pileup fraction '+string(pileup_frac[0,1],format='(F5.2)')+'% -'+string(pileup_frac[0,0],format='(F5.2)')+'%',$
      flareclass[1]+': '+strtrim(string(round(totcount[1])),2)+' cts/s,  pileup fraction '+string(pileup_frac[1,1],format='(F5.2)')+'% -'+string(pileup_frac[1,0],format='(F5.2)')+'%',$
      flareclass[2]+': '+strtrim(string(round(totcount[2])),2)+' cts/s,  pileup fraction '+string(pileup_frac[2,1],format='(F5.2)')+'% -'+string(pileup_frac[2,0],format='(F5.2)')+'%',$
      flareclass[3]+': '+strtrim(string(round(totcount[3])),2)+' cts/s,  pileup fraction '+string(pileup_frac[3,1],format='(F5.2)')+'% -'+string(pileup_frac[3,0],format='(F5.2)')+'%'],$
      chars=0.8, charth=2, box=0,linestyle=[0,0,0,0], linsi=0.3, color=colorcode, thick=4, spacing=1.05, position=[2.9,9e5]

  Endfor 

  pclose
  cgPS2PDF, 'dissertation_plots/typical_ctspec_c_to_m2.ps',/delete_ps ;convert .ps to .pdf

  stop
  
  ; ---------------- Bright flares (attenuator wheel in) ------------------------
  popen,'dissertation_plots/typical_ctspec_m_to_x2.ps', xsi=8, ysi=8, /port
  goesflux = [1e-4,7e-5,5e-5,2e-5]
  flareclass = ['X1','M7','M5','M2']

  For pos = 2, 5 do begin
    totcount = fltarr(n_elements(goesflux))
    pileup_frac = fltarr(n_elements(goesflux),2)
    For i = 0, n_elements(goesflux)-1 do begin
      phspec = typical_flare_phspec(fgoes = goesflux[i])
      ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos = pos, energy_bin = 0.4, erange = [2,25], att_wheel = 1)  ; flare count spectrum
      totcount[i] = ctspec.count_rate_tot
      pileup_frac[i,*] = [1-exp(-totcount[i]/2*3.2e-6),1-exp(-totcount[i]/8*3.2e-6)]*100  ;pileup fraction assuming 2 or 8 strips
      if i eq 0 then begin
        plot, ctspec.energy_kev, ctspec.count_flux, chars=1.1, thick=3, charth=1.5, xth=3, yth=3, background=255, color=0, $
          /xlog, /ylog, title='Position '+strtrim(string(pos),2)+' (Atten. wheel in)', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', $
          yr=[1.,1d5], xr=[3.,30.], /xsty, /ysty
      endif
      oplot, ctspec.energy_kev, ctspec.count_flux, psym=10, color=colorcode[i], thick=3
    Endfor
    al_legend, [flareclass[0]+': '+strtrim(string(round(totcount[0])),2)+' cts/s,  pileup fraction '+string(pileup_frac[0,1],format='(F5.2)')+'% -'+string(pileup_frac[0,0],format='(F5.2)')+'%',$
      flareclass[1]+': '+strtrim(string(round(totcount[1])),2)+' cts/s,  pileup fraction '+string(pileup_frac[1,1],format='(F5.2)')+'% -'+string(pileup_frac[1,0],format='(F5.2)')+'%',$
      flareclass[2]+': '+strtrim(string(round(totcount[2])),2)+' cts/s,  pileup fraction '+string(pileup_frac[2,1],format='(F5.2)')+'% -'+string(pileup_frac[2,0],format='(F5.2)')+'%',$
      flareclass[3]+': '+strtrim(string(round(totcount[3])),2)+' cts/s,  pileup fraction '+string(pileup_frac[3,1],format='(F5.2)')+'% -'+string(pileup_frac[3,0],format='(F5.2)')+'%'],$
      chars=0.8, charth=2, box=0,linestyle=[0,0,0,0], linsi=0.3, color=colorcode, thick=4, spacing=1.05, position=[2.9,9e4]

  Endfor

  pclose
  cgPS2PDF, 'dissertation_plots/typical_ctspec_m_to_x2.ps',/delete_ps ;convert .ps to .pdf

  
End