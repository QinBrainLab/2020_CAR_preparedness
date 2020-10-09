% bsxiong@mail.bnu.edu.cn 2019-02-01
% ======================================================================= %
clear; clc; clock1 = fix(clock);
dname = sprintf('VOISE_%d%02d%02d_%02d%02d%02.0f.log',clock1);
diary(dname);
disp('------------------------------------------------------------------');
% ======================================================================= %
scr_dir   = pwd;
glm_dir1  = '.../Result_IndividualStats';
glm_dir2  = 'fmri/stats_spm12/WM/stats_spm12_swcar';
roi_dir1  = '.../ROI/';
roi_dir2  = '';   % HPC,PFC
roi_list  = dir(fullfile(roi_dir1,roi_dir2,'*.nii'));
[~,~,raw] = xlsread('.xls','','','basic');
sub_list  = raw(1:60,2);   %                                               
mi_icon   = 2;             %  0/2-back                                     
di_vcon   = [1 1];         %  0 2-back                                     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step0_Con = 0;   fcon_weights = eye(2);                                    
step1_VOI = 0;   voi_adjust   = 4;
step2_DCM = 1;   echo_time    = 0.03;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pfix_mi = num2str(mi_icon);
pfix_di = strrep(num2str(di_vcon),' ','');
spm('Defaults','fMRI');
spm_jobman('initcfg');
for isub = 1:length(sub_list)
    year_fd  = ['20' sub_list{isub}(1:2)];
    spm_dirf = fullfile(glm_dir1,year_fd,sub_list{isub},glm_dir2, 'SPM.mat');
    voi_dirf = fullfile(glm_dir1,year_fd,sub_list{isub},glm_dir2, 'VOI_*.*');
    voi_dir  = fullfile(glm_dir1,year_fd,sub_list{isub},glm_dir2,['VOI_',roi_dir2,'_',num2str(voi_adjust),'a']);
    dcm_dir  = fullfile(voi_dir,['DCM_mod_',pfix_mi,'m_',pfix_di,'d']);
    mkdir(voi_dir); mkdir(dcm_dir);
    %% Step0 SPM > Batch > Stats > Contrast Manager
    if step0_Con == 1
        clear matlabbatch;
        matlabbatch{1}.spm.stats.con.spmmat = cellstr(spm_dirf);
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = fcon_weights;
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = 0;
        spm_jobman('run',matlabbatch);
        disp(['-------',sub_list{isub},'-------step0_Con done-------'])
    end
    %% Step1 SPM > Batch > Util > VOI 
    if step1_VOI == 1
        for iroi = 1:length(roi_list)
            roi_dirf = fullfile([roi_dir1,roi_dir2,'/',roi_list(iroi).name,',1']);
            clear matlabbatch;
            matlabbatch{1}.spm.util.voi.spmmat = cellstr(spm_dirf);
            % Index of F-contrast used to adjust data.
            % Enter '0' for no adjustment.
            % Enter 'NaN' for adjusting for everything.
            matlabbatch{1}.spm.util.voi.adjust = voi_adjust;
            matlabbatch{1}.spm.util.voi.session = 1;
            matlabbatch{1}.spm.util.voi.name = roi_list(iroi).name(1:3);
            matlabbatch{1}.spm.util.voi.roi{1}.mask.image = cellstr(roi_dirf); 
            matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
            matlabbatch{1}.spm.util.voi.expression = 'i1';
            spm_jobman('run',matlabbatch);
        end
        unix(['mv ',voi_dirf,' ',voi_dir]);
        disp(['-------',sub_list{isub},'-------step1_VOI done-------'])
    end
    %% Step2 SPM > DCM > specify & estimate
    if step2_DCM == 1
        clear DCM;
        load(spm_dirf);
        % Load regions of interest
        %------------------------------------------------------------------
        for iroi = 1:length(roi_list)
            load(fullfile(voi_dir,['VOI_',roi_list(iroi).name(1:3),'_1.mat']),'xY');
            DCM.xY(iroi) = xY;
        end
        DCM.n = length(DCM.xY);        % number of regions
        DCM.v = length(DCM.xY(1).u);   % number of time points
        % Time series
        %------------------------------------------------------------------
        DCM.Y.dt = SPM.xY.RT;
        DCM.Y.X0 = DCM.xY(1).X0;
        for iroi = 1:DCM.n
            DCM.Y.y(:,iroi)  = DCM.xY(iroi).u;
            DCM.Y.name{iroi} = DCM.xY(iroi).name;
        end
        DCM.Y.Q = spm_Ce(ones(1,DCM.n)*DCM.v);
        % Experimental inputs
        %------------------------------------------------------------------
        DCM.U.dt    =  SPM.Sess.U(1).dt;
        DCM.U.name  = [SPM.Sess.U.name];
        DCM.U.u     = [               ];   % input spec > include#
        for iinput  = 1:length(SPM.Sess.U)
            DCM.U.u = [DCM.U.u SPM.Sess.U(iinput).u(33:end,1)];
        end 
        % DCM parameters and options
        %------------------------------------------------------------------
        DCM.delays             = repmat(SPM.xY.RT/2,DCM.n,1);
        DCM.TE                 = echo_time;    % Echo Time, TE[s]
        DCM.options.nonlinear  = 0;            % Modulatory effects: bilinear[0]
        DCM.options.two_state  = 0;            % States per region: one[0]
        DCM.options.stochastic = 0;            % Stochastic effects: no[0]
        DCM.options.centre     = 0;            % Centre input: no[0] 
        DCM.options.nograph    = 1;            % ?.analysis = 'timeseries' or 'CSD'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Connectivity matrices
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DCM.a = zeros(2,2);        % (nregions,nregions)
        DCM.b = zeros(2,2,2, 4);   % (nregions,nregions,nconditions)       
        DCM.c = zeros(2,2,   3);   % (nregions,nconditions)                
        DCM.d = zeros(2,2,0);      % (nregions,nregions,0)  % for nonlinear
        % Endogenous connections 2x2
        %------------------------------------------------------------------
        DCM.a = ones(2);
        % Modulatory input x4
        %------------------------------------------------------------------
        mi    = {     }; b = DCM.b;   % 2019-3-22 19:38:52
        mi(1) = {'m00'}; b(:,:,mi_icon, 1) = [0 0;0 0];
        mi(2) = {'m01'}; b(:,:,mi_icon, 2) = [0 0;1 0];
        mi(3) = {'m10'}; b(:,:,mi_icon, 3) = [0 1;0 0];
        mi(4) = {'m11'}; b(:,:,mi_icon, 4) = [0 1;1 0];
        % Driving input x3
        %------------------------------------------------------------------
        di    = {     }; c = DCM.c;
        di(1) = {'d01'}; c(:,:, 1) = [0 0     ; di_vcon];
        di(2) = {'d10'}; c(:,:, 2) = [di_vcon ; 0 0    ];                  
        di(3) = {'d11'}; c(:,:, 3) = [di_vcon ; di_vcon];
        % Estimate
        %------------------------------------------------------------------
        for imi = 1:length(mi)
            DCM.b = b(:,:,:,imi);
            for idi = 1:length(di)
                DCM.c = c(:,:,idi);
                dcm_dirf = fullfile(dcm_dir,[mi{imi},'_',di{idi},'.mat']);
                save(dcm_dirf,'DCM');
                spm_dcm_estimate(dcm_dirf);
            end
        end
        disp(['-------',sub_list{isub},'-------step2_DCM done-------'])
    end
end
% ======================================================================= %
cd(scr_dir); clock2 = fix(clock);
disp('==================================================================');
fprintf('DCM_S1_VOISE  started at %d/%02d/%02d %02d:%02d:%02d \n',clock1);
fprintf('DCM_S1_VOISE finished at %d/%02d/%02d %02d:%02d:%02d \n',clock2);
disp('==================================================================');
diary off; close all;
% ======================================================================= %