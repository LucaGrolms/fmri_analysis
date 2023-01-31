function [CSF_activity, CSF_mask_file_name] = CSF_activity_func(dir_ICA, dir_stats)

% This function calculates the CSF activity (normalised to 1) based on a CSF mask, which SPM creates. If the user has generated their own CSF mask, they have the option of specifying this below:
% _______________________________________________________________________
% Copyright (C) 2012-2013, 2015, 2018 The Florey Institute of 
%    Neuroscience and Mental Health, Melbourne, Australia
%
% Coded by Kaushik Bhaganagarapu
%
% This file is part of the SOCK software package. 
% Please see sock.m for more information.

% SOCK is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
% 
% SOCK is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program (see LICENCE.txt). If not, 
% see <http://www.gnu.org/licenses/>.
%
% _______________________________________________________________________

%	2018-09-25 (dfa): Use fullfile, not strcat, for path construction
%	2015-06-22 (dfa): improved logic to support SPM2 and later (incl. SPM2, 5, 8 and 12) 
%	2012-2013: Original version by Kaushik Bhaganagarapu (supported spm2 and spm8 only)


% Set to 1 to automatically look for CSF mask (default)
% Set to 0 to manually look for it (if you've created your own CSF mask)
get_CSF_mask_flag = 1;

%
% Inputs:
%
% (1) dir_ICA: The directory of the ICA analysis. This is passed from SOCK.m
%
% (3) dir_stats: The "stats" directory path. Varies depending on whether melodic is run via the GUI or the command line.
% Outputs:
%
% (1) CSF_activity: The amount of CSF activity (using thresholded images created by melodic). 
%
% (2) CSF_mask_file_name: The directory path for the user specified CSF mask


   tmpdir = pwd;


   cd(dir_ICA) 
   % This specifies if you want to read in individual thresholded images or one thresholded image which contains all the ICs. Default is 0. 
   group = 0; 

   % Read in ICs. 
   
   if group == 0
   	
	%%%%%%%%%%%%%%%%%%%%% This code is used for when images are seperated into individual volumes %%%%%%%%%%%%%%%%%%%%%%
   	cd(dir_stats) 
   	filelist = dir('thresh_zstat*.img'); 
	no_ics = numel(filelist);
	
   else
    	
	%%%%%%%%%%%%%%%%%%%%% This code is used for when images are contained in one hdr file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   	cd(dir_stats) 
   	VO = bri_read_4D_vol('thresh_zstat.img');
	no_ics = length(VO);
	
   end

   % Calc. the number of voxels in the the CSF Mask
   if get_CSF_mask_flag == 1
		CSF_mask_file_name = fullfile(dir_ICA, 'CSF_mask_fsl.img');
   else	 
   
		disp('Select CSF mask....');

		if strcmp(spm('ver'), 'SPM2')
   			CSF_mask_file_name = spm_get;
		else
			CSF_mask_file_name = spm_select;
		end
   end

   V_CSF_mask = spm_vol(CSF_mask_file_name);
   all_voxels_CSF_mask = spm_read_vols(V_CSF_mask);
   non_zero_voxels_CSF_mask = find(all_voxels_CSF_mask(:));
   
   % Total number of CSF voxels
   total_CSF_voxels = size(non_zero_voxels_CSF_mask);
    
   % Read in each image and calculate the number of voxels overlapping the CSF mask  
   
        % Create CSF activity vector which indicates the percentage of CSF activity in each IC.
	CSF_activity = zeros(no_ics,1);

	name_change = dir('thresh_zstat0*.img');

for img = 1:no_ics

	if length(name_change) == 0
		img_name = strcat('thresh_zstat', num2str(img), '.img');
	elseif length(name_change) == 9
	        if img < 10
			img_name = strcat('thresh_zstat0', num2str(img), '.img');
		else
			img_name = strcat('thresh_zstat', num2str(img), '.img');
		end
	elseif length(name_change) == 99
	        if img < 10
			img_name = strcat('thresh_zstat00', num2str(img), '.img');
		elseif img >=10 & img <=99
			img_name = strcat('thresh_zstat0', num2str(img), '.img');
		else
			img_name = strcat('thresh_zstat', num2str(img), '.img');
		end

	end

	% Read in image.
	size_img = size(spm_vol(img_name));
	if size_img(1) > 1 % If image contains nothing, then do the following. 
		tmp_struct = spm_vol(img_name);
		V_thresh(img) = tmp_struct(1);
	else
		V_thresh(img) = spm_vol(img_name);
        end

        all_voxels_V_thresh = spm_read_vols(V_thresh(img));
    
        % overlapping voxels in each thresh. image
        overlap_voxels = all_voxels_V_thresh(non_zero_voxels_CSF_mask);
        non_zero_overlap_voxels = find(overlap_voxels(:));
        
	total_CSF_voxels_overlap = size( non_zero_overlap_voxels );
        CSF_activity(img,1) = ( total_CSF_voxels_overlap / total_CSF_voxels ) * 100;
        
end % END loop through all images

cd(dir_ICA)
CSF_activity = CSF_activity;
%clearvars -except CSF_activity
save CSF_activity;

% Normalised CSF activity vector
%CSF_activity = CSF_activity./mean(CSF_activity);

 
return; 
 

