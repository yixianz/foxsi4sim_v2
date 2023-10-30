Pro foxsi4_real_85flares, pos = pos, cdte_thr = cdte_thr, bright_ind = bright_ind

; Purpose:
; Calculate count spectra and count rates for real flares studied in Battaglia et al (2005)
; 
; Notes:
; Wrote for CdTe strip detectors.
; Total of 85 B1 - M6 flares available but only consider C and M class (42 flares) here.
; For bright flares, attenuator wheel is inserted.
; Photon spectrum is calculated using an isothermal + broken power-law model (fixed spectral index of 1.5 below 9 keV).
; 
; Keywords:
; pos: position number (choose from 2-5)
; cdte_thr: CdTe count rate threshold to insert the attenuator wheel
; bright_ind: indices of the bright flares to insert the attenuator wheel (this is ignored if cdte_thr is set)
;
; Examples:
; foxsi4_real_85flares, pos = 5, cdte_thr = 8000
; foxsi4_real_85flares, pos = 3, bright_ind = [0,1,2,3,4,6,7,8,9,10,11,14,16,20,22,24]
;
; History:
; Oct 2023, created by Y. Zhang 

Default, pos, 2
Default, bright_ind, [0,1,2,3,4,7,8,10,11,14,20,24]

fgoes_range = [1e-6, 1e-4] ; only select flares that are C or M class

If keyword_set(cdte_thr) then bright_ind = [] 

filename = './flare_data/85_flare_params.fits'  ;parameters for 85 flares from Marina
flare_data = mrdfits(filename,1)

en_edges = indgen(4000)*0.01+1
emean  = get_edges( en_edges, /mean )
ind = []  ; flare index array
cf_arr = []  ;count flux array
cr_arr = []  ;count rate array
cf_att_arr = []  ;attenuated count flux array for bright flares
cr_att_arr = []  ;attenuated count rate array for bright flares

For i = 0, 84 do begin
  If flare_data[i].goes ge fgoes_range[0] and flare_data[i].goes le fgoes_range[1] then begin ;select flares in GOES flux range
    ind = [ind,i]
    ; Calculate photon spectrum
    ; thermal component
    phflux_th = f_vth( en_edges, [flare_data[i].emr, flare_data[i].tr,1.] )  
    ; nonthermal component
    ebreak = 9
    delta_below_break = 1.5
    phflux_nonth = flare_data[i].f35*bpow( emean, [delta_below_break,ebreak,flare_data[i].gamma] )/bpow( 35, [delta_below_break,ebreak,flare_data[i].gamma] )
    phflux = phflux_th + phflux_nonth
 
    ; Count spectrum
    ctspec = foxsi4_ct_spec(emean, phflux, pos = pos, att_wheel = 0)
    en = ctspec.energy_kev
    cf_arr = [[cf_arr], [ctspec.count_flux]]
    cr_arr = [cr_arr, ctspec.count_rate_tot]
    
    ; Check if the flare is "bright" - if so, insert the attenuator wheel
    If keyword_set(cdte_thr) then begin
      If ctspec.count_rate_tot ge cdte_thr then bright_ind = [bright_ind,i]
    Endif    
    If total(i eq bright_ind) eq 1 then begin
      print, "Insert attenuator wheel" 
      ctspec = foxsi4_ct_spec(emean, phflux, pos = pos, att_wheel = 1)
      cf_att_arr = [[cf_att_arr], [ctspec.count_flux]]
      cr_att_arr = [cr_att_arr, ctspec.count_rate_tot]
    Endif
  Endif  
Endfor

hsi_linecolors

; Plot spectra
window,0
For j = 0, n_elements(ind)-1 do begin
  ; plot all count spectra without attenuator wheel
  If j eq 0 then begin
    plot, en, cf_arr[*,j], color=0, background=1, /xlog, /ylog, chars=1.5,$
      xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1.,1d5], xr=[3.,30.], /xsty, /ysty
  Endif else begin
    oplot, en, cf_arr[*,j], color=0
  Endelse
  ; plot for bright flares
  If total(ind[j] eq bright_ind) then begin
    k = where(ind[j] eq bright_ind)
    oplot, en, cf_arr[*,j], color=6       ; before inserting attenuator wheel
    oplot, en, cf_att_arr[*,k], color=7   ; after inserting attenuator wheel
  Endif
Endfor
al_legend, ['fainter flares', 'bright flares without inserting attenuator','bright flares after inserting attenuator'],$
  color=[0,6,7], linestyle=[0,0,0],linsi=0.2, chars=1.3, box=0, /right

; plot count rates vs GOES flux/class
window,1
plot, flare_data[ind].goes, cr_arr, psym=2, color=0, background=1, /xlog, /ylog, chars=1.4, symsize=1.4, xrange = [1e-6,1e-4],$
  xtitle='GOES flux', ytitle= 'counts/s'
oplot, flare_data[bright_ind].goes, cr_arr[bright_ind], psym=2,color=6,symsize=1.4
oplot, flare_data[bright_ind].goes, cr_att_arr, psym=5,color=7,symsize=1.6
axis, xaxis=1, xtickn=['C','M','X'], color=0, chars=1.8
al_legend, ['fainter flares', 'bright flares without inserting attenuator','bright flares after inserting attenuator'],$
  color=[0,6,7], psym=[2,2,5],linsi=0.2, chars=1.3, symsize=[1.4,1.4,1.6]

stop
End