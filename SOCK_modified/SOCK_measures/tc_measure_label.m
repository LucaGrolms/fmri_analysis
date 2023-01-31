function [IC, tc_matrix] = tc_measure_label(IC, tc_matrix)

% This function extracts the power spectrum values from the Melodic analysis and stores them in the IC structure.
%
% Output:
%
% tc_matrix = A matrix containing the power spectrum information for each IC
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


   % Difference in TC's
   diff_tc_matrix  = diff(tc_matrix(:,:));

  
   size_tc_matrix = size(tc_matrix);
   no_ics = size_tc_matrix(2);

   for i=1:no_ics

	tmp = mean(diff_tc_matrix(:,i));
	std_diff_tc_matrix(:,i) = diff_tc_matrix(:,i)./tmp;


	range(i) = max(std_diff_tc_matrix(:,i)) - min(std_diff_tc_matrix(:,i));
	boundL(i) = 0-0.05*range(i);
	boundU(i) = 0+0.05*range(i);
	
	no_near_zero(i) = length(find(std_diff_tc_matrix(:,i)>boundL(i) & std_diff_tc_matrix(:,i)<boundU(i)));
   end

   kmeans_clustering = kmeans(no_near_zero,2);
 
   mean1 = mean(no_near_zero(kmeans_clustering(:)==1));
   mean2 = mean(no_near_zero(kmeans_clustering(:)==2)); 

   if mean2 > mean1
	% This means that kmeans clustering has assigned edge tc's with a 2
  	large_near_zero_tc_ICs_flag = 2;
	small_near_zero_tc_ICs_flag = 1;
   else 
	large_near_zero_tc_ICs_flag = 1;
	small_near_zero_tc_ICs_flag = 2;
   end

   large_near_zero_diff_tc_ICs = find(kmeans_clustering(:)==large_near_zero_tc_ICs_flag);
   small_near_zero_diff_tc_ICs = find(kmeans_clustering(:)==small_near_zero_tc_ICs_flag);

   IC.large_near_zero_diff_tc_ICs = large_near_zero_diff_tc_ICs;
   IC.small_near_zero_diff_tc_ICs = small_near_zero_diff_tc_ICs;

   %clearvars -except IC
   save IC
return; 
 

