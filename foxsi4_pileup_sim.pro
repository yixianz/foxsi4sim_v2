Pro foxsi4_pileup_sim, goesflux = goesflux, pos = pos, att_wheel = att_wheel, n_events = n_events

; Purpose:
; Simulate PILED-UP flare count spectra for FOXSI-4 CdTe strip detectors
; 
; Description:
; For a given GOES flux (flare class) and position number, this is done in following steps:
; (a) Generate photon spectrum using scaling laws
; (b) Calculate count spectrum
; (c) See the count spectrum as a probability distribution for photon energy and generate a event list of photon energies.
;     Here I use the inversion sampling method (see more details below).
; (d) For rate r, the time interval between successive events follows distribution: r*exp(-rt). Based on this distribution, 
;     generate a list of time intervals (again using inversion sampling) assuming the photons are spread over 2,5,and 8 strips.
; (e) Simulate pileup: CdTe slow shaper has a shaping time of 3.2 us and any signal out of this time interval would be ignored.
;     So if the time interval is shorter than 3.2 us, part of the later photon energy is added to the first photon. 
;     The exact fraction is determined by pulse shape, approximated as f(t) = 1-((t/3.2e-6)-1)^2 here. This will generate a new 
;     piled-up event list.
; (f) Generate piled-up count spectrum, print out pileup fraction, and plot.
;
; Keywords:
; goesflux: GOES flux (W m^-2)
; pos: position number, must be from 2 to 5 (CdTe strip detectors, see foxsi4_resp_diag.pro for more details)
; att_wheel: set this to 1 to insert the attenutor wheel
; n_events: total number of simulated events (photons)
; 
; Notes on random number sampling with CDF inversion:
; For a variable X that has a cumulative distribution function (CDF) F(X), F^(-1)(U) (where F^(-1) means the inverse of F 
; and U is uniform on [0,1]) follows the same probability distribution function (PDF) as X.
; This principle can be used to generate random numbers that follows any explicit PDF from uniform distribution.
; If the PDF is simple enough that the inverse of CDF can be calculated analytically, we just plug in the inverse of CDF.
; If the PDF is known but doesn't have an easy expression, CDF can still be calculated numerically and the random variable
; can be calculated using interpolation.
;
; Examples:
; foxsi4_pileup_sim, goesflux = 8e-6, pos = 3, att_wheel = 0, n_events = 500000
; foxsi4_pileup_sim, goesflux = 5e-5, pos = 5, att_wheel = 1, n_events = 300000
;
; History:
; Oct 2023, created by Y. Zhang


Default, goesflux, 1e-5   ; M1 class
Default, pos, 2
Default, att_wheel, 0
Default, n_events, 300000

If pos ne 2 and pos ne 3 and pos ne 4 and pos ne 5 then begin
  print, "Error: position must be 2, 3, 4 or 5 (CdTe strip detectors)"
  stop
Endif

en_edges = indgen(2000)*0.02+1
phspec = typical_flare_phspec(fgoes = goesflux, en_edges = en_edges)
phflux = phspec.phflux
print, "parameters: EM_49/T_kev/f35/delta)", phspec.parameters[0]

; simulate count spectrum in fine energy bins
energy_bin = 0.02 
erange = [3,35]
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos=pos, energy_bin = energy_bin, erange = erange, att_wheel = att_wheel)

; Event list sampling
cdf = total(ctspec.count_flux, /CUMULATIVE)/total(ctspec.count_flux) ;cumulative distribution function
s1 = randomu(seed, n_events)
en = interpol(ctspec.energy_kev,cdf,s1,/SPLINE)
spec_hist = HISTOGRAM(en, binsize = energy_bin, min = erange[0], max = erange[1]-energy_bin)*total(ctspec.count_flux)/n_events
;plot,ctspec.energy_kev,spec_hist,/xlog,/ylog, yrange = [1,1d5], xrange = [3,30],/xsty,psym=10,xtitle='Energy (keV)'
;oplot, ctspec.energy_kev, ctspec.count_flux, psym=10, color=3

; Rebin
bin_num = n_elements(ctspec.energy_kev)/10
emean = rebin(ctspec.energy_kev, bin_num)
ctflux = rebin(ctspec.count_flux, bin_num)
ctflux_sim = rebin(spec_hist, bin_num)

hsi_linecolors
colorcode = [1,3,4,6]
plot,emean,ctflux_sim,/xlog,/ylog,psym=10,color=colorcode[0],yrange=[1,1d4],xrange=[3,30],/xsty,charsize=1.5, $
  xtitle='Energy (keV)',ytitle='counts/s/keV',title='Count spectrum pileup simulation'
;oplot, emean,ctflux_sim,psym=10,color=3

; Calculate pileuped spectrum, assuming counts are spread over 8/5/2 strips
nstrips = [8,5,2]
pileup_frac = fltarr(3)
For k = 0, 2 do begin 
  ; time interval (between successive events) sampling - Possion process
  rps = ctspec.count_rate_tot/nstrips[k] ;rates per strip
  s2 = randomu(seed, n_events)
  t_events = -alog(1.-s2)/rps   ; distribution of time interval between events: pdf = r*exp(-rt)   cdf = 1.-exp(-rt)
  ;t_hist = HISTOGRAM(t_events, binsize = 0.0002, min=0, max = 0.01, locations = bin_edges)
  ;plot, get_edges(bin_edges, /mean), float(t_hist)/n_events, color=1
  ;oplot, findgen(10000)/100000, rps*exp(-findgen(10000)/100000*rps)*0.0002, color=3

  ; pileup simulation
  en_pileup = []
  For j=1, n_events-1 do begin
    If t_events[j] le 3.2e-6 then begin
      ; approximate pulse shape:  1-((t/3.2e-6)-1)^2
      pulse_multiplier = 1-(t_events[j]/3.2e-6)^2
      en_pileup[-1] = en_pileup[-1]+en[j]*pulse_multiplier
    Endif else begin
      en_pileup = [en_pileup,en[j]]
    Endelse
  Endfor
  spec_hist_pileup = HISTOGRAM(en_pileup, binsize = 0.02, min = erange[0], max = erange[1]-energy_bin)*total(ctspec.count_flux)/n_events
  ;oplot,ctspec.energy_kev,spec_hist_pileup,color=6
  pileup_frac[k] = 1-float(n_elements(en_pileup))/n_events
  print, "pileup fraction ("+strtrim(string(nstrips[k]),2)+" strips):", pileup_frac[k]

  ; rebin and plot
  ctflux_sim_pileup = rebin(spec_hist_pileup, bin_num)
  oplot, emean, ctflux_sim_pileup, psym=10, color=colorcode[k+1]
Endfor

al_legend, ['no pileup','pileup fraction '+strtrim(string(pileup_frac*100,format='%5.3f'),2)+'%'], textcolors=colorcode, charsize=1.4

stop
End