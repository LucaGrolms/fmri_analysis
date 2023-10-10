# Handling/Usage SPM_Denoised.m

In den ersten Zeilen des matlab batch scriptes werden folgende Grundeinstellungen vorgenommen:

```matlab
%Denoised Images or Noised Images as base images 1=Denoised, 0=Noised
ImageType = 0;

%Quantity of denoised/noised scans 
denoisedImages=590;

%How many condition modification should be run through, parameter modification change in
%script run after reading condition file values
modifications=4;
Mod4={'rating','UCS','CS+','CS-'};
Mod8={'rating','UCS','Ex1_CS+','Ex2_CS+','Ex3_CS+','Ex1_CS-','Ex2_CS-','Ex3_CS-'};

%Base Path of condition files normal and modified (CS-)
basepathcond='/mnt/hgfs/FSL_ICA/onsets_4D_Patienten_Gesunde';
```

- Der ImageType legt fest, ob die Input Files Noised (Original) oder Denoised (nach SOCK Nutzung) sind.
- denoisedImages gibt die Anzahl der Scan Files an, dieses sind in diesem Projekt immer 590
- basepathcond gibt an in welchem statischen Pfad die Conditionsfiles zu finden sind

Als Studyfile fuer siese Abläufe sind Beispiel Files hinterlegt worden.
- Noised: study_file_SPM_volumes_origin.txt
- Denoised: study_file_SPM_volumes.txt oder study_file_SPM_volumes_test.txt

Die Abläufe basieren i.d.R. auf der Nutzung von SPM12, somit sind die relevanten SPM12 Pfade als matlab Paths zu hinterlegen.

Wird SPM8 genutzt, werden in den Ergebnissen die relevanten base files nicht gelöscht, da diese als .hdr/.img erzeugt werden.
