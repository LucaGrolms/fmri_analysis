function [std_edge_activity] = edge_activity_func(dir_ICA, CSF_mask_file_name, dir_stats)

% This function calculates the edge activity (normalised to 1) based on an edge mask, which the user needs to create prior to running the function. If the user has generated their own edge mask, they have the option of specifying this below:
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

%	2018-09-25 (dfa): use fullfile, not strcat, for path construction
%	2015-06-22 (dfa): improved logic to support SPM2 and later (incl. SPM2, 5, 8 and 12) 
%	2012-2013: Original version by Kaushik Bhaganagarapu (supported spm2 and spm8 only)


% Set to 1 to automatically look for edge mask (default)
% Set to 0 to manually look for it (if you've created your own edge mask)
get_edge_mask_flag = 1;
%
% Inputs:
%
% (1) dir_ICA: The directory of the ICA analysis. This is passed from SOCK.m.
% (2) CSF_mask_file_name: The directory path for the edge mask.
% (3) dir_stats: The "stats" directory path. Varies depending on whether melodic is run via the GUI or the command line.
%
% Output:
%
% (1) edge_activity: The amount of edge activity (using thresholded images created by melodic).


   tmpdir = pwd;

   dir_filt = fullfile(dir_ICA, 'filtered_func_data.ica');
   
   cd(dir_ICA) 
   % This specifies if you want to read in individual thresholded images or one thresholded image  which contains all the ICs. Default is 0.  
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
	
   end

	% Chose edge mask
	if get_edge_mask_flag == 1
		edge_mask_file_name = fullfile(dir_ICA, 'all_edge_mask.img');
   	else	 
   
		disp('Select edge mask....');

		if strcmp(spm('ver'), 'SPM2')
   			edge_mask_file_name = spm_get;
		else
 			edge_mask_file_name = spm_select;
		end
   	end


	name_change = dir('thresh_zstat0*.img');
	exit_flag = 0;

for img = 1:no_ics

	if img == 1	
		fprintf(1,'Obtaining edge activity for IC    ');
	end
	
	if img <= 9
		fprintf(1,'\b%01d',img); pause(.1);
	end
	if (img>=10 & img <=99)
		fprintf(1,'\b\b%d',img); pause(.1);
	end
	if (img>=100 & img <=999)
		fprintf(1,'\b\b\b%i',img); pause(.1);
	end

	if img == no_ics	
		fprintf('\n')
	end
	
	if length(name_change) == 0
		img_name = strcat('thresh_zstat', num2str(img));
	elseif length(name_change) == 9
	        if img < 10
			img_name = strcat('thresh_zstat0', num2str(img));
		else
			img_name = strcat('thresh_zstat', num2str(img));
		end
	elseif length(name_change) == 99
	        if img < 10
			img_name = strcat('thresh_zstat00', num2str(img));
		elseif img >=10 & img <=99
			img_name = strcat('thresh_zstat0', num2str(img));
		else
			img_name = strcat('thresh_zstat', num2str(img));
		end

	end

	zstat_minus_CSF_file_name = create_zstat_minus_CSF(img_name, CSF_mask_file_name); 

	[clusters_in_zstat] = locmax(zstat_minus_CSF_file_name, 0);

	[clusters_in_edge] = locmax(zstat_minus_CSF_file_name, 0, edge_mask_file_name);

	size_clusters_in_zstat = size(clusters_in_zstat);
	no_clusters_in_zstat = size_clusters_in_zstat(1);
	
	size_clusters_in_edge = size(clusters_in_edge);
	no_clusters_in_edge = size_clusters_in_edge(1);

	if no_clusters_in_edge == 0 | no_clusters_in_zstat == 0
		edge_activity(img,1) = 0;

	else	
		total_no_cluster = clusters_in_zstat(end,5); % Total number of clusters in zstat image (as determined by "locmax.m" function)

		vol_cluster_zstat = zeros(1,total_no_cluster);
		vol_cluster_edge = zeros(1,total_no_cluster);

	
		x_edge = clusters_in_edge(:,2);
		y_edge = clusters_in_edge(:,3);
		z_edge = clusters_in_edge(:,4);

		coord_edge = [x_edge y_edge z_edge];


		for i=1:total_no_cluster

			no_clusters_in_ID = find(clusters_in_zstat(:,5)==i); 
			vol_cluster_zstat(i) = clusters_in_zstat(no_clusters_in_ID(1), 6); % vol of a particular cluster in zstat

			for j=1:length(no_clusters_in_ID)
		
				x_zstat = clusters_in_zstat(no_clusters_in_ID(j), 2);
				y_zstat = clusters_in_zstat(no_clusters_in_ID(j), 3);
				z_zstat = clusters_in_zstat(no_clusters_in_ID(j), 4);
		
				coord_zstat = [x_zstat y_zstat z_zstat];

	 			for k=1:no_clusters_in_edge
					if (coord_zstat==coord_edge(k,1:3))
						vol_cluster_edge(i) = clusters_in_edge(k,6); % vol of the same cluster in edge
						exit_flag = 1;
						break;
					end
				end

				if (exit_flag==1)
					break;
				end

			end % End loop: number of clusters in particular ID (which is taken from clusters in ztstat img)

		exit_flag = 0;
		end % End loop: total number of cluster ID's from zstat img
	
		%ratio_edge_zstat = vol_cluster_edge'./vol_cluster_zstat';
		%edge_clusters = find(ratio_edge_zstat(:)>2/3);
		
		%non_zero_edge_ind = find(vol_cluster_edge);
		%total_edge_vox = sum(vol_cluster_edge);
		%total_zstat_vox = sum(vol_cluster_zstat(edge_clusters));
		edge_activity(img,1) = sum(vol_cluster_edge)/sum(vol_cluster_zstat);
		%edge_activity(img,1) =  total_edge_vox/total_zstat_vox;
	end

end % END loop through all images

cd(dir_ICA)

%clearvars -except edge_activity std_edge_activity
std_edge_activity = edge_activity./mean(edge_activity);
save edge_activity;
save std_edge_activity;
 


