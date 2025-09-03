; Flare image from Lindsay's .sav file, which was after small amount of optics psf deconvolution
; (10 iterations using a Lucy-Richardson deconvolution method)
restore, 'foxsi4_flight/deconv_cdte1_10iter_flare.sav',/ver
loadct, 3
reverse_ct
plot_map, deconv
plot_map, deconv, /over, lev=[3,5,8,12,15,20,30], /percent
