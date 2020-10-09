% Replace 0-back with 12
% Replace 1-back with 11
% Replace 2-back with 22

clear;
clc;
data = xlsread('E:\YunPan\Data\2015_DST\Data\Behavior\WM\ExportBehavior\1488\WM_out.xlsx','Sheet1');
Subject = data(:,1);
id      = fix (data(:,2)/10000);
ACC     = data(:,3);
CRESP   = data(:,4);
RESP    = data(:,5);
RT      = data(:,6);
Text    = data(:,7);
clearvars data;

% For 012-back
for Sub = 18:88 
    % Text=>1 to exclude '+' and 'n-back'
      indC1_0back = find(Subject==Sub & Text>=1 & CRESP==1 &          id==1);  % Denominator of Hit
      indC1_1back = find(Subject==Sub & Text>=1 & CRESP==1 &          id==3); 
      indC1_2back = find(Subject==Sub & Text>=1 & CRESP==1 &          id==2);
      
      indC0_0back = find(Subject==Sub & Text>=1 & CRESP==0 &          id==1);  % Denominator of FA
      indC0_1back = find(Subject==Sub & Text>=1 & CRESP==0 &          id==3); 
      indC0_2back = find(Subject==Sub & Text>=1 & CRESP==0 &          id==2);
      
    indC1A1_Oback = find(Subject==Sub & Text>=1 & CRESP==1 & ACC==1 & id==1);  % Numerator of Hit
    indC1A1_1back = find(Subject==Sub & Text>=1 & CRESP==1 & ACC==1 & id==3); 
    indC1A1_2back = find(Subject==Sub & Text>=1 & CRESP==1 & ACC==1 & id==2);
     
    indC0R1_0back = find(Subject==Sub & Text>=1 & CRESP==0 & RESP==1 & id==1); % Numerator of FA
    indC0R1_1back = find(Subject==Sub & Text>=1 & CRESP==0 & RESP==1 & id==3);
    indC0R1_2back = find(Subject==Sub & Text>=1 & CRESP==0 & RESP==1 & id==2);
      
    HitRate_0back = length(indC1A1_Oback)/length(indC1_0back);
    HitRate_1back = length(indC1A1_1back)/length(indC1_1back);
    HitRate_2back = length(indC1A1_2back)/length(indC1_2back);
      HitRT_0back = mean(RT(indC1A1_Oback));
      HitRT_1back = mean(RT(indC1A1_1back));
      HitRT_2back = mean(RT(indC1A1_2back));
           
     FARate_0back = length(indC0R1_0back)/length(indC0_0back);
     FARate_1back = length(indC0R1_1back)/length(indC0_1back);
     FARate_2back = length(indC0R1_2back)/length(indC0_2back);
       FART_0back = mean(RT(indC0R1_0back));
       FART_1back = mean(RT(indC0R1_1back));
       FART_2back = mean(RT(indC0R1_2back));
       
       SDRT_0back = std(RT(indC1A1_Oback));
       SDRT_1back = std(RT(indC1A1_1back));
       SDRT_2back = std(RT(indC1A1_2back));
    
    AllData(Sub,:) = [Sub...
        HitRate_0back   HitRate_1back   HitRate_2back...
          HitRT_0back     HitRT_1back     HitRT_2back...
         FARate_0back    FARate_1back    FARate_2back...
           FART_0back      FART_1back      FART_2back...
           SDRT_0back      SDRT_1back      SDRT_2back];
end