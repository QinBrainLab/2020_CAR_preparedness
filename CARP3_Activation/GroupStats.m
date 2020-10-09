clear; clc;
restoredefaultpath; 
addpath(genpath('.../spm12'));
% -----------------------------------------------------------------------
datadir1 = '.../Result_IndividualStats';   % 
datadir2 = '/fmri/stats_spm12/WM/stats_spm12_swcar';
[~,~,raw] = xlsread('.xls','','','basic');   % 
subid     =          raw(:,3);
CAR       = cell2mat(raw(:,4));
ACC0      = cell2mat(raw(:,7));
ACC2      = cell2mat(raw(:,8));
for a = 1:52
    year_fd = ['20' subid{a}(1:2)];
    c1{a,1} = fullfile(datadir1, year_fd, subid{a}, datadir2, 'con_0001.nii,1');   % 0
    c2{a,1} = fullfile(datadir1, year_fd, subid{a}, datadir2, 'con_0002.nii,1');   % 2
    c3{a,1} = fullfile(datadir1, year_fd, subid{a}, datadir2, 'con_0003.nii,1');   % 2vs0
end
for i = 1:28
    year_fd = ['20' subid{i}(1:2)];
    g1c1{i,1} = fullfile(datadir1, year_fd, subid{i}, datadir2, 'con_0001.nii,1');   % L 0
    g1c2{i,1} = fullfile(datadir1, year_fd, subid{i}, datadir2, 'con_0002.nii,1');   % L 2
    g1c3{i,1} = fullfile(datadir1, year_fd, subid{i}, datadir2, 'con_0003.nii,1');   % L 2vs0
end
for j = 1:24
    year_fd = ['20' subid{i+j}(1:2)];
    g2c1{j,1} = fullfile(datadir1, year_fd, subid{i+j}, datadir2, 'con_0001.nii,1');   % H 0
    g2c2{j,1} = fullfile(datadir1, year_fd, subid{i+j}, datadir2, 'con_0002.nii,1');   % H 2
    g2c3{j,1} = fullfile(datadir1, year_fd, subid{i+j}, datadir2, 'con_0003.nii,1');   % H 2vs0
end
% -----------------------------------------------------------------------
% Job saved on 30-Sep-2017 22:43:00 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
% -----------------------------------------------------------------------CHSWM_GroupStats_ACT_FF_02
spm_jobman('initcfg');
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {'.../GroupStats_FF_02'};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'groups';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'nback';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans  = g1c1;   % L 0
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans  = g1c2;   % L 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans  = g2c1;   % H 0
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans  = g2c2;   % H 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File',...
		substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch);
clear matlabbatch;
% -----------------------------------------------------------------------MR_20
spm_jobman('initcfg');
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {'.../MR_20'};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans  = c3;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = CAR;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = 'CAR';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File',...
		substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch);
% -----------------------------------------------------------------------PT_02
spm_jobman('initcfg');
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {'.../PT_02'};
for p = 1:a
    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(p).scans = {c1{p,1};c2{p,1}};
end
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File',...
		substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch);