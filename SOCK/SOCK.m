
function SOCK(varargin)

% Interactive usage: SOCK
% or if you want to run SOCK in a batch script: SOCK(subject_melodic_dir);
% e.g. SOCK('melodic_dir.ica');
% also support calls from batch_SOCK as: SOCK('batch_SOCK',fullfile(loc,name_melodic_dir));
%
% Use this function to run SOCK on an ICA
% _______________________________________________________________________
% Copyright (C) 2012-2017 The Florey Institute of 
%    Neuroscience and Mental Health, Melbourne, Australia
%
% Coded by Kaushik Bhaganagarapu
%
% Please refer to the following for a description of the
% methods implemented in the SOCK software. If you publish 
% results using these methods or variations of them, please cite 
% this paper: 
%
%  Bhaganagarapu K, Jackson GD and Abbott DF (2013). 
%  An automated method for identifying artifact in ICA of resting-state fMRI. 
%  Front. Hum. Neurosci. 7:343. 
%  doi: 10.3389/fnhum.2013.00343
%
% If you use SOCK as a filter, please also cite:
% Bhaganagarapu K, Jackson GD, Abbott DF. (2014)
% De-noising with a SOCK can improve the performance of event-related ICA. 
% Frontiers in Neuroscience 8(285):1-9
% doi:10.3389/fnins.2014.00285.
%
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
% History: 
%	2017-02-03: dfa: Improved portability by removing the fixed 
% 		subfolder name that was set in this script and appended to
%		each subject's supplied folder name. Thus it is now the
%		responsibility of the caller to provide the pathname of
%		the subject's Melodic directory, rather than the pathname
%		of the parent of that folder. This is done either by direct
%		argument, selection, or in the studylist file. Studylist 
%		files created for legacy SOCK versions may 
%		need to be altered, usually by appending '/swa_all.ica' to 
%		the specified file paths.
%	2015-06-22: dfa: don't addpath a genpath of SPM folder, to avoid 
%		incompatible randsample from fieldtrip toolbox of SPM12;
%		the spm('defaults','fmri') line should be enough.
%		Determine SOCK path from location of the present function
%		rather than hard-coding a path.
%	2015-06-16: dfa added support for latest batch_SOCK
%	2015-02-10: dfa changed location of temporary files. It is now 
%		a uniquely named temporary folder within the operating
%		system's usual location for temporary files. The SOCK
%		temporary folder is removed when SOCK finishes 
%		(unless SOCK crashes!). Multiple instances of SOCK
%		should now be able to run without interference as they
%		will each have unique temporary folder names.
%	2012-2013: Original version by Kaushik Bhaganagarapu


% Set SPM settings and add SOCK path to the Matlab path
%path_SPM = fileparts(which('SPM')); 
%addpath(genpath(path_SPM))
%addpath(genpath('~/SOCK'))

addpath(genpath(fileparts(which('SOCK')))); %Add subfolders of SOCK to matlab path

spm('defaults','fmri'); % Initialise with standard defaults

% Store the current working directory
tmp_dir = pwd;

% Make a spot to store temporary files
SOCK_dir = [ tempname() '_SOCK' ];
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(SOCK_dir);
if SUCCESS == 0
   		disp(['Error: Unable to make SOCK temporary directory: ' SOCK_dir]);
		if halt_on_error, error('Halting due to error.'); exit; else return; end
else
   		disp(['Made SOCK temporary directory: ' SOCK_dir]);
end


% Allows the user to run SOCK multiple subjects. To use this option you will need to store the file paths.
% See "example_study_list.txt" in the SOCK folder for an example.

if (length(varargin) > 0 ) && (strcmp(varargin(1),'batch_SOCK'))

	batch_flag = 3;

elseif length(varargin) == 1
	batch_flag = 1;

else 
	prompt = 'Do you want to run SOCK on multiple subjects from a subjects.txt file? (1=Yes/2=No):';
	batch_flag = input(prompt);
end

if (batch_flag == 1 ) || (batch_flag == 3),
	
	if (length(varargin) == 1) || (batch_flag == 3)
		if (batch_flag ~= 3) %
			dir_ICA = [char(varargin(1)) '/'];
			batch_flag = 1;
		else %  batch_SOCK has used an argument to let us know it is calling, although it is not presently necessary.
			dir_ICA = [char(varargin(2)) '/'];
			batch_flag = 1;
		end
		SOCK_main(dir_ICA, batch_flag, SOCK_dir) % The main function for calculating IC features
	else
		subjects_dir = spm_select(1,'mat','Select subject''s text file');
		studylist = textread(subjects_dir, '%s');
		num_cols = 1;
		no_sub = length(studylist)/num_cols;
		
		for sub=1:no_sub
			dir_ICA = strcat(studylist{sub}, '/');
			SOCK_main(dir_ICA, batch_flag, SOCK_dir) % The main function for calculating IC features
		end
		disp(sprintf('Type "load IC; IC.artifacts" to obtain the ICs which SOCK classified as artifact...\n'));
		disp(sprintf('OR\n'));
		disp(sprintf('Type "load IC; IC.non_artifacts" to obtain the ICs which SOCK classified as non artifacts...\n'));

	end

	disp(sprintf('Completed SOCK procedure\n'));
	% Clear unwanted variables:
	clearvars -except IC SOCK_dir smoothness_measure
	load IC

elseif (batch_flag == 2)
	dir_ICA = spm_select(1,'dir','Select a SINGLE subject''s ICA directory');
	SOCK_main(dir_ICA, batch_flag, SOCK_dir) % The main function for calculating IC features

	disp(sprintf('Completed SOCK procedure\n'));
	% Clear unwanted variables:
	clearvars -except IC SOCK_dir smoothness_measure
	load IC
	disp(sprintf('Type "load IC; IC.artifacts" to obtain the ICs which SOCK classified as artifact...\n'));
	disp(sprintf('OR\n'));
	disp(sprintf('Type "load IC; IC.non_artifacts" to obtain the ICs which SOCK classified as non artifacts...\n'));

elseif (batch_flag == 4)
 	dir_ICA=strcat(pwd(),'/');
	SOCK_main(dir_ICA, batch_flag, SOCK_dir) % The main function for calculating IC features

	disp(sprintf('Completed SOCK procedure\n'));
	% Clear unwanted variables:
	clearvars -except IC SOCK_dir smoothness_measure
else
	disp(sprintf('Please load SOCK again and enter the correct option...\n'));
end

rmdir(SOCK_dir); % Clean up - remove the temporary directory.

return;  
