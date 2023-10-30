Pro foxsi4_typical_flare_ctspec, pos = pos, large_flare = large_flare

; Purpose:
; FOXSI-4 count spectrum simulation for typical flares from scaling laws
; 
; Notes:
; In the plot, numbers at the top left corner show total count rates and pileup fractions (assuming photons are spread over 
; 8 to 2 strips) for each flare class.
; Consider two scenarios: 
; (a) smaller flares ('M3','M2','M1','C5','C1') - no need to insert the attenuator wheel
; (b) large flares ('X1','M7','M5','M3','M2') - insert the attenuator wheel
; M2-M3 is probably near the threshold where we need to insert the attenuator wheel so they are considered in both scenarios.
; For actual flight, decisions will be made based on detector data instead of GOES flux.
; 
; Keywords:
; pos: position number (choose from 0-6, see foxsi4_resp_diag.pro for more details)
; large_flare: set to 1 to generate spectra for large flares. Attenuator wheel is inserted in this case.
;
; Examples:
; foxsi4_typical_flare_ctspec, pos = 2
; foxsi4_typical_flare_ctspec, pos = 4, large_flare = 1
;
; History:
; Oct 2023, created by Y. Zhang
  
Default, large_flare, 0
Default, pos, 2

; Selected GOES classes to look at  
If large_flare eq 0 then begin
  goesflux = [3e-5,2e-5,1e-5,5e-6,1e-6]
  flareclass = ['M3','M2','M1','C5','C1']
  att_wheel = 0
Endif else begin
  goesflux = [1e-4,7e-5,5e-5,3e-5,2e-5]
  flareclass = ['X1','M7','M5','M3','M2']
  att_wheel = 1
Endelse
  
hsi_linecolors
colorcode = [0,6,7,3,8]
window, 0, xsize = 750, ysize = 750

totcount = fltarr(n_elements(goesflux))
pileup_frac = fltarr(n_elements(goesflux),2)

For i = 0, n_elements(goesflux)-1 do begin
  print, 'Flare class: '+ flareclass[i]
  phspec = typical_flare_phspec(fgoes = goesflux[i])     ; flare photon spectrum
  ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos = pos, att_wheel = att_wheel)  ; flare count spectrum
  totcount[i] = ctspec.count_rate_tot
  pileup_frac[i,*] = [1-exp(-totcount[i]/2*3.2e-6),1-exp(-totcount[i]/8*3.2e-6)]  ;pileup fraction assuming 2 or 8 strips
  if i eq 0 then begin
    plot, ctspec.energy_kev, ctspec.count_flux, chars=2, thick=2, charth=2, xth=2, yth=2, background=1, color=colorcode[i], $
      /xlog, /ylog, title='Position '+strtrim(string(pos),2), psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', $
      yr=[1.,1d5], xr=[3.,30.], /xsty, /ysty
  endif else begin
    oplot, ctspec.energy_kev, ctspec.count_flux, psym=10, color=colorcode[i], thick=2
  endelse
endfor

al_legend, flareclass, chars=2, charth=2, box=0, color=colorcode, linestyle=[0,0,0,0,0], linsi=0.2, thick=2, /right
al_legend, [flareclass[0]+': '+strtrim(string(round(totcount[0])),2)+' c/s, '+string(pileup_frac[0,1],format='(F6.4)')+'-'+string(pileup_frac[0,0],format='(F6.4)'),$
  flareclass[1]+': '+strtrim(string(round(totcount[1])),2)+' c/s, '+string(pileup_frac[1,1],format='(F6.4)')+'-'+string(pileup_frac[1,0],format='(F6.4)'),$
  flareclass[2]+': '+strtrim(string(round(totcount[2])),2)+' c/s, '+string(pileup_frac[2,1],format='(F6.4)')+'-'+string(pileup_frac[2,0],format='(F6.4)'),$
  flareclass[3]+': '+strtrim(string(round(totcount[3])),2)+' c/s, '+string(pileup_frac[3,1],format='(F6.4)')+'-'+string(pileup_frac[3,0],format='(F6.4)'),$
  flareclass[4]+': '+strtrim(string(round(totcount[4])),2)+' c/s, '+string(pileup_frac[4,1],format='(F6.4)')+'-'+string(pileup_frac[4,0],format='(F6.4)')],$
  chars=1.8, charth=2, box=0

stop   
    
End
