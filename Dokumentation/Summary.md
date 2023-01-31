# Aufgabenstellung
Aus den vorliegenden Subject Scans, welche nach Patienten und Gesunde unterteilt vorliegen, sollte im ersten Step eine ICA pro Subject durchgeführt werden. Je Subject liegen 590 spezifische NIFTI Images files (.nii) vor. 

Für die Durchführung der ICA wurde aus der FSL Toolbox das Tool "melodic" ausgewählt.
Beispielhaft wird eine ICA melodic Aufruf wie folgt ausgeführt:
~~~
melodic -i FWHM_8_img_sub-1017.nii.gz -o FWHM_8_img_sub-1017-1017.ica
~~~
Hierbei wird davon ausgegangen, dass das relevante Input file als 4D NIFTI file vorliegt.
Da aber all 590 Subject Scans als 3D NIFTI files vorliegen, muss vorher eine Zusammenführung der Scans in ein 4D Image file durchgeführt werden.

Hierfür kann aus dem FSL Toolset das Tool "fslmerge" genutzen werden. Beispielhaft wäre dieser Aufruf:
~~~
 fslmerge -t FWHM_8_img_sub-1017.nii FWHM_8_img_001.nii FWHM_8_img_002.nii ... FWHM_8_img_590.nii
~~~
Hierbei müssen aber alle 3D filenames expliziet angegeben werden, das "..." ist nicht erlaubt, dient hier nur der Verdeutlichung. Um alle relevanten Files in einem folder einfacher ermitteln zu können, stellt FSL ein weiteres Tool "imglob" bereit. imglob listet alle Image-Files in einem Folder mit ihren Namen auf.
~~~
imglob *
~~~
Die beiden Tools/Befehle zusammen angewandt, erleichtern die Arbeit des 3D nach 4D mergen wesentlich.
~~~
fslmerge -t FWHM_8_img_sub-1017.nii $(imglob *)
~~~
Nach dem Durchlauf von fslmerge liegt dann, das für melodic relevante 4D image file FWHM_8_img_sub-1017.nii.gz entsprechend vor.

Alternativ zu diesen zwei Schritten via FSL Toolbox, kann auch SOCK genutzt werden. Innerhalb von SOCK existeren entsprechende Matlab Scripte (.m), welche gesamtheitlich eingesetzt werden können (batchSOCK.m) oder auch nur in Teilschritten (SOCK.m), wenn gewünscht.
- Gesamtheitlich bedeutet:  
Zusammenführen der vorliegenden 3D Images zu einem 4D Image, Durchführung der ICA, Durchführung der Artifaktermittlung, Denoising und final das Aufsplitten des gesamt denoised Image wieder in 3D Images .img und .hdr.
- In Teilschritten bedeutet:  
Es kann auch nur eine Klassifizierung vorgenommen, wenn vorher bereits eine Zusammenführung der 3D Images zu einem 4D Images durchgeführt wurde. Hierfür wird dann nur das Script SOCK.m aufgerufen. Dieses führt nach der Klassifizerung aber auch kein Denoising durch.

## Nutzung von SOCK V1.4d

Bei der ersten Nutzung von SOCK kam es im gesamtheitlichen Ablauf zu Problemen, welche sich zuerst nicht final erklären ließen. So wurden bei den durchgeführten Durchläufen nicht die für die weitere Verarbeitung benötigten mean.img files erzeugt.
Die entsprechenden Analysen führten dann dazu, dass bei der ersten gesamtheitlichen Linux basierten Installation aller Komponenten die aktuelle FSL Version 6 installiert wurde. Im Weiteren wurde festgestellt, dass sich zwischen der FSL Version 5 und 6 anscheinend einige gravierende Änderungen an den intergrieten Funktionen/Tools ergeben haben, welche zu dem entsprechenden Fehlverhalten im SOCK Batch-Ablauf geführt haben. Beispielhaft kann hier die genutzt Funktion "fslchfiletype" genannt werden, aber auch weitere Funktionen unterscheiden sich in FSL 5 und FSL 6.

Somit wurde auf der relevanten Umgebung neben FSL 6 auch FSL 5 installiert und innerhalb der Matlab-Pfade wurde FSL 5 definiert. 

Beim Gesamtheitlichen Ablauf via batchSOCK.m und einer hohen Anzahl an generierten IC-Maps für das relevante Subject, kam es beim Denoising Prozess zu Abbrüchen aufgrund von Memory Allocation Problemen. 

~~~matlab
fsl_regfilt -i ../FWHM_8_img___all -o denoised_data -d melodic_mix -f "1,3,4,6,9,11,13,15,17,18,20,21,25,29,31,32,33,34,38,45,47,48,50,52,54,55,63,64,66,69,75,76,77,88,91,95,100,102,104,105,106,116,117,120,124,126,127,128,129,131": Killed
cp: cannot stat ‘denoised_data.nii.gz’: No such file or directory

