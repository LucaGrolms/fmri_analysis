function SPM_Denoised
 
%SPM runs the denoised or noised subject images with specfic onsets to build
%residuals
%Build the complete denoised or noised scan file list based on the specific input file list 
%and adapted the correct condition file for the relevant SPM run

diary( ['spm_batch_processing' sprintf('-%.2i',fix(clock)) '.log'] )

%Clear the workspace and classes
clear;
clear classes;

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

%Select and load the file which specify all original condition files
scanlistfile = spm_select(1,'mat','Select subject''s denoised/noised scans');
if length(scanlistfile) == 0,
	disp('No condition file selected; Change condition will now exit');
	diary off
	return
end

%Select and load the file which specify all original condition files
f = fopen(scanlistfile);             
   s = textscan(f,'%s','delimiter','\r\n','CommentStyle','#'); % Read the whole file into variable s, with each line a separate cell, ignoring comments
 fclose(f);
 s = cellstr(s{1});
 num_rows = size(s,1);

 for i=1:num_rows
   if size(s{i},1) > 0
     studyLine=textscan(s{i},'%q','CommentStyle', '#'); % Read text of each line into separate fields (supports quoting of delimiter characters)
     studyLine=studyLine{1};
   else studyLine=''; end;
   num_cols=size(studyLine,1);

    %Built matlab spm.stats.fmri_spec.sess.scans denoised starts with
    %'0000' noised with '001'
    for m=1:denoisedImages
        if ImageType == 1
          session_scans{m,1}= fullfile(studyLine{1,1},strrep(studyLine{2,1},'*',sprintf('%04d',m-1)));
        else
          session_scans{m,1}= fullfile(studyLine{1,1},strrep(studyLine{2,1},'*',sprintf('%03d',m)));
        end
        session_scans{m,1}= strcat(session_scans{m,1},',1');
    end 

    %Define the spm result path and define the condition file path per subject for
    %the normal condition usage and the modified condition usage
    result_base = strsplit(studyLine{1,1}, 'Ma2');
    sub_number = strsplit(studyLine{1,1}, 'sub-');
    sub_number = strsplit(sub_number{1,2}, '/');
    path_cond_file =  fullfile(basepathcond, sub_number{1,1});
    
    %Use the normal condition file   
    current_cond_file = strcat(path_cond_file,'_Ma2.mat');
    %Rewrite modifications after proving the base condition file
    %attributes
    clear tmp_conditions;
    tmp_conditions = load (current_cond_file);
    modifications = size(tmp_conditions.names,2);
 
      for j=0:modifications
         if j== 0
            %Check at first the normal condition filde
            if ImageType == 1
               result = strcat (result_base{1,1}, 'spm_Results');
            else
               result = strcat (result_base{1,1}, 'spm_Results_ori');
            end   
            %Check result path exists, if not create the path 
            type = exist (result);
               if type ~=7
                   %Create the folder if not existing
                   mkdir(result);
               end
            %Path of the normal condiation file            
            current_cond_file = strcat(path_cond_file,'_Ma2.mat');
            if isfile(current_cond_file) ~= 1
              disp(['Condition File', current_cond_file, 'not found!!!']);     
            end
         else 
            %Use the modified condition file in the right way return, UCS, CS+, CS- or Ex1_CS+,...  
            if modifications ~= 8
               M=Mod4{j};
            else
               M=Mod8{j};
            end
            current_cond_file = strcat (path_cond_file,'_Ma2_', M,'.mat');
            if isfile(current_cond_file) ~= 1
              disp(['Condition File ', current_cond_file, ' not found!!!']);     
            end

            %Create the Result folder with condition extensions
            if ImageType == 1
              result = strcat (result_base{1,1}, 'spm_Results_', M);
            else 
              result = strcat (result_base{1,1}, 'spm_Results_ori_', M);
            end  
            %Check result path exists, if not create the path 
            type = exist (result);
               if type ~=7
                   %Create the folder if not existing
                   mkdir(result);
               end            
          end
      
       %Rewrite the matlabbatch.spm attributs at all and starts the job  
       spm_first_level_job(i, result, session_scans, current_cond_file);
       
       %Delete the not needed Res_*.nii and beta_*.nii files of the current
       %results folder
       tmp_del=fullfile(result, 'Res_*.nii');
       delete(tmp_del); 
       tmp_del=fullfile(result, 'beta_*.nii');
       delete(tmp_del);
    end
 end
 diary off   

return;