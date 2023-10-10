function secondlevel_dors_cov_crf_job (Result_Folder, group1, group2)
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
contrast = 'F';
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
        matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [10
                                                            16
                                                            1
                                                            2
                                                            3
                                                            4
                                                            8
                                                            20
                                                            4
                                                            10
                                                            9
                                                            7
                                                            11
                                                            12
                                                            14
                                                            19
                                                            12
                                                            3
                                                            1
                                                            5
                                                            16
                                                            12
                                                            6
                                                            5
                                                            25
                                                            23
                                                            23
                                                            25
                                                            18
                                                            21
                                                            31
                                                            18
                                                            39
                                                            6
                                                            39
                                                            39
                                                            35
                                                            18
                                                            12
                                                            18
                                                            45
                                                            21
                                                            34
                                                            21
                                                            33
                                                            20
                                                            26
                                                            41];
        matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'crf_asi';
        matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 2;
        matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [0
                                                            7
                                                            1
                                                            2
                                                            1
                                                            0
                                                            4
                                                            1
                                                            3
                                                            2
                                                            3
                                                            0
                                                            0
                                                            0
                                                            5
                                                            3
                                                            3
                                                            0
                                                            3
                                                            0
                                                            6
                                                            6
                                                            4
                                                            0
                                                            23
                                                            13
                                                            13
                                                            1
                                                            5
                                                            10
                                                            22
                                                            3
                                                            28
                                                            4
                                                            15
                                                            28
                                                            5
                                                            17
                                                            8
                                                            4
                                                            22
                                                            13
                                                            14
                                                            17
                                                            3
                                                            8
                                                            1
                                                            27];
        matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'crf_bdi';
        matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 2;
        matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
        
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
        
        % Define t-contrast G > P and G < P and VAR > 0
    if contrast == 'T'
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Con_g1 crf_asi';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 0 1 0 0 0 ];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Con_g2 crf_asi';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';  
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Con_g1 crf_bdi';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Con_g2 crf_bdi';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 0 1];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';     
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Con_g1- crf_asi';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 -1 0 0 0];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Con_g2- crf_asi';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 -1 0 0];
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Con_g1- crf_bdi';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 -1 0];
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none'; 
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Con_g2- crf_bdi';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 -1];
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    else if contrast == 'F'
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'All_Covariates F-Contrast';
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [0 0 1 -1 0 0
                                                                0 0 0 0 1 -1];
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
     end
    end
%         matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = ' VAR > 0';
%         matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 1];
%         matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;
         
        % Define amount of contrasts,threshold and voxels

        matlabbatch{4}.spm.stats.results.spmmat = {SPM_Result_File};
        matlabbatch{4}.spm.stats.results.conspec.titlestr = '2nd-level DoRs';

     if contrast == 'T'
        matlabbatch{4}.spm.stats.results.conspec.contrasts = [1 2 3 4 5 6 7 8];
     else if contrast == 'F'
        matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
     end
     end
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

