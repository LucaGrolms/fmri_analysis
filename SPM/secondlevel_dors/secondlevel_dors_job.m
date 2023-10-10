function secondlevel_dors_job (Result_Folder, group1, group2)
%-----------------------------------------------------------------------
% matlabbatch parameter for dedicated DoRs
% 1. Specify 2nd-level run
% 2. Estimate
% 3. Contrast definition
%    Result Report with thresholds
%-----------------------------------------------------------------------

spm('defaults', 'fmri');
spm_jobman('initcfg');
SPM_Result_File = fullfile (Result_Folder,'SPM.mat');

% Clear matlabbatch for the next DoR Variant run
clear matlabbatch;



        %========================================================================
        % Part Specify 2nd-level
        %========================================================================
        matlabbatch{1}.spm.stats.factorial_design.dir = {Result_Folder};
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = group1;                                                                 
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = group2;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 2;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;

        matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [3
                                                              3
                                                              3];
        matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'covar1';
        matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [4
                                                              4
                                                              4];
        matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'covar2';
        matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
 

     
        %========================================================================
        % Part Estimate
        %========================================================================
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {SPM_Result_File};
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

        

        %========================================================================
        % Part Results Reporting
        %========================================================================
        matlabbatch{3}.spm.stats.con.spmmat = {SPM_Result_File};
        
        % Define t-contrast G > P and G < P
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'G > P';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'G < P';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = ' VAR > 0';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 1];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;
         
        % Define threshold and voxels

        matlabbatch{4}.spm.stats.results.spmmat = {SPM_Result_File};
        matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
        matlabbatch{4}.spm.stats.results.conspec.contrasts = [1 2 3];
        matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
        matlabbatch{4}.spm.stats.results.conspec.thresh = 0.005;
        matlabbatch{4}.spm.stats.results.conspec.extent = 50;
        matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
        matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
        matlabbatch{4}.spm.stats.results.units = 1;
        matlabbatch{4}.spm.stats.results.export{1}.ps = true;
        matlabbatch{4}.spm.stats.results.print = 'csv';

spm_jobman('run', matlabbatch,' ');

return;

