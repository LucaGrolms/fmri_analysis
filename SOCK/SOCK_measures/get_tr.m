function TR = get_tr(dir_ICA)

% TR is obtained form a file called "design.fsf" or "log.txt" depending on how Melodic is run (i.e via GUI or command line). These files are saved during the Melodic process. 
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



% First check to see how melodic was run:

gui_flag = melodic_gui(dir_ICA);

% Check to see if the files exists within the ".ica" directory
if gui_flag == 0

	log_file_exist = exist('log.txt');
	if (log_file_exist==0)
		prompt = 'No TR is found. Please enter the TR (e.g 3.0, 3.2):';
		TR = input(prompt);
	else
		!grep "tr=" log.txt>tr.txt
		all_data = importdata('tr.txt');
	 	delete tr.txt	
		% Does the log.txt file have a TR value?
		k = findstr(all_data{:}, 'tr=');
		TR = str2num(all_data{1}(k+3:k+5));
	end
else
	design_file_exist = exist('design.fsf');

	if (design_file_exist==0)
		prompt = 'No TR is found. Please enter the TR (e.g 3.0, 3.2):';
		TR = input(prompt);
	else
		!grep -A1 "TR" design.fsf>tr.txt
		all_data = importdata('tr.txt');
	 	delete tr.txt	
	% Does the design.fsf file have a TR value?
		if(isstruct(all_data))
			TR = all_data.data;
		else
			prompt = 'No TR is found. Please enter the TR (e.g 3.0, 3.2):';
			TR = input(prompt);
		end
	end
end

try TR(1); catch
	TR = 3.0; 
	display(sprintf('WARNING: TR not found: assuming %f seconds, in SOCK/SOCK_measures/get_tr.m \n',TR));
end

TR
return; 
 

