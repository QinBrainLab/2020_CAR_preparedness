clear; clc;

%% ------------------------------------------------------------------ Setup
preprocess  = 1;
moveexclude = 1;

spm_dir     = '';
scripts_dir = '';
newdata_dir = '';
[~,~,raw] = xlsread('.xls','','','basic');
newsub_id = raw(:,2);

proj_name   =  '';
fmri_name   = {''};
tr          = ;
slice_order = [];
t1_filter   = '';
func_filter = '';
data_type   = '';

%% ------------------------------------------------------------- Preprocess
% SliceTiming = 'a > ar'; Realign = 'r > c'; Normalise = 'w'; Smooth = 's'.
addpath(genpath(spm_dir));
addpath(genpath(scripts_dir));

if preprocess == 1
    for isub = 1:length(newsub_id)
        for irun = 1:length(fmri_name)
            year_fd = ['20',newsub_id{isub,1}(1:2)];
            disp ([newsub_id{isub},' Preprocessing Started']);
            
            t1_dir    = fullfile(newdata_dir,year_fd,newsub_id{isub},'/mri/anatomy/');
            func_dir  = fullfile(newdata_dir,year_fd,newsub_id{isub},'/fmri/',fmri_name{irun,1},'/unnormalized/');
            final_dir = fullfile(newdata_dir,year_fd,newsub_id{isub},'/fmri/',fmri_name{irun,1},'/smoothed_spm12/');
            
            cd (func_dir)
            Preprocessing_Scripts1(func_dir,func_filter,t1_dir,t1_filter,slice_order,tr,data_type);
            Preprocessing_Scripts2(func_dir,func_filter,t1_dir,t1_filter,slice_order,tr,data_type);
            
            unix('rm arI.mat');
            unix('rm arI.nii');
            unix('rm c*meanarI.nii');
            unix('rm carI.nii');
            unix('rm meanarI_seg8.mat');
            
            rp_dirf       = fullfile(func_dir,'rp_arI.txt');
            vg_dirf       = fullfile(func_dir,'VolumRepair_GlobalSignal.txt');
            mean_dirf     = fullfile(func_dir,'meanarI.nii');
            smooth_dirf   = fullfile(func_dir,'swcarI.nii');
            nosmooth_dirf = fullfile(func_dir,'wcarI.nii');
            
            mkdir(final_dir)
            unix(['mv ',rp_dirf,' ',final_dir]);
            unix(['mv ',vg_dirf,' ',final_dir]);
            unix(['mv ',mean_dirf,' ',final_dir]);
            unix(['mv ',smooth_dirf,' ',final_dir]);
            unix(['mv ',nosmooth_dirf,' ',final_dir]);
            
            cd (t1_dir)
            unix('rm I_seg8.mat');
            unix('rm y_I.nii');
        end
    end
end

%% ----------------------------------------------------- Movement Exclusion
cd (scripts_dir)
if moveexclude == 1
    for irun = 1:length(fmri_name)
        mConfigName = [proj_name,'_MoveExclusionConfig_',fmri_name{irun,1},'.m'];
        mConfig = fopen (mConfigName,'a');
        fprintf (mConfig,'%s\n',['paralist.ServerPath        = ''',newdata_dir,''';']);
        fprintf (mConfig,'%s\n','paralist.PreprocessedFolder = ''smoothed_spm12'';');
        fprintf (mConfig,'%s\n',['[~,~,raw]                  = xlsread( ''',database,''',''pre&ind'',''' ''',''basic'');']);
        fprintf (mConfig,'%s\n', 'newsub_id                  = raw(:,1);');
        fprintf (mConfig,'%s\n','paralist.SubjectList        = newsub_id;');
        fprintf (mConfig,'%s\n',['paralist.SessionList       = {''',fmri_name{irun,1},'''};']);
        fprintf (mConfig,'%s\n','paralist.ScanToScanCrit     = 0.5;');
        MovementExclusion(mConfigName);
    end
end

%% ------------------------------------------------------------------- Done
cd (scripts_dir)
disp ('All Done');