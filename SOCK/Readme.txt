% SOCK
% Copyright (C) 2012-2018 The Florey Institute of 
%        Neuroscience and Mental Health, Melbourne, Australia
% _______________________________________________________________________
%
% Please refer to this version as the
% "SOCK v1.4" in papers and communications, and please cite 
% the following papers where the algorithm is described in detail:
%
% Bhaganagarapu K, Jackson GD and Abbott DF (2013). 
% An automated method for identifying artifact in ICA of resting-state fMRI. 
% Front. Hum. Neurosci. 7:343. 
% http://dx.doi.org/10.3389/fnhum.2013.00343
%
% If you use SOCK to derive a denoised data set for subsequent 
% analysis, please also cite:
%
% Bhaganagarapu K, Jackson GD, Abbott DF (2014).
% De-noising with a SOCK can improve the performance of event-related ICA. 
% Frontiers in Neuroscience 8(285):1-9 (2014).
% http://dx.doi.org/10.3389/fnins.2014.00285 
%
% Created: 6 November 2012
% Creator: Kaushik Bhaganagarapu
% Contributor: David Abbott (dfa)
% Last modified: 25 September 2018
%
% Please send any feedback, requests and bug reports to SOCK@brain.org.au
%
%
% _______________________________________________________________________
% Software Requirements:
%
% Matlab R2010b or later
% SPM 8 or 12
% FSL 4 or 5           
%
% _______________________________________________________________________
% Installation: 
% 
% 1.	Copy the SOCK folder (after uncompressing it) and store it in your 
%	home folder (or another location if you prefer, and change the path 
%	listed below accordingly)   
%
% 2. 	Open Matlab and put the SOCK directory into your Matlab path: 
%	addpath(genpath('~/SOCK'))
%
% _______________________________________________________________________
% Usage:
%
% You can use SOCK as a noise filter in a completely automated pipeline
% by running batch_SOCK in Matlab. This will perform an ICA, 
% SOCK classification and regression of artifacts. See batch_SOCK.m for
% usage instructions.
%
% Alternatively, if you just want to use SOCK to classify an ICA:
%
% 1. 	Run Melodic (with full stats option) to generate ICA results. 
%	SOCK accepts the Melodic results run via both the Melodic GUI or 
%	the command line.
%
% 2. 	To run SOCK, type in "SOCK" in Matlab.
%
% 3. 	Select:
%		(a) the melodic directory that contains the ICA 
% 		results (for one subject).
%
%		(b) or a .txt file which contains the Melodic 
% 		directories (for multiple subjects). 
%	
% 	See "example_study_list.txt" in the SOCK folder for an example. 
%	Note that it will look for a folder called "melodic.ica" in each 
% 	subjects folder (i.e. "subjectX").
% 
% 4. 	Once complete, the information will be saved in the Matlab structure named "IC".
%
% 5. 	Type "IC.artifacts" to list the ICs which SOCK classified as definite artifact.
%
% 6. 	Type "IC.non_artifacts" to list the ICs which SOCK classified as non artifacts. 
% 
% 7.	For more granularity, you may also examine IC.cat: This array lists a 
%	category number for each component: 3=definite artifact, 2=possible artifact,
% 	and 1=unlikely artifact.
%
% Notes: IC.help gives an overview of the all the elements in the structure "IC". 
% Please refer to this for further information.
%
%
%
% _______________________________________________________________________
% Troubleshooting:
%
% If SOCK fails, below are some common sources of error:
%
% 1. 	Check SPM path as it's installed in different locations on different computers. 
%	If it's different, please change it accordingly in SOCK.m (line 8).
%
% 2. 	SOCK assumes that it is installed in your home folder. 
%	If it is different, please change it accordingly in SOCK.m (line 9).
%
% 3. 	Certain errors might result if the SOCK directory is not present in the Matlab path. 
%	Please double check this by outputting the variable "path" in Matlab and 
%	observing whether the SOCK directory is included.
% 
% 4. 	Do not leave spaces in folder names (i.e do not use "REST Controls". 
%	Rename the folder "REST_Controls").
%
% 5.	If the IC categorisation is not as expected, please check that SPM 
%	has correctly generated the CSF and edge masks. These files are 
%	located in the "melodic.ica" directory for subject of interest. 
%	Users can utilise custom CSF and edge masks, by renaming the CSF 
%	and edge masks accordingly (both the .img and .hdr files):
%
% 	"CSF_mask_fsl.img"
% 	"CSF_mask_fsl.hdr"
%
%	"all_edge_mask.img"
%	"all_edge_mask.hdr"
%
% 	The renamed files need to be copied into the "melodic.ica" directory 
%	for subject of interest. 
%
% 6.	Please note that SOCK executes FSL commands in standard form. 
%	That is, to run "fslmaths", the command "fslmaths" is used. 
%	On some computers FSL is installed differently. Please make 
%	sure that prior to running SOCK you use a symbolic link to 
%	map the fsl commands to the standard ones. For example, if 
%	you have to type fsl5.0-Melodic to run Melodic, use the 
%	following "sudo ln -s /usr/bin/fsl5.0-Melodic /usr/bin/Melodic". 
%	This needs to be done for:
%
% 		(a) fslmaths
% 		(b) fslchfiletype
%
% 7. 	Due to the FSL library path, you might obtain the following errors:
%
% 	fslmaths: /opt/MatlabR2010bSP1/sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by fslmaths)
% 	fslmaths: /opt/MatlabR2010bSP1/sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by /usr/lib/fsl/5.0/libnewimage.so)
%
% 	To rectify this, you will need to amend the Unix command in pre-sock folder. 
%	See sai_unix.m file for details.
%
% 8. 	Check to see if the temporal filtering has been done on the data. 
%	If it has, set "temporal_filtering" to ZERO (line 12 in SOCK_classify.m). 
%	Otherwise, SOCK may incorrectly use the temporal criteria.
%
%
% _______________________________________________________________________
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
%% Acknowledgments: 
%
% Files in the fMRIstat folder were developed by the late Keith Worsley
% and others and the copyright notices in those source files also apply
% (see also http://software.incf.org/software/fmristat ). Image files in
% the SPM_priors folder were derived from templates extracted from the
% SPM8 software package. The SPM8 software package was developed by 
% members and collaborators of the Wellcome Trust Centre for Neuroimaging
% and is distributed under the terms of the GNU General Public License; 
% it is available at http://www.fil.ion.ucl.ac.uk/spm/software/spm8
%
% We acknowledge the Australian Government for a postgraduate training
% scholarship for Kaushik Bhaganagarapu and, via the Australian 
% National Imaging Facility (a National Collaborative Research 
% Infrastructure Strategy (NCRIS) capability), for fellowship funding
% for David Abbott.
% The Florey Institute of Neuroscience and Mental Health also 
% acknowledges support from the Victorian Government and in particular
% the funding from the Operational Infrastructure Support Grant.
%
