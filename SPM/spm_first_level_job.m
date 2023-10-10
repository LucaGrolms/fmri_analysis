
function spm_first_level_job(run, path_results, session_scan, path_conditions)

% matlabbatch structur for input values to run the SPM First Level Analysis
% This script use the condition files (normal and modified). The relevant
% path will be hand over by "path_conditions"
% Within "session_sans all" session scan files for a specific subject are
% defined
% "path_results" define the place were the First Level Analysis residuens
% are take place

disp(['Result folder:', path_results]);
disp(['Used conditation file:', path_conditions]);

%Set the result path for all result files
matlabbatch{1}.spm.stats.fmri_spec.dir = {path_results};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
%Set the amount and the location of the denoised subjet scans
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = session_scan;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
%Set the conditions that should be used for the spm run
% matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = conditions.names;
% matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = conditions.onsets;
% matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = conditions.durations;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {path_conditions};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%Save the current matlabbatch parameters to the subject SPM result folder
batch_file_name = fullfile(path_results,'fl_matlabbatch.mat');
save ( batch_file_name, 'matlabbatch') ;

%Start the SPM First Level run with the specific scans and conditions
spm('defaults','FMRI');
spm_jobman('initcfg');
spm_jobman ('run', matlabbatch,'');

%To be save, clear the matlabbatch workspace for the next possible run
clear matlabbatch;

return;
