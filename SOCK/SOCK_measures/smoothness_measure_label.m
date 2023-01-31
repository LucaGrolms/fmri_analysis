function [IC] = smoothness_measure_label(IC, dir_ICA, smoothness_measure)
% This function clusters ICs into smooth, subsmooth and unsmooth categories based on k-means clustering for ratio (high vs low refreuency) vs radius curves. 
%
% Inputs:
%
% IC = A structure containg all the details of the classification of IC's after running SOCK. 
%
% dir_ICA = the ICA directory (i.e. the path to the melodic.ica directory).
%
% smoothness_measure = A matrix containing value of smoothness measure for each IC over a range of radius values specified below.
%
% Output:
%
% IC = A structure containg all the details of the classification of IC's after running SOCK. Afther this function, structure IC is filled with above measure.
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Cluster the ICs into "smooth" and "unsmooth" clusters

   size_smoothness_measure = size(smoothness_measure);
   no_ics = size_smoothness_measure(2);
  
   smoothness_flag = zeros(no_ics, 1);
 
   [idx, C] = kmeans(smoothness_measure(end,:)', 2, 'replicates', 1000); 
   mean1 = mean( mean((smoothness_measure(:, idx==1))) );
   mean2 = mean( mean((smoothness_measure(:, idx==2))) );

   if mean2 > mean1
	smooth_switch = 1;
   else 
	smooth_switch = 0;
   end

   smoothness_flag = idx;	% The flag which indicates whether an IC is smooth (2) or unsmooth (1).

   for i=1:no_ics
	IC.smooth(i) = smoothness_flag(i);
   end

   IC.smoothswitch = smooth_switch;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Kmeans to split smooth, subsmooth and unsmooth ICs

   if IC.smoothswitch == 1
	smooth = 2;
	unsmooth = 1;
   else
	smooth = 1;
	unsmooth = 2;
   end

     cluster_split_val = (C(1)+C(2))/2;
   j = 1;
  
   clear maybe_smooth_ICs 
   for i=1:no_ics
   	if(smoothness_measure(end,i)<cluster_split_val & smoothness_measure(end,i)>cluster_split_val*0.90)
		maybe_smooth_ICs(j) = i;
		j = j + 1;
	end
   end

   if (j==1)
	maybe_smooth_ICs = [];
   end
maybe_smooth_ICs';

% Add the maybe_smooth_ICs to the smooth ICs array
IC.smooth(maybe_smooth_ICs) = smooth;

%%%%% Smooth ICs %%%%%%
smooth_ICs = find(IC.smooth(:)==smooth)';
IC.smooth_ICs = smooth_ICs;
if(length(IC.smooth_ICs)==1)
	IC.smooth_ICs = [IC.smooth_ICs,0];
end			

%%%%% unsmooth ICs %%%%%%
unsmooth_ICs = find(IC.smooth(:)==unsmooth)'; 
IC.unsmooth_ICs = unsmooth_ICs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub Script for creating the subsmooth category

[idx_unsmooth, C_subsmooth] = kmeans(smoothness_measure(end,IC.smooth(:)==unsmooth)', 2, 'replicates', 1000);

mean1 = mean( mean((smoothness_measure(:, unsmooth_ICs(idx_unsmooth==1)))) );
mean2 = mean( mean((smoothness_measure(:, unsmooth_ICs(idx_unsmooth==2)))) );

if mean2 > mean1
smooth_switch_for_unsmooth_ICs = 1;
else
smooth_switch_for_unsmooth_ICs = 0;
end

if smooth_switch_for_unsmooth_ICs == 1
	smooth_for_unsmooth_ICs = 2;
	unsmooth_for_unsmooth_ICs = 1;
else
	smooth_for_unsmooth_ICs = 1;
	unsmooth_for_unsmooth_ICs = 2;
end

subsmooth_ICs = unsmooth_ICs(idx_unsmooth(:) == smooth_for_unsmooth_ICs);
% Label all the subsmooth ICs with 3
IC.smooth(subsmooth_ICs) = 3;

% Find those ICs which are on the boarder of the subsmooth and unsmooth boundary and move the ones which are 90% below this boundary into the subsmooth category: This is being ultra conserative

cluster_split_val_subsmooth = (C_subsmooth(1)+C_subsmooth(2))/2;
j = 1;
  
clear maybe_subsmooth_ICs 
   
for i=1:no_ics
	if(smoothness_measure(end,i)<cluster_split_val_subsmooth & smoothness_measure(end,i)>cluster_split_val_subsmooth*0.90)
		maybe_subsmooth_ICs(j) = i;
		j = j + 1;
	end
end

if (j==1)
	maybe_subsmooth_ICs = [];
end

% Add the maybe_smooth_ICs to the smooth ICs array
IC.smooth(maybe_subsmooth_ICs) = 3;

%%%%% Subsmooth ICs %%%%%%
IC.subsmooth_ICs = find(IC.smooth(:) == 3);

%if(length(IC.subsmooth_ICs)==1)
%	IC.subsmooth_ICs = [IC.subsmooth_ICs,0];
%end


%%%%% Unsmooth ICs %%%%%%
unsmooth_ICs = find(IC.smooth(:) == unsmooth);
IC.unsmooth_ICs = unsmooth_ICs;

%if(length(IC.unsmooth_ICs)==1)
%	IC.unsmooth_ICs = [IC.unsmooth_ICs,0];
%end

%%%%% End Script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save IC structure
cd(dir_ICA)
save IC
return;  
