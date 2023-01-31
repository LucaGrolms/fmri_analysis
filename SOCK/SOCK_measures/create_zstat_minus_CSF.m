function zstat_minus_CSF_file_name = create_zstat_minus_CSF(img_name, CSF_mask_file_name)

% This function:
% Creates a zstat image removing CSF voxels for use in edge_function.m file.
% _______________________________________________________________________
% Copyright (C) 2012-2013 The Florey Institute of 
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


	zstat_minus_CSF_file_name = strcat('minus_CSF_', img_name, '_abs.img');
	exist_minus_file = dir(zstat_minus_CSF_file_name);

	if length(exist_minus_file) == 0

		command_zstat_masked_with_CSF = strcat('fslmaths', {' '}, img_name, '.img', {' '}, '-mas', {' '}, CSF_mask_file_name, {' '}, 'omsai');
		command_zstat_masked_with_CSF = char(command_zstat_masked_with_CSF);

		command_zstat_minus_CSF = strcat('fslmaths', {' '}, img_name, '.img', {' '}, '-sub', {' '}, 'omsai.nii.gz', {' '}, 'minus_CSF_', img_name); 
		command_zstat_minus_CSF = char(command_zstat_minus_CSF);

		command_zstat_minus_CSF_abs = strcat('fslmaths', {' '}, 'minus_CSF_', img_name, '.nii.gz', {' '}, '-abs', {' '}, 'minus_CSF_', img_name, '_abs');  
		command_zstat_minus_CSF_abs = char(command_zstat_minus_CSF_abs);

		command_rm_zstat_minus_CSF = strcat('\rm', {' '}, 'minus_CSF_', img_name, '.nii.gz');
		command_rm_zstat_minus_CSF = char(command_rm_zstat_minus_CSF);

		sai_unix(command_zstat_masked_with_CSF);
		sai_unix(command_zstat_minus_CSF);
		sai_unix(command_zstat_minus_CSF_abs);
		sai_unix(command_rm_zstat_minus_CSF);		
	
		%Convert to from NIFTI to Analyze images
		command_zstat_minus_CSF_convert = strcat('fslchfiletype', {' '}, 'NIFTI_PAIR minus_CSF_', img_name, '_abs.nii.gz');
		command_zstat_minus_CSF_convert = char(command_zstat_minus_CSF_convert);

		sai_unix(command_zstat_minus_CSF_convert);

	end
		
return; 
 

