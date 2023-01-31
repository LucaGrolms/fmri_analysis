function [IC, ps_matrix, TR] = ps_measure(IC, dir_ICA)

% This function extracts the power spectrum values from the Melodic analysis and stores them in the IC structure.
%
% Output:
%
% ps_matrix = A matrix containing the power spectrum information for each IC
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
%	2012-2013: Original version by Kaushik Bhaganagarapu

   
   % Get the TR for the study to use for the PS calc.	
   TR = get_tr(dir_ICA);
   IC.TR = TR;

   gui_flag = melodic_gui(dir_ICA);

   % cd into the directory where the power spectrum files live.
   if gui_flag == 0
   	ps_dir = fullfile(dir_ICA, 'report');
   else
	ps_dir = fullfile(dir_ICA, 'filtered_func_data.ica','report');
   end
   
   cd(ps_dir)

   % No. of vols = length of time course data (used in generating the domain for the ps clustering)
   tc_data = textread('t1.txt');
   IC.vols = length(tc_data);


   ps_files = dir('f*.txt');
   %tc_files = dir('t*.txt');
   no_ics = length(ps_files);

   % Where to store the correlation coeff. of the ICs
   ps_matrix_coeff = ones(no_ics,no_ics);
   %tc_matrix_coeff = ones(no_ics,no_ics);

   for i=1:no_ics

	%filename = strcat('t', num2str(i), '.txt');
	filename = strcat('f', num2str(i), '.txt');
	temp = textread(filename);

	if i==1
		%tc_matrix = ones(length(temp), no_ics); % Create matrix to store all the power specturm values
		ps_matrix = ones(length(temp), no_ics); % Create matrix to store all the power specturm values
	end
	%tc_matrix(:,i) = temp(:,1);
	ps_matrix(:,i) = temp(:,1);
   end

   IC.ps_matrix = ps_matrix; % Save ps_matrix in the IC structure

   %tc_matrix_coeff = corr(tc_matrix);
   ps_matrix_coeff = corr(ps_matrix);

   for i=1:no_ics
   	%temp = sort(abs(tc_matrix_coeff(:,i)));
   	temp = sort(abs(ps_matrix_coeff(:,i)));
	temp = temp(end-1);

	%tc_corr(i) = find(abs(tc_matrix_coeff(:,i)) == temp);
	IC.corr(i) = find(abs(ps_matrix_coeff(:,i)) == temp);
   end
   
   cd(dir_ICA)
   save IC
return; 
 

