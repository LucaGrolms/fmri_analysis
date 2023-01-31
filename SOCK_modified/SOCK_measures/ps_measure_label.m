function [IC] = ps_measure_label(IC, ps_matrix, TR)

% This function clusters based on kmeans whether an IC has high or low temporal frequency. 
%
% Output:
%
% IC = The IC structure which contains all the details of the classification of IC's after running SOCK. Afther this function, structure IC is filled with above the PS measure.
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
%
% History: 
%	2015-02-09: dfa fixed missing transpose of sum_ps_matrix when passed 
%	  to kmeans() that caused crash on Matlab 2014a. Prior versions of 
%         Matlab gracefully dealt with this and produced the correct answer.
%	2012-2013: Original version by Kaushik Bhaganagarapu

   
   size_ps_matrix = size(ps_matrix);
   step_size = 1/(TR*IC.vols);
   tmp_domain = 0:step_size:(size_ps_matrix*step_size);

   % look for frequencies between 0.01-0.08Hz
   freq_range = find(tmp_domain(:)>=0.01 & tmp_domain(:)<=0.08);
   
   % Sum up all freq's beyond 0.08 HZ (i.e. high freq noise)
   sum_ps_matrix = sum(ps_matrix(freq_range(end):end,:));
   
   % Sum up all freq's between 0.01-0.08 HZ (i.e. plausible activity according to the HRF)
   %sum_ps_matrix = sum(ps_matrix(freq_range,:));

   [kmeans_clustering, C] = kmeans(sum_ps_matrix', 2, 'replicates', 1000);
   
   mean1 = mean(sum_ps_matrix(kmeans_clustering(:)==1));
   mean2 = mean(sum_ps_matrix(kmeans_clustering(:)==2)); 

   if mean2 > mean1
	switch_ps_measure = 1; % This means that kmeans clustering has assigned high ps_measure with a 2
  	high_ps_ICs_flag = 2;
	low_ps_ICs_flag = 1;
   else 
	switch_ps_measure = 0;
	high_ps_ICs_flag = 1;
	low_ps_ICs_flag = 2;
   end

   high_ps_measure_ICs = find(kmeans_clustering(:)==high_ps_ICs_flag);
   low_ps_measure_ICs = find(kmeans_clustering(:)==low_ps_ICs_flag);

   IC.high_freq_noise_ICs = high_ps_measure_ICs;
   
   IC.high_freq_non_noise_ICs = low_ps_measure_ICs;

   % Create a variable that caters for IC's which have a PS sum slighter higher than the cluter splitting threshold.
   % These ICs might be interesting to look.

   cluster_split_val = (C(1)+C(2))/2;
   j = 1;
   
   for i=1:size_ps_matrix(2)
   	if(sum_ps_matrix(i)>cluster_split_val & sum_ps_matrix(i)<cluster_split_val*1.10)
		maybe_high_freq_non_noise_ICs(j) = i;
		j = j + 1;
	end
   end

   if (j==1)
	maybe_high_freq_non_noise_ICs = [];
   end
   % Include these ICs in the Non noise IC's structure 
   IC.high_freq_non_noise_ICs = [low_ps_measure_ICs', maybe_high_freq_non_noise_ICs];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Repeat the above for low freq noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   clear sum_ps_matrix
   % Sum up all freq's below 0.01 Hz (i.e. low freq noise)
   sum_ps_matrix = sum(ps_matrix(1:freq_range(1),:));

   kmeans_clustering = kmeans(sum_ps_matrix', 2, 'replicates', 1000);
   
   mean1 = mean(sum_ps_matrix(kmeans_clustering(:)==1));
   mean2 = mean(sum_ps_matrix(kmeans_clustering(:)==2)); 

   if mean2 > mean1
	switch_ps_measure = 1; % This means that kmeans clustering has assigned high ps_measure with a 2
  	high_ps_ICs_flag = 2;
	low_ps_ICs_flag = 1;
   else 
	switch_ps_measure = 0;
	high_ps_ICs_flag = 1;
	low_ps_ICs_flag = 2;
   end

   high_ps_measure_ICs = find(kmeans_clustering(:)==high_ps_ICs_flag);
   low_ps_measure_ICs = find(kmeans_clustering(:)==low_ps_ICs_flag);

   IC.low_freq_noise_ICs = high_ps_measure_ICs;
   
   IC.low_freq_non_noise_ICs = low_ps_measure_ICs;

   %clearvars -except IC
   save IC
return; 
 

