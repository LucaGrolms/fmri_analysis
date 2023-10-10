function secondlevel_dors

%Clear the workspace and classes
clear;

% Get Current path and make it to relevant path
filepath = fileparts(mfilename('fullpath'));
cd(filepath);

% List of open inputs
diary( ['spm_batch_processing' sprintf('-%.2i',fix(clock)) '.log'] )


%Denoised Images or Noised Images as base DoR images 1=Denoised, 0=Noised
DoRType = 1;

%How many different condition modification produces relevante DoR results
Mod8={'rating','Ex1_CS+','Ex2_CS+','Ex3_CS+','Ex1_CS-','Ex2_CS-','Ex3_CS-'};
Gesunde = 'Gesunde';
Patienten = 'Patienten';
DoRs_Denoised = 'diff_ResMs_*_spm_Results_$.nii';
DoRs_Noised = 'diff_ResMs_*_spm_Results_ori_$.nii';
%Run with specific covarates 1=YES, 0=NO
Covarates = 1;

%Base Path of DoR Results files normal and modified (CS-)
basepath_DoR='/mnt/hgfs/D/Smoothed_epis_EXT_T1_20211126/Copy_smoothed_epis_T1_Patienten_Gesunde/sourcedata/';

% DoR files of all subjects available in this folder structure is expected
% (DoR/Denoised, DoR_ori/Noised)
% basepath_DoR
%    |
%    |--DoR
%    |   |- Deoised 
%    |        |-- rating
%    |        |-- UCS
%    |        |-- rating
%    |        |-- ...
%    |--DoR_ori 
%    |   |- Noised 
%    |        |-- rating
%    |        |-- UCS
%    |        |-- ....


%Select and load the file which specify all original condition files
scanlistfile = spm_select(1,'mat','Select subject''s of DoRs');
if length(scanlistfile) == 0
	disp('No subject file selected; Second Level run will now exit');
	diary off
	return
end

%Select and load the file which specify all original condition files
f = fopen(scanlistfile);             
   s = textscan(f,'%s %s','delimiter',' ','CommentStyle','#'); % Read the whole file into variable s, with each line a separate cell, ignoring comments
 fclose(f);
 %s = cellstr(s{1});
 num_rows = size(s{1},1);

%Build the filenames of the DoR files for group1 and group2
%At first get the subjects
g1=1;
g2=1;
for n = 1:num_rows
    if strcmp (s{1}{n}, Gesunde)
       tmp_g1{g1} = s{2}{n};
       g1=g1+1;
    else if strcmp( s{1}{n},Patienten)
       tmp_g2{g2} = s{2}{n};
       g2=g2+1;
    end
    end
end

%Create the full path for the results (SPM.mat) based and the source DoRs
%type
if DoRType == 0
    DoR_filename = DoRs_Noised;
    basepath_DoR = strcat(basepath_DoR, 'DoR_ori');
    Res = 'Noised';

else 
    DoR_filename = DoRs_Denoised;
    basepath_DoR = strcat(basepath_DoR, 'DoR');
    if Covarates == 0 
      Res = 'Denoised';
    else 
      Res = 'Denoised_cov';  
    end  
end

%Now the relevante full path ist build for the respective variant of DoR
for n =1:length(Mod8)
    for m=1:length(tmp_g1)
      group1{m,1}= fullfile(basepath_DoR,strcat(strrep((strrep(DoR_filename,'*', tmp_g1{m})), '$', Mod8{n}), ',1'));
    end
    for m=1:length(tmp_g2)
      group2{m,1}= fullfile(basepath_DoR,strcat(strrep((strrep(DoR_filename,'*', tmp_g2{m})), '$', Mod8{n}), ',1'));
    end
  
   Result_Folder = fullfile(basepath_DoR, Res, Mod8{n});
   %Check result path exists, if not create the path 
   type = exist (Result_Folder);
     if type ~=7
       %Create the folder if not existing
       mkdir(Result_Folder);
     end            
   
   %Set path to find the sub function
   cd(filepath);
   %Rewrite the matlabbatch.spm attributs for the dedicated DoRs Specify 2nd-level runs
   if Covarates == 0 
     secondlevel_dors_job(Result_Folder, group1, group2);
   else
     secondlevel_dors_cov_job(Result_Folder, group1, group2);
   end
end

return;