fsl_regfilt -i ../FWHM_8_img___all -o denoised_data -d melodic_mix -f "1,3,4,6,17,25,29,30,33,34,35,45,51,53,54,63,65,66,67,68,85,91,94,97,98,102,106,109,110,117,119,124,126,131,139,143,145,148,155,158,161,165,171,172,174,176,179,182,183,184,185,205,207,209,213,217,218,221,229,235,237,243,244,246,248" std::bad_alloc
cp: cannot stat ‘denoised_data.nii.gz’: No such file or directory
~~~

Da alle Abläufe in einer virtuellen Linux Umgebung ausgeführt werden, wurde nochmals der Memory für diese VM Instanz auf 13 GB erhöht und auf der Linux OS Ebene wurde ein cronjob etabliert, welcher alle 20 min. den Memory Cache/Pages leert.
~~~
*/20 * * * * root sync; echo 1 > /proc/sys/vm/drop_caches
~~~

Hiernach konnten auch die Denoised Images für Subjects mit vielen IC-Maps (z. Bsp. 242) erzeugt werden.

### Default TR
Die TR wird im batchSOCK.m für die relvanten Images der Subjects definiert. Sollen spezifische TR für die Abläufe angewandt werden, so sehen die SOCK-Scripte hierzu vor, dass in den Subject Foldern nach einer entsprechenden Definitionsdatei gesucht wird "_header_info.txt". Damit diese Datei nicht in jeden Subject Folder hinterlegt werden musste, wurde folgende Anpassung in dem SOCK Script iBT_info.m vorgenommen ...
~~~matlab
fsettings_is_OK = 0; % Initialise
  fsettings = fopen(infoFile); % open info file and read the data
  if fsettings == -1
  		% throw(MException('iBT:open_info_file', ['Unable to find file matching ' infoFile]));
      present = 0; % Unable to open the file.
      value = 0;
      return;
  end
 ~~~ 
 Die TR default Defintion wurde in batchSOCK.m mit 2.0 definiert:
 ~~~matlab
 default_TR = '2.0'; % Default TR, used only if a _header_info.txt file is not found in the same folder as the images selected for processing. 
  % If you use the iBrain Analysis Toolbox for SPM for pre-processing then you probabaly already have this generated automatically.
  % Otherwise, if you want to make your own _header_info.txt, all SOCK needs it to be is a text file containing at least a line 
  % with "TR(s):" followed by the TR. e.g. TR(s):3.0
~~~  

### melodic 3.15 und FSL 6
Bei der Nutzung des Gesamtablaufes via SOCK wird für die ICA das verfübare melodic Tool der FSL Installation genutzt. Bei den relevanten Durchläufen wurde festgestellt, dass mit FSL 5 die melodic Version 3.14 genutzt wird. Die Performance war hier relativ langsam im Schritt <mark> Normalising by voxel-wise variance ....</mark> Die ICA Erstellung mit melodic 3.15 verläuft wesentlich schneller, aus diesem Grund wurde neben FSL 5 auch FSL 6 in der Umgebung installiert und das batchSOCK.m Script so modifiziert, dass hier (über eine Linux Sym Link "melodic6") melodic 3.15 genutzt/aufgerufen wird.
~~~matlab
command_melodic = strcat('melodic6 --in=', name_merged_imgs, ' --report --tr=', num2str(TR, '%0.1f'), {' '}, '--Oall -v');
~~~

## Report Values
Werden mit FSL 5 / melodic 3.14 die ICA durchgeführt, ergeben sich im weiteren Batch Ablauf von batchSOCK.m Problemstellungen mit den Werten in ./report/f1.txt, welche nicht mehr dem von SPM/Matlab erwarteten Format entsprechen. 
~~~matlab
  FWHM_8_img___all.ica/melodic_pcaE
  FWHM_8_img___all.ica/melodic_pcaD
  FWHM_8_img___all.ica/melodic_pca
...done

To view the output report point your web browser at FWHM_8_img___all.ica/report/00index.html
finished!

Made SOCK temporary directory: /tmp/tpec3f2a18_177b_4d7c_8018_78ab7e221057_SOCK
Running SOCK on /mnt/hgfs/D/Smoothed_epis_EXT_T1_20211126/Copy_smoothed_epis_T1_Patienten_Gesunde/sourcedata/Patienten/sub-8030/Ma2/func/FWHM_8_img___all.ica/

Converting mean functional image into NIFTI_PAIR format...
Generating edge and CSF masks using SPM12 Segment

Using mean functional image for SOCK analysis...
Conversion Tools:New Segment -> Spatial:Segment

------------------------------------------------------------------------
28-Jan-2023 05:54:01 - Running job #1
------------------------------------------------------------------------
28-Jan-2023 05:54:01 - Running 'Segment'

