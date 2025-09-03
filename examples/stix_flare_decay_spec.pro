Pro stix_flare_decay_spec, pos = pos, new_att = new_att

; Purpose:
; FOXSI-4/5 count spectrum simulation for sample STIX flares (decay phase)
; Fit parameters were derived in IDL 

Default, pos, 2
Default, new_att, 0

restore,'/Users/zyx/Documents/flare_timing/stix_flare_params.sav',/verb

en_edges = indgen(4000)*0.01+1
emean  = get_edges( en_edges, /mean )
ct_rate = []

popen,'fig_stix_flr_decay_spec', xsi=5, ysi=4, /port

For i = 0, 9 do begin
  phflux_th = f_vth( en_edges, fit_params[i,0:2] )  
  phflux_nonth = f_bpow( en_edges, fit_params[i,3:-1] )  
  phflux = phflux_th + phflux_nonth
  ctspec = foxsi4_ct_spec(emean, phflux, pos = pos, energy_bin = 0.2, erange = [4,25], new_att = new_att)
  ct_rate = [ct_rate, ctspec.count_rate_tot]
  if i eq 0 then begin
    plot, ctspec.energy_kev, ctspec.count_flux,/xlog, /ylog,yr=[0.1,5d4], xr=[4.,30.], /xsty, /ysty, $
       thick = 3, charth=1.5, xth=4, yth=4, xtitle='Energy (keV)', ytitle='Counts/s/keV'
  endif else begin
    oplot, ctspec.energy_kev, ctspec.count_flux, thick = 3
  endelse
Endfor

xyouts, 8.7, 1.7e4, 'count rates: '+strtrim(string(round(min(ct_rate))),2)+' - '+strtrim(string(round(max(ct_rate))),2)+' cts/s', /data

pclose
cgPS2PDF, 'fig_stix_flr_decay_spec.ps', /delete_ps

stop

End