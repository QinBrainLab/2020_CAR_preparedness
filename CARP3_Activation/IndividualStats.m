clear;clc:
restoredefaultpath;

%% ----------------------------------------------------------------- Set up
spm_dir     = '';
scripts_dir = '';
newdata_dir = '';
stats_dir   = '';
[~,~,raw]   = xlsread('.xls','','','basic');
new_subid     = raw(:,2);
proj_name     = '';
task_name     = '';
fmri_sess     = 1;
fmri_name     = '';
design_name   = 'taskdesign.m';
contrast_name = 'contrast4.mat';

%% ------------------------ Individual Analysis ------------------------ %%
addpath(genpath(spm_dir));
addpath(genpath(scripts_dir));

cd(scripts_dir)
if ~exist('Log','dir')
    mkdir(fullfile(scripts_dir,'Log'))
end

iConfigName = [proj_name,task_name,'_IndividualStats_Config.m'];
iConfig     = fopen(iConfigName,'a');

fprintf(iConfig,'%s\n', 'paralist.data_type           = ''nii'';');
fprintf(iConfig,'%s\n', 'paralist.pipeline            = ''swcar'';');
fprintf(iConfig,'%s\n',['paralist.server_path         = ''',newdata_dir,''';']);
fprintf(iConfig,'%s\n',['paralist.stats_path          = ''',stats_dir,''';']);
fprintf(iConfig,'%s\n', 'paralist.parent_folder       = '''';');
fprintf(iConfig,'%s\n',['[~,~,raw]                    = xlsread( ''',sub_info,''',''Pre&Ind'','''',''basic'');']);   % 
fprintf(iConfig,'%s\n', 'newsub_id                    = raw(:,2);');   % 
fprintf(iConfig,'%s\n', 'paralist.subjectlist         = newsub_id;');
if fmri_sess == 1
    fprintf (iConfig,'%s\n',...
                       ['paralist.exp_sesslist        = ''',fmri_name,''';']);
end
if fmri_sess > 1
    fprintf(iConfig,'%s\n',...
                       ['paralist.exp_sesslist        = {''',fmri_name,'''};']);
end
fprintf(iConfig,'%s\n',['paralist.task_dsgn           = ''',design_name,''';']);
fprintf(iConfig,'%s\n',['paralist.contrastmat         = ''',contrast_name,''';']);
fprintf(iConfig,'%s\n', 'paralist.preprocessed_folder = ''smoothed_spm12'';');
fprintf(iConfig,'%s\n',['paralist.stats_folder        = ''',task_name,'/stats_spm12_swcar'';']);
fprintf(iConfig,'%s\n', 'paralist.include_mvmnt       = 1;');

fprintf(iConfig,'%s\n', 'paralist.include_volrepair   = 0;');
fprintf(iConfig,'%s\n', 'paralist.volpipeline         = ''swavr'';');
fprintf(iConfig,'%s\n', 'paralist.volrepaired_folder  = ''volrepair_spm12'';');
fprintf(iConfig,'%s\n', 'paralist.repaired_stats      = ''stats_spm12_VolRepair'';');
fprintf(iConfig,'%s\n',['paralist.template_path       = ''',fullfile(scripts_dir,'Dependence'),''';']);

IndividualStats(iConfigName)

%% All Done
disp ('All Done');