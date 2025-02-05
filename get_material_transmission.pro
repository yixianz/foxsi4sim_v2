Function get_material_transmission, filename, thickness_um, energy_arr = energy_arr

; Purpose:
; Get transmission profile for certain thickness of different materials
;
; Description:
; Read attenuation length data from previously stored '.txt' files
; Data downloaded from https://henke.lbl.gov/optical_constants/atten2.html
;
; Inputs:
; filename (note: path should be included) 
; thickness_um: material thickness in microns
; 
; Keywords:
; energy_arr: 1d energy array in keV (bin centers)
;
; Outputs:
; Data structure that consists of energies (in keV) and transmission
;
; Examples:
; result = get_material_transmission('material_data/al_att_len.txt', 100)
;
; History:
; Oct 2023, created by Y. Zhang


Default, energy_arr, indgen(300)*0.1+1.

If filename.Endswith('_att_len.txt') eq 1 then begin
  data = read_ascii(filename, DATA_START=2)
  atten_len_um = interpol(data.field1[1,*], data.field1[0,*]/1000.0, energy_arr)  ; note: need to convert energy from eV to keV
Endif else print, "please check material data files"

  transmission = exp(-thickness_um/atten_len_um)
  
  result = create_struct("energy_keV", energy_arr, "transmission", transmission)
  return, result

End