function gui_flag = melodic_gui(dir_ICA)

% Input: dir_ICA = The directory path to where the ICA results live
%
% Output: gui_flag = A flag that takes 1 (if melodic is run via GUI) or 0 (if melodic is run via terminal mode)
% _______________________________________________________________________
% Copyright (C) 2012-2013 The Florey Institute of 
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

 
   tmpdir = pwd;
   
   cd(dir_ICA)

   folder_exist = dir('filtered_func_data.ica');

   if length(folder_exist) == 0 %i.e. Melodic is run via terminal mode
	   gui_flag = 0;
   else
	   gui_flag = 1;
   end

return;  