SPM12: spm_preproc_run (v7670)                     05:54:01 - 28/01/2023
========================================================================
Segment /mnt/hgfs/D/Smoothed_epis_EXT_T1_20211126/Copy_smoothed_epis_T1_Patienten_Gesunde/sourcedata/Patienten/sub-8030/Ma2/func/FWHM_8_img___all.ica/mean.img
Completed                               :          05:54:55 - 28/01/2023
28-Jan-2023 05:54:55 - Done    'Segment'
28-Jan-2023 05:54:55 - Done

Converting thresholded images in stats dir to NIFTI_PAIR format...

Obtaining CSF and edge activity measures for SOCK analysis...

Obtaining edge activity for IC  83
DONE

Obtaining smoothness measures for SOCK analysis...

Obtaining power spectrum measures for SOCK analysis...

TR =

     2

Error using dataread
Trouble reading number from file (row 1, field 2) ==>

Error in textread (line 124)
[varargout{1:nlhs}]=dataread('file',varargin{:}); %#ok<REMFF1>

Error in ps_measure (line 54)
   tc_data = textread('t1.txt');

Error in SOCK_main (line 105)
[IC, ps_matrix, TR] = ps_measure(IC, dir_ICA);

Error in SOCK (line 122)
		SOCK_main(dir_ICA, batch_flag, SOCK_dir) % The main function for calculating IC features

Error in batch_SOCK (line 312)
	SOCK('batch_SOCK',fullfile(loc,name_melodic_dir))
 
124 [varargout{1:nlhs}]=dataread('file',varargin{:}); %#ok<REMFF1>
~~~~

Bei der Nutzung FSL 6 werden die Werte in dem korrekten Format hinterlegt. Beispielhaft diese Gegenüberstellung:

|FSL 6         | FSL 5 |
---------------|--------
|141878.3373   |0x1.081b8e803002ap+17
9444.869278    |0x1.f9c841357c3f3p+10
9444.869278    |0x1.055c39bd92d15p+11
3133.838041    |0x1.b82bd691fca2dp+9 
1977.755156    |0x1.501b0d0cc372bp+7
1923.327265    |0x1.46133812fa56ep+11 
177.5300424    |0x1.09ef7870eb4a8p+10 
1186.45837     |0x1.c9fc48252a2bp+4  
496.5086457    |0x1.4ab05534cf532p+9
2577.85962     |0x1.be125d2ee6a52p+9

## Matlab 
Die eingesetzte Matlab "kmeans" Funktion erforderte die zusätzliche Installation der "Statistic and Machine Learning Toolbox" in Matlab.
~~~matlab
% Cluster spatial edge activity (in std_edge_activity.mat)

   [km2, C] = kmeans(std_edge_activity,2, 'replicates', 1000);
   edge_activity_label_spatial(1:no_ics) = {''};
~~~   

# SPM 12
Für die weitere Verabeitung der Denoised Images in SPM ist es notwendig, die relevanten Images im 3D NIFTI Format (.nii) vorliegen zu haben. SPM ist aktuell nicht in der Lage .nii.gz Files zu verarbeiten. Der Standard-Ablauf in SOCK erzeugt aus dem denoised 4D Image am Ende wieder die einzelnen 3D Images, hier aber als .img und .hdr files. 
Damit aus dem 4D Denoised Image am Ende dann die relevanten NIFTI-files erzeugt werden, wurde eine weitere Anpassung in batchSOCK.m vorgenommen.
Der OUTPUT_NIFTI_PAIR Wert 2 wurde neu eingeführt und die Fuktionalität entsprechend erweitert. Es werden hierdurch 3D .nii.gz files erzeugt und entpackt und keine .img und .hdr files.
~~~matlab
if START_AGAIN || (length(exist_split_denoised_imgs) == 0)
		disp(sprintf('Spliting de-noised 4D image into 3D images for subject %s\n', loc));
		command_split = ['fslsplit denoised_data.nii.gz d' clean_name_prefix ' -t'];
		unix(command_split);
        if OUTPUT_NIFTI_PAIR == 2,
            % gunzip the files for further processing with SPM and .nii extension
            disp(sprintf('Create .nii files and no .img/.hdr files for %s\n', loc));
            command_gunzip_all = 'gunzip dFWHM*.gz';
            unix(command_gunzip_all);
        end    
		split_denoised_images = 1;
   		save split_denoised_images;
	else
		disp(sprintf('Split denoised data for subject %s already exists...\n', loc));
	end
   ~~~
   Der OUTPUT_NIFTI_PAIR Wert 2 wird am Anfang des batchSOCK.m dann entsprechend definiert.
   ~~~matlab
   OUTPUT_NIFTI_PAIR = 2;  % If 0 and if input images are 3D, then output will be as you have confingured for fsl (usually NIFTI_GZ)
			% If 1 then output will be NIFTI_PAIR format: in this case only, filename numbering is also zero-padded so they sort more easily.
            % If 2 then output will be NIFTI format and .nii files and no .img/.hdr files  
   ~~~
