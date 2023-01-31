function convert_NIFTI_to_PAIR_mean_functional(dir_ICA, gui_flag)

% Input: dir_ICA = The directory path to where the ICA results live.
%        gui_flag = A flag that takes 1 (if melodic is run via GUI) or 0 (if melodic is run via terminal mode).
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

%	2015-06-16: dfa changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu


   if gui_flag == 0
	   mean_img = 'mean.nii*';
   else
   	   mean_img = 'mean_func.nii*';
   end

   exist_mean_img = dir(mean_img);

   if length(exist_mean_img) ~= 0
   	   disp('Converting mean functional image into NIFTI_PAIR format...');
   	   command = strcat('fslchfiletype', {' '}, 'NIFTI_PAIR', {' '}, mean_img);
   	   command = char(command);
      	   sai_unix(command);
   else
   	   disp('Using mean functional image for SOCK analysis...');
   end	

   return;  
