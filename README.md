# foxsi4sim_v2
A new version of flare spectrum simulation software for FOXSI-4.

This software is adapted from the [original version of foxsi4sim](https://github.com/somusset/foxsi4sim) and some scripts from [foxsi-science](https://github.com/foxsi/foxsi-science).
Compared to the original version, it is organized in a slightly different way and updated with our latest knowledge of the instrument. 
It also has some new features added (see more details below).

Dependencies: SSWIDL (no longer need to install foxsi-science)

### Description
The core part of the software is to simulate count spectrum, which is done in following steps: 
1. Simulate flare photon spectrum in very fine energy bins
2. Calculate count fluxes from photon fluxes and diagonal instrument response (including response from optics, blanketing, attenuator, detector, and any other filters)
3. Convolve with a Gaussian function to account for detector energy resolution
4. rebin the count spectrum in more realistic energy bins
5. if needed, add counting statistics by randomly adjusting count fluxes according to Possion distribution

The simulated count spectrum can be used for further analysis, such as pileup simulation (`foxsi4_pileup_sim.pro`) and spectral fitting in OSPEX (`foxsi4_ospex_fit_example.pro`).

#### Payload configuration
Position 0: MSFC high-resolution optics (2-shell) + collimator + optical filter + blanketing + pre-filter + CMOS  
Position 1: Nagoya high-resolution optics (single-shell) + collimator + optical filter + blanketing + pre-filter + CMOS  
Position 2: heritage 10-shell optics + blanketing + uniform Al attenuator + CdTe   
Position 3: MSFC high-resolution optics + blanketing + pixelated attenuator + CdTe  
Position 4: Nagoya high-resolution optics + blanketing + uniform Al attenuator + CdTe  
Position 5: heritage 10-shell optics + blanketing + pixelated attenuator + CdTe  
Position 6: MSFC high-resolution optics + blanketing + Timepix (+ maybe uniform Al attenuator?) 

Notes:
Values for uniform Al attenuator thicknesses are included in `foxsi4_resp_diag.pro`.
Position 2-5 (all CdTe strip detectors) have additional uniform Al attenuators on the insertable attenuator wheel, which will be inserted if the flare is too bright.

### Examples of basic usage:
Simulate and plot count spectrum at Position 2 for the real M3.5 flare footpoint (attenuator wheel not inserted):
```
phspec = real_m3flare_phspec(footpoint=1, plot = 1)
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos = 2, plot = 1)
```
Simulate and plot count spectrum at Position 4 for a typical M6 class flare when attenuator wheel is inserted, with 30s of integration time and Poission noise:
```
phspec = typical_flare_phspec(fgoes = 6e-5, plot = 1)
ctspec = foxsi4_ct_spec(phspec.energy_keV, phspec.phflux, pos = 4, att_wheel = 1, counting_stat = 1, int_time = 30.,  plot = 1)
```

### List of functions and procedures:
Template flare photon spectrum simulation (functions):
* `typical_flare_phspec.pro`: generate typical flare (hard) X-ray spectrum from a given GOES flux using scaling laws described in
[Battaglia et al (2005)](https://www.aanda.org/articles/aa/abs/2005/32/aa3027-05/aa3027-05.html)
* `real_m3flare_phspec.pro`: simulate photon spectra for the M3.5 RHESSI flare from [Simoes and Kontar (2013)](https://www.aanda.org/articles/aa/full_html/2013/03/aa20304-12/aa20304-12.html)
* `real_c3flare_phspec.pro`: simulate photon spectra for the C2.6 RHESSI flare from [Simoes et al (2015)](https://www.aanda.org/articles/aa/abs/2015/05/aa24795-14/aa24795-14.html)

Instrument response (functions):
* `foxsi4_optics_effarea.pro`: get optics effective area
* `foxsi4_blanketing.pro`: get blanketing transmission
* `foxsi4_attenuator.pro`: get attenuator transmission
* `foxsi4_deteff.pro`: get detector efficiency
* `get_material_transmission.pro`: get transmission profile for certain thickness of material, called by foxsi4_blanketing.pro, foxsi4_attenuator.pro, and foxsi4_deteff.pro
* `foxsi4_resp_diag.pro`: generate diagonal response from optics + blanketing + attenuator + detector combined
* `foxsi4_resp_2d.pro`: generate 2d response matrix (off-diagonal elements are only due to energy resolution so far)

Wrapper (function):
* `foxsi4_ct_spec.pro`: calculate count spectrum from a given photon spectrum, using foxsi4_resp_diag.pro and then convolving with a Gaussian to account for energy resolution

#### More examples (procedures):
* `foxsi4_typical_flare_ctspec.pro`: calculate count spectrum for typical flares from scaling laws 
* `foxsi4_real_85flares.pro`: calculate count spectra and count rates with real parameters for flares in Battaglia et al (2005)
* `foxsi4_pileup_sim.pro`: simulate piled-up flare count spectra for FOXSI-4 CdTe strip detectors
* `foxsi4_ospex_fit_example`: demonstrate how to use OSPEX to reconstruct photon spectrum from simulated FOXSI-4 count spectrum

