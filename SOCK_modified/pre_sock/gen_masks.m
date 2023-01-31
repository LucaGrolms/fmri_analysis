function gen_masks_flag = gen_masks(dir_ICA, batch_flag, SOCK_dir)

% Script for generating edge and CSF masks via SPM8's segment function
% Inputs:
% dir_ICA - The location of the Melodic directory for the subject being analysed.
% batch_flag - A flag which indicates whether SOCK is being used for a multiple subjects (2) or a single subject (1).
% SOCK_dir - The location of the SOCK files.
%
% Output:
% gen_masks_flag = A flag which tells SOCK_main to either generate edge and CSF activity or not.
% _______________________________________________________________________
% Copyright (C) 2012-2013,2015,2017 The Florey Institute of 
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

%	2017-05-26: dfa updated progress messages to be consistent with
%		    the fact that spm8's New Segment became the standard
%		    segment routine in spm12. Renamed the script called to
%		    batch_seg_spm_script.m
%	2015-06-16: dfa changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu

cd(dir_ICA)
% Determine whether melodic was run via GUI or on command line
gui_flag = melodic_gui(dir_ICA);

% Convert the mean_func image to NIFTI_PAIR format
convert_NIFTI_to_PAIR_mean_functional(dir_ICA, gui_flag);

% Check to see whether vCSF and edge masks exist.
exist_CSF_mask = dir('CSF_mask_fsl.img');
exist_edge_mask = dir('all_edge_mask.img');

[SpmVersion,SpmRelease]   = spm('Ver','',1);
if strcmp(SpmVersion, 'SPM8') 
	seg_string = [SpmVersion, ' New Segment'];
else
	seg_string = [SpmVersion, ' Segment']; % the New Segment of spm8 became the standard segment in spm12.
end

if length(exist_CSF_mask)~=0 & length(exist_edge_mask)~=0
	disp(sprintf('Using existing CSF and masks...'));

	if batch_flag == 2 
		prompt = 'Are you sure you don''t want to generate edge and CSF masks? (1=Yes/2=No):';
		gen_masks_flag = input(prompt);
		if gen_masks_flag == 2
			cd(SOCK_dir)
			save dir_ICA	
			% Generate the edge and CSF maks using SPM's segment (or, prior to spm12, "New Segment")
			batch_seg_spm_script;
			cd(SOCK_dir)
			delete dir_ICA;
		end
	end
	gen_masks_flag = 1;

else
		
	cd(SOCK_dir)
	save dir_ICA	
	% Generate the edge and CSF maks using SPM's segment (or, prior to spm12, "New Segment")
	disp(sprintf(['Generating edge and CSF masks using ',seg_string,'\n']));
	batch_seg_spm_script;
	cd(SOCK_dir)
	delete dir_ICA.mat;

	% Remove existing masks, threshold SPM generated masks and convert them to NIFTI_PAIR format
	cd(dir_ICA)
	rm_thr_convert_masks(gui_flag)

	gen_masks_flag = 2;
end
