function SOCK_main(dir_ICA, batch_flag, SOCK_dir)

% Script for automatic implementation of SOCK (after ICA is run)
% Inputs:
% dir_ICA - The location of the Melodic directory for the subject being analysed.
% batch_flag - A flag which indicates whether SOCK is being used for a multiple subjects (2) or a single subject (1).
% SOCK_dir - The location of the SOCK files.
% _______________________________________________________________________
% Copyright (C) 2012-2015 The Florey Institute of 
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

%	2015-06-16(dfa): changed from ANALYZE to NIFTI_PAIR
%	2015-02-10(dfa): enter debug mode if error occurs
%	2012-2013: Original version by Kaushik Bhaganagarapu

dbstop if error % enter debug mode if an error occurs

disp(sprintf('Running SOCK on %s\n', dir_ICA));


% Generate edge and CSF masks
gen_masks_flag = gen_masks(dir_ICA, batch_flag, SOCK_dir);

		
% Convert thresholded images into NIFTI_PAIR format
disp(sprintf('Converting thresholded images in stats dir to NIFTI_PAIR format...\n'));
dir_stats = convert_NIFTI_to_PAIR_thresholded_imgs(dir_ICA);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain CSF and edge activity from the thresholded images
disp(sprintf('Obtaining CSF and edge activity measures for SOCK analysis...\n'));

% Get back into main .ica directory
cd(dir_ICA)

% Load existing CSF_activity.mat file if present
exist_CSF_activity = dir('CSF_activity.mat');
if length(exist_CSF_activity) ~= 0 & gen_masks_flag == 1
	load CSF_activity
	disp(sprintf('Using CSF activity from previous run...\n'));
else
	[CSF_activity, CSF_mask_file_name] = CSF_activity_func(dir_ICA, dir_stats);
end

% Load existing edge_activity.mat file if present
exist_edge_activity = dir('edge_activity.mat');
if length(exist_edge_activity) ~= 0 & gen_masks_flag == 1
	load edge_activity
	disp(sprintf('Using edge activity from previous run...\n'));
else
	% Calculate the edge activity in each IC
	[edge_activity] = edge_activity_func(dir_ICA, CSF_mask_file_name, dir_stats);
end

% Label each IC as edgy or non-edgy
[edge_activity_label_spatial] = edge_activity_label(dir_ICA);

% Save the above calculations to the IC structure
IC.CSF_activity = CSF_activity;
IC.edge_activity = edge_activity;
IC.edge_activity_label_spatial = edge_activity_label_spatial;
save IC

disp(sprintf('DONE\n'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain smoothness measure from unthresholded images and cluster them.
disp(sprintf('Obtaining smoothness measures for SOCK analysis...\n'));
% If r_flag is set to 0, then the smoothness is based on only ONE radius. Always set to 1, so that clustering can be used to determine smoothness.
r_flag = 1;
[smoothness_measure] = smoothness_measure_func(dir_ICA, r_flag);
cd(dir_ICA)
% Save matrix of smoothness values
save smoothness_measure;
% Label the ICs into smooth, subsmooth and unsmooth categories. Now stored in the IC structure.
[IC] = smoothness_measure_label(IC, dir_ICA, smoothness_measure);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain power spectrum measure from thresholded images
disp(sprintf('Obtaining power spectrum measures for SOCK analysis...\n'));
[IC, ps_matrix, TR] = ps_measure(IC, dir_ICA);

% Cluster the power spectrum measure (beyond 0.08Hz)
%disp(sprintf('Clustering power spectrum measures for SOCK analysis...\n'));
[IC] = ps_measure_label(IC, ps_matrix, TR);

save IC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THE TC_MEASURE AND TC_MEASURE_LABEL FUNCTIONS ARE NOT USED IN SOCK (6/11/2012)
% Obtain timecourse measure from thresholded images
%disp(sprintf('Obtaining timecourse measures for SOCK analysis...\n'));

%[IC, tc_matrix] = tc_measure(IC, dir_ICA);

% Cluster the timecourses into high/low differences (i.e. looking for motion in the temoral domain)
%disp(sprintf('Clustering timecourse measures for SOCK analysis...\n'));

%[IC] = tc_measure_label(IC, tc_matrix);

%save IC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run script for classifying IC's into unlikely artifact, possible artifact and definite artifact
disp(sprintf('Classifying ICs using SOCK...\n'));
IC = SOCK_classify;
cd(dir_ICA)
save IC
