Pro fig_pileup_sim

; Simulating pileup for the real M3.5 flare and plotting the piled-up count spectra
; Consider several different pileup fraction values - 0.1%, 0.5%, 1%, 1.5%, 2%
; 100000 photons (before pileup) generated in each case

  ;for M3.5 real flare 
  phspec = real_m3flare_phspec()
   
  pileup_frac = [0,0.005, 0.01, 0.02, 0.04]
  
  popen,'dissertation_plots/pileup_m3_ctspec.ps', xsi=8, ysi=8, /port

  !p.multi=[0,2,2]
  !X.margin=4.2
  !Y.margin=2.8
  !X.thick = 1.6
  !Y.thick = 1.6
  !P.FONT = 0
  colorcode = [0,cgcolor("Dodger blue"),cgcolor("Orange"),cgcolor("dark green"),cgcolor("hot pink")]
  
  For pos = 2, 5 do begin
    ; generate non-piled-up count spectrum
    ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos,energy_bin=0.02, erange=[3,35])
      
    bin_num = n_elements(ctspec.energy_kev)/10
    emean = rebin(ctspec.energy_kev, bin_num)
    For i = 0, 4 do begin
      pileup_spec = pileup_sim(ctspec.energy_keV, ctspec.count_flux, pileup_frac=pileup_frac[i], n_events=1000000)
      ctflux_pileup = rebin(pileup_spec.count_flux, bin_num)
      If i eq 0 then begin
        plot, emean, ctflux_pileup, psym=10, /xlog,/ylog, color=colorcode[i], thick=2.5, yrange = [1,1d4], xrange = [3,35],/xsty,$
          xtitle='Energy (keV)',ytitle='Counts/s/keV',ytickunits='scientific', title='Position '+strtrim(string(pos),2)
      Endif else begin
        oplot, emean, ctflux_pileup, psym=10, color=colorcode[i], thick=2.5
      Endelse
    Endfor
    
    al_legend, [string(pileup_frac[0]*100,format='(F4.2)')+'% pileup', $
      string(pileup_frac[1]*100,format='(F4.2)')+'% pileup', string(pileup_frac[2]*100,format='(F4.2)')+'% pileup', $
      string(pileup_frac[3]*100,format='(F4.2)')+'% pileup', string(pileup_frac[4]*100,format='(F4.2)')+'% pileup'], $
      chars=0.85, charth=2,linestyle=0, linsi=0.3, color=colorcode, thick=3, spacing=1., /right
  
  Endfor
    
  pclose
  cgPS2PDF, 'dissertation_plots/pileup_m3_ctspec.ps',/delete_ps ;convert .ps to .pdf

  stop
End



Function pileup_sim, energy_arr, ct_flux, pileup_frac = pileup_frac, n_events = n_events

  ; Adapted from foxsi4_pileup_sim.pro (see more details on method there)
  ;
  ; Inputs:
  ; energy_arr: 1d energy array in keV (bin centers)
  ; ct_flux: count fluxes at above energies, corresponding to the non-pileup spectrum
  ; 
  ; Keywords:
  ; pileup_frac: pileup fraction
  ; n_events: total number of simulated photons
  ;
  ; Outputs:
  ; Data structure for piled-up spectrum, which consists of energy array (keV), updated count fluxes (counts/s/keV), 
  ;   and updated count rate (counts/s)
  ;
  ; Example:
  ; IDL> phspec = real_m3flare_phspec()
  ; IDL> ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=2,energy_bin=0.1, erange=[3,30])
  ; IDL> pileup_spec = pileup_sim(ctspec.energy_keV, ctspec.phflux, pileup_frac=0.01, n_events=100000)
  
  Default, pileup_frac, 0.  ; Default is no pileup
  Default, n_events, 1d6
  
  ; Event list sampling
  cdf = total(ct_flux, /CUMULATIVE)/total(ct_flux) ;cumulative distribution function
  s1 = randomu(seed, n_events)
  en = interpol(energy_arr,cdf,s1,/SPLINE)
  bin_width = mean(get_edges(energy_arr,/width))
  spec_hist = HISTOGRAM(en, binsize = bin_width, min = min(energy_arr)-bin_width/2, nbins = n_elements(energy_arr))*total(ct_flux)/n_events
  ;plot,energy_arr,spec_hist,/xlog,/ylog, yrange = [1,1d5], xrange = [3,30],/xsty,psym=10,xtitle='Energy (keV)'
  ;oplot, energy_arr, ct_flux, psym=10, color=3
  
  ; Calculate pileuped spectrum for the assumed pileup fraction
  cr_per_strip = -alog(1.-pileup_frac)/3.2d-6 ; Using relation between pileup fraction and per-strip count rates  
  s2 = randomu(seed, n_events)
  t_events = -alog(1.-s2)/cr_per_strip   ; distribution of time interval between events: pdf = r*exp(-rt)   cdf = 1.-exp(-rt)
  
  ; pileup simulation (only first order)
  en_pileup = []
  t_events[0] = 10 ; first event is never piled up
  For j=0, n_events-1 do begin
    If t_events[j] le 3.2e-6 then begin
      If en_pileup[-1] eq en[j-1] then begin   ; the last photon is not a pileup photon
        ; approximate pulse shape:  1-((t/3.2e-6)-1)^2
        pulse_multiplier = 1-(t_events[j]/3.2e-6)^2
        en_pileup[-1] = en_pileup[-1]+en[j]*pulse_multiplier
      Endif
    Endif else begin
      en_pileup = [en_pileup,en[j]]
    Endelse
  Endfor
  
  ; If pileup fraction is 0, use the non-piled-up event list
  If pileup_frac eq 0 then en_pileup = en 
  
  spec_hist_pileup = HISTOGRAM(en_pileup, binsize = bin_width, min = min(energy_arr)-bin_width/2, nbins = n_elements(energy_arr))*total(ct_flux)/n_events
  ;oplot,energy_arr,spec_hist_pileup,color=cgcolor("red")
  
  ; Compare actual pileup fraction from the event list with expected value
  pileup_frac2 = 1-float(n_elements(en_pileup))/n_events
  print, "pileup fraction (expected):", pileup_frac, "     actual:", pileup_frac2
    
  pileup_spec = create_struct("energy_keV", energy_arr, "count_flux", spec_hist_pileup)
  return, pileup_spec

End
