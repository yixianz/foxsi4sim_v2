Pro fig_typical_realflare_ctspec
  ; Plotting simulated CdTe strip detector count spectra for real flares that were used to generate the scaling laws
  ; Adapted from foxsi4_real_85flares.pro
  
  !p.multi=[0,2,4]
  !X.margin=4.2
  !Y.margin=2.2
  !X.thick = 1.6
  !Y.thick = 1.6
  !P.FONT = 0
  
  popen,'dissertation_plots/typical_realflare_ctspec.ps', xsi=7, ysi=9, /port
  
  filename = './flare_data/85_flare_params.fits'  ;parameters for 85 flares from Marina
  flare_data = mrdfits(filename,1)
  ind = where(flare_data.goes ge 5e-6)
  ind = reverse(ind)
  bright_ind = [1,2,3,4,7,8]   ; these flares have count rates at pos 2 and 5 over 10000 cts/s

  en_edges = indgen(4000)*0.01+1
  emean  = get_edges( en_edges, /mean )
  
  For pos = 2, 5 do begin
  
    cr_arr = []  ;count rate array
    cr_bright_arr = []  ;count rate array for bright flares
    cr_bright_arr_atten = []  ;attenuated count rate array for bright flares
    
    For i = 0, n_elements(ind)-1 do begin
      ; Calculate photon spectrum
      ; thermal component
      phflux_th = f_vth( en_edges, [flare_data[ind[i]].emr, flare_data[ind[i]].tr,1.] )
      ; nonthermal component
      ebreak = 9
      delta_below_break = 1.5
      phflux_nonth = flare_data[ind[i]].f35*bpow( emean, [delta_below_break,ebreak,flare_data[ind[i]].gamma] )/bpow( 35, [delta_below_break,ebreak,flare_data[ind[i]].gamma] )
      phflux = phflux_th + phflux_nonth
  
      ; Count spectrum
      ctspec = foxsi4_ct_spec(emean, phflux, pos = pos, att_wheel = 0, energy_bin = 0.4, erange = [2,25])
      en = ctspec.energy_kev
      cr_arr = [cr_arr, ctspec.count_rate_tot]
      
      If i eq 0 then begin
        plot, en, ctspec.count_flux, color=0, background=255, /xlog, /ylog, chars=1.5, ytickunits='scientific',$
          xtitle='Energy (keV)', ytitle='Count flux (cts/s/keV)', yr=[1.,1d5], xr=[3.,25.], /xsty, /ysty
      Endif 
      
      If where(bright_ind eq ind[i]) gt -1 then begin
        ctspec_att = foxsi4_ct_spec(emean, phflux, pos = pos, att_wheel = 1, energy_bin = 0.4, erange = [2,25])  ; attenuator wheel in
        cr_bright_arr = [cr_bright_arr, ctspec.count_rate_tot]
        cr_bright_arr_atten = [cr_bright_arr_atten, ctspec_att.count_rate_tot]
        oplot, en, ctspec.count_flux, color=cgcolor("orangered")
        oplot, en, ctspec_att.count_flux, color=cgcolor("dodger blue")
      Endif else begin
        oplot, en, ctspec.count_flux, color=cgcolor("dark gray"), thick=0.8
      Endelse
       
    Endfor
    
    al_legend, ['fainter flares', 'bright flares (atten. wheel out)','bright flares (atten. wheel in)'],$
        color=[cgcolor("dark gray"),cgcolor("orangered"),cgcolor("dodger blue")], linestyle=[0,0,0],linsi=0.4,$
        chars=0.6, charth=0.1, position=[2.9,9e4], thick=2, textcolors = 0, box=0
    xyouts, 14, 3e4, 'Position '+strtrim(string(pos),2), charsize=1., /data, color=0
        
    plot, flare_data[ind].goes, cr_arr, psym=2, color=0, background=255, /xlog, /ylog, chars=1.4, symsize=0.9, $
      xtitle='GOES flux (W/m!U2!N)', ytitle= 'Count rates (cts/s)',/xst, xrange = [5e-6,7e-5], yrange = [50,2e5],/yst, charthick=2., thick=1.4
    oplot, flare_data[bright_ind].goes, reverse(cr_bright_arr), psym=2, symsize=0.9, color=cgcolor("orangered"), thick=1.4
    oplot, flare_data[bright_ind].goes, reverse(cr_bright_arr_atten), psym=5, symsize=0.9, color=cgcolor("dodger blue"), thick=2
    al_legend, ['fainter flares', 'bright flares (atten. wheel out)','bright flares (atten. wheel in)'],$
        color=[cgcolor("dark gray"),cgcolor("orangered"),cgcolor("dodger blue")], psym=[2,2,5],linsi=0.2, $
        chars=0.6, symsize=0.9, thick=[1.4,1.4,2], box=0, position=[5.2e-6,1.7e5]

   Endfor
   
   pclose
   cgPS2PDF, 'dissertation_plots/typical_realflare_ctspec.ps',/delete_ps ;convert .ps to .pdf

   stop
End
