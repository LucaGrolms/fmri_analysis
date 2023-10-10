# Handling/Usage Subst_ResMS_Condition.py

Dieses kleine Python Script ermittelt die Differenz (DOR) zwischen den Result Images der Referenz und denen der modifizierten Conditions.
Hierbei wird zwischen den denoised und den noised Scans, welche fuer die relevanten SPM Runs hierangezogen wurden, unterschieden.

Je nachdem, ob die SPM runs mit SPM8 oder SPM12 angeführt wurden, sind leichte Modifikationen notwendig.

Im Wesentlichen werden die Script Parameter wie folgt definiert und bei Bedarf modifiziert:

````python
# Liste der Ordner für jedes Subject nach Patienten und Gesunde
base_path = "D:/Smoothed_epis_EXT_T1_20211126/Copy_smoothed_epis_T1_Patienten_Gesunde/sourcedata"
sub_paths = ["Patienten", "Gesunde"]
subject_folders_patienten = ["sub-1018", "sub-1026"]
#subject_folders_patienten = ["sub-1017", "sub-1018", "sub-1026", "sub-1072"]
subject_folders_gesunde = []
#subject_folders_gesunde = ["sub-1975", "sub-1977", "sub-1978", "sub-1979"]
# Liste der results folder Namen nach spm runs für denoised und noised unterschiedlich definiert
imagetype = "noised"
results_modification = ["rating", "UCS", "Ex1_CS+", "Ex2_CS+", "Ex3_CS+", "Ex1_CS-", "Ex2_CS-", "Ex3_CS-"]
# Resudien file name, immer gleich in den jeweiligen results folders, bei SPM8 ResMS.img
residuen = "ResMS.nii"
````
- base_path: Hier ist der Basis Pfad hinterlegt, in dem die relevanten SPM Results gespeichert wurden.
- sub_paths: Definiert die Sub Folder in denen die Scans nach Subject Groups hinterlegt wurden.
- subject_folders_patienten: Definiert die subjects welche für den Sub Folder "Patienten" für die Diff Berechnung herangezogen werden sollen.
- subject_folders_gesunde: Definiert die Subjects, welche für den Sub Folder "Gesunde" für die Diff Berechung herangezogen werden sollen.
- imagetype: Definiert die Basis Scans die Grundlage der relevanten SPM Runs waren (denoised, noised (Original))
- results_modification: Definiert die verschiedenden Condition Modifications, welche in den SPM Runs genutzt wurden.
- residuen: Hier wird der Name der Residuen Datei hinterlegt. Bei SPM8 ist diese als "ResMS.img" und bei SPM12 als "ResMs.nii" definiert

Es wird jeweils pro vorhandener Modification (results_modification) eine Differenzdatei (DOR) zur Residuen Referenz erzeugt.
