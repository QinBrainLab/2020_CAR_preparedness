% bsxiong@mail.bnu.edu.cn 2019-02-01

clear; clc;
[~,~,raw] = xlsread('.xls','','','basic');
CAR(:,1) = cell2mat(raw(1:52,4));   % CHS auci
CAR(:,2) = cell2mat(raw(1:52,5));   % CHS r30
CAR_name = {'AUCi';'R30'};          % CHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir0 = strsplit(pwd,'\'); 
dir1 = dir0{length(dir0)  }; dir1 = strrep(dir1,'_','-');
dir2 = dir0{length(dir0)-1}; dir2 = strrep(dir2,'_','-');
dir3 = dir0{length(dir0)-2}; dir3 = strrep(dir3,'_','-');
mi   = str2double(dir2(9));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grp  = {'all','blt','nrm'};                                                
CS   = {'Combined','Separated'};
MF   = {'Model','Family'};
IMPH = {'iPH','iHP','mPH','mHP'};

for igrp = 1:length(grp)
    bms_dirf = fullfile(pwd,grp{igrp},'BMS.mat');
    msp_dirf = fullfile(pwd,grp{igrp},'model_space.mat');
    load(bms_dirf); load(msp_dirf);
    %% Extract data
    if strcmp(dir1(end-2:end),'FFX') == 1
        m_prb = BMS.DCM.ffx.model.post;  m_idx = find(m_prb==max(m_prb));
        f_prb = BMS.DCM.ffx.family.post; f_idx = find(f_prb==max(f_prb));
        for isub=1:length(subj)
            ep(isub,1,igrp) = subj(isub).sess.model(m_idx).Ep.A(1,2);      % iPH
            ep(isub,2,igrp) = subj(isub).sess.model(m_idx).Ep.A(2,1);      % iHP
            ep(isub,3,igrp) = subj(isub).sess.model(m_idx).Ep.B(1,2,mi);   % mPH
            ep(isub,4,igrp) = subj(isub).sess.model(m_idx).Ep.B(2,1,mi);   % mHP
            ep(isub,5,igrp) = BMS.DCM.ffx.bma.mEps{1,isub}.A(1,2);      % iPH
            ep(isub,6,igrp) = BMS.DCM.ffx.bma.mEps{1,isub}.A(2,1);      % iHP
            ep(isub,7,igrp) = BMS.DCM.ffx.bma.mEps{1,isub}.B(1,2,mi);   % mPH
            ep(isub,8,igrp) = BMS.DCM.ffx.bma.mEps{1,isub}.B(2,1,mi);   % mHP
        end
    elseif strcmp(dir1(end-2:end),'RFX') == 1
        m_prb = BMS.DCM.rfx.model.xp;    m_idx = find(m_prb==max(m_prb));
        f_prb = BMS.DCM.rfx.family.xp;   f_idx = find(f_prb==max(f_prb));
        for isub=1:length(subj)
            ep(isub,1,igrp) = subj(isub).sess.model(m_idx).Ep.A(1,2);      % iPH
            ep(isub,2,igrp) = subj(isub).sess.model(m_idx).Ep.A(2,1);      % iHP
            ep(isub,3,igrp) = subj(isub).sess.model(m_idx).Ep.B(1,2,mi);   % mPH
            ep(isub,4,igrp) = subj(isub).sess.model(m_idx).Ep.B(2,1,mi);   % mHP
            ep(isub,5,igrp) = BMS.DCM.rfx.bma.mEps{1,isub}.A(1,2);      % iPH
            ep(isub,6,igrp) = BMS.DCM.rfx.bma.mEps{1,isub}.A(2,1);      % iHP
            ep(isub,7,igrp) = BMS.DCM.rfx.bma.mEps{1,isub}.B(1,2,mi);   % mPH
            ep(isub,8,igrp) = BMS.DCM.rfx.bma.mEps{1,isub}.B(2,1,mi);   % mHP
        end
    end
    %% BMS(FFX-posterior; RFX-exceedance)
    subplot(2,3,1*igrp),bar(m_prb); xlabel(grp{igrp}); ylabel({'Model probability' });
    subplot(2,3,igrp+3),bar(f_prb); xlabel(grp{igrp}); ylabel({'Family probability'});
end
suptitle([dir3,'  ',dir2,'  ',dir1]);
set(gcf,'units','centimeters','position',[0,0,30,20])
saveas(gcf, 'fig_bms', 'tif'); close all;
%% BMA(T-Test)
cnt = 0;
for iCS = 1:2       % ep(:, : ,1:3) combined or separated
    for iMF = 1:2   % ep(:,1:8, i ) model or family
        title_bma = fullfile([CS(iCS),MF(iMF)]);
        cnt = cnt + 1;
        if iCS == 1
            ep_blt = ep( 1:28, 4*iMF-3:4*iMF, 1);                          
            ep_nrm = ep(29:52, 4*iMF-3:4*iMF, 1);
        elseif iCS == 2
            ep_blt = ep( 1:28, 4*iMF-3:4*iMF, 2);                          
            ep_nrm = ep( 1:24, 4*iMF-3:4*iMF, 3);                          
        end
        
        m = []; p = [];

           m(1,:) =  [mean(ep_nrm(:,1)),mean(ep_blt(:,1))];
        [~,p(1)]  = ttest2(ep_nrm(:,1),      ep_blt(:,1));

           m(2,:) =  [mean(ep_nrm(:,2)),mean(ep_blt(:,2))];
        [~,p(2)]  = ttest2(ep_nrm(:,2),      ep_blt(:,2));

           m(3,:) =  [mean(ep_nrm(:,3)),mean(ep_blt(:,3))];
        [~,p(3)]  = ttest2(ep_nrm(:,3),      ep_blt(:,3));

           m(4,:) =  [mean(ep_nrm(:,4)),mean(ep_blt(:,4))];
        [~,p(4)]  = ttest2(ep_nrm(:,4),      ep_blt(:,4));
        
        subplot(1,4,cnt),bar(m); 
        title(title_bma);
        xlabel(p);
        xticklabels({'iPH','iHP','mPH','mHP'});
        ylabel('Parameter estimates');
    end
end
suptitle([dir3,'  ',dir2,'  ',dir1]);
set(gcf,'units','centimeters','position',[0,0,30,20])
saveas(gcf, 'fig-bma-t', 'tif'); close all;
%% BMA(Correlation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iCAR = 1:2
    cnt = 0;
    for iMF = 1:2                              % {'Model','Family'}
        ep_all = ep(1:52, 4*iMF-3:4*iMF, 1);   % ep(isub,1:8,igrp)
        for iIMPH = 1:length(IMPH)             % {'iPH','iHP','mPH','mHP'};
            cnt = cnt + 1;
            subplot(2,4,cnt),plot(CAR(:,iCAR), ep_all(:,iIMPH),'.');
            [R,P] =      corrcoef(CAR(:,iCAR), ep_all(:,iIMPH)    );
            xlabel(CAR_name(iCAR)); 
            ylabel('Parameter estimates');
            title([MF{iMF},' - ',IMPH{iIMPH}]);
            legend(num2str([R(1,2);P(1,2)]))
        end
    end
    suptitle([dir3,'  ',dir2,'  ',dir1]);
    set(gcf,'units','centimeters','position',[0,0,80,12])
    saveas(gcf, ['fig_bma-c',CAR_name{iCAR}], 'tif'); close all;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%