import numpy as np
import nibabel as nib
import os

# Liste der Ordner für jedes Subject nach Patienten und Gesunde
base_path = "D:/Smoothed_epis_EXT_T1_20211126/Copy_smoothed_epis_T1_Patienten_Gesunde/sourcedata"
sub_paths = ["Patienten", "Gesunde"]
dor = "DoR"
#subject_folders_patienten = []
subject_folders_patienten = ["sub-3105", "sub-1038", "sub-1043", "sub-1083", "sub-1091", "sub-1121"]
subject_folders_gesunde = ["sub-3955", "sub-3956", "sub-3957", "sub-3958", "sub-3959", "sub-3960"]
#subject_folders_gesunde = ["sub-1975", "sub-1977", "sub-1978", "sub-1979"]
# Liste der results folder Namen nach spm runs für denoised und noised unterschiedlich definiert
imagetype = "denoised"
results_modification = ["rating", "UCS", "Ex1_CS+", "Ex2_CS+", "Ex3_CS+", "Ex1_CS-", "Ex2_CS-", "Ex3_CS-"]
# Residuen file name, immer gleich in den jeweiligen results folders, bei SPM8 ResMS.img
residuen = "ResMS.nii"
# base_path
#      |
#      |-Patienten
#      |     |- sub-1017
#      |     |- sub-1018
#      |       ....
#      |-Gesunde
#      |     |- sub-1975
#      |     |- sub-1977
#      |       ....
              

# Schleife durch die Ordner für jedes Subject

for sub_path in sub_paths:
  # Trennung in der Ordern Struktur nach Patienten und Gesunde
  if sub_path == "Patienten":
     subject_folders = subject_folders_patienten
  elif sub_path == "Gesunde":
     subject_folders = subject_folders_gesunde
  else:
    print("Kein Eintraege in sub_paths vorhanden.");
    exit()

  if imagetype == "denoised":
     results_reference_folder = "spm_Results"
  elif imagetype == "noised":     
     results_reference_folder = "spm_Results_ori"
  else:
    print("Kein valider Wert in imagetype vorhanden.");
    exit()
     
  #Nutzung der subjects in den Ordnern für Patienten oder Gesunde
  for subject_folder in subject_folders:
     subject = os.path.join(os.path.normpath(base_path), sub_path, subject_folder)
     
     # Pfad zum Referenzbild für dieses subject
     reference_image = os.path.join(subject, results_reference_folder, residuen)
    
     # Referenzbild laden
     ref_img = nib.load(reference_image)
     ref_data = ref_img.get_fdata()

     # Schleife durch die Modifications für dieses Subject
     for modifications in results_modification:
        # Korrekten folder name ermitteln für noised oder denoised Results
        modification_folder = results_reference_folder + "_" +  modifications
                
        # Modification Bild laden
        img = nib.load(os.path.join(subject, modification_folder, residuen))
        img_data = img.get_fdata()
        
        # Abzug Modification result vom result Referenz
        img_diff = ref_data - img_data

        # Erstellen eines neuen NIFTI-Bilds mit dem Ergebnis
        img_diff_nii = nib.Nifti1Image(img_diff, ref_img.affine, ref_img.header)

        # Speichern des Ergebnisbilds diff_ResMs_....nii
        # nib.save(img_diff_nii, os.path.join(subject, "diff_ResMs_{}".format(modification_folder)))
        nib.save(img_diff_nii, os.path.join(subject, "diff_ResMs_{}".format(modification_folder)))
