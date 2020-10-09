clear; clc;

%% ------------------------------------------------------------------ Setup
data_convert = 1;
data_arrange = 1;
mri_exist    = 1;

scripts_dir = '';
rawdata_dir = '';
newdata_dir = '';

[~,~,raw] = xlsread('.xls','','','basic');   % 
rawsub_id = raw(:,1);
newsub_id = raw(:,2);

proj_name      =  '';
fmri_name      = {''};
fmri_keyword   = {''};
fmri_voldelete = {''};
fmri_volremain = {''};
mri_name       = {''};
mri_keyword    = {''};

%% ----------------------------------------------------------- Data Convert
if data_convert == 1
    for i = 1:length(rawsub_id)
        rawsub_dir = fullfile(rawdata_dir,                             rawsub_id{i,1});
        tmpsub_dir = fullfile(rawdata_dir,'/Temp/',[newsub_id{i,1},'_',rawsub_id{i,1}]);
        if exist(tmpsub_dir,'dir') == 7   % 
            unix(['rm -r ',tmpsub_dir]);
        end
        mkdir(tmpsub_dir);
        unix(['dcm2nii -g n -o ',tmpsub_dir,' ',rawsub_dir]);   % 'dcm2niix -x y -z n -o '
    end
end

%% ----------------------------------------------------------- Data Arrange
if data_arrange == 1
    for i = 1:length(newsub_id)
        year_fd    = ['20',newsub_id{i,1}(1:2)];
        tmpsub_dir = fullfile(rawdata_dir,'/Temp/',[newsub_id{i,1},'_',rawsub_id{i,1}]);
 
        % Arrange fmri
        for j = 1:length(fmri_name)
            tmpfmri_dirf = dir([tmpsub_dir,'/*',fmri_keyword{j,1},'*']); 
            fmri_dir     = fullfile(newdata_dir,year_fd,newsub_id{i,1},'fmri',fmri_name{j,1},'unnormalized');
            if length(tmpfmri_dirf) == 1   % HLG
                if exist(fmri_dir,'dir') == 7   % 
                    unix(['rm -r ',fmri_dir]);
                end
                mkdir(fmri_dir);
                % Move fmri
                unix(['mv ',    tmpsub_dir,'/',tmpfmri_dirf(1,1).name,' ',fmri_dir,'/I.nii']);
                unix(['mv ',    fmri_dir,'/I.nii',' ',fmri_dir,'/I_all.nii']);
                unix(['fslroi ',fmri_dir,'/I_all.nii ',fmri_dir,'/I.nii ',fmri_voldelete{j,1},' ',fmri_volremain{j,1}]);
                unix(['gunzip ',fmri_dir,'/I.nii.gz']);
                unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_Y_',fmri_name{j,1},'.txt']);     
            elseif length(tmpfmri_dirf) < 1
                unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_L_',fmri_name{j,1},'.txt']);
            elseif length(tmpfmri_dirf) > 1
                unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_M_',fmri_name{j,1},'.txt']);
            end                                            
        end
                        
        % Arrange mri
        if mri_exist == 0
            for j = 1:length(mri_name)
                tmpmri_dirf = dir([tmpsub_dir,'/*',mri_keyword{j,1},'*']);
                mri_dir     = fullfile(newdata_dir,year_fd,newsub_id{i,1},'mri',mri_name{j,1});
                if length(tmpmri_dirf) == 1
                    if exist(mri_dir,'dir') == 7   % 
                        unix(['rm -r ',mri_dir]);
                    end
                    mkdir(mri_dir);
                    % Move
                    unix(['mv ',tmpsub_dir,'/',tmpmri_dirf(1,1).name,' ',mri_dir,'/I.nii']);
                    unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_Y_T1.txt']);   % mri_name{j,1}
                elseif length(tmpmri_dirf) < 1
                    unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_L_T1.txt']);
                elseif length(tmpmri_dirf) > 1
                    unix(['echo ',newsub_id{i,1},' >> ',scripts_dir,'/',proj_name,'_Sublist_M_T1.txt']);
                end
            end
        end
    end
end

%% ------------------------------------------------------------------- Done
cd (scripts_dir)
disp ('All Done');