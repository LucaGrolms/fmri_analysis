%
%  bri_read_4D_vol  - read in a 4D analyze volume
%
%  [V, v] = bri_read_4D_vol(filename)
%
%   V                       - volume structures
%   v                       - the actual image data
%   filename [optional]     - filename
%
% _______________________________________________________________________
% Copyright (C) 2012-2013, 2015 The Florey Institute of 
%    Neuroscience and Mental Health, Melbourne, Australia
%
% Coded by Richard Masterton
%
% This file is included with the SOCK software package. 
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

%	2015-06-22: dfa improved logic to support SPM2 and later (incl. SPM5, 8 and 12) 
%	2012-2013: Original version by Richard Masterton (supported spm2 and spm8 only)


function [V, v] = bri_read_4D_vol(filename)

    %spm_defaults;
    %global defaults;
    spm('defaults','fmri');

    try
        V = spm_vol(filename);
    catch
        spm_ver = spm('ver');

	if strcmp(spm_ver, 'SPM2') == 1
		filename = spm_get(1, '*IMAGE', 'Select 4D image');
	else
		filename = spm_select(1, '*IMAGE', 'Select 4D image');
        end

	V = spm_vol(filename);
    end

    if (nargout > 1)
        v = zeros(V.private.hdr.dime.dim(2:5));
    end
   
spm_ver = spm('ver');

if strcmp(spm_ver, 'SPM2') == 1 
    for i = 1:V.private.hdr.dime.dim(5)

        V(i) = spm_vol([filename ',' num2str(i)]);

        if (nargout > 1)
            v(:,:,:,i) = spm_read_vols(V(i));
        end

    end
end
return
