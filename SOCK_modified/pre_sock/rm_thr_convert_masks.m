function rm_thr_convert_masks(gui_flag)

% This function:
%
% (1) Removes existing CSF and edge masks (if they exist)
% (2) Thresholds SPM generated CSF and edge masks.
% (3) Converts these thresholded images to Analyze format.
% _______________________________________________________________________
% Copyright (C) 2012-2013,2015 The Florey Institute of 
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

%	2015-06-16: dfa changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu


	exist_CSF_mask = dir('CSF_mask*');
	if length(exist_CSF_mask) > 0
		delete CSF_mask*
	end

	exist_edge_mask = dir('edge_mask*');
	if length(exist_edge_mask) > 0
		delete edge_mask*
	end
	
	exist_all_edge_mask = dir('all_edge_mask*');
	if length(exist_all_edge_mask) > 0
		delete all_edge_mask*
	end

	% Threshold SPM generated CSF and edge masks and rename them CSF_mask and edge_mask respectively
	if gui_flag == 0
		command_CSF = strcat('fslmaths', {' '}, 'c3mean.nii -thr 0.5 CSF_mask_fsl');
		command_CSF = char(command_CSF);

		command_edge_inner = strcat('fslmaths', {' '}, 'c4mean.nii -thr 0.5 edge_mask_inner_fsl');
		command_edge_inner = char(command_edge_inner);

		command_edge = strcat('fslmaths', {' '}, 'c5mean.nii -thr 0.5 edge_mask_fsl');
		command_edge = char(command_edge);
		
		command_all_edge = strcat('fslmaths', {' '}, 'edge_mask_fsl.nii.gz', {' '}, '-add', {' '}, 'edge_mask_inner_fsl.nii.gz', {' '}, 'all_edge_mask');
		command_all_edge = char(command_all_edge);
		

	else
		command_CSF = strcat('fslmaths', {' '}, 'c3mean_func.nii -thr 0.5 CSF_mask_fsl');
		command_CSF = char(command_CSF);

		command_edge_inner = strcat('fslmaths', {' '}, 'c4mean_func.nii -thr 0.5 edge_mask_inner_fsl');
		command_edge_inner = char(command_edge_inner);
		

		command_edge = strcat('fslmaths', {' '}, 'c5mean_func.nii -thr 0.5 edge_mask_fsl');
		command_edge = char(command_edge);

		command_all_edge = strcat('fslmaths', {' '}, 'edge_mask_fsl.nii.gz', {' '}, '-add', {' '}, 'edge_mask_inner_fsl.nii.gz', {' '}, 'all_edge_mask');
		command_all_edge = char(command_all_edge);	

	end


	sai_unix(command_CSF);
	sai_unix(command_edge_inner);
	sai_unix(command_edge);
	sai_unix(command_all_edge);


	% Convert to from NIFTI to Analyze images
	command_CSF_mask_fsl_convert = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR CSF_mask_fsl.nii.gz'));
	command_edge_mask_fsl_convert = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR edge_mask_fsl.nii.gz'));
	command_edge_mask_inner_fsl_convert = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR edge_mask_inner_fsl.nii.gz'));
	command_all_edge_mask_convert = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR all_edge_mask.nii.gz')); 

	sai_unix(command_CSF_mask_fsl_convert);
	sai_unix(command_edge_mask_fsl_convert);
	sai_unix(command_edge_mask_inner_fsl_convert);
	sai_unix(command_all_edge_mask_convert);
 
return; 
 

