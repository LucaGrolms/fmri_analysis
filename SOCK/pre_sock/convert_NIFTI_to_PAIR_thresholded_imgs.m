function stats_dir = convert_NIFTI_to_PAIR_thresholded_imgs(dir_ICA)

% Input: dir_ICA - The directory path to where the ICA results live
% Output: stats_dir - The directory path to the stats directory (where the thresholded images live)
% _______________________________________________________________________
% Copyright (C) 2012-2013,2015 The Florey Institute of 
%    Neuroscience and Mental Health, Melbourne, Australia
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

%	2018-09-25 (dfa): use fullfile, not strcat, for path construction
%	2015-06-16 (dfa): changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu

   cd(dir_ICA)

   gui_flag = melodic_gui(dir_ICA);

   if gui_flag == 0
   	stats_dir = fullfile(dir_ICA, 'stats');
   else
	stats_dir = fullfile(dir_ICA, 'filtered_func_data.ica','stats');
   end
    
   cd(stats_dir)

   exist_flag = dir('convert_NIFTI_to_PAIR.mat');

   if length(exist_flag) == 0
	   thresholed_files = dir('thresh*.nii*');
   	   no_ics = length(thresholed_files);

  	   for i=1:no_ics
    	  	% convert NIFTI to NIFTI_PAIR
	   	command1 = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR thresh_zstat', num2str(i), '.nii*'));
		sai_unix(command1);
	   end
   
       	   convert_NIFTI_to_PAIR = 1;
   	   save('convert_NIFTI_to_PAIR.mat', 'convert_NIFTI_to_PAIR');
    else
	   disp('Images in stats dir are already in NIFTI_PAIR format');
    end
return;  
