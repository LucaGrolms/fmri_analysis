function [edge_activity_label_spatial]= edge_activity_label(dir_ICA)

% This function clusters based on kmeans whether an IC is edgy or non-edgy. 
%
% Input:
%
% (1) dir_ICA: The directory of the ICA analysis. This is passed from SOCK.m
%
% Output:
%
% (1) edge_activity_label_spatial: A label which indicates whether an IC is edgy or non-edgy. 
%
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



   cd(dir_ICA) 

   load std_edge_activity;

   % Cluster spatial edge activity (in std_edge_activity.mat)

   [km2, C] = kmeans(std_edge_activity,2, 'replicates', 1000);
   edge_activity_label_spatial(1:no_ics) = {''};

   mean1 = mean(std_edge_activity(km2(:)==1));
   mean2 = mean(std_edge_activity(km2(:)==2));

   cluster_split_val = (C(1)+C(2))/2;
   k = 1;
  
   for i=1:no_ics
   	if(std_edge_activity(i)>cluster_split_val & std_edge_activity(i)<cluster_split_val*1.10)
		maybe_high_edge_ICs(k) = i;
		k = k + 1;
	end
   end

   if(k==1)
	maybe_high_edge_ICs = [];
   end
	
   if mean1>mean2
   	high_ICs = find(km2(:)==1);
	low_ICs = find(km2(:)==2);
   else
	high_ICs = find(km2(:)==2);
	low_ICs = find(km2(:)==1);
   end 

   maybe_high_edge_ICs;
   for j=1:no_ics

	if(find(low_ICs(:)==j))
		edge_activity_label_spatial(j) = {'low'};
	elseif(find(maybe_high_edge_ICs(:)==j))
		edge_activity_label_spatial(j) = {'low'};
	elseif(find(high_ICs(:)==j))
		edge_activity_label_spatial(j) = {'high'};
	end
   end

   %clearvars -except edge_activity_label_spatial
   save edge_activity_label_spatial;
		
return; 
 


