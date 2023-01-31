% _______________________________________________________________________
% Copyright (C) 2012-2013,2015,2017-18 The Florey Institute of 
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

%	2018-09-25 (dfa): fixed unreliable path construction (use fullfile,
%			not strcat): Previously might have trouble finding
%			mean.img if running SOCK from the GUI for an  
%			existing MELODIC ICA folder.
%	2017-05-26 (dfa): improved code to locate SPM's 'TPM.nii' file
%			(so it does not have to be in the Matlab path)
%	2015-06-16 (dfa): changed from ANALYZE to NIFTI_PAIR
%	2012-2013: Original version by Kaushik Bhaganagarapu

% List of open inputs

spm('defaults', 'FMRI');
spm_jobman('initcfg');

load dir_ICA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine whether melodic was run via GUI or on command line
gui_flag = melodic_gui(dir_ICA);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert mean functional image to desired format
convert_NIFTI_to_PAIR_mean_functional(dir_ICA, gui_flag);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% customize "job" structure for this particular subject
if gui_flag == 0
	vols = fullfile(dir_ICA, 'mean.img');
else
	vols = fullfile(dir_ICA, 'mean_func.img');
end

tpm =  fullfile(spm('Dir'),'tpm','TPM.nii'); % normal location for SPM12
if ~exist(tpm, 'file')
  tpm =  fullfile(spm('Dir'),'toolbox','Seg','TPM.nii'); % normal location for SPM8
  if ~exist(tpm, 'file')
    tpm = which('TPM.nii'); % look anywhere in current matlab path
    if ~exist(tpm, 'file')
	error('Unable to locate SPM''s tissue probability map ''TPM.nii'' ')
    end
  end
end

loc_SOCK = which('SOCK.m');
[pathstr_SOCK] = fileparts(loc_SOCK);

% Define the structure to pass onto SPM's "New Segmentation" tool
matlabbatch{1}.spm.tools.preproc8.channel.vols = {vols};
matlabbatch{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{1}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).tpm = {strcat(tpm,',1')};
matlabbatch{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(1).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).tpm = {strcat(tpm,',2')};
matlabbatch{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(2).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).tpm = {strcat(fullfile(pathstr_SOCK,'SPM_priors','CSF_mask_thresh.img'),',1')};
matlabbatch{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).tpm = {strcat(tpm,',4')};
matlabbatch{1}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{1}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).tpm = {strcat(tpm,',5')};
matlabbatch{1}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{1}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).tpm = {strcat(tpm,',6')};
matlabbatch{1}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{1}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{1}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{1}.spm.tools.preproc8.warp.write = [0 0];

spm_jobman('serial', matlabbatch);
