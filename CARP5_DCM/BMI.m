% bsxiong@mail.bnu.edu.cn 2019-02-01
clear;clc;

dcm_dir1 = '.../Result_IndividualStats/';
dcm_dir2 = '/fmri/stats_spm12/WM/stats_spm12_swcar/';
dcm_dir3 = '.../DCM_mod_2m_11d';   % VOI & DCM                
bmi_dir1 = '.../BMI';
bmi_dir2 = '.../DCM_mod_2m_11d';   % VOI & DCM                
bmi_dir3 = {'all';'blt';'nrm'};
bmi_dir4 = {'FFX';'RFX'};
bma_chos = {'fWin';'mAll'};

[~,~,raw] = xlsread('.xls','','','basic');
sub_lists = {raw(1:52,3);raw(1:28,3);raw(29:52,3)};   % all; blt; nrm      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm('Defaults','fMRI');
spm_jobman('initcfg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------------------------------
% Job saved on 20-Mar-2019 11:54:08 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
for ibd3 = 1:length(bmi_dir3)
    sub_list = sub_lists{ibd3};
    for ibd4 = 1:length(bmi_dir4)
        for ibma = 1:length(bma_chos)
            bmi_dir = fullfile(bmi_dir1,bmi_dir2,[
                bma_chos{ibma},'_'...
                bmi_dir4{ibd4}],...
                bmi_dir3{ibd3});
            mkdir(bmi_dir); cd(bmi_dir);
            %% SPM > Batch > BMS > Model Inference
            % -----------------------------------------------------------------
            clear matlabbatch
            matlabbatch{1}.spm.dcm.bms.inference.dir = {bmi_dir};
            for isub = 1:length(sub_list)
                year_id  = ['20' sub_list{isub}(1:2)];
                dcm_dir  = fullfile(dcm_dir1,year_id,sub_list{isub},dcm_dir2,dcm_dir3);
                matlabbatch{1}.spm.dcm.bms.inference.sess_dcm{isub}.dcmmat = {
                    fullfile(dcm_dir,'m00_d01.mat')
                    fullfile(dcm_dir,'m00_d10.mat')
                    fullfile(dcm_dir,'m00_d11.mat')
                    fullfile(dcm_dir,'m01_d01.mat')
                    fullfile(dcm_dir,'m01_d10.mat')
                    fullfile(dcm_dir,'m01_d11.mat')
                    fullfile(dcm_dir,'m10_d01.mat')
                    fullfile(dcm_dir,'m10_d10.mat')
                    fullfile(dcm_dir,'m10_d11.mat')
                    fullfile(dcm_dir,'m11_d01.mat')
                    fullfile(dcm_dir,'m11_d10.mat')
                    fullfile(dcm_dir,'m11_d11.mat')};
            end
            matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
            matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
            matlabbatch{1}.spm.dcm.bms.inference.method = bmi_dir4{ibd4};
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_name   = 'f1';
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_models = [1 2 3];
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_name   = 'f2';
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_models = [4 5 6];
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_name   = 'f3';
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_models = [7 8 9];
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(4).family_name   = 'f4';
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(4).family_models = [10 11 12];
            % Choose from:
            % * Winning family: bma_famwin = 'famwin'; 
            % * All families:   bma_all    = 'famwin'; 
            % * Enter family:   bma_part   = [f_index];
            if strcmp(bma_chos{ibma},'fWin') == 1
                matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_famwin = 'famwin';
            elseif strcmp(bma_chos{ibma},'mAll') == 1
                matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_all    = 'famwin';
            end
            matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;
            %% Save and run batch
            % -----------------------------------------------------------------
            save batch matlabbatch;
            spm_jobman('run',matlabbatch);
            disp(['---------- ',fullfile([
                bma_chos{ibma},'_',...
                bmi_dir3{ibd3},'_',...
                bmi_dir4{ibd4}]),' Done! ----------']);
        end
    end
end