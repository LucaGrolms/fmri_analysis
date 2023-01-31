function [smoothness_measure] = smoothness_measure_func(dir_ICA, r_flag)

% The smoothness_measure_func.m function is responsible for obtain a measure on the smoothness of each IC using unthresholded spatial maps.  
%
% Inputs:
%
% dir_ICA: The directory of the ICA. This is passed on from SOCK_main.m.
%
% r_flag: If this is set to 0, then the smoothness is based on only ONE radius. Always set to 1 (in SOCK_main.m file), so that clustering can be used to determine smoothness.
%
% Output:
% 
% smoothness_measure: A matrix containing value of smoothness measure for each IC over a range of radius values specified below.
%
% _______________________________________________________________________
% Copyright (C) 2012-2013,2018 The Florey Institute of 
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

%	2018-09-25 (dfa): use fullfile, not strcat, for path construction
%	2015-06-16 (dfa): changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu
 
   tmpdir = pwd;

   gui_flag = melodic_gui(dir_ICA);

   if gui_flag == 0
        % Use when Melodic is run via the command line
   	 dir_filt = dir_ICA;
   else
	% Use when Melodic is run via the GUI
	dir_filt = fullfile(dir_ICA, 'filtered_func_data.ica');
   end

   cd(dir_ICA) 

   % The group var influences how the unthresholded images are read. Set to 1 when reading from melodic directories.
   group = 1; 

   % Read in ICs. 
   
   if group == 0
   	
	%%%%%%%%%%%%%%%%%%%%% This code is used for when images are seperated into individual volumes %%%%%%%%%%%%%%%%%%%%%%
   	dir_IC_masks = fullfile(dir_filt, 'filtered_func_data.ica', 'unthresh_ICs_all');
   	cd(dir_IC_masks) 
   	filelist = dir('melodic_IC*.img'); 
	no_ics = numel(filelist);
	V_mask = spm_vols('mask.hdr');
	
	% Define the x,y,z coordinates
   	x = V_mask.dim(1);
   	y = V_mask.dim(2);
   	z = V_mask.dim(3);

   else
    	
	%%%%%%%%%%%%%%%%%%%%% This code is used for when images are contained in one hdr file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   	cd(dir_filt) 
	file_exist = dir('melodic_IC.img');
	if length(file_exist) == 0 
		command_melodic_convert = char(strcat('fslchfiletype', {' '}, 'NIFTI_PAIR melodic_IC.nii.gz'));
		sai_unix(command_melodic_convert);
	end
   	VO = bri_read_4D_vol('melodic_IC.img');
	no_ics = length(VO);
	
	% Define the x,y,z coordinates
   	x = VO(1).dim(1);
   	y = VO(1).dim(2);
   	z = VO(1).dim(3);
   end


   % Define fft var. This will be used for calculating fft of each IC.
   fft_var = zeros( x,y,z, no_ics );

   % Define shifted fft var. as well.
   shift_fft_var = zeros( x,y,z, no_ics );

   % Define Ratio var., which will contain the degree of smoothness
   ratio = zeros(no_ics);

   % Define elipse parameters for roi calc.
   a = 1;
   b = 1;
   c = 1;
   if mod(x,2) == 0
   	x_range = -floor(x/2)+1:floor(x/2);
   else
	x_range = -floor(x/2):floor(x/2);
   end

   if mod(y,2) == 0
   	y_range = -floor(y/2)+1:floor(y/2);
   else
	y_range = -floor(y/2):floor(y/2);
   end

   if mod(z,2) == 0
	z_range = -floor(z/2)+1:floor(z/2);
   else
	z_range = -floor(z/2):floor(z/2);
   end

   [X,Y,Z] = meshgrid(y_range,x_range,z_range);
   D = (X.^2)./(a^2) + (Y.^2)./(b^2) + (Z.^2)./(c^2);

   % Define r value(s)
   if r_flag == 0
	r = x*0.046875;
   else
	r = [1:1:6];
	smoothness_measure = zeros(length(r), no_ics);
   end

%*********************************************************** Start looping through R values ****************************************
   for i=1:length(r)
   
        sphere = D <= r(i).^2;

	% Reading in each image and claculating the estimates of smoothness 
   	for img = 1:no_ics

		if group == 0
			V(img) = spm_vol(filelist(img).name);
        		all_voxels_V = spm_read_vols(V(img));
 		else
			all_voxels_V = spm_read_vols(VO(img));
		end
         fft_var(:,:,:,img) = fftn(all_voxels_V);
	 shift_fft_var(:,:,:,img) = fftshift(fft_var(:,:,:,img));
	 region_in = shift_fft_var(:,:,:,img).*sphere;
	 region_out = shift_fft_var(:,:,:,img) - region_in;
	 
         region_in_sum = sum(sum(sum(abs(region_in))));
	 region_out_sum = sum(sum(sum(abs(region_out))));

	 ratio(img) = region_in_sum/region_out_sum;

   	 % Place dim, radius of circle for roi and number of ICs in the info structure
   	 info.r = r;
   	 info.dim = [x y z];
   	 info.no_ics = no_ics;
	 
	 smoothness_measure(i,img) = ratio(img);
	end	 

   end

%********************************************************* END looping through r values *****************************************%
	

% Extra code for obtaing the most smooth IC curve within the unsmooth cluster (NOT CURRENTLY USED)
%	 if smooth_switch == 0
%	 	mean_non_smoothness = mean( smoothness_measure(:,idx==2) );
%		all_non_smooth_ic = find(idx == 2);	
%	 else
%		mean_non_smoothness = mean( smoothness_measure(:,idx==1) );
%		all_non_smooth_ic = find(idx == 1);
%	 end

%	 max_non_smooth_index = find( mean_non_smoothness == max(mean_non_smoothness) );
%	 max_non_smooth_ic = all_non_smooth_ic(max_non_smooth_index); 

return; 

